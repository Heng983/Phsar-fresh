import type { Metadata } from "next";
import Link from "next/link";
import { ScrollIntoViewOnNarrow, SubmitButton } from "@/components/client";
import { Icon } from "@/components/icon";
import { Page } from "@/components/topbar";
import { Alert, Badge, ButtonLink, Card, EmptyState, LinkTabs, Pagination, ProductCell, StatusBadge } from "@/components/ui";
import { api, orDefault } from "@/lib/api";
import { requirePermission } from "@/lib/auth";
import { getDict, getLang } from "@/i18n/server";
import type { Dict, Lang } from "@/i18n/dict";
import { STATUS, STATUS_ORDER, dateTime, money, orderCode } from "@/lib/format";
import type { Order, OrderList, OrderStatus } from "@/lib/types";
import { moveOrder, sendOrderMessage } from "./actions";
import { CancelWithReason, MessageComposer } from "./order-messages";

export const metadata: Metadata = { title: "Orders" };

type Search = { status?: string; q?: string; page?: string; id?: string; error?: string; denied?: string; sent?: string };
/** ABA Pay is paid first; cash on delivery is paid at the door, so it has no "Paid" step. */
const FLOW_PREPAID: OrderStatus[] = ["PENDING", "PAID", "PREPARING", "DELIVERING", "DELIVERED"];
const FLOW_CASH: OrderStatus[] = ["PENDING", "PREPARING", "DELIVERING", "DELIVERED"];

