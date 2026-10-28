import { Prisma } from "@prisma/client";

/** Switched on, and inside its start / end dates (empty date = no limit). */
export function liveNow(now = new Date()): Prisma.PromotionWhereInput {
  return {
    isActive: true,
    AND: [
      { OR: [{ startsAt: null }, { startsAt: { lte: now } }] },
      { OR: [{ endsAt: null }, { endsAt: { gt: now } }] },
    ],
  };
}

export const carouselOrder: Prisma.PromotionOrderByWithRelationInput[] = [{ sortOrder: "asc" }, { createdAt: "desc" }];
