import { BadRequestException, ConflictException, Injectable, Logger, NotFoundException } from "@nestjs/common";
import { Order, Payment } from "@prisma/client";
import { randomBytes } from "crypto";
import { logOrderEvent } from "../orders/order-events";
import { PrismaService } from "../prisma/prisma.service";
import { PaywayClient } from "./payway.client";

/** 14 chars, unique, within PayWay's 20-char tran_id limit. */
const newTranId = () => `PF${Date.now().toString(36).toUpperCase()}${randomBytes(2).toString("hex").toUpperCase()}`;

export const toPublicPayment = (p: Payment) => ({
  id: p.id,
  orderId: p.orderId,
  tranId: p.tranId,
  status: p.status === "PENDING" && p.expiresAt <= new Date() ? "EXPIRED" : p.status,
  amountCents: p.amountCents,
  currency: p.currency,
  qrString: p.qrString,
  deeplink: p.deeplink,
  expiresAt: p.expiresAt,
  paidAt: p.paidAt,
  paymentType: p.paymentType,
  /** Simulated payment (PAYWAY_MOCK): the app shows a "Simulate payment" button. */
  testMode: p.provider === "PAYWAY_MOCK",
});
export type PublicPayment = ReturnType<typeof toPublicPayment>;

@Injectable()
export class PaymentsService {
  private readonly log = new Logger("Payments");

  constructor(private readonly prisma: PrismaService, private readonly payway: PaywayClient) {}

  /** A fresh KHQR for an unpaid ABA Pay order (a new tranId every time). */
  async startKhqr(order: Pick<Order, "id" | "totalCents" | "status" | "paymentMethod">) {
    if (order.paymentMethod !== "ABA_PAY") throw new BadRequestException("This order isn't paid with ABA Pay");
    if (order.status !== "PENDING") throw new ConflictException({ reason: "ORDER_NOT_PAYABLE", message: "This order is already paid or closed" });
    const tranId = newTranId();
    const qr = await this.payway.createKhqr({
      tranId,
      amountCents: order.totalCents,
      currency: "USD",
      returnParams: JSON.stringify({ orderId: order.id }),
    });
    // Older QRs of this order can no longer be used.
    await this.prisma.payment.updateMany({ where: { orderId: order.id, status: "PENDING" }, data: { status: "EXPIRED" } });
    const p = await this.prisma.payment.create({
      data: {
        orderId: order.id,
        provider: this.payway.mock ? "PAYWAY_MOCK" : "PAYWAY",
        tranId,
        amountCents: order.totalCents,
        currency: "USD",
        qrString: qr.qrString,
        deeplink: qr.deeplink,
        checkoutUrl: qr.checkoutUrl,
        expiresAt: new Date(Date.now() + this.payway.lifetimeMinutes * 60_000),
      },
    });
    return toPublicPayment(p);
  }

  async renew(userId: string, orderId: string) {
    const order = await this.ownOrder(userId, orderId);
    // Someone may have paid the old QR a second ago: check before replacing it.
    const latest = await this.latest(orderId);
    if (latest) {
      const fresh = await this.refresh(latest);
      if (fresh.status === "APPROVED") return toPublicPayment(fresh);
    }
    return this.startKhqr(order);
  }

  /** The app polls this while the QR is on screen. */
  async status(userId: string, orderId: string) {
    await this.ownOrder(userId, orderId);
    const latest = await this.latest(orderId);
    if (!latest) throw new NotFoundException("No payment for this order yet");
    return toPublicPayment(await this.refresh(latest));
  }

  /** Test mode only: pay the order's current QR as if the customer scanned it. */
  async testPay(userId: string, orderId: string) {
    if (!this.payway.mock) throw new NotFoundException();
    const order = await this.ownOrder(userId, orderId);
    if (order.status !== "PENDING") throw new ConflictException({ reason: "ORDER_NOT_PAYABLE", message: "This order is already paid or cancelled" });
    const latest = await this.latest(orderId);
    if (!latest || latest.status !== "PENDING") throw new ConflictException({ reason: "NOTHING_TO_PAY", message: "No open QR for this order" });
    this.payway.mockPay(latest.tranId);
    const paid = await this.refresh(latest, { paymentType: "KHQR (test)", bankRef: "TEST", payerBank: "Test bank" });
    return toPublicPayment(paid);
  }

