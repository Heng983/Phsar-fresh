import { Prisma } from "@prisma/client";
import { orderCode } from "../orders/order-code";

/** What the admin bell needs to show one order. */
export const alertSelect = {
  id: true,
  totalCents: true,
  paymentMethod: true,
  createdAt: true,
  paidAt: true,
  recipientName: true,
  user: { select: { name: true, phone: true } },
} satisfies Prisma.OrderSelect;

type AlertRow = Prisma.OrderGetPayload<{ select: typeof alertSelect }>;

export const toOrderAlert = (o: AlertRow) => ({
  id: o.id,
  code: orderCode(o.id),
  totalCents: o.totalCents,
  paymentMethod: o.paymentMethod,
  customer: o.recipientName || o.user.name || o.user.phone,
  // ABA Pay orders reach staff once they're paid.
  at: o.paymentMethod === "ABA_PAY" ? (o.paidAt ?? o.createdAt) : o.createdAt,
});
export type OrderAlert = ReturnType<typeof toOrderAlert>;
