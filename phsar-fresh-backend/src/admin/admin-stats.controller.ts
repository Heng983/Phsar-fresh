import { Controller, Get, Injectable, Query } from "@nestjs/common";
import { ApiPropertyOptional, ApiTags } from "@nestjs/swagger";
import { OrderStatus } from "@prisma/client";
import { Type } from "class-transformer";
import { IsIn, IsOptional } from "class-validator";
import { PrismaService } from "../prisma/prisma.service";
import { CacheService } from "../redis/redis.module";
import { AdminOnly, Can, LOW_STOCK } from "./admin.decorator";

/** Cambodia is UTC+7 all year (no daylight saving). Days and hours are bucketed in local time. */
const TZ_MS = 7 * 60 * 60 * 1000;
const DAY_MS = 24 * 60 * 60 * 1000;
/** Orders that count as money in. */
const PAID: OrderStatus[] = ["PAID", "PREPARING", "DELIVERING", "DELIVERED"];

class StatsQueryDto {
  @ApiPropertyOptional({ enum: [7, 30], default: 7 })
  @IsOptional() @Type(() => Number) @IsIn([7, 30])
  days: 7 | 30 = 7;
}

function localDayStart(ms: number) {
  return Math.floor((ms + TZ_MS) / DAY_MS) * DAY_MS - TZ_MS;
}

@Injectable()
export class AdminStatsService {
  constructor(private readonly prisma: PrismaService, private readonly cache: CacheService) {}

  /** Reads every order of the period: cached 30 s, cleared when an order changes in the admin. */
  dashboard(days: number) {
    return this.cache.remember("dashboard", `d:${days}`, 30, () => this.load(days));
  }

  private async load(days: number) {
    const now = Date.now();
    const todayStart = localDayStart(now);
    const from = new Date(todayStart - (days - 1) * DAY_MS);
    const prevFrom = new Date(from.getTime() - days * DAY_MS);

    const [orders, prevOrders, lowStock, pending] = await Promise.all([
      this.prisma.order.findMany({ where: { createdAt: { gte: from } }, select: { id: true, createdAt: true, totalCents: true, status: true } }),
      this.prisma.order.findMany({ where: { createdAt: { gte: prevFrom, lt: from } }, select: { createdAt: true, totalCents: true, status: true } }),
      this.prisma.product.findMany({
        where: { isActive: true, stock: { lte: LOW_STOCK } },
        orderBy: [{ stock: "asc" }, { name: "asc" }],
        take: 8,
        select: { id: true, name: true, nameKm: true, stock: true, unit: true, imageUrl: true },
      }),
      this.prisma.order.count({ where: { status: "PENDING" } }),
    ]);

    const summarise = (list: { totalCents: number; status: OrderStatus }[]) => {
      const paid = list.filter((o) => PAID.includes(o.status));
      const revenueCents = paid.reduce((s, o) => s + o.totalCents, 0);
      const cancelled = list.filter((o) => o.status === "CANCELLED").length;
      return {
        revenueCents,
        orders: list.length,
        avgBasketCents: paid.length ? Math.round(revenueCents / paid.length) : 0,
        cancellationRate: list.length ? cancelled / list.length : 0,
      };
    };

    const cur = summarise(orders);
    const prev = summarise(prevOrders);
    const delta = (a: number, b: number) => (b === 0 ? (a === 0 ? 0 : 100) : Math.round(((a - b) / b) * 1000) / 10);

    // revenue per day, this period and the one before
    const revenueByDay = Array.from({ length: days }, (_, i) => {
      const start = from.getTime() + i * DAY_MS;
      const sum = (list: { createdAt: Date; totalCents: number; status: OrderStatus }[], offset: number) =>
        list
          .filter((o) => PAID.includes(o.status) && o.createdAt.getTime() >= start - offset && o.createdAt.getTime() < start - offset + DAY_MS)
          .reduce((s, o) => s + o.totalCents, 0);
      return { date: new Date(start + TZ_MS).toISOString().slice(0, 10), revenueCents: sum(orders, 0), previousCents: sum(prevOrders, days * DAY_MS) };
    });

    // orders per local hour, today
    const ordersByHour = Array.from({ length: 24 }, (_, hour) => ({ hour, orders: 0 }));
    for (const o of orders) {
      const t = o.createdAt.getTime();
      if (t >= todayStart) ordersByHour[Math.floor((t - todayStart) / (60 * 60 * 1000))].orders += 1;
    }

    // best sellers in the period
    const ids = orders.filter((o) => o.status !== "CANCELLED").map((o) => o.id);
    const grouped = ids.length
      ? await this.prisma.orderItem.groupBy({
          by: ["productId"],
          where: { orderId: { in: ids } },
          _sum: { qty: true, priceCents: true },
          orderBy: { _sum: { qty: "desc" } },
          take: 5,
        })
      : [];
    const names = await this.prisma.product.findMany({
      where: { id: { in: grouped.map((g) => g.productId) } },
      select: { id: true, name: true, nameKm: true, unit: true },
    });
    const topProducts = grouped.map((g) => {
      const p = names.find((n) => n.id === g.productId);
      return { productId: g.productId, name: p?.name ?? "Deleted product", nameKm: p?.nameKm ?? null, unit: p?.unit ?? "", qty: g._sum.qty ?? 0 };
    });

    return {
      days,
      totals: cur,
      deltas: {
        revenue: delta(cur.revenueCents, prev.revenueCents),
        orders: delta(cur.orders, prev.orders),
        avgBasket: delta(cur.avgBasketCents, prev.avgBasketCents),
        cancellationRate: Math.round((cur.cancellationRate - prev.cancellationRate) * 1000) / 10,
      },
      revenueByDay,
      ordersByHour,
      topProducts,
      lowStock,
      lowStockThreshold: LOW_STOCK,
      pendingOrders: pending,
    };
  }
}

@ApiTags("admin")
@AdminOnly()
@Controller("admin/stats")
export class AdminStatsController {
  constructor(private readonly stats: AdminStatsService) {}

  @Can("dashboard.view")
  @Get("dashboard") dashboard(@Query() dto: StatsQueryDto) { return this.stats.dashboard(dto.days); }
}