export default async function OrdersPage({ searchParams }: { searchParams: Promise<Search> }) {
  const access = await requirePermission("orders.view", "orders.deliver");
  // Delivery role: only orders on the road (and the ones they delivered).
  const driver = !access.can("orders.view");
  const [sp, lang, d] = await Promise.all([searchParams, getLang(), getDict()]);
  const t = d.orders;
  const statusLabel = (s: OrderStatus) => (lang === "km" ? STATUS[s].km : STATUS[s].en);
  const tabs: OrderStatus[] = driver ? ["DELIVERING", "DELIVERED"] : STATUS_ORDER;
  const status = tabs.includes(sp.status as OrderStatus) ? (sp.status as OrderStatus) : driver ? "DELIVERING" : undefined;
  const page = Math.max(1, Number(sp.page) || 1);
  const qs = (over: Partial<Search>) => {
    const p = new URLSearchParams();
    for (const [k, v] of Object.entries({ status, q: sp.q, page: String(page), id: sp.id, ...over })) if (v && !(k === "page" && v === "1")) p.set(k, v);
    const s = p.toString();
    return `/orders${s ? `?${s}` : ""}`;
  };

  const query = new URLSearchParams({ page: String(page), limit: "20" });
  if (status) query.set("status", status);
  if (sp.q) query.set("q", sp.q);
  const list = await api<OrderList>(`/admin/orders?${query}`);
  const selected = sp.id ? await orDefault(api<Order>(`/admin/orders/${sp.id}`), null) : (list.items[0] ?? null);
  const returnTo = qs({ id: undefined, error: undefined });

  return (
    <Page title={driver ? t.driverTitle : t.title} subtitle={driver ? t.driverSubtitle(list.counts.DELIVERING) : t.subtitle(list.counts.ALL, list.counts.PENDING)}>
      {sp.denied && <Alert tone="warning" title={d.common.denied} />}
      <div className="pf-orders">
        <Card flush>
          <div style={{ padding: "0 20px" }}>
            <LinkTabs
              active={status ?? "ALL"}
              items={[
                ...(driver ? [] : [{ id: "ALL", label: t.all, count: list.counts.ALL, href: qs({ status: undefined, page: "1", id: undefined }) }]),
                ...tabs.map((s) => ({ id: s, label: statusLabel(s), count: list.counts[s], href: qs({ status: s, page: "1", id: undefined }) })),
              ]}
            />
          </div>
          <form className="pf-toolbar" action="/orders">
            {status && <input type="hidden" name="status" value={status} />}
            <div style={{ width: 320 }}>
              <div className="pf-control">
                <span className="pf-adorn"><Icon name="search" size={18} /></span>
                <input name="q" defaultValue={sp.q} placeholder={t.searchPh} aria-label={d.common.search} />
              </div>
            </div>
            <button type="submit" className="pf-btn pf-btn-secondary">{d.common.search}</button>
            {sp.q && <ButtonLink href={qs({ q: undefined, page: "1", id: undefined })} variant="ghost" size="sm">{d.common.clear}</ButtonLink>}
          </form>
          {list.items.length === 0 ? (
            <EmptyState icon="cart" title={status || sp.q ? t.noMatch : t.none}>
              {status || sp.q ? t.noMatchBody : t.noneBody}
            </EmptyState>
          ) : (
            <div className="pf-table-wrap">
              <table className="pf-table pf-cards pf-cards-orders">
                <thead>
                  <tr><th>{t.colOrder}</th><th>{t.colCustomer}</th><th className="is-right">{t.colItems}</th><th className="is-right">{t.colTotal}</th><th>{t.colStatus}</th></tr>
                </thead>
                <tbody>
                  {list.items.map((o) => {
                    const href = qs({ id: o.id, error: undefined });
                    // Every cell links to the order, so a click anywhere on the row opens it.
                    const cell = (child: React.ReactNode, main = false) => (
                      <Link href={href} className="pf-row-link" tabIndex={main ? undefined : -1} aria-hidden={main ? undefined : true}>{child}</Link>
                    );
                    return (
                      <tr key={o.id} className={`pf-row-click${selected?.id === o.id ? " is-selected" : ""}`}>
                        <td>
                          {cell(<>
                            <div className="pf-nowrap" style={{ fontWeight: 650 }}>{orderCode(o.id)}</div>
                            <div className="pf-hint pf-nowrap">{dateTime(o.createdAt, lang)}</div>
                          </>, true)}
                        </td>
                        <td>
                          {cell(<>
                            <div className="pf-nowrap" style={{ fontWeight: 600 }}>{o.customer.name ?? t.noName}</div>
                            <div className="pf-hint">{o.customer.phone}</div>
                          </>)}
                        </td>
                        <td className="is-right pf-num">{cell(o.itemCount)}</td>
                        <td className="is-right pf-num" style={{ fontWeight: 650 }}>{cell(money(o.totalCents))}</td>
                        <td>{cell(<StatusBadge status={o.status} />)}</td>
                      </tr>
                    );
                  })}
                </tbody>
              </table>
            </div>
          )}
          <Pagination page={list.page} limit={list.limit} total={list.total} href={(n) => qs({ page: String(n), id: undefined })} />
        </Card>

        <ScrollIntoViewOnNarrow target="order-panel" when={sp.id} />
        {selected ? <div id="order-panel" className="pf-order-panel"><OrderPanel order={selected} t={d.orders} roles={d.roles} lang={lang} canUpdate={access.can("orders.update") || access.can("orders.deliver")} canMessage={access.can("orders.update") || access.can("orders.cancel")} returnTo={returnTo} error={sp.id === selected.id ? sp.error : undefined} sent={sp.id === selected.id && !!sp.sent} /></div> : sp.id && (
          <Card title={t.notFound}><p className="pf-muted" style={{ margin: 0 }}>{t.notFoundBody}</p></Card>
        )}
      </div>
    </Page>
  );
}

const PAY_TONE = { PENDING: "citrus", APPROVED: "leaf", FAILED: "berry", EXPIRED: "neutral" } as const;

