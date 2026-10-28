import type { Metadata } from "next";
import { Page } from "@/components/topbar";
import { ButtonLink } from "@/components/ui";
import { requirePermission } from "@/lib/auth";
import { getDict } from "@/i18n/server";
import { CodeForm } from "../code-form";

export const metadata: Metadata = { title: "New discount code" };

export default async function NewCodePage() {
  await requirePermission("promotions.write");
  const d = await getDict();
  return (
    <Page title={d.codes.new} subtitle={d.codes.newSub} actions={<ButtonLink href="/promotions/codes" variant="ghost">{d.common.cancel}</ButtonLink>}>
      <CodeForm />
    </Page>
  );
}
