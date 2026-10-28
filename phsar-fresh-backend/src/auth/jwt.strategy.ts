import { ForbiddenException, Injectable, UnauthorizedException } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { PassportStrategy } from "@nestjs/passport";
import { Role } from "@prisma/client";
import { ExtractJwt, Strategy } from "passport-jwt";
import { PrismaService } from "../prisma/prisma.service";
import { CacheService } from "../redis/redis.module";
import { AuthUser } from "./dto/current-user.decorator";

interface JwtPayload {
  sub: string;
  role: Role;
}

interface UserStatus {
  role: Role;
  disabled: boolean;
}

/** How long a user's role / disabled flag is trusted from cache. */
const STATUS_TTL_SECONDS = 60;
export const userStatusKey = (id: string) => `user:status:${id}`;

@Injectable()
export class JwtStrategy extends PassportStrategy(Strategy) {
  constructor(
    config: ConfigService,
    private readonly prisma: PrismaService,
    private readonly cache: CacheService,
  ) {
    super({
      jwtFromRequest: ExtractJwt.fromAuthHeaderAsBearerToken(),
      ignoreExpiration: false,
      secretOrKey: config.getOrThrow<string>("JWT_ACCESS_SECRET"),
      algorithms: ["HS256"],
    });
  }

  /**
   * A valid token is not enough: the account must still exist and be active,
   * and its *current* role is used (not the one in the token). So disabling a
   * staff member or changing their role takes effect within a minute, not
   * when their 15-minute token runs out.
   */
  async validate(payload: JwtPayload): Promise<AuthUser> {
    const key = userStatusKey(payload.sub);
    let status = await this.cache.getJson<UserStatus>(key);
    if (!status) {
      const user = await this.prisma.user.findUnique({ where: { id: payload.sub }, select: { role: true, disabledAt: true } });
      if (!user) throw new UnauthorizedException("This account no longer exists");
      status = { role: user.role, disabled: !!user.disabledAt };
      await this.cache.setJson(key, status, STATUS_TTL_SECONDS);
    }
    if (status.disabled) throw new ForbiddenException("This account is disabled. Ask a super admin.");
    return { id: payload.sub, role: status.role };
  }
}
