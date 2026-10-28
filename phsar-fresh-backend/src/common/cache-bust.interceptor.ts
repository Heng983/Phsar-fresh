import { CallHandler, ExecutionContext, Injectable, NestInterceptor } from "@nestjs/common";
import type { Request } from "express";
import { Observable, from, mergeMap } from "rxjs";
import { CacheGroup, CacheService } from "../redis/redis.module";

/** Which cached answers an admin change makes stale. */
const RULES: [RegExp, CacheGroup[]][] = [
  [/\/admin\/(products|categories)\b/, ["catalog", "promotions"]], // promotions embed products
  [/\/admin\/promotions\b/, ["promotions"]],
  [/\/admin\/orders\b/, ["catalog", "dashboard"]], // cancelling gives stock back
];

/**
 * After any successful admin write (POST/PATCH/PUT/DELETE), clears the caches
 * it affects, so the app shows the change right away instead of after the
 * cache expires.
 */
@Injectable()
export class CacheBustInterceptor implements NestInterceptor {
  constructor(private readonly cache: CacheService) {}

  intercept(ctx: ExecutionContext, next: CallHandler): Observable<unknown> {
    const req = ctx.switchToHttp().getRequest<Request>();
    const groups = req.method === "GET" ? [] : RULES.filter(([re]) => re.test(req.path)).flatMap(([, g]) => g);
    if (groups.length === 0) return next.handle();
    return next.handle().pipe(mergeMap((body) => from(this.cache.bump(...new Set(groups)).then(() => body))));
  }
}
