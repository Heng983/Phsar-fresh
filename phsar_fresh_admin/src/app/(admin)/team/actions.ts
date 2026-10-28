"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { api, attempt } from "@/lib/api";
import { getDict } from "@/i18n/server";

const back = (q: string): never => redirect(`/team?${q}`);
const text = (f: FormData, k: string) => String(f.get(k) ?? "").trim();

export async function createMember(form: FormData) {
  const body = { name: text(form, "name"), phone: text(form, "phone"), password: String(form.get("password") ?? ""), role: text(form, "role") };
  const t = (await getDict()).team;
  if (body.name.length < 2) back(`error=${encodeURIComponent(t.errName)}`);
  if (body.password.length < 8) back(`error=${encodeURIComponent(t.errPassword)}`);
  const res = await attempt(() => api("/admin/team", { method: "POST", json: body }));
  revalidatePath("/team");
  back(res.error ? `error=${encodeURIComponent(res.error)}` : `saved=${encodeURIComponent(t.added(body.name))}`);
}

export async function updateMember(id: string, name: string, form: FormData) {
  const password = String(form.get("password") ?? "");
  const body: Record<string, unknown> = { role: text(form, "role") };
  if (password) body.password = password;
  const res = await attempt(() => api(`/admin/team/${id}`, { method: "PATCH", json: body }));
  revalidatePath("/team");
  back(res.error ? `error=${encodeURIComponent(res.error)}` : `saved=${encodeURIComponent((await getDict()).team.savedX(name))}`);
}

export async function setDisabled(id: string, name: string, disabled: boolean) {
  const res = await attempt(() => api(`/admin/team/${id}`, { method: "PATCH", json: { disabled } }));
  revalidatePath("/team");
  back(res.error ? `error=${encodeURIComponent(res.error)}` : `saved=${encodeURIComponent(disabled ? (await getDict()).team.disabledX(name) : (await getDict()).team.enabledX(name))}`);
}

export interface MatrixState { error?: string; saved?: boolean }

/** Saves the ticked permissions for MANAGER, STAFF and DRIVER. */
export async function savePermissions(_prev: MatrixState, form: FormData): Promise<MatrixState> {
  for (const role of ["MANAGER", "STAFF", "DRIVER"]) {
    const permissions = form.getAll(role).map(String);
    const res = await attempt(() => api(`/admin/permissions/${role}`, { method: "PUT", json: { permissions } }));
    if (res.error) return { error: res.error };
  }
  revalidatePath("/", "layout");
  return { saved: true };
}
