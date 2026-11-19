"use server";

import { api, attempt } from "@/lib/api";
import type { OrderAlert } from "@/lib/types";

/** Orders that need staff since [since] — polled by the bell every few seconds. */
export async function fetchOrderAlerts(since: string) {
  const res = await attempt(() => api<{ now: string; items: OrderAlert[] }>(`/admin/orders/alerts?since=${encodeURIComponent(since)}`));
  return res.data ?? null;
}

/**
 * A one-minute, one-time pass for the live connection (Socket.io). The login
 * token stays in its httpOnly cookie; only this pass reaches the browser.
 */
export async function fetchLiveTicket() {
  const res = await attempt(() => api<{ ticket: string | null }>("/admin/orders/live-ticket", { method: "POST" }));
  return res.data?.ticket ?? null;
}
