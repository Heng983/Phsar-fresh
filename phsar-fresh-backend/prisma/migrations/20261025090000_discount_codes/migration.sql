-- CreateEnum
CREATE TYPE "DiscountType" AS ENUM ('PERCENT', 'FIXED');

-- CreateTable
CREATE TABLE "DiscountCode" (
    "id" TEXT NOT NULL,
    "code" TEXT NOT NULL,
    "description" TEXT,
    "descriptionKm" TEXT,
    "type" "DiscountType" NOT NULL DEFAULT 'FIXED',
    "value" INTEGER NOT NULL,
    "maxDiscountCents" INTEGER,
    "minSubtotalCents" INTEGER NOT NULL DEFAULT 0,
    "startsAt" TIMESTAMP(3),
    "endsAt" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "DiscountCode_pkey" PRIMARY KEY ("id")
);

-- CreateIndex
CREATE UNIQUE INDEX "DiscountCode_code_key" ON "DiscountCode"("code");

-- The code the app has always advertised keeps working.
INSERT INTO "DiscountCode" ("id", "code", "description", "descriptionKm", "type", "value", "updatedAt")
VALUES (gen_random_uuid()::text, 'KHMERFRESH', '$1.50 off your order', 'បញ្ចុះ $1.50 លើការបញ្ជាទិញ', 'FIXED', 150, CURRENT_TIMESTAMP);
