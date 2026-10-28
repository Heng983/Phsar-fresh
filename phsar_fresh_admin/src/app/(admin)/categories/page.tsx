import type { Metadata } from "next";
import Link from "next/link";
import { ConfirmButton, SubmitButton } from "@/components/client";
import { TextField } from "@/components/fields";
import { Page } from "@/components/topbar";
import { Alert, Card, EmptyState } from "@/components/ui";
import { api } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict } from "@/i18n/server";
import type { Category } from "@/lib/types";
import { assetUrl } from "@/lib/config";
import { createCategory, deleteCategory, removeCategoryImage, updateCategory, uploadCategoryImage } from "./actions";
import { CategoryPhoto } from "./category-photo";

export const metadata: Metadata = { title: "Categories" };

export default async function CategoriesPage({ searchParams }: { searchParams: Promise<{ saved?: string; msg?: string; error?: string; deleted?: string }> }) {
  await requirePermission("categories.write");
  const [sp, categories, d] = await Promise.all([searchParams, api<Category[]>("/admin/categories"), getDict()]);
  const t = d.categories;
  return (
    <Page title={t.title} subtitle={t.subtitle(categories.length)}>
      {sp.saved && <Alert tone="success" title={t.savedX(sp.saved)} />}
      {sp.msg && <Alert tone="success" title={sp.msg} />}
      {sp.deleted && <Alert tone="success" title={t.deleted} />}
      {sp.error && <Alert tone="danger" title={sp.error} />}

      <Card title={t.add}>
        <form action={createCategory} className="pf-cat-new">
          <TextField label={d.common.english} lang="EN" name="name" required placeholder="Vegetables" />
          <TextField label={d.common.khmer} lang="ខ្មែរ" name="nameKm" className="pf-km" placeholder="បន្លែ" />
          <div className="pf-field">
            <label className="pf-label" htmlFor="new-cat-image">{t.photo} <span className="pf-hint">{d.common.optional}</span></label>
            <input id="new-cat-image" type="file" name="image" accept="image/jpeg,image/png,image/webp" className="pf-file" />
          </div>
          <SubmitButton icon="plus" pendingLabel={t.adding}>{t.addBtn}</SubmitButton>
        </form>
      </Card>

      <Card title={t.all} subtitle={t.allSub} flush>
        {categories.length === 0 ? (
          <EmptyState icon="tag" title={t.none} />
        ) : (
          categories.map((c) => (
            <div key={c.id} className="pf-cat-item">
            <CategoryPhoto
              name={c.name}
              coverUrl={assetUrl(c.coverUrl)}
              source={c.coverSource}
              upload={uploadCategoryImage.bind(null, c.id, c.name)}
              remove={removeCategoryImage.bind(null, c.id, c.name)}
            />
            <form action={updateCategory.bind(null, c.id)} className="pf-cat-row">
              <TextField label={d.common.english} lang="EN" name="name" id={`n-${c.id}`} required defaultValue={c.name} />
              <TextField label={d.common.khmer} lang="ខ្មែរ" name="nameKm" id={`k-${c.id}`} className="pf-km" defaultValue={c.nameKm ?? ""} />
              <Link className="pf-cat-count pf-link" href={`/products?categoryId=${c.id}`}>{d.common.products(c.productCount)}</Link>
              <div className="pf-actions-row">
                <SubmitButton variant="secondary" size="sm">{d.common.save}</SubmitButton>
                {c.productCount === 0 && <ConfirmButton formAction={deleteCategory.bind(null, c.id)} confirmLabel={t.deleteQ}>{d.common.delete}</ConfirmButton>}
              </div>
            </form>
            </div>
          ))
        )}
      </Card>
    </Page>
  );
}
