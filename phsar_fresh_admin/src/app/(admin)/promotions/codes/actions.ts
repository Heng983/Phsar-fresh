"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { api, attempt } from "@/lib/api";
import type { DiscountCode } from "@/lib/types";
import { getDict } from "@/i18n/server";

export interface CodeFormState { error?: string }

const text = (f: FormData, k: string) => String(f.get(k) ?? "").trim();
const cents = (v: string) => (v ? Math.round(Number(v.replace(/[$,\s]/g, "")) * 100) : null);
/** <input type="datetime-local"> has no time zone: the admin means Phnom Penh time (UTC+7). */
const pnhDate = (v: string) => (v ? new Date(`${v}:00+07:00`).toISOString() : null);

export async function saveCode(id: string | null, _prev: CodeFormState, form: FormData): Promise<CodeFormState> {
  const t = (await getDict()).codes;
  const code = text(form, "code").toUpperCase().replace(/\s+/g, "");
  if (!/^[A-Z0-9_-]{3,24}$/.test(code)) return { error: t.errCode };

  const type = text(form, "type") === "PERCENT" ? "PERCENT" : "FIXED";
  const raw = text(form, "value");
  const value = type === "PERCENT" ? Math.round(Number(raw)) : cents(raw);
  if (!raw || !Number.isFinite(value) || !value || value < 1) return { error: t.errValue };
  if (type === "PERCENT" && value > 100) return { error: t.errPercent };

  const max = type === "PERCENT" ? cents(text(form, "maxDiscount")) : null;
  const min = cents(text(form, "minSubtotal")) ?? 0;
  if ((max !== null && !Number.isFinite(max)) || !Number.isFinite(min)) return { error: t.errMoney };

  const startsAt = pnhDate(text(form, "startsAt"));
  const endsAt = pnhDate(text(form, "endsAt"));
  if (startsAt && endsAt && endsAt <= startsAt) return { error: t.errDates };

  const body = {
    code,
    description: text(form, "description"),
    descriptionKm: text(form, "descriptionKm"),
    type,
    value,
    maxDiscountCents: max,
    minSubtotalCents: min,
    startsAt,
    endsAt,
    isActive: form.get("isActive") === "on",
    newCustomersOnly: text(form, "newCustomersOnly") === "1",
    oncePerCustomer: text(form, "newCustomersOnly") === "1" || form.get("oncePerCustomer") === "on",
  };
  const saved = await attempt(() =>
    id ? api<DiscountCode>(`/admin/discount-codes/${id}`, { method: "PATCH", json: body }) : api<DiscountCode>("/admin/discount-codes", { method: "POST", json: body }),
  );
  if (saved.error || !saved.data) return { error: saved.error };
  revalidatePath("/promotions/codes");
  redirect(`/promotions/codes/${saved.data.id}?saved=1`);
}

export async function setCodeActive(id: string, isActive: boolean) {
  await attempt(() => api(`/admin/discount-codes/${id}`, { method: "PATCH", json: { isActive } }));
  revalidatePath("/promotions/codes");
}

export async function deleteCode(id: string) {
  const res = await attempt(() => api(`/admin/discount-codes/${id}`, { method: "DELETE" }));
  revalidatePath("/promotions/codes");
  redirect(res.error ? `/promotions/codes/${id}?error=${encodeURIComponent(res.error)}` : "/promotions/codes?deleted=1");
}
