import { Logger, OnModuleDestroy } from "@nestjs/common";
import { OnGatewayConnection, OnGatewayInit, WebSocketGateway } from "@nestjs/websockets";
import type { Namespace, Socket } from "socket.io";
import { PermissionsService } from "../admin/permissions.service";
import { PrismaService } from "../prisma/prisma.service";
import { RealtimeService, ROOM_DELIVERIES, ROOM_ORDERS } from "./realtime.service";

/** Re-check every open connection this often (disabled staff, changed roles). */
const RECHECK_MS = 60_000;

/**
 * Browsers allowed to connect: CORS_ORIGINS (comma separated), or any origin
 * outside production. Read on every request because .env is loaded after
 * this file is imported.
 */
function allowedOrigin(origin: string | undefined, cb: (err: Error | null, allow?: boolean) => void) {
  const list = (process.env.CORS_ORIGINS ?? "").split(",").map((o) => o.trim()).filter(Boolean);
  if (!origin) return cb(null, true); // not a browser
  if (list.length) return cb(null, list.includes(origin));
  cb(null, process.env.NODE_ENV !== "production");
}

/**
 * Live updates for the admin panel at ws(s)://<api>/admin (Socket.io).
 * Connect with { auth: { ticket } } from POST /api/v1/admin/orders/live-ticket.
 */
@WebSocketGateway({
  namespace: "/admin",
  cors: { origin: allowedOrigin, credentials: true },
  pingInterval: 25_000,
  pingTimeout: 20_000,
})
export class AdminGateway implements OnGatewayInit, OnGatewayConnection, OnModuleDestroy {
  private readonly log = new Logger("AdminGateway");
  private recheck?: NodeJS.Timeout;

  constructor(
    private readonly realtime: RealtimeService,
    private readonly prisma: PrismaService,
    private readonly permissions: PermissionsService,
  ) {}

  afterInit(nsp: Namespace) {
    this.realtime.attach(nsp);
    // Refused here, the browser gets a connect_error with the reason.
    nsp.use((socket, next) => {
      void (async () => {
        const userId = await this.realtime.redeemTicket(socket.handshake.auth?.ticket);
        if (!userId) return next(new Error("UNAUTHORIZED"));
        const rooms = await this.roomsFor([userId]);
        if (!rooms.get(userId)?.length) return next(new Error("FORBIDDEN"));
        socket.data.userId = userId;
        socket.data.rooms = rooms.get(userId);
        next();
      })().catch((e: Error) => {
        this.log.warn(`connection refused: ${e.message}`);
        next(new Error("UNAVAILABLE"));
      });
    });
    this.recheck = setInterval(() => void this.recheckAll(nsp), RECHECK_MS);
    this.recheck.unref();
  }

  async handleConnection(socket: Socket) {
    await socket.join(socket.data.rooms as string[]);
  }

  onModuleDestroy() {
    if (this.recheck) clearInterval(this.recheck);
  }

  /** Which rooms each user may be in right now ([] = none: disconnect). */
  private async roomsFor(userIds: string[]) {
    const users = await this.prisma.user.findMany({ where: { id: { in: userIds } }, select: { id: true, role: true, disabledAt: true } });
    const out = new Map<string, string[]>();
    for (const u of users) {
      if (u.disabledAt) continue;
      const perms = await this.permissions.forRole(u.role);
      const rooms: string[] = [];
      if (perms.includes("orders.view")) rooms.push(ROOM_ORDERS);
      if (perms.includes("orders.deliver")) rooms.push(ROOM_DELIVERIES);
      out.set(u.id, rooms);
    }
    return out;
  }

  /** A disabled account or a role that lost access stops receiving at once (within a minute). */
  private async recheckAll(nsp: Namespace) {
    try {
      const sockets = [...nsp.sockets.values()];
      if (sockets.length === 0) return;
      const rooms = await this.roomsFor([...new Set(sockets.map((s) => s.data.userId as string))]);
      for (const s of sockets) {
        const allowed = rooms.get(s.data.userId) ?? [];
        if (allowed.length === 0) {
          s.disconnect(true);
          continue;
        }
        for (const r of [ROOM_ORDERS, ROOM_DELIVERIES]) {
          if (allowed.includes(r)) void s.join(r);
          else void s.leave(r);
        }
      }
    } catch (e) {
      this.log.warn(`recheck failed: ${(e as Error).message}`);
    }
  }
}
