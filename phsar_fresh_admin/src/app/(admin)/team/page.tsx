import type { Metadata } from "next";
import { ConfirmButton, SubmitButton } from "@/components/client";
import { Select, TextField } from "@/components/fields";
import { Page } from "@/components/topbar";
import { Alert, Badge, Card } from "@/components/ui";
import { api } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict } from "@/i18n/server";
import { ROLE_LABEL, STAFF_ROLES, type Permission } from "@/lib/permissions";
import { PermissionMatrix } from "./permission-matrix";
import { ACCESS_COOKIE, decodeToken } from "@/lib/session";
import type { TeamMember } from "@/lib/types";
import { cookies } from "next/headers";
import { createMember, setDisabled, updateMember } from "./actions";
import { PasswordField } from "@/components/password-field";

export const metadata: Metadata = { title: "Team & roles" };



export default async function TeamPage({ searchParams }: { searchParams: Promise<{ saved?: string; error?: string }> }) {
  await requirePermission("team.manage");
  const [sp, team, matrix, jar, d] = await Promise.all([
    searchParams,
    api<TeamMember[]>("/admin/team"),
    api<{ roles: Record<"SUPER_ADMIN" | "MANAGER" | "STAFF" | "DRIVER", Permission[]>; defaults: Record<"MANAGER" | "STAFF" | "DRIVER", Permission[]> }>("/admin/permissions"),
    cookies(),
    getDict(),
  ]);
  const t = d.team;
  const roleOptions = STAFF_ROLES.map((r) => ({ value: r, label: d.roles[r] }));
  const meId = decodeToken(jar.get(ACCESS_COOKIE)?.value)?.sub;
  const active = team.filter((m) => !m.disabled).length;

  return (
    <Page title={t.title} subtitle={t.subtitle(active, team.length - active)}>
      {sp.saved && <Alert tone="success" title={sp.saved} />}
      {sp.error && <Alert tone="danger" title={sp.error} />}

        <Card title={t.members} subtitle={t.membersSub} flush>
          <div className="pf-table-wrap">
            <table className="pf-table pf-cards pf-cards-team">
              <thead>
                <tr><th>{t.colMember}</th><th style={{ width: 170 }}>{t.colRole}</th><th style={{ width: 190 }}>{t.colPassword}</th><th /></tr>
              </thead>
              <tbody>
                {team.map((m) => {
                  const self = m.id === meId;
                  const name = m.name ?? m.phone ?? t.colMember;
                  return (
                    <tr key={m.id} style={m.disabled ? { opacity: 0.6 } : undefined}>
                      <td>
                        <div className="pf-product">
                          <span className="pf-avatar" style={{ width: 32, height: 32, fontSize: 12 }}>{name.split(" ").map((w) => w[0]).slice(0, 2).join("").toUpperCase()}</span>
                          <div>
                            <div className="pf-product-name">{name}{self && <span className="pf-hint"> {t.you}</span>}</div>
                            <div className="pf-hint">{m.phone}</div>
                          </div>
                          {m.disabled && <Badge tone="berry">{t.disabled}</Badge>}
                        </div>
                      </td>
                      <td colSpan={3}>
                        <form action={updateMember.bind(null, m.id, name)} className="pf-team-row">
                          {self ? (
                            <Badge tone={ROLE_LABEL[m.role].tone}>{d.roles[m.role]}</Badge>
                          ) : (
                            <Select name="role" id={`r-${m.id}`} aria-label={t.roleFor(name)} defaultValue={m.role} options={roleOptions} />
                          )}
                          {self && <input type="hidden" name="role" value={m.role} />}
                          <PasswordField name="password" id={`p-${m.id}`} placeholder={t.keepPassword} aria-label={t.passwordFor(name)} minLength={8} autoComplete="new-password" />
                          <div className="pf-actions-row" style={{ justifyContent: "flex-end" }}>
                            <SubmitButton size="sm" variant="secondary">{d.common.save}</SubmitButton>
                            {!self && (m.disabled ? (
                              <SubmitButton size="sm" variant="ghost" formAction={setDisabled.bind(null, m.id, name, false)} pendingLabel="…">{t.enable}</SubmitButton>
                            ) : (
                              <ConfirmButton icon="lock" formAction={setDisabled.bind(null, m.id, name, true)} confirmLabel={t.disableQ}>{t.disable}</ConfirmButton>
                            ))}
                          </div>
                        </form>
                      </td>
                    </tr>
                  );
                })}
              </tbody>
            </table>
          </div>
        </Card>

          <Card title={t.add} subtitle={t.addSub}>
            <form action={createMember} className="pf-add-member">
              <TextField label={t.name} name="name" required placeholder="Sok Dara" />
              <TextField label={t.phone} name="phone" prefix="+855" inputMode="tel" required placeholder="12 345 678" />
              <PasswordField label={t.password} name="password" required minLength={8} autoComplete="new-password" hint={t.passwordHint} />
              <Select label={t.role} name="role" defaultValue="STAFF" options={roleOptions} />
              <SubmitButton icon="plus" pendingLabel={d.categories.adding}>{t.addBtn}</SubmitButton>
            </form>
          </Card>

      <Card title={t.matrix} subtitle={t.matrixSub} flush>
        <PermissionMatrix initial={{ MANAGER: matrix.roles.MANAGER, STAFF: matrix.roles.STAFF, DRIVER: matrix.roles.DRIVER ?? ["orders.deliver"] }} defaults={matrix.defaults} />
      </Card>
    </Page>
  );
}
