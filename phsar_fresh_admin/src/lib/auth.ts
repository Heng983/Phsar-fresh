import "server-only";
import { redirect } from "next/navigation";
import { cache } from "react";
import { api } from "./api";
import { homeFor, type Permission, type StaffRole } from "./permissions";

export interface Access {
  role: StaffRole;
  permissions: Permission[];
  can: (p: Permission) => boolean;
}

/** The signed-in admin's role and live permissions (one API call per page render). */
export const getAccess = cache(async (): Promise<Access> => {
  const me = await api<{ role: StaffRole; permissions: Permission[] }>("/admin/me");
  return { ...me, can: (p) => me.permissions.includes(p) };
});

/** Use at the top of a page: sends the admin to a page they can open unless they have one of these permissions. */
export async function requirePermission(...permissions: Permission[]): Promise<Access> {
  const access = await getAccess();
  if (!permissions.some((p) => access.can(p))) {
    const home = homeFor(access.permissions);
    redirect(`${home}${home.includes("?") ? "&" : "?"}denied=1`);
  }
  return access;
}
