import { Injectable, Logger } from "@nestjs/common";
import { OrderStatus } from "@prisma/client";
import { randomBytes } from "crypto";
import type { Namespace } from "socket.io";
import { PrismaService } from "../prisma/prisma.service";
import { CacheService } from "../redis/redis.module";
import { alertSelect, toOrderAlert } from "./order-alert";

/** Staff who handle orders (orders.view): bell, pop-up, sound, order list. */
export const ROOM_ORDERS = "orders";
/** Drivers (orders.deliver only): their delivery list and badge. */
export const ROOM_DELIVERIES = "deliveries";

const TICKET_TTL_SECONDS = 60;
const ticketKey = (ticket: string) => `realtime:ticket:${ticket}`;

/** Events the admin panel listens for. */
export interface ServerEvents {
  /** A cash order was placed or an ABA Pay order was paid: it needs staff. */
  "order:new": (alert: ReturnType<typeof toOrderAlert>) => void;
  /** An order was created, paid, moved or cancelled: refresh lists and counts. */
  "order:changed": (change: { id: string; status: OrderStatus; at: string }) => void;
}

/**
 * Pushes order news to the admin panel over Socket.io. Every call is
 * fire-and-forget: a failed push never fails the order, and the panel
 * catches up through GET /admin/orders/alerts when it reconnects.
 */
@Injectable()
export class RealtimeService {
  private readonly log = new Logger("Realtime");
  private nsp?: Namespace;

  constructor(private readonly prisma: PrismaService, private readonly cache: CacheService) {}

  /** Called by the gateway once Socket.io is listening. */
  attach(nsp: Namespace) {
    this.nsp = nsp;
  }

  /**
   * The admin panel's browser never sees the login token (it's an httpOnly
   * cookie), so its server asks for a one-time pass that lives one minute.
   */
  async issueTicket(userId: string) {
    const ticket = randomBytes(24).toString("base64url");
    const saved = await this.cache.setJson(ticketKey(ticket), { userId }, TICKET_TTL_SECONDS);
    return saved ? { ticket, expiresIn: TICKET_TTL_SECONDS } : { ticket: null, expiresIn: 0 };
  }

  /** Who the pass belongs to; a pass works once. */
  async redeemTicket(ticket: unknown): Promise<string | null> {
    if (typeof ticket !== "string" || ticket.length > 64) return null;
    const owner = await this.cache.takeJson<{ userId: string }>(ticketKey(ticket));
    return owner?.userId ?? null;
  }

  /** Rings the bell for this order (call after the transaction has committed). */
  orderNeedsStaff(orderId: string) {
    const nsp = this.nsp;
    if (!nsp) return;
    void this.prisma.order
      .findUnique({ where: { id: orderId }, select: alertSelect })
      .then((o) => {
        if (o) nsp.to(ROOM_ORDERS).emit("order:new", toOrderAlert(o));
      })
      .catch((e: Error) => this.log.warn(`order:new ${orderId} not sent: ${e.message}`));
  }

  /** Tells every open admin panel that this order changed. */
  orderChanged(orderId: string, status: OrderStatus) {
    try {
      this.nsp?.to([ROOM_ORDERS, ROOM_DELIVERIES]).emit("order:changed", { id: orderId, status, at: new Date().toISOString() });
    } catch (e) {
      this.log.warn(`order:changed ${orderId} not sent: ${(e as Error).message}`);
    }
  }
}
