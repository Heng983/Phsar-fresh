"use client";

import Link from "next/link";
import { usePathname } from "next/navigation";
import { useEffect, useRef, useState, type ReactNode } from "react";
import { useFormStatus } from "react-dom";
import { useDict } from "@/i18n/client";
import { Icon, type IconName } from "./icon";

const cx = (...c: (string | false | null | undefined)[]) => c.filter(Boolean).join(" ");

export type ThemeChoice = "light" | "dark" | "system";
export const THEME_COOKIE = "pf_theme";

/** Light / Dark / System. Saved in a cookie so the server renders the right theme with no flash. */
export function ThemeToggle({ initial, compact }: { initial: ThemeChoice; compact?: boolean }) {
  const [theme, setTheme] = useState<ThemeChoice>(initial);
  const t = useDict().common;
  function choose(t: ThemeChoice) {
    setTheme(t);
    const html = document.documentElement;
    if (t === "system") delete html.dataset.theme;
    else html.dataset.theme = t;
    document.cookie = `${THEME_COOKIE}=${t}; path=/; max-age=31536000; samesite=lax`;
  }
  const options: { id: ThemeChoice; label: string; icon: IconName }[] = [
    { id: "light", label: t.lightTheme, icon: "sun" },
    { id: "dark", label: t.darkTheme, icon: "moon" },
    { id: "system", label: t.systemTheme, icon: "monitor" },
  ];
  return (
    <div className={cx("pf-theme", compact && "is-compact")} role="radiogroup" aria-label={t.theme}>
      {options.map((o) => (
        <button
          key={o.id} type="button" role="radio" aria-checked={theme === o.id} title={o.label}
          className={cx("pf-theme-opt", theme === o.id && "is-active")} onClick={() => choose(o.id)}
        >
          <Icon name={o.icon} size={16} />
          {!compact && <span>{o.label}</span>}
        </button>
      ))}
    </div>
  );
}

/** A submit button that shows a pending label while its form's Server Action runs. */
export function SubmitButton({ children, pendingLabel, variant = "primary", icon, block, size, name, value, formAction }: {
  children: ReactNode; pendingLabel?: string; variant?: "primary" | "secondary" | "ghost" | "danger"; icon?: IconName;
  block?: boolean; size?: "sm" | "md"; name?: string; value?: string; formAction?: (fd: FormData) => void;
}) {
  const { pending } = useFormStatus();
  const t = useDict().common;
  return (
    <button
      type="submit" name={name} value={value} formAction={formAction} disabled={pending}
      className={cx("pf-btn", `pf-btn-${variant}`, block && "pf-btn-block", size === "sm" && "pf-btn-sm")}
    >
      {icon && <Icon name={icon} size={size === "sm" ? 16 : 18} />}
      {pending ? (pendingLabel ?? t.saving) : children}
    </button>
  );
}

/** First click arms it, second click within 4 s submits. No browser confirm() pop-up. */
export function ConfirmButton({ children, confirmLabel, icon = "trash", formAction }: {
  children: ReactNode; confirmLabel?: string; icon?: IconName; formAction: (fd: FormData) => void;
}) {
  const [armed, setArmed] = useState(false);
  const { pending } = useFormStatus();
  const t = useDict().common;
  if (!armed) {
    return (
      <button type="button" className="pf-btn pf-btn-ghost" onClick={() => { setArmed(true); setTimeout(() => setArmed(false), 4000); }}>
        <Icon name={icon} size={18} />{children}
      </button>
    );
  }
  return (
    <button type="submit" formAction={formAction} disabled={pending} className="pf-btn pf-btn-danger" formNoValidate>
      <Icon name={icon} size={18} />{pending ? t.working : (confirmLabel ?? t.clickAgain)}
    </button>
  );
}

export interface NavItem { href: string; label: string; icon: IconName; badge?: number }
export type NavEntry = NavItem | { group: string };

