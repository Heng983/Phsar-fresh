import type { Metadata } from "next";
import { ThemeToggle } from "@/components/client";
import { LangToggle } from "@/i18n/client";
import { getDict } from "@/i18n/server";
import { getTheme } from "@/lib/theme";
import { LoginForm } from "./login-form";

export const metadata: Metadata = { title: "Sign in · ចូលប្រើ" };

export default async function LoginPage({ searchParams }: { searchParams: Promise<{ from?: string; reason?: string }> }) {
  const [{ from, reason }, theme, d] = await Promise.all([searchParams, getTheme(), getDict()]);
  const t = d.login;
  const REASONS: Record<string, { tone: "warning" | "danger" | "success"; title: string }> = {
    expired: { tone: "warning", title: t.reasonExpired },
    forbidden: { tone: "danger", title: t.reasonForbidden },
    disabled: { tone: "danger", title: t.reasonDisabled },
    "signed-out": { tone: "success", title: t.reasonSignedOut },
  };
  return (
    <div className="pf-auth">
      <div className="pf-auth-art">
        <div className="pf-brand">
          <span className="pf-brand-name">Phsar Fresh</span>
          <span className="pf-brand-tag" style={{ color: "inherit", opacity: 0.8 }}>Admin</span>
        </div>
        <svg width="420" height="420" viewBox="0 0 420 420" aria-hidden>
          <circle cx="260" cy="160" r="150" style={{ fill: "var(--leaf-strong)" }} />
          <circle cx="150" cy="300" r="90" style={{ fill: "var(--citrus)" }} />
          <rect x="250" y="260" width="120" height="120" rx="16" style={{ fill: "var(--leaf-soft)" }} />
        </svg>
        <div>
          <h2>{t.heroTitle}</h2>
          <p>{t.heroBody}</p>
        </div>
      </div>
      <div className="pf-auth-panel">
        <div className="pf-auth-theme">
          <LangToggle compact />
          <ThemeToggle initial={theme} compact />
        </div>
        <LoginForm from={from} notice={reason ? REASONS[reason] : undefined} />
      </div>
    </div>
  );
}
