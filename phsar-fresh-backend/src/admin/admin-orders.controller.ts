import {
  BadRequestException, Body, ConflictException, Controller, ForbiddenException, Get, Injectable, NotFoundException,
  Param, ParseUUIDPipe, Patch, Post, Query,
} from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { OrderStatus, PaymentMethod, Prisma } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { AuthUser, CurrentUser } from "../auth/dto/current-user.decorator";
import { releaseOrder } from "../orders/orders.controller";
import { AdminOnly, Can } from "./admin.decorator";
import { logOrderEvent } from "../orders/order-events";
import { PermissionsService } from "./permissions.service";
import { AdminListOrdersDto, OrderAlertsDto, SendOrderMessageDto, UpdateOrderStatusDto } from "./dto/admin-order.dto";

/**
 * Which status an order may move to next. Delivered and cancelled are final.
 * Cash on delivery skips "Paid": the cash is collected when it's delivered.
 */
export const NEXT_STATUS: Record<OrderStatus, OrderStatus[]> = {
  PENDING: ["PREPARING", "CANCELLED"],
  PAID: ["PREPARING", "CANCELLED"],
  PREPARING: ["DELIVERING", "CANCELLED"],
  DELIVERING: ["DELIVERED", "CANCELLED"],
  DELIVERED: [],
  CANCELLED: [],
};

/**
 * ABA Pay is paid before anything happens, and PayWay (not the admin) marks
 * it Paid, so a waiting ABA order can only be cancelled.
 */
const NEXT_STATUS_PREPAID: Record<OrderStatus, OrderStatus[]> = {
  ...NEXT_STATUS,
  PENDING: ["CANCELLED"],
};

const prepaid = (method: PaymentMethod) => method === "ABA_PAY";

const include = {
  user: { select: { id: true, name: true, phone: true } },
  items: { include: { product: { select: { imageUrl: true, nameKm: true, unit: true } } } },
  events: {
    orderBy: { createdAt: "asc" },
    select: { status: true, actorName: true, actorRole: true, source: true, note: true, createdAt: true, actor: { select: { name: true, phone: true } } },
  },
  payments: { orderBy: { createdAt: "desc" }, take: 1, select: { status: true, tranId: true, paymentType: true, bankRef: true, paidAt: true, expiresAt: true } },
  messages: {
    orderBy: { createdAt: "asc" },
    select: { id: true, kind: true, body: true, senderName: true, createdAt: true, sender: { select: { name: true, phone: true } } },
  },
} satisfies Prisma.OrderInclude;

/** "PF-3F9A2C", as the app and receipts show it. */
export const orderCode = (id: string) => `PF-${id.slice(0, 6).toUpperCase()}`;

type Row = Prisma.OrderGetPayload<{ include: typeof include }>;

interface StatusRights {
  view: boolean; // every order
  update: boolean;
  cancel: boolean;
  deliver: boolean; // orders out for delivery only: mark them delivered
  activity: boolean; // who handled the order, and when
}

/** What a delivery-only role (orders.deliver without orders.view) may see. */
const DELIVERY_STATUSES: OrderStatus[] = ["DELIVERING", "DELIVERED"];

/** Next statuses this admin may pick: moving forward needs orders.update, cancelling orders.cancel. */
function allowedNext(status: OrderStatus, method: PaymentMethod, rights: StatusRights, paymentStatus?: string) {
  // Cancelled while its KHQR was open, then the customer paid anyway: the
  // admin can restore it as Paid (or refund the customer outside the app).
  if (status === "CANCELLED" && paymentStatus === "APPROVED") return rights.update ? (["PAID"] as OrderStatus[]) : [];
  const flow = prepaid(method) ? NEXT_STATUS_PREPAID : NEXT_STATUS;
  return flow[status].filter((s) => {
    if (s === "CANCELLED") return rights.cancel;
    if (s === "DELIVERED") return rights.update || rights.deliver;
    return rights.update;
  });
}

const paymentStatusOf = (p?: { status: string; expiresAt: Date }) =>
  !p ? undefined : p.status === "PENDING" && p.expiresAt <= new Date() ? "EXPIRED" : p.status;

