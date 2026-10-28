import Link from "next/link";
import type { ReactNode } from "react";
import { Icon } from "./icon";

type Back = { href: string; label: string };

export function Topbar({ title, subtitle, actions, back }: { title: ReactNode; subtitle?: ReactNode; actions?: ReactNode; back?: Back }) {
  return (
    <header className="pf-topbar">
      <div className="pf-topbar-titles">
        <div className="pf-title-row">
          {back && (
            <Link href={back.href} className="pf-back">
              <Icon name="chevron-left" size={16} />
              {back.label}
            </Link>
          )}
          <h1 className="pf-page-title">{title}</h1>
        </div>
        {subtitle && <p className="pf-page-sub">{subtitle}</p>}
      </div>
      {actions && <div className="pf-topbar-actions">{actions}</div>}
    </header>
  );
}

export function Page({ title, subtitle, actions, back, children }: { title: ReactNode; subtitle?: ReactNode; actions?: ReactNode; back?: Back; children: ReactNode }) {
  return (
    <>
      <Topbar title={title} subtitle={subtitle} actions={actions} back={back} />
      <main className="pf-shell-content">{children}</main>
    </>
  );
}
