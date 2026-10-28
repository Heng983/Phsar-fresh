"use client";

import { useRef, useState } from "react";
import { SubmitButton } from "@/components/client";
import { Icon } from "@/components/icon";
import { useDict } from "@/i18n/client";

/** Message to the customer: pick a quick message (editable) or write one. */
export function MessageComposer({ action }: { action: (form: FormData) => void }) {
  const t = useDict().orders;
  const body = useRef<HTMLTextAreaElement>(null);
  const [kind, setKind] = useState<"INFO" | "PROBLEM">("INFO");
  return (
    <form action={action} className="pf-composer">
      <div className="pf-composer-label">{t.quick}</div>
      <div className="pf-chips">
        {t.templates.map((tpl) => (
          <button
            key={tpl.label}
            type="button"
            className="pf-chip"
            onClick={() => {
              if (body.current) {
                body.current.value = tpl.body;
                body.current.focus();
              }
              setKind(tpl.kind === "PROBLEM" ? "PROBLEM" : "INFO");
            }}
          >
            {tpl.label}
          </button>
        ))}
      </div>
      <textarea ref={body} name="body" required maxLength={500} rows={3} placeholder={t.messagePh} className="pf-textarea" aria-label={t.messagePh} />
      <div className="pf-composer-foot">
        <div className="pf-theme is-compact" role="radiogroup" aria-label={t.kindLabel}>
          {(["INFO", "PROBLEM"] as const).map((k) => (
            <button key={k} type="button" role="radio" aria-checked={kind === k} className={`pf-theme-opt${kind === k ? " is-active" : ""}`} onClick={() => setKind(k)} style={{ width: "auto", padding: "0 12px" }}>
              {t.kind[k]}
            </button>
          ))}
        </div>
        <input type="hidden" name="kind" value={kind} />
        <SubmitButton icon="message" pendingLabel={t.sending}>{t.send}</SubmitButton>
      </div>
    </form>
  );
}

/** "Cancel order" asks why first; the reason goes to the customer's app. */
export function CancelWithReason({ action }: { action: (form: FormData) => void }) {
  const t = useDict().orders;
  const [open, setOpen] = useState(false);
  const reason = useRef<HTMLTextAreaElement>(null);
  if (!open) {
    return (
      <button type="button" className="pf-btn pf-btn-ghost" onClick={() => setOpen(true)}>
        <Icon name="x" size={18} />{t.action.CANCELLED}
      </button>
    );
  }
  return (
    <form action={action} className="pf-cancel-box">
      <strong>{t.cancelTitle}</strong>
      <span className="pf-hint">{t.cancelHint}</span>
      <div className="pf-chips">
        {t.cancelReasons.map((r) => (
          <button key={r} type="button" className="pf-chip" onClick={() => { if (reason.current) { reason.current.value = r; reason.current.focus(); } }}>
            {r}
          </button>
        ))}
      </div>
      <textarea ref={reason} name="message" required maxLength={500} rows={2} placeholder={t.cancelPh} className="pf-textarea" aria-label={t.cancelPh} autoFocus />
      <div className="pf-actions-row">
        <SubmitButton variant="danger" icon="x" pendingLabel={t.updating}>{t.cancelConfirm}</SubmitButton>
        <button type="button" className="pf-btn pf-btn-ghost" onClick={() => setOpen(false)}>{t.keepOrder}</button>
      </div>
    </form>
  );
}
