import {
  applyDecorators, CanActivate, ExecutionContext, ForbiddenException,
  Injectable, SetMetadata, UseGuards,
} from "@nestjs/common";
import { Reflector } from "@nestjs/core";
import { ApiBearerAuth } from "@nestjs/swagger";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { AuthUser } from "../auth/dto/current-user.decorator";
import { isStaffRole, Permission } from "./permissions";
import { PermissionsService } from "./permissions.service";

const PERMISSION_KEY = "admin:permission";

/** The route needs one of these permissions (granted per role on the Team & roles page). */
export const Can = (...permissions: Permission[]) => SetMetadata(PERMISSION_KEY, permissions);

@Injectable()
export class PermissionGuard implements CanActivate {
  constructor(private readonly reflector: Reflector, private readonly permissions: PermissionsService) {}

  async canActivate(ctx: ExecutionContext): Promise<boolean> {
    const user: AuthUser | undefined = ctx.switchToHttp().getRequest().user;
    if (!user || !isStaffRole(user.role)) throw new ForbiddenException("Admin panel access only");
    const needed = this.reflector.getAllAndOverride<Permission[] | undefined>(PERMISSION_KEY, [ctx.getHandler(), ctx.getClass()]);
    const mine = needed?.length ? await this.permissions.forRole(user.role) : [];
    if (needed?.length && !needed.some((p) => mine.includes(p))) {
      throw new ForbiddenException("Your role doesn't allow this");
    }
    return true;
  }
}

/** Signed in as SUPER_ADMIN, MANAGER, STAFF or DRIVER; add @Can(...) on a route to narrow it further. */
export const AdminOnly = () => applyDecorators(ApiBearerAuth(), UseGuards(JwtAuthGuard, PermissionGuard));

/** Products at or below this stock count are "low stock" in the admin. */
export const LOW_STOCK = 10;
