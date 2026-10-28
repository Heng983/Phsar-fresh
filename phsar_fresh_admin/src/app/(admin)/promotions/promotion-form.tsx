"use client";

import { useActionState, useMemo, useState } from "react";
import { ConfirmButton, SubmitButton } from "@/components/client";
import { Select, TextField } from "@/components/fields";
import { Icon } from "@/components/icon";
import { ScheduleFields } from "@/components/schedule-fields";
import type { Category, Product, Promotion, PromotionAction, PromotionKind } from "@/lib/types";
import { useDict, useLang } from "@/i18n/client";
import { localName } from "@/lib/format";
import { DICTS } from "@/i18n/dict";
import { deletePromotion, savePromotion, type PromotionFormState } from "./actions";


/** ISO → value for <input type="datetime-local"> in Phnom Penh time. */
const toLocal = (iso: string | null) => (iso ? new Date(new Date(iso).getTime() + 7 * 3600e3).toISOString().slice(0, 16) : "");
const money = (c: number) => `$${(c / 100).toFixed(2)}`;

export function PromotionForm({ promotion, categories, products, imageSrc, assetBase }: {
  promotion?: Promotion; categories: Category[]; products: Product[]; imageSrc: string | null; assetBase: string;
}) {
  const [state, action] = useActionState<PromotionFormState, FormData>(savePromotion.bind(null, promotion?.id ?? null), {});
  const d = useDict();
  const uiLang = useLang();
  const t = d.promotions;
  const ACTIONS: { value: PromotionAction; label: string }[] = [
    { value: "OPEN_CHAT", label: t.actOpenChat },
    { value: "OPEN_CATEGORY", label: t.actOpenCategory },
    { value: "OPEN_PRODUCT", label: t.actOpenProduct },
    { value: "NONE", label: t.actNone },
  ];
  const [kind, setKind] = useState<PromotionKind>(promotion?.kind ?? "BANNER");
  const [f, setF] = useState({
    title: promotion?.title ?? "",
    titleKm: promotion?.titleKm ?? "",
    body: promotion?.body ?? "",
    bodyKm: promotion?.bodyKm ?? "",
    buttonLabel: promotion?.buttonLabel ?? "",
    buttonLabelKm: promotion?.buttonLabelKm ?? "",
    action: (promotion?.action && promotion.kind === "BANNER" ? promotion.action : "OPEN_CHAT") as PromotionAction,
    categoryId: promotion?.categoryId ?? "",
    productId: promotion?.kind === "BANNER" ? (promotion.productId ?? "") : "",
    dealProductId: promotion?.kind === "DEAL" ? (promotion.productId ?? "") : "",
    dealPrice: promotion?.dealPriceCents != null ? (promotion.dealPriceCents / 100).toFixed(2) : "",
  });
  const [preview, setPreview] = useState<string | null>(imageSrc);
  const [lang, setLang] = useState<"en" | "km">("en");
  const set = (k: keyof typeof f) => (e: { target: { value: string } }) => setF((s) => ({ ...s, [k]: e.target.value }));

  const dealProduct = products.find((p) => p.id === f.dealProductId);
  const dealCents = Math.round(Number(f.dealPrice) * 100);
  const discount = dealProduct && dealCents > 0 && dealCents < dealProduct.priceCents ? Math.round((1 - dealCents / dealProduct.priceCents) * 100) : null;
  const productOptions = useMemo(
    () =>
      products
        .map((p) => ({ value: p.id, name: localName(uiLang, p.name, p.nameKm), p }))
        .sort((a, b) => a.name.localeCompare(b.name, uiLang === "km" ? "km" : "en"))
        .map(({ value, name, p }) => ({ value, label: `${name} — ${money(p.priceCents)} / ${p.unit}${p.isActive ? "" : t.hiddenSuffix}` })),
    [products, t, uiLang],
  );
  const km = lang === "km";
  const pv = DICTS[lang].promotions; // the app's own words, in the preview's language
  const pick = (en: string, kmText: string) => (km && kmText.trim() ? kmText : en);
  const productImg = (url: string | null | undefined) => (!url ? null : /^https?:/.test(url) ? url : `${assetBase}${url}`);

  return (
    <form action={action} className="pf-grid pf-grid-3-1" style={{ alignItems: "start" }}>
      <input type="hidden" name="kind" value={kind} />
      <div className="pf-col">
        {state.error && <div className="pf-alert pf-alert-danger" role="alert"><Icon name="alert" size={18} /><div className="pf-alert-title">{state.error}</div></div>}

        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.type}</h2></div></header>
          <div className="pf-card-body">
            <div className="pf-kind" role="radiogroup" aria-label={t.type}>
              {([["BANNER", "megaphone", t.typeBanner, t.typeBannerHint], ["DEAL", "tag", t.typeDeal, t.typeDealHint]] as const).map(([k, icon, label, hint]) => (
                <button key={k} type="button" role="radio" aria-checked={kind === k} className={`pf-kind-opt${kind === k ? " is-active" : ""}`} onClick={() => setKind(k)} disabled={!!promotion && promotion.kind !== k}>
                  <Icon name={icon} size={20} /><strong>{label}</strong><span>{hint}</span>
                </button>
              ))}
            </div>
            {promotion && <p className="pf-hint" style={{ margin: "8px 0 0" }}>{t.typeLocked}</p>}
          </div>
        </section>

        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.text}</h2><p className="pf-card-sub">{t.textSub}</p></div></header>
          <div className="pf-card-body pf-form-grid">
            <div className="pf-bilingual">
              <TextField label={t.titleField} lang="EN" name="title" required maxLength={80} value={f.title} onChange={set("title")} placeholder={kind === "DEAL" ? "Fresh Pursat citrus" : "Meet Ming Sros, your AI kitchen helper"} />
              <TextField label={t.titleField} lang="ខ្មែរ" name="titleKm" className="pf-km" maxLength={80} value={f.titleKm} onChange={set("titleKm")} />
            </div>
            {kind === "BANNER" && (
              <div className="pf-bilingual">
                <TextField label={t.bodyField} lang="EN" name="body" maxLength={160} value={f.body} onChange={set("body")} placeholder="Ask what to cook tonight and get a ready shopping list." />
                <TextField label={t.bodyField} lang="ខ្មែរ" name="bodyKm" className="pf-km" maxLength={160} value={f.bodyKm} onChange={set("bodyKm")} />
              </div>
            )}
          </div>
        </section>

        {kind === "BANNER" ? (
          <>
            <section className="pf-card">
              <header className="pf-card-head"><div><h2 className="pf-card-title">{t.picture}</h2><p className="pf-card-sub">{t.pictureSub}</p></div></header>
              <div className="pf-card-body">
                <label className={`pf-drop${preview ? " has-banner" : ""}`}>
                  {preview ? <img src={preview} alt="" className="pf-banner-pick" /> : <span className="pf-drop-icon"><Icon name="upload" size={20} /></span>}
                  <strong>{preview ? t.replacePicture : <>{t.choosePicture} <span>{d.picker.browse}</span></>}</strong>
                  <span className="pf-hint">{t.pictureHint}</span>
                  <input type="file" name="image" accept="image/jpeg,image/png,image/webp" hidden onChange={(e) => { const file = e.target.files?.[0]; if (file) setPreview(URL.createObjectURL(file)); }} />
                </label>
              </div>
            </section>
            <section className="pf-card">
              <header className="pf-card-head"><div><h2 className="pf-card-title">{t.button}</h2><p className="pf-card-sub">{t.buttonSub}</p></div></header>
              <div className="pf-card-body pf-form-grid">
                <Select label={t.whenTapped} name="action" value={f.action} onChange={set("action")} options={ACTIONS} />
                {f.action === "OPEN_CATEGORY" && <Select label={t.category} name="categoryId" required value={f.categoryId} onChange={set("categoryId")} placeholder={t.chooseCategory} options={categories.map((c) => ({ value: c.id, label: localName(uiLang, c.name, c.nameKm) }))} />}
                {f.action === "OPEN_PRODUCT" && <Select label={t.product} name="productId" required value={f.productId} onChange={set("productId")} placeholder={t.chooseProduct} options={productOptions} />}
                {f.action !== "NONE" && (
                  <div className="pf-bilingual">
                    <TextField label={t.buttonLabel} lang="EN" name="buttonLabel" maxLength={24} value={f.buttonLabel} onChange={set("buttonLabel")} placeholder={f.action === "OPEN_CHAT" ? DICTS.en.promotions.askMingSros : DICTS.en.promotions.shopNow} />
                    <TextField label={t.buttonLabel} lang="ខ្មែរ" name="buttonLabelKm" className="pf-km" maxLength={24} value={f.buttonLabelKm} onChange={set("buttonLabelKm")} />
                  </div>
                )}
              </div>
            </section>
          </>
        ) : (
          <section className="pf-card">
            <header className="pf-card-head"><div><h2 className="pf-card-title">{t.dealCard}</h2><p className="pf-card-sub">{t.dealSub}</p></div></header>
            <div className="pf-card-body pf-form-grid">
              <Select label={t.productOnSale} name="dealProductId" required value={f.dealProductId} onChange={set("dealProductId")} placeholder={t.chooseProduct} options={productOptions} />
              <TextField label={t.dealPrice} name="dealPrice" prefix="$" inputMode="decimal" required value={f.dealPrice} onChange={set("dealPrice")}
                hint={dealProduct ? (discount != null ? t.off(discount, money(dealProduct.priceCents)) : t.mustBeLower(money(dealProduct.priceCents))) : t.pickFirst} />
            </div>
          </section>
        )}
      </div>

      <div className="pf-col" style={{ position: "sticky", top: 24 }}>
        <section className="pf-card">
          <header className="pf-card-head">
            <div><h2 className="pf-card-title">{t.preview}</h2><p className="pf-card-sub">{t.previewSub}</p></div>
            <div className="pf-theme is-compact" role="radiogroup" aria-label={d.common.language}>
              <button type="button" className={`pf-theme-opt${!km ? " is-active" : ""}`} style={{ width: 36 }} onClick={() => setLang("en")}>EN</button>
              <button type="button" className={`pf-theme-opt pf-km${km ? " is-active" : ""}`} style={{ width: 44 }} onClick={() => setLang("km")}>ខ្មែរ</button>
            </div>
          </header>
          <div className="pf-card-body">
            <div className="pf-app-slide">
              <div className="pf-app-slide-img">
                {kind === "BANNER"
                  ? preview ? <img src={preview} alt="" /> : <Icon name="image" size={28} />
                  : productImg(dealProduct?.imageUrl) ? <img src={productImg(dealProduct?.imageUrl)!} alt="" style={{ objectFit: "contain" }} /> : <Icon name="tag" size={28} />}
                {kind === "DEAL" && discount != null && <span className="pf-app-badge">-{discount}%</span>}
              </div>
              <div className="pf-app-slide-foot">
                <div style={{ minWidth: 0, flex: 1 }}>
                  <div className={`pf-app-title${km ? " pf-km" : ""}`}>{pick(f.title, f.titleKm) || t.titleField}</div>
                  {kind === "BANNER" ? (
                    (f.body || f.bodyKm) && <div className={`pf-app-body${km ? " pf-km" : ""}`}>{pick(f.body, f.bodyKm)}</div>
                  ) : (
                    <div className="pf-app-body"><strong style={{ color: "var(--leaf)" }}>{dealCents > 0 ? money(dealCents) : "$0.00"}</strong> {dealProduct && <s>{money(dealProduct.priceCents)}</s>}</div>
                  )}
                </div>
                {kind === "DEAL" ? <span className={`pf-app-btn${km ? " pf-km" : ""}`}>{pv.addToCart}</span> : f.action !== "NONE" && (
                  <span className={`pf-app-btn${km ? " pf-km" : ""}`}>{f.action === "OPEN_CHAT" && <Icon name="sparkles" size={14} />}{pick(f.buttonLabel, f.buttonLabelKm) || (f.action === "OPEN_CHAT" ? pv.askMingSros : pv.shopNow)}</span>
                )}
              </div>
            </div>
          </div>
        </section>

        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.schedule}</h2><p className="pf-card-sub">{t.scheduleSub}</p></div></header>
          <div className="pf-card-body pf-form-grid">
            <ScheduleFields startsAt={toLocal(promotion?.startsAt ?? null)} endsAt={toLocal(promotion?.endsAt ?? null)} />
            <TextField label={t.position} name="sortOrder" type="number" min={0} max={999} defaultValue={String(promotion?.sortOrder ?? 0)} hint={t.positionHint} />
            <label className="pf-switch">
              <input type="checkbox" role="switch" name="isActive" defaultChecked={promotion?.isActive ?? true} />
              <span className="pf-switch-track" /> {t.showInApp}
            </label>
          </div>
        </section>

        <div className="pf-actions-row">
          <SubmitButton icon="check">{promotion ? d.common.saveChanges : t.create}</SubmitButton>
          {promotion && <ConfirmButton formAction={deletePromotion.bind(null, promotion.id)} confirmLabel={d.common.deleteConfirm}>{d.common.delete}</ConfirmButton>}
        </div>
      </div>
    </form>
  );
}
