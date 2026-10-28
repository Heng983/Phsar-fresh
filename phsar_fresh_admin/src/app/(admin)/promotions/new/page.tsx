import type { Metadata } from "next";
import { Page } from "@/components/topbar";
import { ButtonLink } from "@/components/ui";
import { api } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict } from "@/i18n/server";
import { ASSET_URL } from "@/lib/config";
import type { Category, ProductList } from "@/lib/types";
import { PromotionForm } from "../promotion-form";

export const metadata: Metadata = { title: "New promotion" };

export default async function NewPromotionPage() {
  await requirePermission("promotions.write");
  const [categories, products, d] = await Promise.all([api<Category[]>("/admin/categories"), api<ProductList>("/admin/products?limit=100"), getDict()]);
  return (
    <Page title={d.promotions.new} subtitle={d.promotions.newSub} actions={<ButtonLink href="/promotions" variant="ghost">{d.common.cancel}</ButtonLink>}>
      <PromotionForm categories={categories} products={products.items} imageSrc={null} assetBase={ASSET_URL} />
    </Page>
  );
}
