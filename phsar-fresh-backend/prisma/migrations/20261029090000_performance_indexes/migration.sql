-- Indexes for the queries that run most often, so they stay fast as orders
-- and products grow. Postgres doesn't index foreign keys on its own.

-- A customer's orders (Orders tab, notifications), newest first.
CREATE INDEX "Order_userId_createdAt_idx" ON "Order"("userId", "createdAt");
-- Admin order list per status tab, the dashboard's date ranges.
CREATE INDEX "Order_status_createdAt_idx" ON "Order"("status", "createdAt");
CREATE INDEX "Order_createdAt_idx" ON "Order"("createdAt");
-- New-order alerts for ABA Pay (paid after a moment).
CREATE INDEX "Order_paidAt_idx" ON "Order"("paidAt");

-- Order lines: loading an order, and "popular this week".
CREATE INDEX "OrderItem_orderId_idx" ON "OrderItem"("orderId");
CREATE INDEX "OrderItem_productId_idx" ON "OrderItem"("productId");

-- Browsing a category, and the in-stock-first product list.
CREATE INDEX "Product_categoryId_idx" ON "Product"("categoryId");
CREATE INDEX "Product_isActive_stock_name_idx" ON "Product"("isActive", "stock", "name");

-- Order events of a customer (notifications feed) by time.
CREATE INDEX "OrderEvent_createdAt_idx" ON "OrderEvent"("createdAt");
