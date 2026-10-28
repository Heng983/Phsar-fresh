import { Injectable, UnprocessableEntityException } from "@nestjs/common";
import { DiscountCode, Prisma } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { DiscountProblem, discountFor, isOncePerCustomer, normalizeCode, problemWith } from "./discount-rules";

type Db = PrismaService | Prisma.TransactionClient;

export type Evaluation =
  | { ok: true; code: DiscountCode; discountCents: number }
  | { ok: false; reason: DiscountProblem; minSubtotalCents?: number };

@Injectable()
export class DiscountsService {
  constructor(private readonly prisma: PrismaService) {}

  /**
   * Every rule for one code, one subtotal and (optionally) one customer.
   * Order placing calls this inside its transaction with `db` = the transaction.
   */
  async evaluate(rawCode: string, subtotalCents: number, userId: string | null, db: Db = this.prisma): Promise<Evaluation> {
    const code = await db.discountCode.findUnique({ where: { code: normalizeCode(rawCode) } });
    const basic = problemWith(code, subtotalCents);
    if (basic || !code) {
      return { ok: false, reason: basic ?? "NOT_FOUND", minSubtotalCents: basic === "MIN_SUBTOTAL" ? code!.minSubtotalCents : undefined };
    }
    if (isOncePerCustomer(code) && !userId) return { ok: false, reason: "LOGIN_REQUIRED" };
    if (userId && code.newCustomersOnly) {
      const ordered = await db.order.count({ where: { userId, status: { not: "CANCELLED" } } });
      if (ordered > 0) return { ok: false, reason: "NOT_NEW_CUSTOMER" };
    }
    if (userId && isOncePerCustomer(code)) {
      const used = await db.discountRedemption.count({ where: { codeId: code.id, userId, onceKey: { not: null } } });
      if (used > 0) return { ok: false, reason: "ALREADY_USED" };
    }
    return { ok: true, code, discountCents: discountFor(code, subtotalCents) };
  }

  /** The 422 the app reads: { reason, message, minSubtotalCents? }. */
  static refuse(e: Extract<Evaluation, { ok: false }>) {
    return new UnprocessableEntityException({
      statusCode: 422,
      reason: e.reason,
      message: MESSAGES[e.reason],
      minSubtotalCents: e.minSubtotalCents,
    });
  }

  async check(rawCode: string, subtotalCents: number, userId: string | null) {
    const e = await this.evaluate(rawCode, subtotalCents, userId);
    if (!e.ok) throw DiscountsService.refuse(e);
    const c = e.code;
    return {
      code: c.code,
      description: c.description,
      descriptionKm: c.descriptionKm,
      type: c.type,
      value: c.value,
      maxDiscountCents: c.maxDiscountCents,
      minSubtotalCents: c.minSubtotalCents,
      newCustomersOnly: c.newCustomersOnly,
      oncePerCustomer: isOncePerCustomer(c),
      endsAt: c.endsAt,
      discountCents: e.discountCents,
    };
  }
}

const MESSAGES: Record<DiscountProblem, string> = {
  NOT_FOUND: "This code is not valid",
  NOT_STARTED: "This code can't be used yet",
  EXPIRED: "This code has expired",
  MIN_SUBTOTAL: "Your basket is below this code's minimum order",
  LOGIN_REQUIRED: "Sign in to use this code",
  NOT_NEW_CUSTOMER: "This code is for your first order only",
  ALREADY_USED: "You've already used this code",
};
