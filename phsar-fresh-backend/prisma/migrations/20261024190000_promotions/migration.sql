-- Explore carousel slides managed in the admin panel.
CREATE TYPE "PromotionKind" AS ENUM ('BANNER', 'DEAL');

CREATE TYPE "PromotionAction" AS ENUM ('NONE', 'OPEN_CHAT', 'OPEN_CATEGORY', 'OPEN_PRODUCT');

CREATE TABLE "Promotion" (
    "id" TEXT NOT NULL,
    "kind" "PromotionKind" NOT NULL DEFAULT 'BANNER',
    "title" TEXT NOT NULL,
    "titleKm" TEXT,
    "body" TEXT,
    "bodyKm" TEXT,
    "buttonLabel" TEXT,
    "buttonLabelKm" TEXT,
    "imageUrl" TEXT,
    "action" "PromotionAction" NOT NULL DEFAULT 'NONE',
    "categoryId" TEXT,
    "productId" TEXT,
    "dealPriceCents" INTEGER,
    "startsAt" TIMESTAMP(3),
    "endsAt" TIMESTAMP(3),
    "isActive" BOOLEAN NOT NULL DEFAULT true,
    "sortOrder" INTEGER NOT NULL DEFAULT 0,
    "createdAt" TIMESTAMP(3) NOT NULL DEFAULT CURRENT_TIMESTAMP,
    "updatedAt" TIMESTAMP(3) NOT NULL,

    CONSTRAINT "Promotion_pkey" PRIMARY KEY ("id")
);

CREATE INDEX "Promotion_isActive_sortOrder_idx" ON "Promotion"("isActive", "sortOrder");

ALTER TABLE "Promotion" ADD CONSTRAINT "Promotion_categoryId_fkey" FOREIGN KEY ("categoryId") REFERENCES "Category"("id") ON DELETE SET NULL ON UPDATE CASCADE;

ALTER TABLE "Promotion" ADD CONSTRAINT "Promotion_productId_fkey" FOREIGN KEY ("productId") REFERENCES "Product"("id") ON DELETE SET NULL ON UPDATE CASCADE;
