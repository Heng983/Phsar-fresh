"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { api, attempt } from "@/lib/api";
import { getDict } from "@/i18n/server";

const back = (q: string) => redirect(`/categories?${q}`);

const photo = (form: FormData) => {
  const f = form.get("image");
  return f instanceof File && f.size > 0 ? f : null;
};

async function upload(id: string, file: File) {
  const body = new FormData();
  body.append("file", file, file.name);
  return attempt(() => api(`/admin/categories/${id}/image`, { method: "POST", body }));
}

export async function createCategory(form: FormData) {
  const t = (await getDict()).categories;
  const name = String(form.get("name") ?? "").trim();
  const nameKm = String(form.get("nameKm") ?? "").trim();
  if (name.length < 2) back(`error=${encodeURIComponent(t.errName)}`);
  const res = await attempt(() => api<{ id: string }>("/admin/categories", { method: "POST", json: { name, nameKm: nameKm || null } }));
  if (res.error || !res.data) back(`error=${encodeURIComponent(res.error ?? "Couldn't create the category")}`);
  const file = photo(form);
  if (file && res.data) {
    const up = await upload(res.data.id, file);
    if (up.error) back(`error=${encodeURIComponent(t.createdNoPhoto(name, up.error))}`);
  }
  revalidatePath("/categories");
  back(`saved=${encodeURIComponent(name)}`);
}

export async function uploadCategoryImage(id: string, name: string, form: FormData) {
  const t = (await getDict()).categories;
  const file = photo(form);
  if (!file) back(`error=${encodeURIComponent(t.errChoose)}`);
  const res = await upload(id, file!);
  revalidatePath("/categories");
  back(res.error ? `error=${encodeURIComponent(res.error)}` : `msg=${encodeURIComponent(t.newPhotoFor(name))}`);
}

export async function removeCategoryImage(id: string, name: string) {
  const t = (await getDict()).categories;
  const res = await attempt(() => api(`/admin/categories/${id}/image`, { method: "DELETE" }));
  revalidatePath("/categories");
  back(res.error ? `error=${encodeURIComponent(res.error)}` : `msg=${encodeURIComponent(t.removedPhoto(name))}`);
}

export async function updateCategory(id: string, form: FormData) {
  const name = String(form.get("name") ?? "").trim();
  const nameKm = String(form.get("nameKm") ?? "").trim();
  const res = await attempt(() => api(`/admin/categories/${id}`, { method: "PATCH", json: { name, nameKm: nameKm || null } }));
  revalidatePath("/categories");
  back(res.error ? `error=${encodeURIComponent(res.error)}` : `saved=${encodeURIComponent(name)}`);
}

export async function deleteCategory(id: string) {
  const res = await attempt(() => api(`/admin/categories/${id}`, { method: "DELETE" }));
  revalidatePath("/categories");
  back(res.error ? `error=${encodeURIComponent(res.error)}` : "deleted=1");
}
