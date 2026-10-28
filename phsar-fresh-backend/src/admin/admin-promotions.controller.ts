import {
  BadRequestException, Body, Controller, Delete, Get, Injectable, NotFoundException,
  Param, ParseUUIDPipe, Patch, Post, UploadedFile, UseInterceptors,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { ApiBody, ApiConsumes, ApiTags } from "@nestjs/swagger";
import { Prisma, Promotion } from "@prisma/client";
import { randomBytes } from "crypto";
import { promises as fs } from "fs";
import { memoryStorage } from "multer";
import { basename, join } from "path";
import sharp from "sharp";
import { PrismaService } from "../prisma/prisma.service";
import { carouselOrder } from "../promotions/promotion-window";
import { AdminOnly, Can } from "./admin.decorator";
import { CreatePromotionDto, UpdatePromotionDto } from "./dto/admin-promotion.dto";

const include = {
  product: { select: { id: true, name: true, nameKm: true, priceCents: true, unit: true, imageUrl: true, isActive: true, stock: true } },
  category: { select: { id: true, name: true, nameKm: true } },
} satisfies Prisma.PromotionInclude;
type Row = Prisma.PromotionGetPayload<{ include: typeof include }>;

function status(p: Promotion, now = new Date()) {
  if (!p.isActive) return "OFF";
  if (p.startsAt && p.startsAt > now) return "SCHEDULED";
  if (p.endsAt && p.endsAt <= now) return "ENDED";
  return "LIVE";
}

const toAdmin = (p: Row) => ({ ...p, status: status(p) });

@Injectable()
export class AdminPromotionsService {
  // Must match the static folder served at /uploads in main.ts.
  private readonly imageDir = join(process.cwd(), "uploads", "promotions");

  constructor(private readonly prisma: PrismaService) {}

  async list() {
    const rows = await this.prisma.promotion.findMany({ include, orderBy: carouselOrder });
    return rows.map(toAdmin);
  }

  async findOne(id: string) {
    const p = await this.prisma.promotion.findUnique({ where: { id }, include });
    if (!p) throw new NotFoundException("Promotion not found");
    return toAdmin(p);
  }

  async create(dto: CreatePromotionDto) {
    const data = await this.check(dto);
    const p = await this.prisma.promotion.create({ data: data as Prisma.PromotionUncheckedCreateInput, include });
    return toAdmin(p);
  }

  async update(id: string, dto: UpdatePromotionDto) {
    const current = await this.findOne(id);
    const data = await this.check({ ...current, ...dto });
    const p = await this.prisma.promotion.update({ where: { id }, data, include });
    return toAdmin(p);
  }

  async remove(id: string) {
    const p = await this.findOne(id);
    await this.prisma.promotion.delete({ where: { id } });
    await this.deleteFile(p.imageUrl);
    return { deleted: true };
  }

  /** Wide banner, 1600×640 (2.5 : 1, the carousel's shape), WebP so transparency survives. */
  async setImage(id: string, file: Express.Multer.File) {
    const current = await this.findOne(id);
    let image: Buffer;
    try {
      image = await sharp(file.buffer, { limitInputPixels: 60_000_000 })
        .rotate()
        .resize(1600, 640, { fit: "cover" })
        .webp({ quality: 85, alphaQuality: 100 })
        .toBuffer();
    } catch {
      throw new BadRequestException("Invalid image file");
    }
    await fs.mkdir(this.imageDir, { recursive: true });
    const name = `${id}-${randomBytes(6).toString("hex")}.webp`;
    await fs.writeFile(join(this.imageDir, name), image);
    const p = await this.prisma.promotion.update({ where: { id }, data: { imageUrl: `/uploads/promotions/${name}` }, include });
    await this.deleteFile(current.imageUrl);
    return toAdmin(p);
  }

  async removeImage(id: string) {
    const current = await this.findOne(id);
    const p = await this.prisma.promotion.update({ where: { id }, data: { imageUrl: null }, include });
    await this.deleteFile(current.imageUrl);
    return toAdmin(p);
  }

  /** Rules that depend on several fields at once. Returns only the columns to save. */
  private async check(d: CreatePromotionDto) {
    const action = d.kind === "DEAL" ? "NONE" : (d.action ?? "NONE");
    if (d.startsAt && d.endsAt && d.endsAt <= d.startsAt) throw new BadRequestException("The end date must be after the start date");

    if (d.kind === "DEAL") {
      if (!d.productId) throw new BadRequestException("Choose the product on sale");
      const product = await this.prisma.product.findUnique({ where: { id: d.productId } });
      if (!product) throw new BadRequestException("Product not found");
      if (d.dealPriceCents == null) throw new BadRequestException("Enter the deal price");
      if (d.dealPriceCents >= product.priceCents) throw new BadRequestException("The deal price must be lower than the normal price");
    }
    if (action === "OPEN_CATEGORY") {
      if (!d.categoryId || !(await this.prisma.category.findUnique({ where: { id: d.categoryId } }))) {
        throw new BadRequestException("Choose the category the button opens");
      }
    }
    if (action === "OPEN_PRODUCT") {
      if (!d.productId || !(await this.prisma.product.findUnique({ where: { id: d.productId } }))) {
        throw new BadRequestException("Choose the product the button opens");
      }
    }

    return {
      kind: d.kind,
      title: d.title,
      titleKm: d.titleKm ?? null,
      body: d.kind === "BANNER" ? (d.body ?? null) : null,
      bodyKm: d.kind === "BANNER" ? (d.bodyKm ?? null) : null,
      buttonLabel: d.kind === "BANNER" && action !== "NONE" ? (d.buttonLabel ?? null) : null,
      buttonLabelKm: d.kind === "BANNER" && action !== "NONE" ? (d.buttonLabelKm ?? null) : null,
      action,
      categoryId: action === "OPEN_CATEGORY" ? d.categoryId : null,
      productId: d.kind === "DEAL" || action === "OPEN_PRODUCT" ? d.productId : null,
      dealPriceCents: d.kind === "DEAL" ? d.dealPriceCents : null,
      startsAt: d.startsAt ?? null,
      endsAt: d.endsAt ?? null,
      ...(d.isActive !== undefined && { isActive: d.isActive }),
      ...(d.sortOrder !== undefined && { sortOrder: d.sortOrder }),
    };
  }

  private async deleteFile(url: string | null | undefined) {
    if (!url || !url.startsWith("/uploads/promotions/")) return;
    await fs.unlink(join(this.imageDir, basename(url))).catch(() => undefined);
  }
}

@ApiTags("admin")
@AdminOnly()
@Can("promotions.write")
@Controller("admin/promotions")
export class AdminPromotionsController {
  constructor(private readonly promotions: AdminPromotionsService) {}

  @Get() list() { return this.promotions.list(); }
  @Get(":id") findOne(@Param("id", ParseUUIDPipe) id: string) { return this.promotions.findOne(id); }
  @Post() create(@Body() dto: CreatePromotionDto) { return this.promotions.create(dto); }
  @Patch(":id") update(@Param("id", ParseUUIDPipe) id: string, @Body() dto: UpdatePromotionDto) { return this.promotions.update(id, dto); }
  @Delete(":id") remove(@Param("id", ParseUUIDPipe) id: string) { return this.promotions.remove(id); }

  @Post(":id/image")
  @ApiConsumes("multipart/form-data")
  @ApiBody({ schema: { type: "object", properties: { file: { type: "string", format: "binary" } } } })
  @UseInterceptors(FileInterceptor("file", { storage: memoryStorage(), limits: { fileSize: 8 * 1024 * 1024, files: 1 } }))
  uploadImage(@Param("id", ParseUUIDPipe) id: string, @UploadedFile() file?: Express.Multer.File) {
    if (!file) throw new BadRequestException('No image uploaded (field name must be "file")');
    return this.promotions.setImage(id, file);
  }

  @Delete(":id/image") removeImage(@Param("id", ParseUUIDPipe) id: string) { return this.promotions.removeImage(id); }
}
