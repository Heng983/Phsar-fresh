import { OrderStatus, Prisma, Role } from "@prisma/client";

type Db = Prisma.TransactionClient;

export type EventSource = "APP" | "ADMIN" | "PAYWAY";

/**
 * Appends to an order's activity log. Call it inside the same transaction as
 * the status change so the log never disagrees with the order.
 */
export async function logOrderEvent(
  db: Db,
  orderId: string,
  status: OrderStatus,
  by: { userId: string } | { system: string },
  source: EventSource,
  note?: string,
) {
  let actorId: string | null = null;
  let actorName: string | null = null;
  let actorRole: Role | null = null;
  if ("userId" in by) {
    const u = await db.user.findUnique({ where: { id: by.userId }, select: { id: true, name: true, phone: true, role: true } });
    actorId = u?.id ?? null;
    actorName = u?.name || u?.phone || null;
    actorRole = u?.role ?? null;
  } else {
    actorName = by.system;
  }
  await db.orderEvent.create({ data: { orderId, status, actorId, actorName, actorRole, source, note: note ?? null } });
}