function OrderPanel({ order, returnTo, error, sent, canUpdate, canMessage, t, roles, lang }: { order: Order; returnTo: string; error?: string; sent?: boolean; canUpdate: boolean; canMessage: boolean; t: Dict["orders"]; roles: Dict["roles"]; lang: Lang }) {
  const roleName = (role: string | null, source: string) =>
    source === "PAYWAY" || !role ? t.roleSystem : role === "CUSTOMER" ? t.roleCustomer : (roles as Record<string, string>)[role] ?? role;
  /** The latest log entry for a status, e.g. who sent it for delivery. */
  const eventFor = (s: OrderStatus) => order.activity?.filter((e) => e.status === s).at(-1);
  const byLine = (s: OrderStatus) => {
    const e = eventFor(s);
    return e ? `${dateTime(e.at, lang)} · ${t.by(e.by ?? t.someone)} (${roleName(e.role, e.source)})` : null;
  };
  const cash = order.paymentMethod !== "ABA_PAY";
  const FLOW = cash ? FLOW_CASH : FLOW_PREPAID;
  // A legacy cash order marked Paid counts as confirmed (Pending done).
  const reached = Math.max(FLOW.indexOf(order.status), order.status === "PAID" ? 0 : -1);
  /** The extra line under a step: when, done/waiting, and what it means for this payment method. */
  const note = (s: OrderStatus, i: number) => {
    if (i === 0) return `${dateTime(order.createdAt, lang)}${!cash && reached === 0 ? ` · ${t.awaitingKhqr}` : ""}`;
    if (i <= reached && byLine(s)) return `${byLine(s)}${s === "DELIVERED" && cash ? ` · ${t.cashCollectedShort}` : ""}`;
    if (s === "DELIVERED" && cash) return i <= reached ? t.cashCollected : t.collectCash(money(order.totalCents));
    if (s === "PAID" && i > reached) return t.paidByPayway;
    return i <= reached ? t.done : t.waiting;
  };
  const discount = order.discountCents ?? 0;
  const subtotal = order.subtotalCents || order.totalCents - order.deliveryCents + discount;
  const map = `https://www.google.com/maps?q=${order.address.lat},${order.address.lng}`;
  return (
    <Card
      title={orderCode(order.id)}
      subtitle={`${order.customer.name ?? t.customer} · ${order.customer.phone ?? t.noPhone}`}
      actions={<StatusBadge status={order.status} />}
    >
      <div className="pf-form-grid" style={{ gap: 20 }}>
        {error && <Alert tone="danger" title={error} />}
        {sent && !error && <Alert tone="success" title={t.sent} />}

        {order.status === "CANCELLED" ? (
          order.paidAfterCancel ? <Alert tone="warning" title={t.paidAfterCancel}>{t.paidAfterCancelBody}</Alert> : <Alert tone="danger" title={t.cancelled} />
        ) : (
          <ol className="pf-timeline">
            {FLOW.map((s, i) => (
              <li key={s} className={[i <= reached && "is-done", i === reached + 1 && "is-current"].filter(Boolean).join(" ")}>
                <span className="pf-tl-dot">{i <= reached && <Icon name="check" size={14} strokeWidth={2.5} />}</span>
                <div>
                  <div className="pf-tl-title">{lang === "km" ? <span className="pf-km">{STATUS[s].km}</span> : <>{STATUS[s].en}<span className="pf-km">{STATUS[s].km}</span></>}</div>
                  <div className="pf-tl-time">{note(s, i)}</div>
                </div>
              </li>
            ))}
          </ol>
        )}

        {order.nextStatuses.filter((s) => canUpdate || s === "CANCELLED").length > 0 && (
          <div className="pf-actions-row">
            {order.nextStatuses.filter((s) => canUpdate || s === "CANCELLED").map((s) => s === "CANCELLED" ? (
              <CancelWithReason key={s} action={moveOrder.bind(null, order.id, s, returnTo)} />
            ) : (
              <form key={s} action={moveOrder.bind(null, order.id, s, returnTo)}>
                <SubmitButton variant="primary" icon={s === "DELIVERING" ? "truck" : "check"} pendingLabel={t.updating}>
                  {order.status === "CANCELLED" && s === "PAID" ? t.restorePaid : t.action[s]}
                </SubmitButton>
              </form>
            ))}
          </div>
        )}

        {canMessage && (
          <section className="pf-msgbox" aria-label={t.messagesTitle}>
            <div className="pf-activity-head">
              <h3 className="pf-card-title" style={{ fontSize: 15, display: "flex", alignItems: "center", gap: 6 }}><Icon name="message" size={16} />{t.messagesTitle}</h3>
              <span className="pf-hint">{t.messagesSub}</span>
            </div>
            {(order.messages ?? []).length === 0 ? (
              <p className="pf-hint" style={{ margin: 0 }}>{t.messagesNone}</p>
            ) : (
              <ol className="pf-messages">
                {[...(order.messages ?? [])].reverse().map((m) => (
                  <li key={m.id} className={`is-${m.kind.toLowerCase()}`}>
                    <div className="pf-message-meta">
                      <Badge tone={m.kind === "INFO" ? "sky" : m.kind === "PROBLEM" ? "citrus" : "berry"}>{t.kind[m.kind]}</Badge>
                      <span className="pf-hint">{dateTime(m.at, lang)}{m.by ? ` · ${t.by(m.by)}` : ""}</span>
                    </div>
                    <p>{m.body}</p>
                  </li>
                ))}
              </ol>
            )}
            {order.status !== "CANCELLED" && order.status !== "DELIVERED" && (
              <MessageComposer action={sendOrderMessage.bind(null, order.id, returnTo)} />
            )}
          </section>
        )}

        {order.activity && (
          <section className="pf-activity" aria-label={t.activityTitle}>
            <div className="pf-activity-head">
              <h3 className="pf-card-title" style={{ fontSize: 15 }}>{t.activityTitle}</h3>
              <span className="pf-hint">{t.activitySub}</span>
            </div>
            {order.activity.length === 0 ? (
              <p className="pf-hint" style={{ margin: 0 }}>{t.activityNone}</p>
            ) : (
              <ol className="pf-activity-list">
                {[...order.activity].reverse().map((e, i) => (
                  <li key={i}>
                    <div>
                      <div><StatusBadge status={e.status} /> <strong>{e.by ?? t.someone}</strong> <span className="pf-hint">· {roleName(e.role, e.source)}</span></div>
                      <div className="pf-hint">{dateTime(e.at, lang)}{e.note ? ` · ${e.note}` : ""}</div>
                    </div>
                  </li>
                ))}
              </ol>
            )}
          </section>
        )}

        <ul className="pf-items">
          {order.items.map((it) => (
            <li key={it.id}>
              <ProductCell name={it.name} nameKm={it.nameKm} image={it.imageUrl} meta={`${it.qty} × ${money(it.priceCents)} / ${it.unit}`} />
              <span className="pf-num" style={{ fontWeight: 600 }}>{money(it.priceCents * it.qty)}</span>
            </li>
          ))}
        </ul>

        <dl className="pf-kv">
          <dt>{t.placed}</dt><dd>{dateTime(order.createdAt, lang)}</dd>
          <dt>{t.deliverTo}</dt><dd>{order.addressText && <>{order.addressText}<br /></>}<a className="pf-link" href={map} target="_blank" rel="noreferrer">{t.openMap}</a></dd>
          {(order.recipientName || order.recipientPhone) && <><dt>{t.recipient}</dt><dd>{[order.recipientName, order.recipientPhone].filter(Boolean).join(" · ")}</dd></>}
          {order.paymentMethod && (
            <><dt>{t.payment}</dt><dd>
              {t.paymentMethod[order.paymentMethod]}
              {order.payment && (
                <> · <Badge tone={PAY_TONE[order.payment.status]}>{t.paymentState[order.payment.status]}</Badge>
                  <div className="pf-hint">
                    {[order.payment.paymentType, order.payment.bankRef && `${t.bankRef} ${order.payment.bankRef}`, `PayWay ${order.payment.tranId}`].filter(Boolean).join(" · ")}
                  </div>
                </>
              )}
            </dd></>
          )}
          {order.note && <><dt>{t.note}</dt><dd>{order.note}</dd></>}
          <dt>{t.items(order.itemCount)}</dt><dd>{money(subtotal)}</dd>
          {discount > 0 && <><dt>{order.discountCode ? t.discountWith(order.discountCode) : t.discount}</dt><dd className="pf-num" style={{ color: "var(--leaf)" }}>−{money(discount)}</dd></>}
          <dt>{t.deliveryFee}</dt><dd>{money(order.deliveryCents)}</dd>
        </dl>
        <div className="pf-total"><span>{t.total}</span><span>{money(order.totalCents)}</span></div>
      </div>
    </Card>
  );
}
