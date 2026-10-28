"use client";

import { useActionState } from "react";
import { Icon } from "@/components/icon";
import { SubmitButton } from "@/components/client";
import { Checkbox, TextField } from "@/components/fields";
import { useDict } from "@/i18n/client";
import { login, type LoginState } from "../auth-actions";
import { PasswordField } from "@/components/password-field";

export function LoginForm({ from, notice }: { from?: string; notice?: { tone: "warning" | "danger" | "success"; title: string } }) {
  const [state, action] = useActionState<LoginState, FormData>(login, {});
  const t = useDict().login;
  return (
    <form className="pf-auth-card" action={action}>
      <div>
        <h1>{t.title}</h1>
        <p className="pf-sub">{t.adminOnly}</p>
      </div>
      {state.error ? (
        <div className="pf-alert pf-alert-danger" role="alert"><Icon name="alert" size={18} /><div className="pf-alert-title">{state.error}</div></div>
      ) : notice && (
        <div className={`pf-alert pf-alert-${notice.tone}`} role="status"><Icon name={notice.tone === "success" ? "check" : "alert"} size={18} /><div className="pf-alert-title">{notice.title}</div></div>
      )}
      <input type="hidden" name="from" value={from ?? ""} />
      <TextField label={t.phone} name="phone" prefix="+855" placeholder="12 345 678" inputMode="tel" autoComplete="username" required defaultValue={state.phone} key={state.phone} />
      <PasswordField label={t.password} name="password" icon="lock" autoComplete="current-password" required />
      <div className="pf-auth-row">
        <Checkbox name="remember" label={t.keepSignedIn} defaultChecked />
      </div>
      <SubmitButton block pendingLabel={t.signingIn}>{t.submit}</SubmitButton>
      <div className="pf-session"><Icon name="shield" size={16} />{t.secure}</div>
    </form>
  );
}
