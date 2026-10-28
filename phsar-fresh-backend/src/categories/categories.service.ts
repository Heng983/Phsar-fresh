import { Injectable } from "@nestjs/common";
import { PrismaService } from "../prisma/prisma.service";
import { CacheService } from "../redis/redis.module";

/** Generated placeholder images (seed data) never become a category cover. */
const PLACEHOLDER_HOSTS = ["placehold.co"];
const isRealPhoto = (url: string | null | undefined): url is string =>
  !!url && !PLACEHOLDER_HOSTS.some((h) => url.includes(h));

@Injectable()
export class CategoriesService {
  constructor(private readonly prisma: PrismaService, private readonly cache: CacheService) {}

  /**
   * Categories with how many active products they have, and a cover image:
   *   1. the photo an admin uploaded for the category, else
   *   2. the first active product that has a real photo, else
   *   3. null — the app shows its leaf placeholder.
   */
  list() {
    // Same answer for every shopper: cached 60 s, cleared on admin changes.
    return this.cache.remember("catalog", "categories", 60, () => this.load());
  }

  private async load() {
    const rows = await this.prisma.category.findMany({
      orderBy: { name: "asc" },
      include: {
        _count: { select: { products: { where: { isActive: true } } } },
        products: {
          where: { isActive: true, imageUrl: { not: null } },
          select: { imageUrl: true },
          orderBy: { name: "asc" },
          take: 10,
        },
      },
    });

    return rows.map((c) => ({
      id: c.id,
      name: c.name,
      nameKm: c.nameKm,
      productCount: c._count.products,
      imageUrl: c.imageUrl ?? c.products.map((p) => p.imageUrl).find(isRealPhoto) ?? null,
    }));
  }
}
