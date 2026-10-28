import Link from "next/link";
import type { ComponentProps, ReactNode } from "react";
import { assetUrl } from "@/lib/config";
import { getDict, getLang } from "@/i18n/server";
import { STATUS } from "@/lib/format";
import type { OrderStatus } from "@/lib/types";
import { Icon, type IconName } from "./icon";

const cx = (...c: (string | false | null | undefined)[]) => c.filter(Boolean).join(" ");

type Variant = "primary" | "secondary" | "ghost" | "danger";
interface BtnStyle { variant?: Variant; size?: "md" | "sm"; icon?: IconName; block?: boolean }
const btnClass = ({ variant = "secondary", size = "md", block }: BtnStyle, extra?: string) =>
  cx("pf-btn", `pf-btn-${variant}`, size === "sm" && "pf-btn-sm", block && "pf-btn-block", extra);

export function Button({ variant, size, icon, block, className, children, ...rest }: BtnStyle & ComponentProps<"button">) {
  return (
    <button type="button" {...rest} className={btnClass({ variant, size, block }, className)}>
      {icon && <Icon name={icon} size={size === "sm" ? 16 : 18} />}
      {children}
    </button>
  );
}

export function ButtonLink({ variant, size, icon, block, className, children, ...rest }: BtnStyle & ComponentProps<typeof Link>) {
  return (
    <Link {...rest} className={btnClass({ variant, size, block }, className)}>
      {icon && <Icon name={icon} size={size === "sm" ? 16 : 18} />}
      {children}
    </Link>
  );
}

export function IconLink({ icon, label, href, variant = "ghost" }: { icon: IconName; label: string; href: string; variant?: Variant }) {
  return (
    <Link href={href} aria-label={label} title={label} className={cx("pf-btn pf-iconbtn pf-btn-sm", `pf-btn-${variant}`)}>
      <Icon name={icon} size={16} />
    </Link>
  );
}

export function Badge({ tone = "neutral", dot, children }: { tone?: string; dot?: boolean; children: ReactNode }) {
  return <span className={cx("pf-badge", `pf-badge-${tone}`, dot && "pf-badge-dot")}>{children}</span>;
}

export async function StatusBadge({ status, lang }: { status: OrderStatus; lang?: "en" | "km" }) {
  const s = STATUS[status];
  lang ??= await getLang();
  return <Badge tone={s.tone} dot>{lang === "km" ? <span className="pf-km">{s.km}</span> : s.en}</Badge>;
}

export function Card({ title, subtitle, actions, flush, children, className }: {
  title?: ReactNode; subtitle?: ReactNode; actions?: ReactNode; flush?: boolean; children: ReactNode; className?: string;
}) {
  return (
    <section className={cx("pf-card", className)}>
      {(title || actions) && (
        <header className="pf-card-head">
          <div>
            {title && <h2 className="pf-card-title">{title}</h2>}
            {subtitle && <p className="pf-card-sub">{subtitle}</p>}
          </div>
          {actions && <div className="pf-topbar-actions">{actions}</div>}
        </header>
      )}
      {flush ? children : <div className="pf-card-body">{children}</div>}
    </section>
  );
}

export function Alert({ tone = "info", title, children }: { tone?: "info" | "success" | "warning" | "danger"; title: ReactNode; children?: ReactNode }) {
  const icon: IconName = tone === "success" ? "check" : tone === "info" ? "info" : "alert";
  return (
    <div className={`pf-alert pf-alert-${tone}`} role={tone === "danger" ? "alert" : "status"}>
      <Icon name={icon} size={18} />
      <div>
        <div className="pf-alert-title">{title}</div>
        {children && <p>{children}</p>}
      </div>
    </div>
  );
}

export async function StockLevel({ qty, threshold, unit, compact }: { qty: number; threshold: number; unit: string; compact?: boolean }) {
  const state = qty <= 0 ? "out" : qty <= threshold ? "low" : "ok";
  const label = (await getDict()).stock[state];
  const pct = Math.max(qty > 0 ? 4 : 0, Math.min(100, (qty / (threshold * 4)) * 100));
  return (
    <div className={`pf-stock is-${state}`}>
      <div className="pf-stock-top">
        <span className="pf-stock-qty">{qty} {unit}</span>
        {!compact && <span className="pf-stock-state">{label}</span>}
      </div>
      <div className="pf-bar" role="meter" aria-valuenow={qty} aria-valuemin={0} aria-valuemax={threshold * 4} aria-label={label}>
        <span style={{ width: `${pct}%` }} />
      </div>
    </div>
  );
}

