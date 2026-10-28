import type { DiscountCode } from "@/lib/types";
import type { Dict } from "@/i18n/dict";

const money = (c: number) => `$${(c / 100).toFixed(2)}`;

/** "10% off, up to $3.00 · Orders from $10.00" */
export function ruleText(c: Pick<DiscountCode, "type" | "value" | "maxDiscountCents" | "minSubtotalCents">, t: Dict["codes"]) {
  const off = c.type === "PERCENT"
    ? c.maxDiscountCents ? t.percentCapped(c.value, money(c.maxDiscountCents)) : t.percentOff(c.value)
    : t.fixedOff(money(c.value));
  return c.minSubtotalCents > 0 ? `${off} · ${t.minOrder(money(c.minSubtotalCents))}` : `${off} · ${t.anyOrder}`;
}
