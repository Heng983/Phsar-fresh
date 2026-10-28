import type { OrderStatus } from "./types";

export const RIEL_PER_USD = 4100;

export const money = (cents: number) =>
  `$${(cents / 100).toLocaleString("en-US", { minimumFractionDigits: 2, maximumFractionDigits: 2 })}`;

export const riel = (cents: number) => `${Math.round((cents / 100) * RIEL_PER_USD).toLocaleString("en-US")}៛`;

/** "PF-3F9A2C" — a short, readable id from the order's uuid. */
export const orderCode = (id: string) => `PF-${id.slice(0, 6).toUpperCase()}`;

/** The Khmer name when the admin panel is in Khmer and one is set, else the English one. */
export const localName = (lang: "en" | "km", name: string, nameKm?: string | null) =>
  lang === "km" && nameKm?.trim() ? nameKm : name;

const TZ = "Asia/Phnom_Penh";
const locale = (lang: "en" | "km") => (lang === "km" ? "km-KH" : "en-GB");
export const dateTime = (iso: string, lang: "en" | "km" = "en") =>
  new Date(iso).toLocaleString(locale(lang), { timeZone: TZ, day: "numeric", month: "short", hour: "2-digit", minute: "2-digit" });
export const today = (lang: "en" | "km" = "en") =>
  new Date().toLocaleDateString(locale(lang), { timeZone: TZ, weekday: "long", day: "numeric", month: "long" });

export const STATUS: Record<OrderStatus, { en: string; km: string; tone: "citrus" | "sky" | "neutral" | "leaf" | "solid" | "berry" }> = {
  PENDING: { en: "Pending", km: "រង់ចាំ", tone: "citrus" },
  PAID: { en: "Paid", km: "បានបង់ប្រាក់", tone: "sky" },
  PREPARING: { en: "Preparing", km: "កំពុងរៀបចំ", tone: "neutral" },
  DELIVERING: { en: "Out for delivery", km: "កំពុងដឹកជញ្ជូន", tone: "leaf" },
  DELIVERED: { en: "Delivered", km: "បានដឹកដល់", tone: "solid" },
  CANCELLED: { en: "Cancelled", km: "បានបោះបង់", tone: "berry" },
};
export const STATUS_ORDER: OrderStatus[] = ["PENDING", "PAID", "PREPARING", "DELIVERING", "DELIVERED", "CANCELLED"];

/** Shown on the "move to" button for each next status. */
export const STATUS_ACTION: Record<OrderStatus, string> = {
  PENDING: "Mark as pending",
  PAID: "Mark as paid",
  PREPARING: "Start preparing",
  DELIVERING: "Send for delivery",
  DELIVERED: "Mark as delivered",
  CANCELLED: "Cancel order",
};
