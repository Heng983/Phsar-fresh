import { Page } from "@/components/topbar";
import { EmptyState } from "@/components/ui";
import { getDict } from "@/i18n/server";

export default async function NoAccess() {
  const t = (await getDict()).noAccess;
  return (
    <Page title={t.title}>
      <div className="pf-card">
        <EmptyState icon="lock" title={t.body}>{t.hint}</EmptyState>
      </div>
    </Page>
  );
}
