import { LinkTabs } from "@/components/ui";
import { getDict } from "@/i18n/server";

/** Carousel | Discount codes — the two halves of Promotions. */
export async function PromoTabs({ active, carousel, codes }: { active: "carousel" | "codes"; carousel?: number; codes?: number }) {
  const t = (await getDict()).codes;
  return (
    <LinkTabs
      active={active}
      items={[
        { id: "carousel", label: t.tabCarousel, count: carousel, href: "/promotions" },
        { id: "codes", label: t.tabCodes, count: codes, href: "/promotions/codes" },
      ]}
    />
  );
}
