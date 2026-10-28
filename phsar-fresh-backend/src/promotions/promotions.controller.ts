import { Controller, Get, Injectable, Module } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { PrismaService } from "../prisma/prisma.service";
import { CacheService } from "../redis/redis.module";
import { toPublicProduct } from "../products/product.mapper";
import { carouselOrder, liveNow } from "./promotion-window";

@Injectable()
export class PromotionsService {
  constructor(private readonly prisma: PrismaService, private readonly cache: CacheService) {}

  // Every Explore screen asks for these; 30 s keeps start/end times accurate.
  banners() {
    return this.cache.remember("promotions", "banners", 30, () => this.loadBanners());
  }

  deals() {
    return this.cache.remember("promotions", "deals", 30, () => this.loadDeals());
  }

  /** Live picture banners for the Explore carousel. */
  private async loadBanners() {
    const rows = await this.prisma.promotion.findMany({
      where: { ...liveNow(), kind: "BANNER" },
      orderBy: carouselOrder,
      include: { product: { include: { category: true } } },
    });
    return rows
      // a banner that opens a product needs that product to still be for sale
      .filter((b) => b.action !== "OPEN_PRODUCT" || (b.product && b.product.isActive))
      .filter((b) => b.action !== "OPEN_CATEGORY" || b.categoryId)
      .map((b) => ({
        id: b.id,
        title: b.title,
        titleKm: b.titleKm,
        body: b.body,
        bodyKm: b.bodyKm,
        buttonLabel: b.buttonLabel,
        buttonLabelKm: b.buttonLabelKm,
        imageUrl: b.imageUrl,
        action: b.action,
        categoryId: b.action === "OPEN_CATEGORY" ? b.categoryId : null,
        product: b.action === "OPEN_PRODUCT" && b.product ? toPublicProduct(b.product) : null,
        endsAt: b.endsAt,
      }));
  }

  /** Live product deals — the shape the app already reads (priceCents = deal price). */
  private async loadDeals() {
    const rows = await this.prisma.promotion.findMany({
      where: { ...liveNow(), kind: "DEAL", product: { isActive: true, stock: { gt: 0 } } },
      orderBy: carouselOrder,
      include: { product: { include: { category: true } } },
    });
    return rows
      .filter((d) => d.product && d.dealPriceCents != null && d.dealPriceCents < d.product.priceCents)
      .map((d) => ({
        id: d.id,
        title: d.title,
        titleKm: d.titleKm,
        originalPriceCents: d.product!.priceCents,
        endsAt: d.endsAt,
        product: { ...toPublicProduct(d.product!), priceCents: d.dealPriceCents! },
      }));
  }
}

/** Public: guests see the carousel without signing in. */
@ApiTags("promotions")
@Controller()
export class PromotionsController {
  constructor(private readonly promotions: PromotionsService) {}

  @Get("banners") banners() { return this.promotions.banners(); }
  @Get("promotions") deals() { return this.promotions.deals(); }
}

@Module({ controllers: [PromotionsController], providers: [PromotionsService] })
export class PromotionsModule {}