export function SidebarNav({ items }: { items: NavEntry[] }) {
  const path = usePathname();
  return (
    <nav className="pf-nav" aria-label="Main">
      {items.map((it, i) =>
        "group" in it ? (
          <div key={`g${i}`} className="pf-nav-group">{it.group}</div>
        ) : (
          <Link key={it.href} href={it.href} className={cx("pf-nav-item", path.startsWith(it.href) && "is-active")} aria-current={path.startsWith(it.href) ? "page" : undefined}>
            <Icon name={it.icon} size={20} />
            <span className="pf-nav-label">{it.label}</span>
            {!!it.badge && <span className="pf-nav-badge">{it.badge}</span>}
          </Link>
        ),
      )}
    </nav>
  );
}

/** Picks one photo, previews it, and posts it with the form (field "image"). */
export function ImagePicker({ current, name = "image" }: { current?: string | null; name?: string }) {
  const input = useRef<HTMLInputElement>(null);
  const [preview, setPreview] = useState<string | null>(current ?? null);
  const [over, setOver] = useState(false);
  const [error, setError] = useState<string | null>(null);
  const t = useDict().picker;

  function pick(files: FileList | null) {
    const f = files?.[0];
    if (!f) return;
    if (!/^image\/(jpeg|png|webp)$/.test(f.type)) return setError(t.badType);
    if (f.size > 5 * 1024 * 1024) return setError(t.tooBig);
    setError(null);
    setPreview(URL.createObjectURL(f));
    if (input.current && input.current.files !== files) {
      const dt = new DataTransfer();
      dt.items.add(f);
      input.current.files = dt.files;
    }
  }

  return (
    <div className="pf-upload">
      <div
        className={cx("pf-drop", over && "is-over")} role="button" tabIndex={0}
        onClick={() => input.current?.click()}
        onKeyDown={(e) => { if (e.key === "Enter" || e.key === " ") { e.preventDefault(); input.current?.click(); } }}
        onDragOver={(e) => { e.preventDefault(); setOver(true); }}
        onDragLeave={() => setOver(false)}
        onDrop={(e) => { e.preventDefault(); setOver(false); pick(e.dataTransfer.files); }}
      >
        {preview ? (
          <img src={preview} alt={t.alt} className="pf-drop-preview" />
        ) : (
          <span className="pf-drop-icon"><Icon name="upload" size={20} /></span>
        )}
        <strong>{preview ? t.replace : <>{t.drop} <span>{t.browse}</span></>}</strong>
        <span className="pf-hint">{t.hint}</span>
        <input ref={input} type="file" name={name} accept="image/jpeg,image/png,image/webp" hidden onChange={(e) => pick(e.target.files)} />
      </div>
      {error && <span className="pf-error">{error}</span>}
    </div>
  );
}

/** Revenue line with a dashed previous-period line and hover read-out. */
export function RevenueChart({ data, height = 240 }: { data: { label: string; value: number; previous?: number }[]; height?: number }) {
  const W = 640, H = height, L = 52, R = 12, T = 18, B = 28;
  const values = data.flatMap((d) => [d.value, d.previous ?? 0]);
  const max = niceMax(Math.max(0, ...values) * 1.08);
  const iw = W - L - R, ih = H - T - B;
  const x = (i: number) => L + (data.length > 1 ? (i / (data.length - 1)) * iw : iw / 2);
  const y = (v: number) => T + ih - (v / max) * ih;
  const path = (get: (d: (typeof data)[number]) => number) => data.map((d, i) => `${i ? "L" : "M"}${x(i).toFixed(1)},${y(get(d)).toFixed(1)}`).join(" ");
  const [hi, setHi] = useState(data.length - 1);
  const t = useDict().dashboard;
  const cur = data[hi];
  const ticks = [0, 0.25, 0.5, 0.75, 1].map((t) => t * max);
  const showPrev = data.some((d) => d.previous);
  const every = Math.ceil(data.length / 10);

  return (
    <div>
      <svg className="pf-chart" viewBox={`0 0 ${W} ${H}`} role="img" aria-label="Revenue chart" onMouseLeave={() => setHi(data.length - 1)}>
        {ticks.map((t, i) => (
          <g key={i}>
            <line className="pf-chart-grid" x1={L} x2={W - R} y1={y(t)} y2={y(t)} />
            <text className="pf-chart-axis" x={L - 8} y={y(t) + 4} textAnchor="end">{short(t)}</text>
          </g>
        ))}
        {data.map((d, i) => (i % every === 0 || i === data.length - 1) && (
          <text key={i} className="pf-chart-axis" x={x(i)} y={H - 8} textAnchor="middle">{d.label}</text>
        ))}
        {data.length > 1 && <path className="pf-chart-area" d={`${path((d) => d.value)} L${x(data.length - 1)},${y(0)} L${x(0)},${y(0)} Z`} />}
        {showPrev && <path className="pf-chart-compare" d={path((d) => d.previous ?? 0)} />}
        <path className="pf-chart-line" d={path((d) => d.value)} />
        {cur && (
          <g>
            <line className="pf-chart-grid" x1={x(hi)} x2={x(hi)} y1={T} y2={T + ih} strokeDasharray="3 3" />
            <circle className="pf-chart-dot" cx={x(hi)} cy={y(cur.value)} r={5} />
            <text className="pf-chart-value" x={Math.min(Math.max(x(hi), L + 34), W - R - 34)} y={Math.max(y(cur.value) - 12, 12)} textAnchor="middle">
              ${cur.value.toLocaleString("en-US", { maximumFractionDigits: 2 })}
            </text>
          </g>
        )}
        {data.map((_, i) => (
          <rect key={`h${i}`} x={x(i) - iw / data.length / 2} y={T} width={iw / data.length} height={ih} fill="transparent" onMouseEnter={() => setHi(i)} />
        ))}
      </svg>
      {showPrev && (
        <div className="pf-legend">
          <span><i />{t.thisPeriod}</span>
          <span><i className="is-compare" />{t.prevPeriod}</span>
        </div>
      )}
    </div>
  );
}

