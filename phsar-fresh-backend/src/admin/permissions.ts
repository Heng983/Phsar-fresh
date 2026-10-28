import { Role } from "@prisma/client";

/**
 * Every permission the admin panel knows. A Super admin ticks which of these
 * MANAGER, STAFF and DRIVER get (stored in the RolePermission table); SUPER_ADMIN always has all.
 * Keep in sync with src/lib/permissions.ts in the admin web app.
 */
export const PERMISSIONS = [
  "dashboard.view", // revenue and analytics
  "products.view",
  "products.stock", // change stock quantity only
  "products.write", // create, edit everything, photos, visibility
  "products.delete",
  "categories.write",
  "orders.view",
  "orders.update", // move an order forward
  "orders.cancel",
  "orders.deliver", // see orders out for delivery and mark them delivered (drivers)
  "orders.activity", // see who handled each order (staff, drivers, PayWay) and when
  "promotions.write", // Explore banners and deals
  "team.manage", // create admins, change roles, edit permissions — Super admin only
] as const;

export type Permission = (typeof PERMISSIONS)[number];
export type StaffRole = Extract<Role, "SUPER_ADMIN" | "MANAGER" | "STAFF" | "DRIVER">;
export type EditableRole = Exclude<StaffRole, "SUPER_ADMIN">;

export const STAFF_ROLES: StaffRole[] = ["SUPER_ADMIN", "MANAGER", "STAFF", "DRIVER"];
export const EDITABLE_ROLES: EditableRole[] = ["MANAGER", "STAFF", "DRIVER"];

/** Never grantable to anyone but SUPER_ADMIN (otherwise a manager could promote themselves). */
export const SUPER_ADMIN_ONLY: Permission[] = ["team.manage"];

/** Used until a Super admin saves the matrix for that role. */
export const DEFAULT_PERMISSIONS: Record<EditableRole, Permission[]> = {
  MANAGER: PERMISSIONS.filter((p) => !SUPER_ADMIN_ONLY.includes(p)),
  STAFF: ["products.view", "products.stock", "orders.view", "orders.update"],
  // Delivery: only the orders on the road, and "Mark as delivered".
  DRIVER: ["orders.deliver"],
};

/** Granting the left one also grants what it needs to work. */
export const IMPLIES: Partial<Record<Permission, Permission[]>> = {
  "products.write": ["products.view", "products.stock"],
  "products.stock": ["products.view"],
  "products.delete": ["products.view"],
  "categories.write": ["products.view"],
  "orders.update": ["orders.view"],
  "orders.cancel": ["orders.view"],
  "orders.activity": ["orders.view"],
};

export function isStaffRole(role: Role | string | undefined): role is StaffRole {
  return STAFF_ROLES.includes(role as StaffRole);
}

/** Drops unknown / super-admin-only entries and adds implied ones. */
export function normalize(perms: readonly string[]): Permission[] {
  const set = new Set<Permission>();
  for (const p of perms) {
    if (!(PERMISSIONS as readonly string[]).includes(p) || SUPER_ADMIN_ONLY.includes(p as Permission)) continue;
    set.add(p as Permission);
    for (const extra of IMPLIES[p as Permission] ?? []) set.add(extra);
  }
  return PERMISSIONS.filter((p) => set.has(p));
}