function toAdminOrder(o: Row, rights: StatusRights) {
  return {
    id: o.id,
    status: o.status,
    nextStatuses: allowedNext(o.status, o.paymentMethod, rights, paymentStatusOf(o.payments[0])),
    /** Money received for an order that is cancelled: restore it or refund. */
    paidAfterCancel: o.status === "CANCELLED" && o.payments[0]?.status === "APPROVED",
    subtotalCents: o.subtotalCents,
    discountCents: o.discountCents,
    discountCode: o.discountCode,
    totalCents: o.totalCents,
    deliveryCents: o.deliveryCents,
    paymentMethod: o.paymentMethod,
    paidAt: o.paidAt,
    payment: o.payments[0] ? { ...o.payments[0], status: paymentStatusOf(o.payments[0]) } : null,
    recipientName: o.recipientName,
    recipientPhone: o.recipientPhone,
    addressText: o.addressText,
    note: o.note,
    address: { lat: o.addressLat, lng: o.addressLng },
    createdAt: o.createdAt,
    customer: o.user,
    itemCount: o.items.reduce((n, i) => n + i.qty, 0),
    /** Messages staff sent to the customer about this order. */
    messages: o.messages.map((m) => ({
      id: m.id,
      kind: m.kind,
      body: m.body,
      at: m.createdAt,
      by: m.sender?.name || m.sender?.phone || m.senderName,
    })),
    /** Who moved the order to each status — only for roles with orders.activity. */
    activity: rights.activity
      ? o.events.map((e) => ({
          status: e.status,
          at: e.createdAt,
          // current name if the account still exists, else the name at the time
          by: e.actor?.name || e.actor?.phone || e.actorName,
          role: e.actorRole,
          source: e.source,
          note: e.note,
        }))
      : undefined,
    items: o.items.map((i) => ({
      id: i.id,
      productId: i.productId,
      name: i.name,
      nameKm: i.product.nameKm,
      unit: i.product.unit,
      imageUrl: i.product.imageUrl,
      priceCents: i.priceCents,
      qty: i.qty,
    })),
  };
}

@Injectable()
export class AdminOrdersService {
  constructor(private readonly prisma: PrismaService, private readonly permissions: PermissionsService) {}

  private async rights(role: string): Promise<StatusRights> {
    const perms = await this.permissions.forRole(role);
    return {
      view: perms.includes("orders.view"),
      update: perms.includes("orders.update"),
      cancel: perms.includes("orders.cancel"),
      deliver: perms.includes("orders.deliver"),
      activity: perms.includes("orders.activity"),
    };
  }

  async list(dto: AdminListOrdersDto, role: string) {
    const rights = await this.rights(role);
    const search: Prisma.OrderWhereInput = dto.q
      ? {
          OR: [
            { id: { startsWith: dto.q.toLowerCase() } },
            { user: { name: { contains: dto.q, mode: "insensitive" } } },
            { user: { phone: { contains: dto.q.replace(/^0/, "") } } },
          ],
        }
      : {};
    // Drivers only ever see orders on the road (and the ones they finished).
    if (!rights.view) search.status = { in: DELIVERY_STATUSES };
    const status = !rights.view && dto.status && !DELIVERY_STATUSES.includes(dto.status) ? "DELIVERING" : dto.status;
    const where: Prisma.OrderWhereInput = { ...search, ...(status && { status }) };

    const [rows, total, grouped] = await this.prisma.$transaction([
      this.prisma.order.findMany({
        where,
        include,
        orderBy: { createdAt: "desc" },
        skip: (dto.page - 1) * dto.limit,
        take: dto.limit,
      }),
      this.prisma.order.count({ where }),
      this.prisma.order.groupBy({ by: ["status"], where: search, orderBy: { status: "asc" }, _count: { _all: true } }),
    ]);

    const counts = Object.fromEntries(Object.values(OrderStatus).map((s) => [s, 0])) as Record<OrderStatus, number>;
    let all = 0;
    for (const g of grouped) {
      const n = (g._count as { _all: number })._all;
      counts[g.status] = n;
      all += n;
    }

    return { items: rows.map((r) => toAdminOrder(r, rights)), page: dto.page, limit: dto.limit, total, counts: { ALL: all, ...counts } };
  }

  async findOne(id: string, role: string) {
    const o = await this.prisma.order.findUnique({ where: { id }, include });
    const rights = await this.rights(role);
    if (!o || (!rights.view && !DELIVERY_STATUSES.includes(o.status))) throw new NotFoundException("Order not found");
    return toAdminOrder(o, rights);
  }

  /**
   * Orders that need staff since [since]: cash orders when placed, ABA Pay
   * orders once paid. Drives the admin bell, toast and sound.
   */
  async alerts(since: Date) {
    const rows = await this.prisma.order.findMany({
      where: {
        status: { not: "CANCELLED" },
        OR: [
          { paymentMethod: { not: "ABA_PAY" }, createdAt: { gt: since } },
          { paymentMethod: "ABA_PAY", paidAt: { gt: since } },
        ],
      },
      select: { id: true, totalCents: true, paymentMethod: true, createdAt: true, paidAt: true, recipientName: true, user: { select: { name: true, phone: true } } },
      orderBy: { createdAt: "desc" },
      take: 20,
    });
    return {
      now: new Date(),
      items: rows.map((o) => ({
        id: o.id,
        code: orderCode(o.id),
        totalCents: o.totalCents,
        paymentMethod: o.paymentMethod,
        customer: o.recipientName || o.user.name || o.user.phone,
        at: o.paymentMethod === "ABA_PAY" ? o.paidAt ?? o.createdAt : o.createdAt,
      })),
    };
  }

