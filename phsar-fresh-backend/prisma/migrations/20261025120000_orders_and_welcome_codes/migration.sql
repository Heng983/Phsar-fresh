-- CreateEnum
CREATE TYPE "PaymentMethod" AS ENUM ('ABA_PAY', 'CARD', 'CASH');

-- AlterTable: orders remember the discount, payment and delivery details
ALTER TABLE "Order"
  ADD COLUMN "subtotalCents" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "discountCents" INTEGER NOT NULL DEFAULT 0,
  ADD COLUMN "discountCode" TEXT,
  ADD COLUMN "paymentMethod" "PaymentMethod" NOT NULL DEFAULT 'CASH',
  ADD COLUMN "addressText" TEXT,
  ADD COLUMN "recipientName" TEXT,
  ADD COLUMN "recipientPhone" TEXT,
  ADD COLUMN "note" TEXT;

-- Older orders: subtotal = total - delivery
UPDATE "Order" SET "subtotalCents" = GREATEST("totalCents" - "deliveryCents", 0);

-- AlterTable: welcome codes
ALTER TABLE "DiscountCode"
  ADD COLUMN "newCustomersOnly" BOOLEAN NOT NULL DEFAULT false,
  ADD COLUMN "oncePerCustomer" BOOLEAN NOT NULL DEFAULT false;

-- CreateTable
CREATE TABLE "DiscountRedemption" (
    "id" TEXT NOT NULL,
    "codeId" TEXT NOT NULL,
    "userId" TEXT NOT NULL,
    "orderId" TEXT NOT NULL,
    "onceKey" TEXT,
    "discountCents" INTEGER NOT NULL,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,

    CONSTRAINT "DiscountRedemption_pkey" PRIMARY KEY ("id")
);

CREATE UNIQUE INDEX "DiscountRedemption_orderId_key" ON "DiscountRedemption"("orderId");
CREATE UNIQUE INDEX "DiscountRedemption_onceKey_key" ON "DiscountRedemption"("onceKey");
CREATE INDEX "DiscountRedemption_codeId_idx" ON "DiscountRedemption"("codeId");
CREATE INDEX "DiscountRedemption_userId_idx" ON "DiscountRedemption"("userId");

ALTER TABLE "DiscountRedemption" ADD CONSTRAINT "DiscountRedemption_codeId_fkey" FOREIGN KEY ("codeId") REFERENCES "DiscountCode"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "DiscountRedemption" ADD CONSTRAINT "DiscountRedemption_userId_fkey" FOREIGN KEY ("userId") REFERENCES "User"("id") ON DELETE CASCADE ON UPDATE CASCADE;
ALTER TABLE "DiscountRedemption" ADD CONSTRAINT "DiscountRedemption_orderId_fkey" FOREIGN KEY ("orderId") REFERENCES "Order"("id") ON DELETE CASCADE ON UPDATE CASCADE;
