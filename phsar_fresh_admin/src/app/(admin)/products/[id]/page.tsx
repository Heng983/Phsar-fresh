import type { Metadata } from "next";
import { Page } from "@/components/topbar";
import { Alert, Card, ProductCell, StockLevel } from "@/components/ui";
import { getDict, getLang } from "@/i18n/server";
import { api } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { LOW_STOCK, assetUrl } from "@/lib/config";
import { localName, money } from "@/lib/format";
import type { Category, Product } from "@/lib/types";
import { ProductForm } from "../product-form";
import { StockForm } from "../stock-form";

export const metadata: Metadata = { title: "Edit product" };

export default async function EditProductPage({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ saved?: string; hidden?: string; error?: string; imageError?: string }>;
}) {
  const [{ id }, sp, dict, lang] = await Promise.all([params, searchParams, getDict(), getLang()]);
  const t = dict.productForm;
  const access = await requirePermission("products.view");
  const [product, categories] = await Promise.all([api<Product>(`/admin/products/${id}`), api<Category[]>("/admin/categories")]);
  const back = { href: "/products", label: t.allProducts };
  const subtitle = `${dict.products.title} / ${localName(lang, product.category.name, product.category.nameKm)}`;

  // Without products.write: read-only details, plus the stock form if allowed.
  if (!access.can("products.write")) {
    return (
      <Page title={product.name} subtitle={subtitle} back={back}>
        <div className="pf-grid pf-grid-3-1">
          <Card title={t.product}>
            <div className="pf-form-grid">
              <ProductCell name={product.name} nameKm={product.nameKm} image={product.imageUrl} meta={product.origin} />
              <dl className="pf-kv">
                <dt>{t.category}</dt><dd>{localName(lang, product.category.name, product.category.nameKm)}</dd>
                <dt>{t.price}</dt><dd>{money(product.priceCents)} / {product.unit}</dd>
                <dt>{t.inApp}</dt><dd>{product.isActive ? dict.common.visible : dict.common.hidden}</dd>
              </dl>
              <StockLevel qty={product.stock} threshold={LOW_STOCK} unit={product.unit} />
            </div>
          </Card>
          {access.can("products.stock") && (
            <Card title={t.updateStock} subtitle={t.updateStockSub}>
              <StockForm id={product.id} stock={product.stock} unit={product.unit} />
            </Card>
          )}
        </div>
      </Page>
    );
  }

  return (
    <Page title={product.name} subtitle={subtitle} back={back}>
      {sp.saved && !sp.imageError && <Alert tone="success" title={t.saved} />}
      {sp.imageError && <Alert tone="warning" title={t.imageFailed}>{sp.imageError}</Alert>}
      {sp.hidden && <Alert tone="info" title={t.hiddenNotice}>{t.hiddenNoticeBody}</Alert>}
      {sp.error && <Alert tone="danger" title={sp.error} />}
      <ProductForm product={product} categories={categories} imageSrc={assetUrl(product.imageUrl)} />
    </Page>
  );
}
