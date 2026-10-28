export type OrderStatus = "PENDING" | "PAID" | "PREPARING" | "DELIVERING" | "DELIVERED" | "CANCELLED";

export interface Category {
  id: string;
  name: string;
  nameKm: string | null;
  productCount: number;
  /** The photo uploaded in the admin (null = none). */
  imageUrl: string | null;
  /** What the app shows: the uploaded photo, else a product photo, else nothing. */
  coverUrl: string | null;
  coverSource: "uploaded" | "product" | "none";
}

export interface Product {
  id: string;
  name: string;
  nameKm: string | null;
  description: string | null;
  origin: string | null;
  unit: string;
  priceCents: number;
  stock: number;
  isActive: boolean;
  imageUrl: string | null;
  lowStock: boolean;
  category: { id: string; name: string; nameKm: string | null };
}

export interface ProductList {
  items: Product[];
  page: number;
  limit: number;
  total: number;
  counts: { all: number; low: number; out: number; hidden: number };
}

export interface OrderItem {
  id: string;
  productId: string;
  name: string;
  nameKm: string | null;
  unit: string;
  imageUrl: string | null;
  priceCents: number;
  qty: number;
}

export interface Order {
  id: string;
  status: OrderStatus;
  nextStatuses: OrderStatus[];
  /** Who moved the order to each status (Super admin / Manager only). */
  activity?: { status: OrderStatus; at: string; by: string | null; role: string | null; source: "APP" | "ADMIN" | "PAYWAY"; note: string | null }[];
  /** Cancelled, but the customer's KHQR payment went through. */
  paidAfterCancel?: boolean;
  subtotalCents?: number;
  discountCents?: number;
  discountCode?: string | null;
  totalCents: number;
  deliveryCents: number;
  paymentMethod?: "ABA_PAY" | "CARD" | "CASH";
  paidAt?: string | null;
  payment?: { status: "PENDING" | "APPROVED" | "FAILED" | "EXPIRED"; tranId: string; paymentType: string | null; bankRef: string | null; paidAt: string | null } | null;
  recipientName?: string | null;
  recipientPhone?: string | null;
  addressText?: string | null;
  note?: string | null;
  address: { lat: number; lng: number };
  createdAt: string;
  customer: { id: string; name: string | null; phone: string | null };
  itemCount: number;
  items: OrderItem[];
  /** Notes staff sent to the customer's app about this order. */
  messages?: OrderMessage[];
}

export type MessageKind = "INFO" | "PROBLEM" | "CANCELLED";

export interface OrderMessage {
  id: string;
  kind: MessageKind;
  body: string;
  at: string;
  by: string | null;
}

/** An order that needs staff: placed (cash) or paid (ABA Pay). */
export interface OrderAlert {
  id: string;
  code: string;
  totalCents: number;
  paymentMethod: "ABA_PAY" | "CARD" | "CASH";
  customer: string | null;
  at: string;
}

export interface OrderList {
  items: Order[];
  page: number;
  limit: number;
  total: number;
  counts: Record<OrderStatus | "ALL", number>;
}

export interface Dashboard {
  days: number;
  totals: { revenueCents: number; orders: number; avgBasketCents: number; cancellationRate: number };
  deltas: { revenue: number; orders: number; avgBasket: number; cancellationRate: number };
  revenueByDay: { date: string; revenueCents: number; previousCents: number }[];
  ordersByHour: { hour: number; orders: number }[];
  topProducts: { productId: string; name: string; nameKm: string | null; unit: string; qty: number }[];
  lowStock: { id: string; name: string; nameKm: string | null; stock: number; unit: string; imageUrl: string | null }[];
  lowStockThreshold: number;
  pendingOrders: number;
}

export interface TeamMember {
  id: string;
  name: string | null;
  phone: string | null;
  role: "SUPER_ADMIN" | "MANAGER" | "STAFF";
  disabled: boolean;
  createdAt: string;
}

export type PromotionKind = "BANNER" | "DEAL";
export type PromotionAction = "NONE" | "OPEN_CHAT" | "OPEN_CATEGORY" | "OPEN_PRODUCT";

export interface Promotion {
  id: string;
  kind: PromotionKind;
  title: string;
  titleKm: string | null;
  body: string | null;
  bodyKm: string | null;
  buttonLabel: string | null;
  buttonLabelKm: string | null;
  imageUrl: string | null;
  action: PromotionAction;
  categoryId: string | null;
  productId: string | null;
  dealPriceCents: number | null;
  startsAt: string | null;
  endsAt: string | null;
  isActive: boolean;
  sortOrder: number;
  status: "LIVE" | "SCHEDULED" | "ENDED" | "OFF";
  product: { id: string; name: string; nameKm: string | null; priceCents: number; unit: string; imageUrl: string | null; isActive: boolean; stock: number } | null;
  category: { id: string; name: string; nameKm: string | null } | null;
}

export type DiscountType = "PERCENT" | "FIXED";

export interface DiscountCode {
  id: string;
  code: string;
  description: string | null;
  descriptionKm: string | null;
  type: DiscountType;
  /** PERCENT: 1–100. FIXED: US cents. */
  value: number;
  maxDiscountCents: number | null;
  minSubtotalCents: number;
  newCustomersOnly: boolean;
  oncePerCustomer: boolean;
  /** Orders that used this code. */
  uses: number;
  startsAt: string | null;
  endsAt: string | null;
  isActive: boolean;
  status: "LIVE" | "SCHEDULED" | "ENDED" | "OFF";
  createdAt: string;
}
