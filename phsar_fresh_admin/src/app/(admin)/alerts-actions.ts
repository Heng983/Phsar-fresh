"use server";

import { api, attempt } from "@/lib/api";
import type { OrderAlert } from "@/lib/types";

/** Orders that need staff since [since] — polled by the bell every few seconds. */
export async function fetchOrderAlerts(since: string) {
  const res = await attempt(() => api<{ now: string; items: OrderAlert[] }>(`/admin/orders/alerts?since=${encodeURIComponent(since)}`));
  return res.data ?? null;
}
