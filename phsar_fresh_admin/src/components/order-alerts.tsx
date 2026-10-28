"use client";

import Link from "next/link";
import { useRouter } from "next/navigation";
import { createContext, useCallback, useContext, useEffect, useRef, useState, type ReactNode } from "react";
import { fetchOrderAlerts } from "@/app/(admin)/alerts-actions";
import { useDict, useLang } from "@/i18n/client";
import { money } from "@/lib/format";
import type { OrderAlert } from "@/lib/types";
import { Icon } from "./icon";

const POLL_MS = 10_000;
const TOAST_MS = 12_000;
const KEEP = 20;
const SINCE_KEY = "pf_alerts_since";
const UNREAD_KEY = "pf_alerts_unread";
const SOUND_KEY = "pf_alerts_sound";

interface AlertsState {
  unread: OrderAlert[];
  open: boolean;
  setOpen: (open: boolean) => void;
  markAllRead: () => void;
  /** One order was opened: drop it from the bell's count. */
  markRead: (id: string) => void;
  muted: boolean;
  toggleMute: () => void;
}

const AlertsContext = createContext<AlertsState | null>(null);

const read = <T,>(key: string, fallback: T): T => {
  try {
    const v = localStorage.getItem(key);
    return v == null ? fallback : (JSON.parse(v) as T);
  } catch {
    return fallback;
  }
};
const write = (key: string, value: unknown) => {
  try {
    localStorage.setItem(key, JSON.stringify(value));
  } catch {
    /* private mode: alerts still work for this visit */
  }
};

/** A short two-note "ding", made in the browser (no sound file to load). */
function ding(ctx: AudioContext | null) {
  if (!ctx || ctx.state !== "running") return;
  const now = ctx.currentTime;
  [880, 1320].forEach((freq, i) => {
    const osc = ctx.createOscillator();
    const gain = ctx.createGain();
    osc.type = "sine";
    osc.frequency.value = freq;
    const start = now + i * 0.16;
    gain.gain.setValueAtTime(0.0001, start);
    gain.gain.exponentialRampToValueAtTime(0.25, start + 0.02);
    gain.gain.exponentialRampToValueAtTime(0.0001, start + 0.45);
    osc.connect(gain).connect(ctx.destination);
    osc.start(start);
    osc.stop(start + 0.5);
  });
}

/**
 * Watches for new orders while the admin panel is open: every 10 s it asks
 * the API what came in, then rings, shows a pop-up and adds it to the bell.
 * Cash orders count when placed, ABA Pay orders once they're paid.
 */
export function OrderAlertsProvider({ enabled, children }: { enabled: boolean; children: ReactNode }) {
  const router = useRouter();
  const [unread, setUnread] = useState<OrderAlert[]>([]);
  const [toasts, setToasts] = useState<OrderAlert[]>([]);
  const [open, setOpen] = useState(false);
  const [muted, setMuted] = useState(false);
  const audio = useRef<AudioContext | null>(null);
  const mutedRef = useRef(false);
  /** Every alert already shown, so a slow poll never rings twice. */
  const seen = useRef(new Set<string>());

  useEffect(() => {
    const saved = read<OrderAlert[]>(UNREAD_KEY, []);
    saved.forEach((a) => seen.current.add(a.id));
    setUnread(saved);
    const m = read<string>(SOUND_KEY, "on") === "off";
    setMuted(m);
    mutedRef.current = m;
  }, []);

  // Browsers only allow sound after the user has clicked or typed once.
  useEffect(() => {
    const unlock = () => {
      try {
        audio.current ??= new AudioContext();
        void audio.current.resume();
      } catch {
        /* no Web Audio: silent alerts */
      }
    };
    window.addEventListener("pointerdown", unlock);
    window.addEventListener("keydown", unlock);
    return () => {
      window.removeEventListener("pointerdown", unlock);
      window.removeEventListener("keydown", unlock);
    };
  }, []);

  useEffect(() => {
    if (!enabled) return;
    let stopped = false;
    // First visit: only orders from now on, not the whole history.
    let since = read<string | null>(SINCE_KEY, null) ?? new Date().toISOString();
    const tick = async () => {
      const res = await fetchOrderAlerts(since).catch(() => null);
      if (stopped || !res) return;
      since = res.now;
      write(SINCE_KEY, since);
      if (res.items.length === 0) return;
      const fresh = res.items.filter((a) => !seen.current.has(a.id));
      if (fresh.length === 0) return;
      fresh.forEach((a) => seen.current.add(a.id));
      setUnread((prev) => {
        const next = [...fresh, ...prev].slice(0, KEEP);
        write(UNREAD_KEY, next);
        return next;
      });
      setToasts((t) => [...fresh, ...t].slice(0, 3));
      if (!mutedRef.current) ding(audio.current);
      router.refresh(); // order list and sidebar counts
    };
    void tick();
    const id = window.setInterval(tick, POLL_MS);
    return () => {
      stopped = true;
      window.clearInterval(id);
    };
  }, [enabled, router]);

  // Each pop-up hides on its own after a while.
  useEffect(() => {
    if (toasts.length === 0) return;
    const id = window.setTimeout(() => setToasts((t) => t.slice(0, -1)), TOAST_MS);
    return () => window.clearTimeout(id);
  }, [toasts]);

  const markRead = useCallback((id: string) => {
    setUnread((prev) => {
      const next = prev.filter((a) => a.id !== id);
      write(UNREAD_KEY, next);
      return next;
    });
    setToasts((t) => t.filter((a) => a.id !== id));
  }, []);
  const markAllRead = useCallback(() => {
    setUnread([]);
    write(UNREAD_KEY, []);
  }, []);
  const toggleMute = useCallback(() => {
    setMuted((m) => {
      mutedRef.current = !m;
      write(SOUND_KEY, m ? "on" : "off");
      return !m;
    });
  }, []);

  return (
    <AlertsContext.Provider value={{ unread, open, setOpen, markAllRead, markRead, muted, toggleMute }}>
      {children}
      {enabled && open && <AlertsPanel />}
      {enabled && toasts.length > 0 && (
        <div className="pf-toasts" role="status" aria-live="polite">
          {toasts.map((a) => (
            <AlertToast key={a.id} alert={a} onClose={() => setToasts((t) => t.filter((x) => x.id !== a.id))} />
          ))}
        </div>
      )}
    </AlertsContext.Provider>
  );
}

