-- CreateTable
CREATE TABLE "OrderEvent" (
    "id" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "status" "OrderStatus" NOT NULL,
    "actorId" TEXT,
    "actorName" TEXT,
    "actorRole" "Role",
    "source" TEXT NOT NULL,
    "note" TEXT,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "OrderEvent_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "OrderEvent_orderId_createdAt_idx" ON "OrderEvent"("orderId", "createdAt");
CREATE INDEX "OrderEvent_actorId_idx" ON "OrderEvent"("actorId");

ALTER TABLE "OrderEvent" ADD CONSTRAINT "OrderEvent_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "OrderEvent" ADD CONSTRAINT "OrderEvent_actorId_fkey" FOREIGN KEY ("actorId") REFERENCES "User"("id") ON DELETE SET NULL ON UPDATE CASCADE;

-- Existing orders: one "placed" entry by their customer, so the log isn't empty.
INSERT INTO "OrderEvent" ("id", "orderId", "status", "actorId", "actorName", "actorRole", "source", "createdAt")
SELECT gen_random_uuid()::text, o."id", 'PENDING', o."userId", u."name", u."role", 'APP', o."createdAt"
FROM "Order" o JOIN "User" u ON u."id" = o."userId";

-- Managers who already have a saved permission set also get the new "see order activity".
UPDATE "RolePermission" SET "permissions" = array_append("permissions", 'orders.activity')
WHERE "role" = 'MANAGER' AND NOT ('orders.activity' = ANY("permissions"));
