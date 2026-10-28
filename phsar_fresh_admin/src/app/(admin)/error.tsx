"use client";

import { Icon } from "@/components/icon";
import { useDict } from "@/i18n/client";

export default function AdminError({ error, reset }: { error: Error & { digest?: string }; reset: () => void }) {
  const t = useDict().common;
  return (
    <main className="pf-shell-content">
      <div className="pf-card">
        <div className="pf-emptystate">
          <span className="pf-drop-icon"><Icon name="alert" size={20} /></span>
          <strong>{t.loadError}</strong>
          <span className="pf-hint">{error.message}</span>
          <button className="pf-btn pf-btn-secondary" onClick={reset}><Icon name="refresh" size={18} />{t.tryAgain}</button>
        </div>
      </div>
    </main>
  );
}
