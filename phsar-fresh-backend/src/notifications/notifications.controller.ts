import { Controller, Get, Injectable, Module, UseGuards } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { AuthUser, CurrentUser } from "../auth/dto/current-user.decorator";
import { OptionalJwtAuthGuard } from "../auth/optional-jwt.guard";
import { PrismaService } from "../prisma/prisma.service";
import { CacheService } from "../redis/redis.module";
import { liveNow } from "../promotions/promotion-window";

/** Older news drops off the bell. */
const WINDOW_DAYS = 30;
const LIMIT = 40;

@Injectable()
export class NotificationsService {
  constructor(private readonly prisma: PrismaService, private readonly cache: CacheService) {}

  /**
   * Live promotions and, when signed in, what happened to the customer's
   * orders, newest first. Read state stays on the device.
   */
  async feed(userId?: string) {
    const since = new Date(Date.now() - WINDOW_DAYS * 86_400_000);
    const [promotions, events, messages] = await Promise.all([
      // The same for everyone (every phone polls this every 30 s): cached.
      this.cache.remember("promotions", "feed", 60, () => this.prisma.promotion.findMany({
        where: { AND: [liveNow(), { OR: [{ startsAt: { gte: since } }, { startsAt: null, createdAt: { gte: since } }] }] },
        orderBy: { createdAt: "desc" },
        take: LIMIT,
      })),
      userId
        ? this.prisma.orderEvent.findMany({
            where: {
              createdAt: { gte: since },
              order: { userId },
              NOT: [
                // The customer's own cancel needs no alert.
                { source: "APP", status: "CANCELLED" },
                // An ABA Pay order only counts once it's paid.
                { status: "PENDING", order: { paymentMethod: "ABA_PAY" } },
              ],
            },
            include: { order: { select: { id: true, totalCents: true, paymentMethod: true } } },
            orderBy: { createdAt: "desc" },
            take: LIMIT,
          })
        : [],
      userId
        ? this.prisma.orderMessage.findMany({
            where: { createdAt: { gte: since }, order: { userId } },
            include: { order: { select: { id: true } } },
            orderBy: { createdAt: "desc" },
            take: LIMIT,
          })
        : [],
    ]);
    return [
      ...promotions.map((p) => ({
        id: `promotion:${p.id}`,
        type: "PROMOTION" as const,
        at: p.startsAt ?? p.createdAt,
        promotion: { id: p.id, title: p.title, titleKm: p.titleKm, body: p.body, bodyKm: p.bodyKm },
      })),
      // A cancel that came with a reason is told by its message instead.
      ...events
        .filter((e) => !(e.status === "CANCELLED" && messages.some((m) => m.kind === "CANCELLED" && m.order.id === e.order.id)))
        .map((e) => ({
          id: `order:${e.id}`,
          type: "ORDER" as const,
          at: e.createdAt,
          order: {
            id: e.order.id,
            code: `PF-${e.order.id.slice(0, 6).toUpperCase()}`,
            status: e.status,
            totalCents: e.order.totalCents,
            paymentMethod: e.order.paymentMethod,
          },
        })),
      // A note from the market team about one order.
      ...messages.map((m) => ({
        id: `message:${m.id}`,
        type: "MESSAGE" as const,
        at: m.createdAt,
        order: { id: m.order.id, code: `PF-${m.order.id.slice(0, 6).toUpperCase()}` },
        message: { kind: m.kind, body: m.body },
      })),
    ]
      .sort((a, b) => b.at.getTime() - a.at.getTime())
      .slice(0, LIMIT);
  }
}

/** Guests get promotions; a signed-in customer also gets their order updates. */
@ApiTags("notifications")
@UseGuards(OptionalJwtAuthGuard)
@Controller("notifications")
export class NotificationsController {
  constructor(private readonly notifications: NotificationsService) {}

  @Get() feed(@CurrentUser() user: AuthUser | undefined) { return this.notifications.feed(user?.id); }
}

@Module({ controllers: [NotificationsController], providers: [NotificationsService] })
export class NotificationsModule {}
