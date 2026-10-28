import type { Metadata } from "next";
import Link from "next/link";
import { BarChart, RankList } from "@/components/charts";
import { RevenueChart } from "@/components/client";
import { Page } from "@/components/topbar";
import { Alert, Badge, ButtonLink, Card, EmptyState, ProductCell, StatCard, StockLevel } from "@/components/ui";
import { getDict, getLang } from "@/i18n/server";
import { api } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { money, today } from "@/lib/format";
import type { Dashboard } from "@/lib/types";

export const metadata: Metadata = { title: "Dashboard" };

export default async function DashboardPage({ searchParams }: { searchParams: Promise<{ days?: string; denied?: string }> }) {
  await requirePermission("dashboard.view");
  const [sp, lang, dict] = await Promise.all([searchParams, getLang(), getDict()]);
  const t = dict.dashboard;
  const days = sp.days === "30" ? 30 : 7;
  const d = await api<Dashboard>(`/admin/stats/dashboard?days=${days}`);
  const label = (iso: string) => {
    const dt = new Date(`${iso}T00:00:00`);
    return days === 7 ? dt.toLocaleDateString(lang === "km" ? "km-KH" : "en-GB", { weekday: "short" }) : String(dt.getDate());
  };
  const revenue = d.revenueByDay.map((r) => ({ label: label(r.date), value: r.revenueCents / 100, previous: r.previousCents / 100 }));
  const hours = d.ordersByHour.slice(6, 23).map((h) => ({ label: h.hour < 12 ? `${h.hour}a` : h.hour === 12 ? "12p" : `${h.hour - 12}p`, value: h.orders }));
  const ordersTrend = d.revenueByDay.map((r) => r.revenueCents);
  const periodLabel = t.vsPrev(days);

  return (
    <Page
      title={t.title}
      subtitle={`${today(lang)} · ${lang === "km" ? "ភ្នំពេញ" : "Phnom Penh"}`}
      actions={
        <div className="pf-actions-row">
          <ButtonLink href="/dashboard?days=7" size="sm" variant={days === 7 ? "primary" : "secondary"}>{t.days7}</ButtonLink>
          <ButtonLink href="/dashboard?days=30" size="sm" variant={days === 30 ? "primary" : "secondary"}>{t.days30}</ButtonLink>
        </div>
      }
    >
      {sp.denied && <Alert tone="warning" title={dict.common.denied} />}
      <div className="pf-grid pf-grid-4">
        <StatCard label={t.revenue} value={money(d.totals.revenueCents)} delta={d.deltas.revenue} icon="chart" hint={periodLabel} trend={ordersTrend} />
        <StatCard label={t.orders} value={String(d.totals.orders)} delta={d.deltas.orders} icon="cart" hint={periodLabel} />
        <StatCard label={t.avgBasket} value={money(d.totals.avgBasketCents)} delta={d.deltas.avgBasket} icon="box" hint={periodLabel} />
        <StatCard label={t.cancelRate} value={`${(d.totals.cancellationRate * 100).toFixed(1)}%`} delta={d.deltas.cancellationRate} invert icon="x" hint={t.pointsVs} />
      </div>

      <div className="pf-grid pf-grid-3-1">
        <Card title={t.revenue} subtitle={t.revenueSub(days)}>
          {d.totals.revenueCents === 0 && d.revenueByDay.every((r) => r.previousCents === 0) ? (
            <EmptyState icon="chart" title={t.noPaid}>{t.noPaidBody}</EmptyState>
          ) : (
            <RevenueChart data={revenue} height={260} />
          )}
        </Card>
        <Card title={t.popular} subtitle={t.popularSub(days)} actions={<Link className="pf-link" href="/products">{dict.common.viewAll}</Link>}>
          {d.topProducts.length === 0 ? (
            <EmptyState icon="box" title={t.noSales} />
          ) : (
            <RankList items={d.topProducts.map((p) => ({ name: p.name, nameKm: p.nameKm, value: p.qty, display: `${p.qty}` }))} />
          )}
        </Card>
      </div>

      <div className="pf-grid" style={{ gridTemplateColumns: "repeat(auto-fit, minmax(340px, 1fr))" }}>
        <Card title={t.trend} subtitle={t.trendSub} actions={d.pendingOrders > 0 && <Link className="pf-link" href="/orders?status=PENDING">{t.pending(d.pendingOrders)}</Link>}>
          <BarChart data={hours} height={210} label={t.trendSub} />
        </Card>
        <Card
          title={t.inventory}
          subtitle={t.inventorySub(d.lowStockThreshold)}
          flush
          actions={d.lowStock.length > 0 && <Badge tone="citrus">{t.low(d.lowStock.length)}</Badge>}
        >
          {d.lowStock.length === 0 ? (
            <EmptyState icon="check" title={t.stockGood}>{t.stockGoodBody(d.lowStockThreshold)}</EmptyState>
          ) : (
            <ul className="pf-invlist">
              {d.lowStock.map((p) => (
                <li key={p.id}>
                  <ProductCell name={p.name} nameKm={p.nameKm} image={p.imageUrl} />
                  <div style={{ width: 140 }}><StockLevel qty={p.stock} threshold={d.lowStockThreshold} unit={p.unit} /></div>
                  <ButtonLink size="sm" href={`/products/${p.id}`}>{t.restock}</ButtonLink>
                </li>
              ))}
            </ul>
          )}
        </Card>
      </div>
    </Page>
  );
}
