import type { Metadata } from "next";
import { Page } from "@/components/topbar";
import { Alert } from "@/components/ui";
import { api } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict } from "@/i18n/server";
import { ASSET_URL, assetUrl } from "@/lib/config";
import type { Category, ProductList, Promotion } from "@/lib/types";
import { PromotionForm } from "../promotion-form";

export const metadata: Metadata = { title: "Edit promotion" };

export default async function EditPromotionPage({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ saved?: string; imageError?: string; error?: string }>;
}) {
  await requirePermission("promotions.write");
  const [{ id }, sp, d] = await Promise.all([params, searchParams, getDict()]);
  const t = d.promotions;
  const [promotion, categories, products] = await Promise.all([
    api<Promotion>(`/admin/promotions/${id}`),
    api<Category[]>("/admin/categories"),
    api<ProductList>("/admin/products?limit=100"),
  ]);
  const note = t.statusNote[promotion.status];

  return (
    <Page title={promotion.title} subtitle={`${t.title} · ${note}`} back={{ href: "/promotions", label: t.all }}>
      {sp.saved && !sp.imageError && <Alert tone="success" title={t.saved} />}
      {sp.imageError && <Alert tone="warning" title={t.imageFailed}>{sp.imageError}</Alert>}
      {sp.error && <Alert tone="danger" title={sp.error} />}
      <PromotionForm promotion={promotion} categories={categories} products={products.items} imageSrc={assetUrl(promotion.imageUrl)} assetBase={ASSET_URL} />
    </Page>
  );
}
