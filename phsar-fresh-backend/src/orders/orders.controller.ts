import {
  Body, ConflictException, Controller, Get, HttpCode, Injectable, Module, NotFoundException, Param, ParseUUIDPipe, Post,
  UseGuards,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { ApiBearerAuth, ApiTags } from "@nestjs/swagger";
import { Prisma } from "@prisma/client";
import { AuthUser, CurrentUser } from "../auth/dto/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { isOncePerCustomer, onceKey } from "../discounts/discount-rules";
import { DiscountsModule } from "../discounts/discounts.controller";
import { DiscountsService } from "../discounts/discounts.service";
import { PaymentsModule } from "../payments/payments.controller";
import { PaymentsService, PublicPayment, toPublicPayment } from "../payments/payments.service";
import { PrismaService } from "../prisma/prisma.service";
import { toPublicProduct } from "../products/product.mapper";
import { CreateOrderDto } from "./dto/create-order.dto";
import { logOrderEvent } from "./order-events";

const include = {
  items: { include: { product: { include: { category: true } } } },
  payments: { orderBy: { createdAt: "desc" }, take: 1 },
  events: { orderBy: { createdAt: "asc" }, select: { status: true, createdAt: true, actorName: true, actorRole: true } },
} satisfies Prisma.OrderInclude;
type Row = Prisma.OrderGetPayload<{ include: typeof include }>;

/** Gives back what a cancelled order held: its stock, its once-per-customer code and its open KHQR. */
export async function releaseOrder(tx: Prisma.TransactionClient, orderId: string, items: { productId: string; qty: number }[]) {
  for (const i of items) {
    await tx.product.update({ where: { id: i.productId }, data: { stock: { increment: i.qty } } });
  }
  await tx.discountRedemption.updateMany({ where: { orderId }, data: { onceKey: null } });
  await tx.payment.updateMany({ where: { orderId, status: "PENDING" }, data: { status: "EXPIRED" } });
}

const notCancellable = () =>
  new ConflictException({ reason: "ORDER_NOT_CANCELLABLE", message: "This order is already paid or on its way" });

const toCustomerOrder = (o: Row) => ({
  id: o.id,
  status: o.status,
  subtotalCents: o.subtotalCents,
  discountCents: o.discountCents,
  discountCode: o.discountCode,
  deliveryCents: o.deliveryCents,
  totalCents: o.totalCents,
  paymentMethod: o.paymentMethod,
  address: { lat: o.addressLat, lng: o.addressLng, text: o.addressText },
  note: o.note,
  paidAt: o.paidAt,
  payment: o.payments[0] ? toPublicPayment(o.payments[0]) : null,
  createdAt: o.createdAt,
  items: o.items.map((i) => ({
    productId: i.productId,
    name: i.name,
    priceCents: i.priceCents, // what the customer paid
    qty: i.qty,
    // Today's product (photo, unit, current price, in stock) — for showing it and reordering.
    product: i.product.isActive ? toPublicProduct(i.product) : { ...toPublicProduct(i.product), inStock: false },
  })),
  /** When each status was reached (no staff names: customers only see the driver). */
  history: o.events.map((e) => ({ status: e.status, at: e.createdAt })),
  deliveredAt: o.events.filter((e) => e.status === "DELIVERED").at(-1)?.createdAt ?? null,
  courierName: o.events.filter((e) => e.actorRole === "DRIVER").at(-1)?.actorName ?? null,
});

@Injectable()
export class OrdersService {
  private readonly deliveryCents: number;

  constructor(
    private readonly prisma: PrismaService,
    private readonly discounts: DiscountsService,
    private readonly payments: PaymentsService,
    config: ConfigService,
  ) {
    this.deliveryCents = Number(config.get("DELIVERY_FEE_CENTS") ?? 100);
  }

  /**
   * Prices come from the database, never from the app. Stock, the order, its
   * items and the code's redemption are written in one transaction, so a
   * once-per-customer code can't be used twice even by two phones at once.
   */
  async create(userId: string, dto: CreateOrderDto) {
    // The same product twice → one line.
    const qty = new Map<string, number>();
    for (const i of dto.items) qty.set(i.productId, (qty.get(i.productId) ?? 0) + i.qty);

    try {
      const order = await this.prisma.$transaction(async (tx) => {
        const products = await tx.product.findMany({ where: { id: { in: [...qty.keys()] }, isActive: true } });
        if (products.length !== qty.size) throw new ConflictException({ reason: "PRODUCT_UNAVAILABLE", message: "Some items are no longer for sale" });

        for (const p of products) {
          const n = qty.get(p.id)!;
          const taken = await tx.product.updateMany({ where: { id: p.id, stock: { gte: n } }, data: { stock: { decrement: n } } });
          if (taken.count === 0) {
            throw new ConflictException({ reason: "OUT_OF_STOCK", productId: p.id, message: `Only ${p.stock} ${p.unit} of ${p.name} left` });
          }
        }

        const subtotal = products.reduce((sum, p) => sum + p.priceCents * qty.get(p.id)!, 0);
        let discount = 0;
        let code: { id: string; code: string; once: boolean } | null = null;
        if (dto.voucherCode) {
          const e = await this.discounts.evaluate(dto.voucherCode, subtotal, userId, tx);
          if (!e.ok) throw DiscountsService.refuse(e);
          discount = e.discountCents;
          code = { id: e.code.id, code: e.code.code, once: isOncePerCustomer(e.code) };
        }

        const created = await tx.order.create({
          data: {
            userId,
            subtotalCents: subtotal,
            discountCents: discount,
            discountCode: code?.code ?? null,
            deliveryCents: this.deliveryCents,
            totalCents: subtotal - discount + this.deliveryCents,
            paymentMethod: dto.paymentMethod ?? "CASH",
            addressLat: dto.address.lat,
            addressLng: dto.address.lng,
            addressText: dto.address.text ?? null,
            recipientName: dto.recipientName ?? null,
            recipientPhone: dto.recipientPhone ?? null,
            note: dto.note ?? null,
            items: { create: products.map((p) => ({ productId: p.id, name: p.name, priceCents: p.priceCents, qty: qty.get(p.id)! })) },
          },
          include,
        });

        if (code) {
          await tx.discountRedemption.create({
            data: {
              codeId: code.id,
              userId,
              orderId: created.id,
              onceKey: code.once ? onceKey(code.id, userId) : null,
              discountCents: discount,
            },
          });
        }
        await logOrderEvent(tx, created.id, "PENDING", { userId }, "APP");
        return created;
      });
      const placed = toCustomerOrder(order);
      if (order.paymentMethod !== "ABA_PAY") return placed;
      // The order is saved either way; if PayWay fails the app shows
      // "Try again", which calls POST /orders/:id/payment.
      let payment: PublicPayment | null = null;
      let paymentError: string | null = null;
      try {
        payment = await this.payments.startKhqr(order);
      } catch (e) {
        const body = (e as { getResponse?: () => unknown }).getResponse?.();
        paymentError = (body as { message?: string } | undefined)?.message ?? "Couldn't create the ABA KHQR";
      }
      return { ...placed, payment, paymentError };
    } catch (e) {
      // Two orders raced for the same once-per-customer code: the database kept one.
      if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002") {
        throw DiscountsService.refuse({ ok: false, reason: "ALREADY_USED" });
      }
      throw e;
    }
  }

  async mine(userId: string) {
    const rows = await this.prisma.order.findMany({ where: { userId }, include, orderBy: { createdAt: "desc" }, take: 50 });
    return rows.map(toCustomerOrder);
  }

  /** The customer left the KHQR without paying: the basket goes back to them, so the order lets go of it. */
  async cancel(userId: string, id: string) {
    const order = await this.prisma.order.findFirst({ where: { id, userId }, include });
    if (!order) throw new NotFoundException("Order not found");
    if (order.status === "CANCELLED") return toCustomerOrder(order);
    if (order.paymentMethod !== "ABA_PAY" || order.status !== "PENDING") throw notCancellable();
    // They may have paid a second ago.
    if ((await this.payments.settle(id))?.status === "APPROVED") throw notCancellable();
    const cancelled = await this.prisma.$transaction(async (tx) => {
      // Only a still-waiting order: a payment confirmed meanwhile wins.
      const moved = await tx.order.updateMany({ where: { id, status: "PENDING" }, data: { status: "CANCELLED" } });
      if (moved.count === 0) throw notCancellable();
      await logOrderEvent(tx, id, "CANCELLED", { userId }, "APP", "Cancelled by the customer");
      await releaseOrder(tx, id, order.items);
      return tx.order.findUniqueOrThrow({ where: { id }, include });
    });
    return toCustomerOrder(cancelled);
  }
}

@ApiTags("orders")
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller("orders")
export class OrdersController {
  constructor(private readonly orders: OrdersService) {}

  @Post() create(@CurrentUser() user: AuthUser, @Body() dto: CreateOrderDto) { return this.orders.create(user.id, dto); }
  @Get() mine(@CurrentUser() user: AuthUser) { return this.orders.mine(user.id); }

  /** Only an unpaid ABA Pay order; 409 once it's paid. */
  @Post(":id/cancel")
  @HttpCode(200)
  cancel(@CurrentUser() user: AuthUser, @Param("id", ParseUUIDPipe) id: string) { return this.orders.cancel(user.id, id); }
}

@Module({ imports: [DiscountsModule, PaymentsModule], controllers: [OrdersController], providers: [OrdersService] })
export class OrdersModule {}
