"use client";

import { useActionState, useEffect, useState } from "react";
import { SubmitButton } from "@/components/client";
import { Icon } from "@/components/icon";
import { useDict } from "@/i18n/client";
import { EDITABLE_ROLES, PERMISSIONS, PERMISSION_INFO, ROLE_LABEL, type Permission } from "@/lib/permissions";
import { savePermissions, type MatrixState } from "./actions";

type Editable = (typeof EDITABLE_ROLES)[number];

/** Same rules as the backend's IMPLIES: ticking the key also ticks what it needs. */
const IMPLIES: Partial<Record<Permission, Permission[]>> = {
  "products.write": ["products.view", "products.stock"],
  "products.stock": ["products.view"],
  "products.delete": ["products.view"],
  "categories.write": ["products.view"],
  "orders.update": ["orders.view"],
  "orders.cancel": ["orders.view"],
  "orders.activity": ["orders.view"],
};
const NEEDED_BY = (p: Permission) => (Object.keys(IMPLIES) as Permission[]).filter((k) => IMPLIES[k]?.includes(p));

export function PermissionMatrix({ initial, defaults }: { initial: Record<Editable, Permission[]>; defaults: Record<Editable, Permission[]> }) {
  const [grants, setGrants] = useState<Record<Editable, Set<Permission>>>(() => ({ MANAGER: new Set(initial.MANAGER), STAFF: new Set(initial.STAFF), DRIVER: new Set(initial.DRIVER) }));
  const [state, action] = useActionState<MatrixState, FormData>(savePermissions, {});
  const [dirty, setDirty] = useState(false);
  const d = useDict();
  const t = d.team;
  useEffect(() => {
    if (state.saved) setDirty(false);
  }, [state]);

  function toggle(role: Editable, p: Permission, on: boolean) {
    setGrants((g) => {
      const next = new Set(g[role]);
      if (on) {
        next.add(p);
        for (const extra of IMPLIES[p] ?? []) next.add(extra);
      } else {
        next.delete(p);
        // un-ticking "view" also removes what can't work without it
        for (const dep of NEEDED_BY(p)) next.delete(dep);
        for (const dep of NEEDED_BY(p)) for (const d2 of NEEDED_BY(dep)) next.delete(d2);
      }
      return { ...g, [role]: next };
    });
    setDirty(true);
  }

  function reset() {
    setGrants({ MANAGER: new Set(defaults.MANAGER), STAFF: new Set(defaults.STAFF), DRIVER: new Set(defaults.DRIVER) });
    setDirty(true);
  }

  let lastGroup = "";
  return (
    <form action={action}>
      {EDITABLE_ROLES.map((r) => [...grants[r]].map((p) => <input key={`${r}-${p}`} type="hidden" name={r} value={p} />))}
      <div className="pf-table-wrap">
        <table className="pf-table pf-perm">
          <thead>
            <tr>
              <th>{t.permission}</th>
              {(["SUPER_ADMIN", ...EDITABLE_ROLES] as const).map((r) => (
                <th key={r}>{d.roles[r]}{d.roles[r] !== ROLE_LABEL[r].km && <span className="pf-perm-desc pf-km" style={{ textTransform: "none", letterSpacing: 0 }}>{ROLE_LABEL[r].km}</span>}</th>
              ))}
            </tr>
          </thead>
          <tbody>
            {PERMISSIONS.flatMap((p) => {
              const info = { group: PERMISSION_INFO[p].group, ...d.perms.items[p] };
              const locked = p === "team.manage";
              const rows = [];
              if (info.group !== lastGroup) {
                lastGroup = info.group;
                rows.push(<tr key={`g-${info.group}`} className="pf-perm-group"><td colSpan={2 + EDITABLE_ROLES.length}><span>{d.perms.groups[info.group] ?? info.group}</span></td></tr>);
              }
              rows.push(
                <tr key={p}>
                  <td>
                    <span style={{ fontWeight: 600 }}>{info.label}</span>
                    {info.note && <span className="pf-perm-desc">{info.note}</span>}
                  </td>
                  <td><span className="pf-yes" title={t.superAlways}><Icon name="check" size={16} strokeWidth={2.5} /></span></td>
                  {EDITABLE_ROLES.map((r) => (
                    <td key={r}>
                      {locked ? (
                        <span className="pf-no" title={t.superOnly}>–</span>
                      ) : (
                        <label className="pf-check">
                          <input type="checkbox" checked={grants[r].has(p)} onChange={(e) => toggle(r, p, e.target.checked)} aria-label={`${d.roles[r]}: ${info.label}`} />
                        </label>
                      )}
                    </td>
                  ))}
                </tr>,
              );
              return rows;
            })}
          </tbody>
        </table>
      </div>
      <div className="pf-pager">
        <span className="pf-hint">
          {state.error ? <span className="pf-error">{state.error}</span> : state.saved && !dirty ? t.savedMatrix : dirty ? t.unsaved : t.matrixHint}
        </span>
        <div className="pf-actions-row">
          <button type="button" className="pf-btn pf-btn-ghost pf-btn-sm" onClick={reset}>{t.reset}</button>
          <SubmitButton size="sm" icon="check">{t.savePerms}</SubmitButton>
        </div>
      </div>
    </form>
  );
}
