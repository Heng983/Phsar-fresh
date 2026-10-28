import type { Metadata } from "next";
import { Page } from "@/components/topbar";
import { Alert } from "@/components/ui";
import { api } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict } from "@/i18n/server";
import type { DiscountCode } from "@/lib/types";
import { CodeForm } from "../code-form";

export const metadata: Metadata = { title: "Edit discount code" };

export default async function EditCodePage({ params, searchParams }: {
  params: Promise<{ id: string }>;
  searchParams: Promise<{ saved?: string; error?: string }>;
}) {
  await requirePermission("promotions.write");
  const [{ id }, sp, d] = await Promise.all([params, searchParams, getDict()]);
  const code = await api<DiscountCode>(`/admin/discount-codes/${id}`);
  const t = d.codes;

  return (
    <Page title={code.code} subtitle={`${t.title} · ${d.promotions.statusNote[code.status]}`} back={{ href: "/promotions/codes", label: t.all }}>
      {sp.saved && <Alert tone="success" title={t.saved} />}
      {sp.error && <Alert tone="danger" title={sp.error} />}
      <CodeForm code={code} />
    </Page>
  );
}
