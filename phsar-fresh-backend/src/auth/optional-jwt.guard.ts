import { ExecutionContext, Injectable } from "@nestjs/common";
import { AuthGuard } from "@nestjs/passport";

/**
 * Lets guests through (req.user stays undefined) but still checks a token
 * when one is sent — an expired token gets 401 so the app refreshes it.
 */
@Injectable()
export class OptionalJwtAuthGuard extends AuthGuard("jwt") {
  canActivate(context: ExecutionContext) {
    const req = context.switchToHttp().getRequest<{ headers: Record<string, string | undefined> }>();
    if (!req.headers.authorization) return true;
    return super.canActivate(context);
  }
}
