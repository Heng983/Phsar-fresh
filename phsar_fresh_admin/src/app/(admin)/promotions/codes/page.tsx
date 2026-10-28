import type { Metadata } from "next";
import Link from "next/link";
import { Page } from "@/components/topbar";
import { Alert, Badge, ButtonLink, Card, EmptyState, IconLink } from "@/components/ui";
import { api, orDefault } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict, getLang } from "@/i18n/server";
import { dateTime } from "@/lib/format";
import type { DiscountCode, Promotion } from "@/lib/types";
import { PromoTabs } from "../promo-tabs";
import { setCodeActive } from "./actions";
import { ruleText } from "./rule";

export const metadata: Metadata = { title: "Discount codes" };

const TONE = { LIVE: "leaf", SCHEDULED: "sky", ENDED: "neutral", OFF: "neutral" } as const;

export default async function CodesPage({ searchParams }: { searchParams: Promise<{ deleted?: string }> }) {
  await requirePermission("promotions.write");
  const [sp, list, promos, lang, d] = await Promise.all([
    searchParams,
    api<DiscountCode[]>("/admin/discount-codes"),
    orDefault(api<Promotion[]>("/admin/promotions"), []),
    getLang(),
    getDict(),
  ]);
  const t = d.codes;
  const live = list.filter((c) => c.status === "LIVE").length;

  return (
    <Page
      title={d.promotions.title}
      subtitle={t.subtitle(live, list.length)}
      actions={<ButtonLink href="/promotions/codes/new" variant="primary" icon="plus">{t.new}</ButtonLink>}
    >
      {sp.deleted && <Alert tone="success" title={t.deleted} />}
      <Card flush>
        <PromoTabs active="codes" carousel={promos.length} codes={list.length} />
        {list.length === 0 ? (
          <EmptyState icon="tag" title={t.none}>{t.noneBody}</EmptyState>
        ) : (
          <ul className="pf-promo-list">
            {list.map((c) => (
              <li key={c.id}>
                <Link href={`/promotions/codes/${c.id}`} className="pf-code-chip">{c.code}</Link>
                <div className="pf-promo-main">
                  <div className="pf-promo-top">
                    <Link href={`/promotions/codes/${c.id}`} className="pf-product-name" style={{ textDecoration: "none" }}>{ruleText(c, t)}</Link>
                    <Badge tone={TONE[c.status]} dot>{d.promotions.status[c.status]}</Badge>
                    {c.newCustomersOnly ? <Badge tone="citrus">{t.badgeWelcome}</Badge> : c.oncePerCustomer && <Badge tone="sky">{t.badgeOnce}</Badge>}
                  </div>
                  {(lang === "km" ? c.descriptionKm || c.description : c.description) && (
                    <div className={lang === "km" && c.descriptionKm ? "pf-product-km" : "pf-hint"}>{lang === "km" ? c.descriptionKm || c.description : c.description}</div>
                  )}
                  <div className="pf-hint">
                    {c.startsAt || c.endsAt
                      ? `${c.startsAt ? dateTime(c.startsAt, lang) : d.promotions.now} → ${c.endsAt ? dateTime(c.endsAt, lang) : d.promotions.noEnd}`
                      : t.always}
                    {" · "}{t.uses(c.uses ?? 0)}
                  </div>
                </div>
                <form action={setCodeActive.bind(null, c.id, !c.isActive)}>
                  <button type="submit" className="pf-switch pf-switch-btn" aria-pressed={c.isActive} aria-label={c.isActive ? d.promotions.turnOff(c.code) : d.promotions.turnOn(c.code)}>
                    <span className="pf-switch-track" />
                  </button>
                </form>
                <IconLink href={`/promotions/codes/${c.id}`} icon="edit" label={d.products.editX(c.code)} />
              </li>
            ))}
          </ul>
        )}
      </Card>
    </Page>
  );
}
