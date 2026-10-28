import type { Metadata } from "next";
import { Icon } from "@/components/icon";
import { Select } from "@/components/fields";
import { Page } from "@/components/topbar";
import {
  Alert,
  Badge,
  ButtonLink,
  Card,
  EmptyState,
  IconLink,
  LinkTabs,
  Pagination,
  ProductCell,
  StockLevel,
} from "@/components/ui";
import { api } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict, getLang } from "@/i18n/server";
import { LOW_STOCK } from "@/lib/config";
import { localName, money } from "@/lib/format";
import type { Category, ProductList } from "@/lib/types";
import { setVisible } from "./actions";

export const metadata: Metadata = { title: "Products" };

type Search = {
  q?: string;
  categoryId?: string;
  filter?: string;
  page?: string;
  deleted?: string;
  denied?: string;
};

export default async function ProductsPage({
  searchParams,
}: {
  searchParams: Promise<Search>;
}) {
  const sp = await searchParams;
  const filter = ["low", "out", "hidden"].includes(sp.filter ?? "")
    ? sp.filter!
    : "all";
  const page = Math.max(1, Number(sp.page) || 1);
  const qs = (over: Partial<Search>) => {
    const p = new URLSearchParams();
    const merged = {
      q: sp.q,
      categoryId: sp.categoryId,
      filter,
      page: String(page),
      ...over,
    };
    for (const [k, v] of Object.entries(merged))
      if (v && !(k === "filter" && v === "all") && !(k === "page" && v === "1"))
        p.set(k, v);
    const s = p.toString();
    return `/products${s ? `?${s}` : ""}`;
  };

  const query = new URLSearchParams({
    filter,
    page: String(page),
    limit: "20",
  });
  if (sp.q) query.set("q", sp.q);
  if (sp.categoryId) query.set("categoryId", sp.categoryId);
  const access = await requirePermission("products.view");
  const [list, categories] = await Promise.all([
    api<ProductList>(`/admin/products?${query}`),
    api<Category[]>("/admin/categories"),
  ]);
  const canEdit = access.can("products.write");
  const canStock = access.can("products.stock");
  const [dict, lang] = await Promise.all([getDict(), getLang()]);
  const t = dict.products;

  return (
    <Page
      title={t.title}
      subtitle={t.subtitle(list.counts.all, categories.length)}
      actions={
        canEdit && (
          <ButtonLink href="/products/new" variant="primary" icon="plus">
            {t.add}
          </ButtonLink>
        )
      }
    >
      {sp.deleted && <Alert tone="success" title={t.deleted} />}
      {sp.denied && <Alert tone="warning" title={dict.common.denied} />}
      <Card flush>
        <div style={{ padding: "0 20px" }}>
          <LinkTabs
            active={filter}
            items={[
              {
                id: "all",
                label: t.tabAll,
                count: list.counts.all,
                href: qs({ filter: "all", page: "1" }),
              },
              {
                id: "low",
                label: t.tabLow,
                count: list.counts.low,
                href: qs({ filter: "low", page: "1" }),
              },
              {
                id: "out",
                label: t.tabOut,
                count: list.counts.out,
                href: qs({ filter: "out", page: "1" }),
              },
              {
                id: "hidden",
                label: t.tabHidden,
                count: list.counts.hidden,
                href: qs({ filter: "hidden", page: "1" }),
              },
            ]}
          />
        </div>
        <form className="pf-toolbar" action="/products">
          {filter !== "all" && (
            <input type="hidden" name="filter" value={filter} />
          )}
          <div style={{ width: 300 }}>
            <div className="pf-control">
              <span className="pf-adorn">
                <Icon name="search" size={18} />
              </span>
              <input
                name="q"
                defaultValue={sp.q}
                placeholder={t.searchPh}
                aria-label={dict.common.search}
              />
            </div>
          </div>
          <div style={{ width: 220 }}>
            <Select
              name="categoryId"
              aria-label={t.colCategory}
              defaultValue={sp.categoryId ?? ""}
              placeholder={t.allCategories}
              options={categories.map((c) => ({ value: c.id, label: localName(lang, c.name, c.nameKm) }))}
            />
          </div>
          <button type="submit" className="pf-btn pf-btn-secondary">
            {dict.common.search}
          </button>
          <span className="pf-grow" />
          {(sp.q || sp.categoryId) && (
            <ButtonLink
              href={qs({ q: "", categoryId: "", page: "1" })}
              variant="ghost"
              size="sm"
            >
              {dict.common.clearFilters}
            </ButtonLink>
          )}
        </form>

        {list.items.length === 0 ? (
          <EmptyState
            icon="box"
            title={
              sp.q || sp.categoryId || filter !== "all"
                ? t.noMatch
                : t.none
            }
          >
            {sp.q || sp.categoryId || filter !== "all"
              ? t.noMatchBody
              : t.noneBody}
          </EmptyState>
        ) : (
          <div className="pf-table-wrap">
            <table className="pf-table pf-cards pf-cards-products">
              <thead>
                <tr>
                  <th>{t.colProduct}</th>
                  <th>{t.colCategory}</th>
                  <th className="is-right">{t.colPrice}</th>
                  <th style={{ width: 180 }}>{t.colStock}</th>
                  <th>{t.colVisible}</th>
                  <th />
                </tr>
              </thead>
              <tbody>
                {list.items.map((p) => (
                  <tr key={p.id}>
                    <td>
                      <ProductCell
                        name={p.name}
                        nameKm={p.nameKm}
                        image={p.imageUrl}
                        meta={p.origin}
                      />
                    </td>
                    <td className="pf-muted">{localName(lang, p.category.name, p.category.nameKm)}</td>
                    <td className="is-right pf-num">
                      <div style={{ fontWeight: 600 }}>
                        {money(p.priceCents)}
                      </div>
                      <div className="pf-hint">/ {p.unit}</div>
                    </td>
                    <td>
                      <StockLevel
                        qty={p.stock}
                        threshold={LOW_STOCK}
                        unit={p.unit}
                      />
                    </td>
                    <td>
                      {!canEdit ? (
                        <Badge tone={p.isActive ? "leaf" : "neutral"}>{p.isActive ? dict.common.visible : dict.common.hidden}</Badge>
                      ) : (
                      <form action={setVisible.bind(null, p.id, !p.isActive)}>
                        <button
                          type="submit"
                          className="pf-switch pf-switch-btn"
                          aria-pressed={p.isActive}
                          aria-label={
                            p.isActive ? t.hide(p.name) : t.show(p.name)
                          }
                        >
                          <span className="pf-switch-track" />
                        </button>
                      </form>
                      )}
                    </td>
                    <td className="is-right">
                      {(canEdit || canStock) && (
                      <IconLink
                        href={`/products/${p.id}`}
                        icon="edit"
                        label={canEdit ? t.editX(p.name) : t.stockX(p.name)}
                      />
                      )}
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          </div>
        )}
        <Pagination
          page={list.page}
          limit={list.limit}
          total={list.total}
          href={(n) => qs({ page: String(n) })}
        />
      </Card>
    </Page>
  );
}
