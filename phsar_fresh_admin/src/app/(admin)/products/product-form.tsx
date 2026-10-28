"use client";

import { useActionState } from "react";
import { ConfirmButton, ImagePicker, SubmitButton } from "@/components/client";
import { BilingualField, Select, Switch, TextArea, TextField } from "@/components/fields";
import { Icon } from "@/components/icon";
import { RIEL_PER_USD } from "@/lib/format";
import type { Category, Product } from "@/lib/types";
import { useDict } from "@/i18n/client";
import { deleteProduct, saveProduct, type ProductFormState } from "./actions";

const UNITS = ["kg", "g", "pack", "bunch", "piece", "bag", "bottle", "dozen", "litre"];

export function ProductForm({ product, categories, imageSrc }: { product?: Product; categories: Category[]; imageSrc?: string | null }) {
  const [state, action] = useActionState<ProductFormState, FormData>(saveProduct.bind(null, product?.id ?? null), {});
  const d = useDict();
  const t = d.productForm;
  const f = state.fields;
  const e = state.fieldErrors ?? {};
  const v = (k: string, fallback: string | number | null | undefined) => f?.[k] ?? (fallback == null ? "" : String(fallback));
  const units = product && !UNITS.includes(product.unit) ? [product.unit, ...UNITS] : UNITS;
  const price = Number(v("price", product ? (product.priceCents / 100).toFixed(2) : ""));

  return (
    <form action={action} className="pf-grid pf-grid-3-1" key={product?.id ?? "new"}>
      <div className="pf-col">
        {state.error && (
          <div className="pf-alert pf-alert-danger" role="alert"><Icon name="alert" size={18} /><div className="pf-alert-title">{state.error}</div></div>
        )}
        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.details}</h2><p className="pf-card-sub">{t.detailsSub}</p></div></header>
          <div className="pf-card-body pf-form-grid">
            <BilingualField label={t.name} labelEn={d.common.english} labelKm={d.common.khmer} required nameEn="name" nameKm="nameKm" defaultEn={v("name", product?.name)} defaultKm={v("nameKm", product?.nameKm)} errorEn={e.name} placeholderEn="Kampot black pepper" placeholderKm="ម្រេចខ្មៅកំពត" />
            <TextArea label={t.description} name="description" defaultValue={v("description", product?.description)} placeholder="Sun-dried pepper from family farms in Kampot…" rows={4} hint={t.descriptionHint} />
            <div className="pf-two">
              <Select label={t.category} name="categoryId" required defaultValue={v("categoryId", product?.category.id)} placeholder={t.chooseCategory} error={e.categoryId}
                options={categories.map((c) => ({ value: c.id, label: c.nameKm ? `${c.name} · ${c.nameKm}` : c.name }))} />
              <TextField label={t.origin} name="origin" icon="map" defaultValue={v("origin", product?.origin)} placeholder="Kampot, Cambodia" />
            </div>
          </div>
        </section>
        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.photo}</h2><p className="pf-card-sub">{t.photoSub}</p></div></header>
          <div className="pf-card-body"><ImagePicker current={imageSrc} /></div>
        </section>
      </div>

      <div className="pf-col">
        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.pricing}</h2></div></header>
          <div className="pf-card-body pf-form-grid">
            <TextField label={t.price} name="price" prefix="$" inputMode="decimal" required defaultValue={v("price", product ? (product.priceCents / 100).toFixed(2) : "")} error={e.price}
              hint={Number.isFinite(price) && price > 0 ? t.rielHint(Math.round(price * RIEL_PER_USD).toLocaleString("en-US"), RIEL_PER_USD.toLocaleString("en-US")) : t.priceHint} />
            <Select label={t.soldBy} name="unit" required defaultValue={v("unit", product?.unit ?? "kg")} error={e.unit} options={units.map((u) => ({ value: u, label: u }))} />
          </div>
        </section>
        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.inventory}</h2></div></header>
          <div className="pf-card-body pf-form-grid">
            <TextField label={t.inStock} name="stock" type="number" min={0} step={1} required defaultValue={v("stock", product?.stock ?? 0)} error={e.stock} suffix={v("unit", product?.unit ?? "kg")} />
          </div>
        </section>
        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.visibility}</h2></div></header>
          <div className="pf-card-body pf-form-grid">
            <Switch name="isActive" label={t.visibleInApp} defaultChecked={product?.isActive ?? true} />
          </div>
        </section>
        <div className="pf-actions-row">
          <SubmitButton icon="check">{product ? d.common.saveChanges : t.create}</SubmitButton>
          {product && (
            <ConfirmButton formAction={deleteProduct.bind(null, product.id)} confirmLabel={d.common.deleteConfirm}>{d.common.delete}</ConfirmButton>
          )}
        </div>
      </div>
    </form>
  );
}