  /** The order's latest payment, re-checked with PayWay while it is pending. */
  async settle(orderId: string) {
    const latest = await this.latest(orderId);
    return latest ? this.refresh(latest) : null;
  }

  /** PayWay's push notification. Confirmed with check-transaction before trusting it. */
  async callback(payload: Record<string, unknown>, signature: string | undefined) {
    if (!this.payway.verifyCallback(payload, signature)) {
      this.log.warn(`callback with a bad signature for ${String(payload.tran_id)}`);
      return false;
    }
    const tranId = String(payload.tran_id ?? "");
    // Visible in the backend terminal, so a test payment shows the push arrived.
    this.log.log(`callback received for ${tranId} (status ${String(payload.status ?? "?")})`);
    const p = await this.prisma.payment.findUnique({ where: { tranId } });
    if (!p) return true; // not ours / already cleaned up: acknowledge anyway
    await this.refresh(p, {
      apv: payload.apv ? String(payload.apv) : undefined,
      bankRef: payload.bank_ref ? String(payload.bank_ref) : undefined,
      paymentType: payload.payment_type ? String(payload.payment_type) : undefined,
      payerBank: payload.bank_name ? String(payload.bank_name) : undefined,
    });
    return true;
  }

  /** Asks PayWay about a pending payment and records the answer. */
  private async refresh(p: Payment, extra: Partial<Pick<Payment, "apv" | "bankRef" | "paymentType" | "payerBank">> = {}) {
    if (p.status !== "PENDING") return p;
    let result;
    try {
      result = await this.payway.check(p.tranId);
    } catch (e) {
      this.log.warn(`check ${p.tranId} failed: ${(e as Error).message}`);
      return p; // keep PENDING; the app polls again
    }
    if (result.status === "APPROVED") return this.markPaid(p, { ...extra, apv: extra.apv ?? result.apv });
    if (result.status === "FAILED") return this.prisma.payment.update({ where: { id: p.id }, data: { status: "FAILED" } });
    if (p.expiresAt <= new Date()) return this.prisma.payment.update({ where: { id: p.id }, data: { status: "EXPIRED" } });
    return p;
  }

  private async markPaid(p: Payment, extra: Partial<Pick<Payment, "apv" | "bankRef" | "paymentType" | "payerBank">>) {
    const now = new Date();
    return this.prisma.$transaction(async (tx) => {
      const paid = await tx.payment.update({ where: { id: p.id }, data: { status: "APPROVED", paidAt: now, ...strip(extra) } });
      // Only a waiting order moves to PAID; a cancelled one stays cancelled (refund by hand).
      const moved = await tx.order.updateMany({ where: { id: p.orderId, status: "PENDING" }, data: { status: "PAID", paidAt: now } });
      if (moved.count > 0) {
        const via = paid.paymentType ? ` · ${paid.paymentType}` : "";
        await logOrderEvent(tx, p.orderId, "PAID", { system: this.payway.mock ? "ABA PayWay (test)" : "ABA PayWay" }, "PAYWAY", `Payment ${paid.tranId}${via}`);
      }
      return paid;
    });
  }

  private latest(orderId: string) {
    return this.prisma.payment.findFirst({ where: { orderId }, orderBy: { createdAt: "desc" } });
  }

  private async ownOrder(userId: string, orderId: string) {
    const order = await this.prisma.order.findFirst({ where: { id: orderId, userId } });
    if (!order) throw new NotFoundException("Order not found");
    return order;
  }
}

const strip = <T extends object>(o: T) => Object.fromEntries(Object.entries(o).filter(([, v]) => v !== undefined)) as Partial<T>;