  /** A note to the customer; it shows in their app's bell. */
  async sendMessage(id: string, dto: SendOrderMessageDto, user: AuthUser) {
    await this.findOne(id, user.role); // same visibility rules as viewing it
    const sender = await this.prisma.user.findUnique({ where: { id: user.id }, select: { name: true, phone: true } });
    await this.prisma.orderMessage.create({
      data: { orderId: id, senderId: user.id, senderName: sender?.name || sender?.phone || null, kind: dto.kind, body: dto.body },
    });
    return this.findOne(id, user.role);
  }

  async updateStatus(id: string, status: OrderStatus, user: AuthUser, message?: string) {
    const role = user.role;
    const o = await this.findOne(id, role);
    const rights = await this.rights(role);
    const allowedByRole = status === "CANCELLED" ? rights.cancel : status === "DELIVERED" ? rights.update || rights.deliver : rights.update;
    if (!allowedByRole) {
      throw new ForbiddenException(status === "CANCELLED" ? "Your role can't cancel orders" : "Your role can't update orders");
    }
    if (!o.nextStatuses.includes(status)) {
      throw new BadRequestException(`An order that is ${o.status} can't move to ${status}`);
    }
    const updated = await this.prisma.$transaction(async (tx) => {
      if (status === "CANCELLED") await releaseOrder(tx, id, o.items);
      if (o.status === "CANCELLED" && status === "PAID") {
        // Restoring a paid order: take its stock again.
        for (const i of o.items) {
          const taken = await tx.product.updateMany({ where: { id: i.productId, stock: { gte: i.qty } }, data: { stock: { decrement: i.qty } } });
          if (taken.count === 0) throw new ConflictException(`Not enough stock of ${i.name} to restore this order — refund the customer instead`);
        }
      }
      // Cash on delivery: the money is collected at the door.
      const cashCollected = status === "DELIVERED" && !prepaid(o.paymentMethod) && !o.paidAt;
      const note = cashCollected
        ? `Cash collected (${(o.totalCents / 100).toFixed(2)} USD)`
        : o.status === "CANCELLED" && status === "PAID"
          ? "Restored after the customer paid"
          : undefined;
      const reason = status === "CANCELLED" ? message?.trim() : undefined;
      await logOrderEvent(tx, id, status, { userId: user.id }, "ADMIN", reason ? `Reason: ${reason}` : note);
      if (reason) {
        // The customer sees why in their app.
        const sender = await tx.user.findUnique({ where: { id: user.id }, select: { name: true, phone: true } });
        await tx.orderMessage.create({
          data: { orderId: id, senderId: user.id, senderName: sender?.name || sender?.phone || null, kind: "CANCELLED", body: reason },
        });
      }
      return tx.order.update({ where: { id }, data: { status, ...(cashCollected && { paidAt: new Date() }) }, include });
    });
    return toAdminOrder(updated, rights);
  }
}

@ApiTags("admin")
@AdminOnly()
@Controller("admin/orders")
export class AdminOrdersController {
  constructor(private readonly orders: AdminOrdersService) {}

  /** Must stay above ":id" so "alerts" isn't read as an order id. */
  @Can("orders.view")
  @Get("alerts") alerts(@Query() dto: OrderAlertsDto) { return this.orders.alerts(new Date(dto.since)); }

  @Can("orders.view", "orders.deliver")
  @Get() list(@Query() dto: AdminListOrdersDto, @CurrentUser() user: AuthUser) { return this.orders.list(dto, user.role); }

  @Can("orders.view", "orders.deliver")
  @Get(":id") findOne(@Param("id", ParseUUIDPipe) id: string, @CurrentUser() user: AuthUser) { return this.orders.findOne(id, user.role); }

  /** orders.update to move forward, orders.cancel to cancel, orders.deliver to mark delivered — checked in the service. */
  @Can("orders.view", "orders.deliver")
  @Patch(":id/status")
  updateStatus(@Param("id", ParseUUIDPipe) id: string, @Body() dto: UpdateOrderStatusDto, @CurrentUser() user: AuthUser) {
    return this.orders.updateStatus(id, dto.status, user, dto.message);
  }

  @Can("orders.update", "orders.cancel")
  @Post(":id/messages")
  sendMessage(@Param("id", ParseUUIDPipe) id: string, @Body() dto: SendOrderMessageDto, @CurrentUser() user: AuthUser) {
    return this.orders.sendMessage(id, dto, user);
  }
}
