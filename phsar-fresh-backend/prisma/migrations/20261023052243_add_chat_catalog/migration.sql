/*
  Warnings:

  - You are about to drop the column `deliveryFee` on the `Order` table. All the data in the column will be lost.
  - You are about to drop the column `totalRiel` on the `Order` table. All the data in the column will be lost.
  - You are about to drop the column `priceRiel` on the `OrderItem` table. All the data in the column will be lost.
  - You are about to drop the column `priceRiel` on the `Product` table. All the data in the column will be lost.
  - A unique constraint covering the columns `[name]` on the table `Category` will be added. If there are existing duplicate values, this will fail.
  - Added the required column `deliveryCents` to the `Order` table without a default value. This is not possible if the table is not empty.
  - Added the required column `totalCents` to the `Order` table without a default value. This is not possible if the table is not empty.
  - Added the required column `priceCents` to the `OrderItem` table without a default value. This is not possible if the table is not empty.
  - Added the required column `priceCents` to the `Product` table without a default value. This is not possible if the table is not empty.

*/
-- AlterTable
ALTER TABLE "Category" ADD COLUMN     "nameKm" TEXT;

-- AlterTable
ALTER TABLE "Order" DROP COLUMN "deliveryFee",
DROP COLUMN "totalRiel",
ADD COLUMN     "deliveryCents" INTEGER NOT NULL,
ADD COLUMN     "totalCents" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "OrderItem" DROP COLUMN "priceRiel",
ADD COLUMN     "priceCents" INTEGER NOT NULL;

-- AlterTable
ALTER TABLE "Product" DROP COLUMN "priceRiel",
ADD COLUMN     "description" TEXT,
ADD COLUMN     "nameKm" TEXT,
ADD COLUMN     "origin" TEXT,
ADD COLUMN     "priceCents" INTEGER NOT NULL;

-- CreateIndex
CREATE UNIQUE INDEX "Category_name_key" ON "Category"("name");

-- CreateIndex
CREATE INDEX "Product_name_idx" ON "Product"("name");
