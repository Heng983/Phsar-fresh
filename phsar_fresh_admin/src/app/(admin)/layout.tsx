import { MobileBar, NavClose, SidebarNav, ThemeToggle, type NavEntry } from "@/components/client";
import { Icon } from "@/components/icon";
import { AlertBell, OrderAlertsProvider } from "@/components/order-alerts";
import { LangToggle } from "@/i18n/client";
import { getDict } from "@/i18n/server";
import { api, orDefault } from "@/lib/api";
import { getAccess } from "@/lib/auth";
import type { AuthUser } from "@/lib/session";
import { getTheme } from "@/lib/theme";
import { logout } from "../auth-actions";

export default async function AdminLayout({ children }: { children: React.ReactNode }) {
  const access = await getAccess();
  const [me, pending, theme, d] = await Promise.all([
    orDefault(api<AuthUser>("/auth/me"), null),
    access.can("orders.view") || access.can("orders.deliver")
      ? orDefault(
          api<{ counts: { PENDING: number; DELIVERING: number } }>("/admin/orders?limit=1").then((r) =>
            // Drivers see how many orders are waiting on the road.
            access.can("orders.view") ? r.counts.PENDING : r.counts.DELIVERING,
          ),
          0,
        )
      : 0,
    getTheme(),
    getDict(),
  ]);
  const t = d.nav;
  const name = me?.name || me?.phone || "Admin";
  const initials = name.split(" ").map((w) => w[0]).slice(0, 2).join("").toUpperCase();

  const nav: NavEntry[] = [
    ...(access.can("dashboard.view") ? [{ href: "/dashboard", label: t.dashboard, icon: "dashboard" } as const] : []),
    { group: t.catalog },
    ...(access.can("products.view") ? [{ href: "/products", label: t.products, icon: "box" } as const] : []),
    ...(access.can("categories.write") ? [{ href: "/categories", label: t.categories, icon: "tag" } as const] : []),
    { group: t.sales },
    ...(access.can("orders.view") ? [{ href: "/orders", label: t.orders, icon: "cart", badge: pending } as const] : []),
    ...(!access.can("orders.view") && access.can("orders.deliver")
      ? [{ href: "/orders?status=DELIVERING", label: t.deliveries, icon: "truck", badge: pending } as const]
      : []),
    ...(access.can("promotions.write") ? [{ group: t.marketing }, { href: "/promotions", label: t.promotions, icon: "megaphone" } as const] : []),
    ...(access.can("team.manage") ? [{ group: t.admin }, { href: "/team", label: t.team, icon: "users" } as const] : []),
  ];

  // New-order bell, pop-up and sound for everyone who handles orders.
  const alerts = access.can("orders.view");

  return (
    <OrderAlertsProvider enabled={alerts}>
    <div className="pf-shell">
      <MobileBar badge={pending} action={alerts ? <AlertBell /> : undefined} />
      <aside className="pf-sidebar" aria-label={d.common.menu}>
        <div className="pf-sidebar-head">
          <div className="pf-brand">
            <span className="pf-brand-name">Phsar Fresh</span>
            <span className="pf-brand-tag">Admin</span>
          </div>
          <div className="pf-sidebar-tools">
            {alerts && <AlertBell />}
            <NavClose />
          </div>
        </div>
        <SidebarNav items={nav} />
        <div className="pf-sidebar-foot">
          <LangToggle />
          <ThemeToggle initial={theme} />
          <div className="pf-user">
            <span className="pf-avatar">{initials}</span>
            <div className="pf-user-meta">
              <div className="pf-user-name">{name}</div>
              <div className="pf-user-role">{d.roles[access.role]}</div>
            </div>
            <form action={logout}>
              <button type="submit" className="pf-btn pf-btn-ghost pf-iconbtn pf-btn-sm" aria-label={d.common.signOut} title={d.common.signOut}>
                <Icon name="logout" size={16} />
              </button>
            </form>
          </div>
        </div>
      </aside>
      <div className="pf-shell-main">{children}</div>
    </div>
    </OrderAlertsProvider>
  );
}
