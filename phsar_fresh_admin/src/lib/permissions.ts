/**
 * Same permission names as the backend's src/admin/permissions.ts.
 * Which role has which is stored in the backend (Team & roles page) and read from GET /admin/me;
 * here it only decides what the UI shows — NestJS enforces it on every request.
 */
export const PERMISSIONS = [
  "dashboard.view",
  "products.view",
  "products.stock",
  "products.write",
  "products.delete",
  "categories.write",
  "orders.view",
  "orders.update",
  "orders.cancel",
  "orders.deliver",
  "orders.activity",
  "promotions.write",
  "team.manage",
] as const;

export type Permission = (typeof PERMISSIONS)[number];
export type StaffRole = "SUPER_ADMIN" | "MANAGER" | "STAFF" | "DRIVER";
export const STAFF_ROLES: StaffRole[] = ["SUPER_ADMIN", "MANAGER", "STAFF", "DRIVER"];
export const EDITABLE_ROLES = ["MANAGER", "STAFF", "DRIVER"] as const;

export const PERMISSION_INFO: Record<Permission, { label: string; group: string; note?: string }> = {
  "dashboard.view": { label: "Dashboard & revenue", group: "Dashboard" },
  "products.view": { label: "View products", group: "Catalog" },
  "products.stock": { label: "Update stock counts", group: "Catalog", note: "Also allows viewing products" },
  "products.write": { label: "Create & edit products, prices, photos", group: "Catalog", note: "Also allows viewing and stock" },
  "products.delete": { label: "Delete products", group: "Catalog" },
  "categories.write": { label: "Manage categories", group: "Catalog" },
  "orders.view": { label: "View orders", group: "Orders" },
  "orders.update": { label: "Move orders forward", group: "Orders", note: "Also allows viewing orders" },
  "orders.cancel": { label: "Cancel orders", group: "Orders", note: "Also allows viewing orders" },
  "orders.activity": { label: "See who handled each order", group: "Orders", note: "Staff, drivers and ABA PayWay, with times" },
  "orders.deliver": { label: "Deliver orders", group: "Orders", note: "Sees only orders out for delivery and marks them delivered" },
  "promotions.write": { label: "Manage Explore banners & deals", group: "Marketing" },
  "team.manage": { label: "Manage team & roles", group: "Admin", note: "Super admin only" },
};

export const ROLE_LABEL: Record<StaffRole, { en: string; km: string; tone: "solid" | "sky" | "neutral" }> = {
  SUPER_ADMIN: { en: "Super admin", km: "អ្នកគ្រប់គ្រងជាន់ខ្ពស់", tone: "solid" },
  MANAGER: { en: "Manager", km: "អ្នកគ្រប់គ្រង", tone: "sky" },
  STAFF: { en: "Staff", km: "បុគ្គលិក", tone: "neutral" },
  DRIVER: { en: "Delivery", km: "អ្នកដឹកជញ្ជូន", tone: "neutral" },
};

export function isStaffRole(role: string | undefined | null): role is StaffRole {
  return STAFF_ROLES.includes(role as StaffRole);
}

/** Where an admin lands, given what they're allowed to do. */
export function homeFor(perms: readonly string[]): string {
  if (perms.includes("dashboard.view")) return "/dashboard";
  if (perms.includes("orders.view")) return "/orders";
  if (perms.includes("orders.deliver")) return "/orders?status=DELIVERING";
  if (perms.includes("products.view")) return "/products";
  return "/no-access";
}
