import type { Metadata } from "next";
import Link from "next/link";
import { Page } from "@/components/topbar";
import { Icon } from "@/components/icon";
import { Alert, Badge, ButtonLink, Card, EmptyState, IconLink } from "@/components/ui";
import { api, orDefault } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict, getLang } from "@/i18n/server";
import { assetUrl } from "@/lib/config";
import { dateTime, localName, money } from "@/lib/format";
import type { Promotion } from "@/lib/types";
import { setPromotionActive } from "./actions";
import { PromoTabs } from "./promo-tabs";
import type { DiscountCode } from "@/lib/types";

export const metadata: Metadata = { title: "Promotions" };

const TONE = { LIVE: "leaf", SCHEDULED: "sky", ENDED: "neutral", OFF: "neutral" } as const;

export default async function PromotionsPage({ searchParams }: { searchParams: Promise<{ deleted?: string }> }) {
  await requirePermission("promotions.write");
  const [sp, list, lang, d] = await Promise.all([searchParams, api<Promotion[]>("/admin/promotions"), getLang(), getDict()]);
  const codes = await orDefault(api<DiscountCode[]>("/admin/discount-codes"), []);
  const t = d.promotions;
  const live = list.filter((p) => p.status === "LIVE");

  return (
    <Page
      title={t.title}
      subtitle={t.subtitle(live.length, list.length)}
      actions={<ButtonLink href="/promotions/new" variant="primary" icon="plus">{t.new}</ButtonLink>}
    >
      {sp.deleted && <Alert tone="success" title={t.deleted} />}
      {live.filter((p) => p.kind === "BANNER").length === 0 && (
        <Alert tone="info" title={t.noBanners}>{t.noBannersBody}</Alert>
      )}
      <Card flush>
        <PromoTabs active="carousel" carousel={list.length} codes={codes.length} />
        <p className="pf-hint" style={{ margin: 0, padding: "12px 20px 0" }}>{t.carouselSub}</p>
        {list.length === 0 ? (
          <EmptyState icon="megaphone" title={t.none}>{t.noneBody}</EmptyState>
        ) : (
          <ul className="pf-promo-list">
            {list.map((p) => {
              const img = p.kind === "BANNER" ? assetUrl(p.imageUrl) : assetUrl(p.product?.imageUrl);
              const s = { label: t.status[p.status], tone: TONE[p.status] };
              return (
                <li key={p.id}>
                  <Link href={`/promotions/${p.id}`} className={`pf-promo-thumb${p.kind === "DEAL" ? " is-deal" : ""}`}>
                    {img ? <img src={img} alt="" /> : <Icon name={p.kind === "DEAL" ? "tag" : "image"} size={22} />}
                  </Link>
                  <div className="pf-promo-main">
                    <div className="pf-promo-top">
                      <Link href={`/promotions/${p.id}`} className="pf-product-name" style={{ textDecoration: "none" }}>{p.title}</Link>
                      <Badge tone={s.tone} dot>{s.label}</Badge>
                    </div>
                    {p.titleKm && <div className="pf-product-km">{p.titleKm}</div>}
                    <div className="pf-hint">
                      {p.kind === "DEAL"
                        ? <>{t.deal} · {p.product ? `${localName(lang, p.product.name, p.product.nameKm)}: ${money(p.dealPriceCents ?? 0)} (${t.was} ${money(p.product.priceCents)})` : t.productDeleted}</>
                        : <>{t.banner} · {t.action[p.action]}{p.category ? `: ${localName(lang, p.category.name, p.category.nameKm)}` : ""}{p.product ? `: ${localName(lang, p.product.name, p.product.nameKm)}` : ""}</>}
                      {" · "}
                      {p.startsAt || p.endsAt ? `${p.startsAt ? dateTime(p.startsAt, lang) : t.now} → ${p.endsAt ? dateTime(p.endsAt, lang) : t.noEnd}` : t.noEndDate}
                      {" · "}{t.position} {p.sortOrder}
                    </div>
                  </div>
                  <form action={setPromotionActive.bind(null, p.id, !p.isActive)}>
                    <button type="submit" className="pf-switch pf-switch-btn" aria-pressed={p.isActive} aria-label={p.isActive ? t.turnOff(p.title) : t.turnOn(p.title)}>
                      <span className="pf-switch-track" />
                    </button>
                  </form>
                  <IconLink href={`/promotions/${p.id}`} icon="edit" label={d.products.editX(p.title)} />
                </li>
              );
            })}
          </ul>
        )}
      </Card>
    </Page>
  );
}
