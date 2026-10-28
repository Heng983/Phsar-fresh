"use client";

import { useActionState, useState } from "react";
import { ConfirmButton, SubmitButton } from "@/components/client";
import { TextField } from "@/components/fields";
import { Icon } from "@/components/icon";
import { ScheduleFields } from "@/components/schedule-fields";
import type { DiscountCode, DiscountType } from "@/lib/types";
import { useDict } from "@/i18n/client";
import { deleteCode, saveCode, type CodeFormState } from "./actions";
import { ruleText } from "./rule";

/** ISO → value for <input type="datetime-local"> in Phnom Penh time. */
const toLocal = (iso: string | null) => (iso ? new Date(new Date(iso).getTime() + 7 * 3600e3).toISOString().slice(0, 16) : "");
const dollars = (c: number | null | undefined) => (c ? (c / 100).toFixed(2) : "");
const money = (c: number) => `$${(c / 100).toFixed(2)}`;
const toCents = (v: string) => Math.round(Number(v.replace(/[$,\s]/g, "")) * 100) || 0;

export function CodeForm({ code }: { code?: DiscountCode }) {
  const [state, action] = useActionState<CodeFormState, FormData>(saveCode.bind(null, code?.id ?? null), {});
  const t = useDict().codes;
  const d = useDict();
  const [type, setType] = useState<DiscountType>(code?.type ?? "FIXED");
  const [newOnly, setNewOnly] = useState(code?.newCustomersOnly ?? false);
  const [once, setOnce] = useState(code?.oncePerCustomer ?? false);
  const [f, setF] = useState({
    code: code?.code ?? "",
    value: code ? (code.type === "PERCENT" ? String(code.value) : dollars(code.value)) : "",
    maxDiscount: dollars(code?.maxDiscountCents),
    minSubtotal: dollars(code?.minSubtotalCents),
    trySubtotal: "20.00",
  });
  const set = (k: keyof typeof f) => (e: { target: { value: string } }) => setF((s) => ({ ...s, [k]: e.target.value }));

  // Live example: what a customer would save on a cart of this size.
  const rule = {
    type,
    value: type === "PERCENT" ? Math.round(Number(f.value) || 0) : toCents(f.value),
    maxDiscountCents: type === "PERCENT" && f.maxDiscount ? toCents(f.maxDiscount) : null,
    minSubtotalCents: toCents(f.minSubtotal),
  };
  const sub = toCents(f.trySubtotal);
  let off = type === "PERCENT" ? Math.floor((sub * rule.value) / 100) : rule.value;
  if (rule.maxDiscountCents) off = Math.min(off, rule.maxDiscountCents);
  off = Math.max(0, Math.min(off, sub));
  const tooSmall = sub < rule.minSubtotalCents;

  return (
    <form action={action} className="pf-grid pf-grid-3-1" style={{ alignItems: "start" }}>
      <input type="hidden" name="type" value={type} />
      <input type="hidden" name="newCustomersOnly" value={newOnly ? "1" : ""} />
      <div className="pf-col">
        {state.error && <div className="pf-alert pf-alert-danger" role="alert"><Icon name="alert" size={18} /><div className="pf-alert-title">{state.error}</div></div>}

        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.codeCard}</h2><p className="pf-card-sub">{t.codeCardSub}</p></div></header>
          <div className="pf-card-body pf-form-grid">
            <TextField label={t.codeField} name="code" required maxLength={24} value={f.code} autoCapitalize="characters" spellCheck={false}
              onChange={(e) => setF((s) => ({ ...s, code: e.target.value.toUpperCase().replace(/\s+/g, "") }))}
              placeholder="KHMERFRESH" hint={t.codeHint} className="pf-code-input" />
            <div className="pf-bilingual">
              <TextField label={t.descField} lang="EN" name="description" maxLength={120} defaultValue={code?.description ?? ""} placeholder="$1.50 off your order" />
              <TextField label={t.descField} lang="ខ្មែរ" name="descriptionKm" className="pf-km" maxLength={120} defaultValue={code?.descriptionKm ?? ""} />
            </div>
          </div>
        </section>

        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.discountCard}</h2><p className="pf-card-sub">{t.discountCardSub}</p></div></header>
          <div className="pf-card-body pf-form-grid">
            <div className="pf-kind" role="radiogroup" aria-label={t.discountCard}>
              {([["FIXED", "tag", t.typeFixed, t.typeFixedHint], ["PERCENT", "sparkles", t.typePercent, t.typePercentHint]] as const).map(([k, icon, label, hint]) => (
                <button key={k} type="button" role="radio" aria-checked={type === k} className={`pf-kind-opt${type === k ? " is-active" : ""}`}
                  onClick={() => { if (type !== k) { setType(k); setF((s) => ({ ...s, value: "" })); } }}>
                  <Icon name={icon} size={20} /><strong>{label}</strong><span>{hint}</span>
                </button>
              ))}
            </div>
            <div className="pf-two">
              {type === "PERCENT" ? (
                <TextField label={t.percentField} name="value" suffix="%" inputMode="numeric" required value={f.value} onChange={set("value")} placeholder="10" />
              ) : (
                <TextField label={t.amountField} name="value" prefix="$" inputMode="decimal" required value={f.value} onChange={set("value")} placeholder="1.50" />
              )}
              {type === "PERCENT" && (
                <TextField label={t.capField} name="maxDiscount" prefix="$" inputMode="decimal" value={f.maxDiscount} onChange={set("maxDiscount")} placeholder={t.noCap} hint={t.capHint} />
              )}
            </div>
            <TextField label={t.minField} name="minSubtotal" prefix="$" inputMode="decimal" value={f.minSubtotal} onChange={set("minSubtotal")} placeholder="0.00" hint={t.minHint} />
          </div>
        </section>

        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.whoCard}</h2><p className="pf-card-sub">{t.whoCardSub}</p></div></header>
          <div className="pf-card-body pf-form-grid">
            <div className="pf-kind" role="radiogroup" aria-label={t.whoCard}>
              {([[false, "users", t.whoEveryone, t.whoEveryoneHint], [true, "sparkles", t.whoNew, t.whoNewHint]] as const).map(([v, icon, label, hint]) => (
                <button key={String(v)} type="button" role="radio" aria-checked={newOnly === v} className={`pf-kind-opt${newOnly === v ? " is-active" : ""}`} onClick={() => setNewOnly(v)}>
                  <Icon name={icon} size={20} /><strong>{label}</strong><span>{hint}</span>
                </button>
              ))}
            </div>
            <label className="pf-switch" style={newOnly ? { opacity: 0.7 } : undefined}>
              <input type="checkbox" role="switch" name="oncePerCustomer" checked={newOnly || once} disabled={newOnly} onChange={(e) => setOnce(e.target.checked)} />
              <span className="pf-switch-track" /> {t.once}
            </label>
            <p className="pf-hint" style={{ margin: 0 }}>{newOnly ? `${t.onceForced} ${t.tryNewNote}` : t.onceHint}</p>
          </div>
        </section>
      </div>

      <div className="pf-col" style={{ position: "sticky", top: 24 }}>
        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.tryCard}</h2><p className="pf-card-sub">{t.tryCardSub}</p></div></header>
          <div className="pf-card-body pf-form-grid">
            <div className="pf-code-ticket">
              <span className="pf-code-chip">{f.code || "CODE"}</span>
              <span className="pf-hint">{rule.value > 0 ? ruleText(rule, t) : t.setValue}</span>
              {(newOnly || once) && <span className="pf-hint">{newOnly ? t.badgeWelcome : t.badgeOnce}</span>}
            </div>
            <TextField label={t.cartSubtotal} name="_try" prefix="$" inputMode="decimal" value={f.trySubtotal} onChange={set("trySubtotal")} />
            <dl className="pf-code-sum" data-testid="code-try">
              <div><dt>{t.cartSubtotal}</dt><dd className="pf-num">{money(sub)}</dd></div>
              {tooSmall ? (
                <div className="is-warn"><dt>{t.notYet}</dt><dd>{t.addMore(money(rule.minSubtotalCents - sub))}</dd></div>
              ) : (
                <div className="is-off"><dt>{t.discount}</dt><dd className="pf-num">−{money(off)}</dd></div>
              )}
              <div className="is-total"><dt>{t.afterDiscount}</dt><dd className="pf-num">{money(sub - (tooSmall ? 0 : off))}</dd></div>
            </dl>
          </div>
        </section>

        <section className="pf-card">
          <header className="pf-card-head"><div><h2 className="pf-card-title">{t.schedule}</h2><p className="pf-card-sub">{t.scheduleSub}</p></div></header>
          <div className="pf-card-body pf-form-grid">
            <ScheduleFields startsAt={toLocal(code?.startsAt ?? null)} endsAt={toLocal(code?.endsAt ?? null)} />
            <label className="pf-switch">
              <input type="checkbox" role="switch" name="isActive" defaultChecked={code?.isActive ?? true} />
              <span className="pf-switch-track" /> {t.active}
            </label>
          </div>
        </section>

        <div className="pf-actions-row">
          <SubmitButton icon="check">{code ? d.common.saveChanges : t.create}</SubmitButton>
          {code && <ConfirmButton formAction={deleteCode.bind(null, code.id)} confirmLabel={d.common.deleteConfirm}>{d.common.delete}</ConfirmButton>}
        </div>
      </div>
    </form>
  );
}
