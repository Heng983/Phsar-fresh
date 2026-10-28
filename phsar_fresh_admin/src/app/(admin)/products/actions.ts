"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { api, attempt } from "@/lib/api";
import type { Product } from "@/lib/types";
import { getDict } from "@/i18n/server";

export interface ProductFormState {
  error?: string;
  fields?: Record<string, string>;
  fieldErrors?: Record<string, string>;
}

const text = (f: FormData, k: string) => String(f.get(k) ?? "").trim();

export async function saveProduct(id: string | null, _prev: ProductFormState, form: FormData): Promise<ProductFormState> {
  const fields = Object.fromEntries(["name", "nameKm", "description", "origin", "categoryId", "price", "stock", "unit"].map((k) => [k, text(form, k)]));
  const fieldErrors: Record<string, string> = {};
  const t = (await getDict()).productForm;

  if (fields.name.length < 2) fieldErrors.name = t.errName;
  if (!fields.categoryId) fieldErrors.categoryId = t.errCategory;
  const price = Number(fields.price.replace(/[$,\s]/g, ""));
  if (!fields.price || Number.isNaN(price) || price < 0) fieldErrors.price = t.errPrice;
  const stock = Number(fields.stock);
  if (fields.stock === "" || !Number.isInteger(stock) || stock < 0) fieldErrors.stock = t.errStock;
  if (!fields.unit) fieldErrors.unit = t.errUnit;
  if (Object.keys(fieldErrors).length) return { fields, fieldErrors, error: t.errCheck };

  const body = {
    name: fields.name,
    nameKm: fields.nameKm || null,
    description: fields.description || null,
    origin: fields.origin || null,
    categoryId: fields.categoryId,
    priceCents: Math.round(price * 100),
    stock,
    unit: fields.unit,
    isActive: form.get("isActive") === "on",
  };

  const saved = await attempt(() =>
    id ? api<Product>(`/admin/products/${id}`, { method: "PATCH", json: body }) : api<Product>("/admin/products", { method: "POST", json: body }),
  );
  if (saved.error || !saved.data) return { fields, error: saved.error };
  const productId = saved.data.id;

  const image = form.get("image");
  if (image instanceof File && image.size > 0) {
    const upload = new FormData();
    upload.append("file", image, image.name);
    const up = await attempt(() => api<Product>(`/admin/products/${productId}/image`, { method: "POST", body: upload }));
    if (up.error) {
      revalidatePath("/products");
      redirect(`/products/${productId}?saved=1&imageError=${encodeURIComponent(up.error)}`);
    }
  }

  revalidatePath("/products");
  revalidatePath("/dashboard");
  redirect(`/products/${productId}?saved=1`);
}

export interface StockFormState { error?: string; saved?: boolean; stock?: string }

/** Staff: change only the stock count. */
export async function updateStock(id: string, _prev: StockFormState, form: FormData): Promise<StockFormState> {
  const raw = String(form.get("stock") ?? "").trim();
  const stock = Number(raw);
  if (raw === "" || !Number.isInteger(stock) || stock < 0) return { error: (await getDict()).productForm.errStock, stock: raw };
  const res = await attempt(() => api(`/admin/products/${id}`, { method: "PATCH", json: { stock } }));
  if (res.error) return { error: res.error, stock: raw };
  revalidatePath("/products");
  return { saved: true, stock: raw };
}

export async function deleteProduct(id: string) {
  const res = await attempt(() => api<{ deleted: boolean; hidden: boolean; message: string }>(`/admin/products/${id}`, { method: "DELETE" }));
  revalidatePath("/products");
  if (res.data?.hidden) redirect(`/products/${id}?hidden=1`);
  if (res.error) redirect(`/products/${id}?error=${encodeURIComponent(res.error)}`);
  redirect("/products?deleted=1");
}

export async function setVisible(id: string, isActive: boolean) {
  await attempt(() => api(`/admin/products/${id}`, { method: "PATCH", json: { isActive } }));
  revalidatePath("/products");
}
