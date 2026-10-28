"use server";

import { cookies } from "next/headers";
import { redirect } from "next/navigation";
import { API_URL } from "@/lib/config";
import { isStaffRole } from "@/lib/permissions";
import { getDict } from "@/i18n/server";
import { ACCESS_COOKIE, REFRESH_COOKIE, REFRESH_MAX_AGE, cookieOptions, secondsLeft, type TokenPair } from "@/lib/session";

export interface LoginState { error?: string; phone?: string }

export async function login(_prev: LoginState, form: FormData): Promise<LoginState> {
  const phone = String(form.get("phone") ?? "").trim();
  const password = String(form.get("password") ?? "");
  const remember = form.get("remember") === "on";
  const from = String(form.get("from") ?? "");
  const t = (await getDict()).login;
  if (!phone || !password) return { error: t.enterBoth, phone };

  let res: Response;
  try {
    res = await fetch(`${API_URL}/auth/login`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ phone, password }),
      cache: "no-store",
    });
  } catch {
    return { error: t.unreachable(API_URL), phone };
  }

  if (res.status === 429) return { error: t.tooMany, phone };
  if (!res.ok) {
    const body = await res.json().catch(() => ({}));
    const m = Array.isArray(body.message) ? body.message.join(". ") : body.message;
    // the backend's own wording for 401 → our translated one
    return { error: res.status === 401 || !m ? t.wrong : m, phone };
  }

  const pair = (await res.json()) as TokenPair;
  if (!isStaffRole(pair.user.role)) {
    // Don't leave a usable session behind for a non-admin account.
    await fetch(`${API_URL}/auth/logout`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken: pair.refreshToken }),
    }).catch(() => undefined);
    return { error: t.notAdmin, phone };
  }

  const jar = await cookies();
  jar.set(ACCESS_COOKIE, pair.accessToken, { ...cookieOptions, maxAge: secondsLeft(pair.accessToken) });
  // Without "keep me signed in" the refresh cookie ends with the browser session.
  jar.set(REFRESH_COOKIE, pair.refreshToken, { ...cookieOptions, ...(remember && { maxAge: REFRESH_MAX_AGE }) });

  redirect(from.startsWith("/") && !from.startsWith("//") ? from : "/");
}

export async function logout() {
  const jar = await cookies();
  const refreshToken = jar.get(REFRESH_COOKIE)?.value;
  if (refreshToken) {
    await fetch(`${API_URL}/auth/logout`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken }),
    }).catch(() => undefined);
  }
  jar.delete(ACCESS_COOKIE);
  jar.delete(REFRESH_COOKIE);
  redirect("/login?reason=signed-out");
}
