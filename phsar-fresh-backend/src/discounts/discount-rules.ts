import { DiscountCode } from "@prisma/client";

export type DiscountProblem =
  | "NOT_FOUND"
  | "NOT_STARTED"
  | "EXPIRED"
  | "MIN_SUBTOTAL"
  | "LOGIN_REQUIRED" // welcome / once-per-customer codes need an account
  | "NOT_NEW_CUSTOMER" // welcome code, but this account already ordered
  | "ALREADY_USED"; // once-per-customer code this account already used

export const normalizeCode = (code: string) => code.trim().toUpperCase().replace(/\s+/g, "");

/** Welcome codes are always one use per account. */
export const isOncePerCustomer = (c: Pick<DiscountCode, "newCustomersOnly" | "oncePerCustomer">) =>
  c.newCustomersOnly || c.oncePerCustomer;

export const onceKey = (codeId: string, userId: string) => `${codeId}:${userId}`;

export function codeStatus(c: DiscountCode, now = new Date()) {
  if (!c.isActive) return "OFF";
  if (c.startsAt && c.startsAt > now) return "SCHEDULED";
  if (c.endsAt && c.endsAt <= now) return "ENDED";
  return "LIVE";
}

/** Cents off a subtotal — never more than the subtotal itself. */
export function discountFor(c: Pick<DiscountCode, "type" | "value" | "maxDiscountCents">, subtotalCents: number) {
  let off = c.type === "PERCENT" ? Math.floor((subtotalCents * c.value) / 100) : c.value;
  if (c.type === "PERCENT" && c.maxDiscountCents != null) off = Math.min(off, c.maxDiscountCents);
  return Math.max(0, Math.min(off, subtotalCents));
}

/** The rules that need no database: active, dates, minimum order. */
export function problemWith(c: DiscountCode | null, subtotalCents: number, now = new Date()): DiscountProblem | null {
  if (!c || !c.isActive) return "NOT_FOUND";
  if (c.startsAt && c.startsAt > now) return "NOT_STARTED";
  if (c.endsAt && c.endsAt <= now) return "EXPIRED";
  if (subtotalCents < c.minSubtotalCents) return "MIN_SUBTOTAL";
  return null;
}
