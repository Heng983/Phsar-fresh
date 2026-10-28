import type { Metadata } from "next";
import { Page } from "@/components/topbar";
import { Alert, ButtonLink } from "@/components/ui";
import { api } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict } from "@/i18n/server";
import type { Category } from "@/lib/types";
import { ProductForm } from "../product-form";

export const metadata: Metadata = { title: "Add product" };

export default async function NewProductPage() {
  await requirePermission("products.write");
  const [categories, d] = await Promise.all([api<Category[]>("/admin/categories"), getDict()]);
  const t = d.productForm;
  return (
    <Page title={t.newTitle} subtitle={t.newSub} actions={<ButtonLink href="/products" variant="ghost">{d.common.cancel}</ButtonLink>}>
      {categories.length === 0 && <Alert tone="warning" title={t.addCategoryFirst}>{t.addCategoryFirstBody}</Alert>}
      <ProductForm categories={categories} />
    </Page>
  );
}
