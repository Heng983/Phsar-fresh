"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { api, attempt } from "@/lib/api";
import type { Promotion } from "@/lib/types";
import { getDict } from "@/i18n/server";

export interface PromotionFormState { error?: string }

const text = (f: FormData, k: string) => String(f.get(k) ?? "").trim();
/** <input type="datetime-local"> has no time zone: the admin means Phnom Penh time (UTC+7). */
const pnhDate = (v: string) => (v ? new Date(`${v}:00+07:00`).toISOString() : null);

export async function savePromotion(id: string | null, _prev: PromotionFormState, form: FormData): Promise<PromotionFormState> {
  const t = (await getDict()).promotions;
  const kind = text(form, "kind") === "DEAL" ? "DEAL" : "BANNER";
  const price = text(form, "dealPrice");
  const dealPriceCents = kind === "DEAL" ? Math.round(Number(price.replace(/[$,\s]/g, "")) * 100) : null;
  if (kind === "DEAL" && (!price || !Number.isFinite(dealPriceCents))) return { error: t.errPrice };

  const action = kind === "DEAL" ? "NONE" : text(form, "action") || "NONE";
  const body = {
    kind,
    title: text(form, "title"),
    titleKm: text(form, "titleKm"),
    body: text(form, "body"),
    bodyKm: text(form, "bodyKm"),
    buttonLabel: text(form, "buttonLabel"),
    buttonLabelKm: text(form, "buttonLabelKm"),
    action,
    categoryId: action === "OPEN_CATEGORY" ? text(form, "categoryId") || null : null,
    productId: kind === "DEAL" ? text(form, "dealProductId") || null : action === "OPEN_PRODUCT" ? text(form, "productId") || null : null,
    dealPriceCents,
    startsAt: pnhDate(text(form, "startsAt")),
    endsAt: pnhDate(text(form, "endsAt")),
    isActive: form.get("isActive") === "on",
    sortOrder: Number(text(form, "sortOrder") || 0),
  };
  if (body.title.length < 2) return { error: t.errTitle };

  const saved = await attempt(() =>
    id ? api<Promotion>(`/admin/promotions/${id}`, { method: "PATCH", json: body }) : api<Promotion>("/admin/promotions", { method: "POST", json: body }),
  );
  if (saved.error || !saved.data) return { error: saved.error };

  const image = form.get("image");
  let imageError = "";
  if (kind === "BANNER" && image instanceof File && image.size > 0) {
    const up = new FormData();
    up.append("file", image, image.name);
    const res = await attempt(() => api(`/admin/promotions/${saved.data!.id}/image`, { method: "POST", body: up }));
    if (res.error) imageError = res.error;
  }
  revalidatePath("/promotions");
  redirect(`/promotions/${saved.data.id}?saved=1${imageError ? `&imageError=${encodeURIComponent(imageError)}` : ""}`);
}

export async function setPromotionActive(id: string, isActive: boolean) {
  await attempt(() => api(`/admin/promotions/${id}`, { method: "PATCH", json: { isActive } }));
  revalidatePath("/promotions");
}

export async function removePromotionImage(id: string) {
  await attempt(() => api(`/admin/promotions/${id}/image`, { method: "DELETE" }));
  revalidatePath(`/promotions/${id}`);
  redirect(`/promotions/${id}`);
}

export async function deletePromotion(id: string) {
  const res = await attempt(() => api(`/admin/promotions/${id}`, { method: "DELETE" }));
  revalidatePath("/promotions");
  redirect(res.error ? `/promotions/${id}?error=${encodeURIComponent(res.error)}` : "/promotions?deleted=1");
}