function niceMax(v: number) {
  if (v <= 0) return 100;
  const e = Math.pow(10, Math.floor(Math.log10(v))), n = v / e;
  return (n <= 1 ? 1 : n <= 2 ? 2 : n <= 2.5 ? 2.5 : n <= 5 ? 5 : 10) * e;
}
function short(v: number) {
  return v >= 1000 ? `$${(v / 1000).toFixed(v % 1000 === 0 ? 0 : 1)}k` : `$${Math.round(v)}`;
}


/* ---------- phone & tablet navigation ---------- */

const NAV_OPEN = "pf-nav-open";
const setNavOpen = (open: boolean) => {
  document.documentElement.classList.toggle(NAV_OPEN, open);
};

/**
 * Top bar shown below 1024px: menu button + brand. The sidebar becomes a
 * drawer that slides in; it closes on navigation, Escape or a tap outside.
 */
export function MobileBar({ badge, action }: { badge?: number; action?: ReactNode }) {
  const path = usePathname();
  const t = useDict().common;
  useEffect(() => {
    setNavOpen(false);
  }, [path]);
  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && setNavOpen(false);
    window.addEventListener("keydown", onKey);
    return () => {
      window.removeEventListener("keydown", onKey);
      setNavOpen(false);
    };
  }, []);
  return (
    <>
      <header className="pf-mobilebar">
        <button type="button" className="pf-btn pf-btn-ghost pf-iconbtn" aria-label={t.openMenu} onClick={() => setNavOpen(true)}>
          <Icon name="menu" size={22} />
          {!!badge && <span className="pf-mobilebar-dot" aria-hidden />}
        </button>
        <div className="pf-brand">
          <span className="pf-brand-name">Phsar Fresh</span>
          <span className="pf-brand-tag">Admin</span>
        </div>
        {action && <div className="pf-mobilebar-action">{action}</div>}
      </header>
      <div className="pf-nav-backdrop" onClick={() => setNavOpen(false)} aria-hidden />
    </>
  );
}

/** The drawer's close button (hidden on laptops, where the sidebar is always shown). */
export function NavClose() {
  const t = useDict().common;
  return (
    <button type="button" className="pf-btn pf-btn-ghost pf-iconbtn pf-nav-close" aria-label={t.closeMenu} onClick={() => setNavOpen(false)}>
      <Icon name="x" size={20} />
    </button>
  );
}

/** On narrow screens the order panel sits under the list: bring it into view when an order is picked. */
export function ScrollIntoViewOnNarrow({ target, when }: { target: string; when?: string }) {
  useEffect(() => {
    if (!when || window.innerWidth > 1100) return;
    document.getElementById(target)?.scrollIntoView({ behavior: "smooth", block: "start" });
  }, [target, when]);
  return null;
}