function useAlerts() {
  return useContext(AlertsContext);
}

/** Bell with the number of unread new orders; opens the list. */
export function AlertBell() {
  const state = useAlerts();
  const t = useDict().alerts;
  if (!state) return null;
  const n = state.unread.length;
  return (
    <button
      type="button"
      className={`pf-bell${n > 0 ? " has-unread" : ""}`}
      aria-label={n ? `${t.bell} (${n})` : t.bell}
      title={t.title}
      aria-expanded={state.open}
      data-alert-bell
      onClick={(e) => {
        e.stopPropagation();
        state.setOpen(!state.open);
      }}
    >
      <Icon name="bell" size={20} strokeWidth={2} />
      {n > 0 && <span className="pf-bell-count" aria-hidden>{n > 9 ? "9+" : n}</span>}
    </button>
  );
}

function line(a: OrderAlert, t: ReturnType<typeof useDict>) {
  const pay = a.paymentMethod === "ABA_PAY" ? t.alerts.paidAba : t.orders.paymentMethod[a.paymentMethod];
  return [money(a.totalCents), pay, a.customer].filter(Boolean).join(" · ");
}

function since(at: string, lang: string) {
  const mins = Math.max(0, Math.round((Date.now() - Date.parse(at)) / 60_000));
  const rtf = new Intl.RelativeTimeFormat(lang === "km" ? "km" : "en", { numeric: "auto" });
  return mins < 60 ? rtf.format(-mins, "minute") : rtf.format(-Math.round(mins / 60), "hour");
}

function AlertsPanel() {
  const state = useAlerts()!;
  const d = useDict();
  const lang = useLang();
  const t = d.alerts;
  const panel = useRef<HTMLDivElement>(null);

  useEffect(() => {
    const onKey = (e: KeyboardEvent) => e.key === "Escape" && state.setOpen(false);
    const onClick = (e: MouseEvent) => {
      const target = e.target as Element;
      if (!panel.current?.contains(target) && !target.closest("[data-alert-bell]")) state.setOpen(false);
    };
    window.addEventListener("keydown", onKey);
    window.addEventListener("click", onClick);
    return () => {
      window.removeEventListener("keydown", onKey);
      window.removeEventListener("click", onClick);
    };
  }, [state]);

  return (
    <div ref={panel} className="pf-alerts-panel" role="dialog" aria-label={t.title}>
      <div className="pf-alerts-head">
        <strong>{t.title}</strong>
        <button type="button" className="pf-btn pf-btn-ghost pf-btn-sm" onClick={state.toggleMute} aria-pressed={!state.muted}>
          <Icon name={state.muted ? "volume-off" : "volume"} size={16} />
          {state.muted ? t.soundOff : t.soundOn}
        </button>
      </div>
      {state.unread.length === 0 ? (
        <div className="pf-alerts-empty">
          <Icon name="bell" size={22} />
          <strong>{t.none}</strong>
          <span className="pf-hint">{t.noneBody}</span>
        </div>
      ) : (
        <ul className="pf-alerts-list">
          {state.unread.map((a) => (
            <li key={a.id}>
              <Link href={`/orders?id=${a.id}`} onClick={() => { state.markRead(a.id); state.setOpen(false); }}>
                <span className="pf-alerts-dot" aria-hidden />
                <span>
                  <strong>{t.newOrder(a.code)}</strong>
                  <span className="pf-hint">{line(a, d)}</span>
                </span>
                <span className="pf-hint pf-nowrap">{since(a.at, lang)}</span>
              </Link>
            </li>
          ))}
        </ul>
      )}
      <div className="pf-alerts-foot">
        <Link href="/orders" className="pf-btn pf-btn-secondary pf-btn-sm" onClick={() => state.setOpen(false)}>{t.viewAll}</Link>
        {state.unread.length > 0 && (
          <button type="button" className="pf-btn pf-btn-ghost pf-btn-sm" onClick={state.markAllRead}>
            <Icon name="check" size={16} />{t.markRead}
          </button>
        )}
      </div>
    </div>
  );
}

function AlertToast({ alert, onClose }: { alert: OrderAlert; onClose: () => void }) {
  const state = useAlerts();
  const d = useDict();
  const t = d.alerts;
  return (
    <div className="pf-toast">
      <span className="pf-toast-icon"><Icon name="cart" size={18} /></span>
      <div className="pf-toast-body">
        <strong>{t.newOrder(alert.code)}</strong>
        <span className="pf-hint">{line(alert, d)}</span>
        <Link href={`/orders?id=${alert.id}`} className="pf-link" onClick={() => { state?.markRead(alert.id); onClose(); }}>{t.view}</Link>
      </div>
      <button type="button" className="pf-btn pf-btn-ghost pf-iconbtn pf-btn-sm" aria-label={t.dismiss} onClick={onClose}>
        <Icon name="x" size={16} />
      </button>
    </div>
  );
}
