"use server";

import { revalidatePath } from "next/cache";
import { redirect } from "next/navigation";
import { api, attempt } from "@/lib/api";
import type { OrderStatus } from "@/lib/types";

/** Bound with (id, status, returnTo); a cancel form may also post a "message" for the customer. */
export async function moveOrder(id: string, status: OrderStatus, returnTo: string, form?: FormData) {
  const message = String(form?.get("message") ?? "").trim();
  const res = await attempt(() =>
    api(`/admin/orders/${id}/status`, { method: "PATCH", json: { status, ...(status === "CANCELLED" && message && { message }) } }),
  );
  revalidatePath("/orders");
  revalidatePath("/dashboard");
  const url = new URL(returnTo, "http://x");
  url.searchParams.set("id", id);
  if (res.error) url.searchParams.set("error", res.error);
  else url.searchParams.delete("error");
  redirect(`${url.pathname}${url.search}`);
}

/** A note to the customer about this order; it shows in their app's bell. */
export async function sendOrderMessage(id: string, returnTo: string, form: FormData) {
  const body = String(form.get("body") ?? "").trim();
  const kind = form.get("kind") === "PROBLEM" ? "PROBLEM" : "INFO";
  const res = await attempt(() => api(`/admin/orders/${id}/messages`, { method: "POST", json: { body, kind } }));
  revalidatePath("/orders");
  const url = new URL(returnTo, "http://x");
  url.searchParams.set("id", id);
  if (res.error) {
    url.searchParams.set("error", res.error);
    url.searchParams.delete("sent");
  } else {
    url.searchParams.delete("error");
    url.searchParams.set("sent", "1");
  }
  redirect(`${url.pathname}${url.search}`);
}
