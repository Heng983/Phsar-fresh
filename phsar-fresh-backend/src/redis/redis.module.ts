import { Global, Inject, Injectable, Logger, Module, OnModuleDestroy } from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { createHash } from "crypto";
import Redis from "ioredis";

export const REDIS = "REDIS_CLIENT";

/** Groups of cached answers that are cleared together. */
export type CacheGroup = "catalog" | "promotions" | "dashboard";

/**
 * Small Redis cache for answers many people ask for at once (the product
 * list, categories, banners). Each group has a version number: bumping it
 * makes every old entry unreachable at once, so admin changes show up
 * immediately. If Redis is slow or down the API just reads the database.
 */
@Injectable()
export class CacheService {
  private readonly log = new Logger("Cache");
  private static readonly TIMEOUT_MS = 150;

  constructor(@Inject(REDIS) private readonly redis: Redis) {}

  /** Stable short key for a set of query parameters. */
  static key(parts: unknown) {
    return createHash("sha1").update(JSON.stringify(parts)).digest("base64url").slice(0, 22);
  }

  /** After a failure, skip Redis for a few seconds instead of waiting on it for every request. */
  private downUntil = 0;
  private static readonly PAUSE_MS = 5_000;

  private quick<T>(p: () => Promise<T>): Promise<T | null> {
    if (Date.now() < this.downUntil) return Promise.resolve(null);
    const fail = (why: string) => {
      if (Date.now() >= this.downUntil) this.log.warn(`redis ${why}: reading the database for ${CacheService.PAUSE_MS / 1000}s`);
      this.downUntil = Date.now() + CacheService.PAUSE_MS;
      return null;
    };
    return new Promise<T | null>((resolve) => {
      const timer = setTimeout(() => resolve(fail("timed out")), CacheService.TIMEOUT_MS);
      timer.unref();
      p().then(
        (value) => {
          clearTimeout(timer);
          resolve(value);
        },
        (e: Error) => {
          clearTimeout(timer);
          resolve(fail(e.message));
        },
      );
    });
  }

  /** Cached [load()] for [ttlSeconds]; always falls back to [load()]. */
  async remember<T>(group: CacheGroup, key: string, ttlSeconds: number, load: () => Promise<T>): Promise<T> {
    const version = (await this.quick(() => this.redis.get(`cache:${group}:v`))) ?? "0";
    const fullKey = `cache:${group}:${version}:${key}`;
    const hit = await this.quick(() => this.redis.get(fullKey));
    if (hit) {
      try {
        return JSON.parse(hit, reviveDates) as T;
      } catch {
        /* corrupt entry: load fresh */
      }
    }
    const value = await load();
    void this.quick(() => this.redis.set(fullKey, JSON.stringify(value), "EX", ttlSeconds));
    return value;
  }

  /** Makes every cached answer of these groups stale right away. */
  async bump(...groups: CacheGroup[]) {
    await Promise.all(groups.map((g) => this.quick(() => this.redis.incr(`cache:${g}:v`))));
  }

  /** Plain key/value with expiry (e.g. a user's status). */
  async getJson<T>(key: string): Promise<T | null> {
    const raw = await this.quick(() => this.redis.get(key));
    try {
      return raw ? (JSON.parse(raw) as T) : null;
    } catch {
      return null;
    }
  }

  async setJson(key: string, value: unknown, ttlSeconds: number) {
    await this.quick(() => this.redis.set(key, JSON.stringify(value), "EX", ttlSeconds));
  }

  async del(key: string) {
    await this.quick(() => this.redis.del(key));
  }
}

/** Dates went into the cache as ISO strings; bring them back as Dates. */
const ISO = /^\d{4}-\d{2}-\d{2}T\d{2}:\d{2}:\d{2}(\.\d+)?Z$/;
function reviveDates(_key: string, value: unknown) {
  return typeof value === "string" && ISO.test(value) ? new Date(value) : value;
}

@Global()
@Module({
  providers: [
    {
      provide: REDIS,
      inject: [ConfigService],
      useFactory: (config: ConfigService) =>
        new Redis(config.getOrThrow<string>("REDIS_URL"), {
          // Fail fast instead of piling requests up while Redis is down.
          maxRetriesPerRequest: 2,
          connectTimeout: 5_000,
        }),
    },
    CacheService,
  ],
  exports: [REDIS, CacheService],
})
export class RedisModule implements OnModuleDestroy {
  constructor(@Inject(REDIS) private readonly redis: Redis) {}

  async onModuleDestroy() {
    await this.redis.quit();
  }
}