export function ProductCell({ name, nameKm, image, meta }: { name: string; nameKm?: string | null; image?: string | null; meta?: ReactNode }) {
  const src = assetUrl(image);
  return (
    <div className="pf-product">
      <span className="pf-thumb">{src ? <img src={src} alt="" /> : name.charAt(0)}</span>
      <div style={{ minWidth: 0 }}>
        <div className="pf-product-name">{name}</div>
        {nameKm && <div className="pf-product-km">{nameKm}</div>}
        {meta && <div className="pf-hint">{meta}</div>}
      </div>
    </div>
  );
}

/** Status tabs as links, so the filter lives in the URL (?status=…) and works with Back. */
export function LinkTabs({ items, active }: { items: { id: string; label: string; count?: number; href: string }[]; active: string }) {
  return (
    <nav className="pf-tabs" aria-label="Filter">
      {items.map((t) => (
        <Link key={t.id} href={t.href} className={cx("pf-tab", active === t.id && "is-active")} aria-current={active === t.id ? "page" : undefined}>
          {t.label}
          {t.count !== undefined && <span className="pf-tab-count">{t.count}</span>}
        </Link>
      ))}
    </nav>
  );
}

export async function Pagination({ page, limit, total, href }: { page: number; limit: number; total: number; href: (page: number) => string }) {
  const pages = Math.max(1, Math.ceil(total / limit));
  if (pages <= 1) return null;
  const t = (await getDict()).common;
  return (
    <div className="pf-pager">
      <span className="pf-hint">
        {t.rangeOf((page - 1) * limit + 1, Math.min(page * limit, total), total)}
      </span>
      <div style={{ display: "flex", gap: 8 }}>
        {page > 1 ? <ButtonLink size="sm" href={href(page - 1)} icon="chevron-left">{t.previous}</ButtonLink> : <Button size="sm" disabled icon="chevron-left">{t.previous}</Button>}
        {page < pages ? <ButtonLink size="sm" href={href(page + 1)}>{t.next}</ButtonLink> : <Button size="sm" disabled>{t.next}</Button>}
      </div>
    </div>
  );
}

export function StatCard({ label, value, delta, invert, icon, hint = "vs previous period", trend }: {
  label: string; value: string; delta?: number; invert?: boolean; icon?: IconName; hint?: string; trend?: number[];
}) {
  const up = (delta ?? 0) >= 0;
  const good = invert ? !up : up;
  let line = "";
  if (trend && trend.length > 1) {
    const max = Math.max(...trend), min = Math.min(...trend), r = max - min || 1;
    line = trend.map((v, i) => `${((i / (trend.length - 1)) * 72).toFixed(1)},${(26 - ((v - min) / r) * 24).toFixed(1)}`).join(" L");
  }
  return (
    <div className="pf-card pf-stat">
      <div className="pf-stat-top">
        <span>{label}</span>
        {icon && <span className="pf-stat-icon"><Icon name={icon} size={18} /></span>}
      </div>
      <div className="pf-stat-value">{value}</div>
      <div className="pf-stat-foot">
        <span>
          {delta !== undefined && (
            <span className={cx("pf-delta", good ? "pf-delta-up" : "pf-delta-down")}>
              <Icon name={up ? "trend-up" : "trend-down"} size={14} strokeWidth={2.25} />
              {up ? "+" : ""}{delta}%
            </span>
          )}
          <span className="pf-hint"> {hint}</span>
        </span>
        {line && (
          <svg className="pf-spark" width="72" height="28" viewBox="0 0 72 28" aria-hidden>
            <path className="pf-spark-area" d={`M${line} L72,28 L0,28 Z`} />
            <path className="pf-spark-line" d={`M${line}`} />
          </svg>
        )}
      </div>
    </div>
  );
}

export function EmptyState({ icon, title, children }: { icon: IconName; title: string; children?: ReactNode }) {
  return (
    <div className="pf-emptystate">
      <span className="pf-drop-icon"><Icon name={icon} size={20} /></span>
      <strong>{title}</strong>
      {children && <span className="pf-hint">{children}</span>}
    </div>
  );
}
