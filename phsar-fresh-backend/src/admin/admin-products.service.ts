import { BadRequestException, Injectable, NotFoundException } from "@nestjs/common";
import { Prisma } from "@prisma/client";
import { randomBytes } from "crypto";
import { promises as fs } from "fs";
import { basename, join } from "path";
import sharp from "sharp";
import { PrismaService } from "../prisma/prisma.service";
import { LOW_STOCK } from "./admin.decorator";
import { AdminListProductsDto, CreateProductDto, UpdateProductDto } from "./dto/admin-product.dto";

type Row = Prisma.ProductGetPayload<{ include: { category: true } }>;

/** The product as the admin sees it: unlike the app, stock and hidden products are included. */
export function toAdminProduct(p: Row) {
  return {
    id: p.id,
    name: p.name,
    nameKm: p.nameKm,
    description: p.description,
    origin: p.origin,
    unit: p.unit,
    priceCents: p.priceCents,
    stock: p.stock,
    isActive: p.isActive,
    imageUrl: p.imageUrl,
    lowStock: p.stock <= LOW_STOCK,
    category: { id: p.category.id, name: p.category.name, nameKm: p.category.nameKm },
  };
}

@Injectable()
export class AdminProductsService {
  // Must match the static folder served at /uploads in main.ts.
  private readonly imageDir = join(process.cwd(), "uploads", "products");

  constructor(private readonly prisma: PrismaService) {}

  async list(dto: AdminListProductsDto) {
    const like = dto.q ? { contains: dto.q, mode: "insensitive" as const } : undefined;
    const where: Prisma.ProductWhereInput = {
      ...(dto.categoryId && { categoryId: dto.categoryId }),
      ...(like && { OR: [{ name: like }, { nameKm: like }, { origin: like }] }),
      ...(dto.filter === "low" && { stock: { gt: 0, lte: LOW_STOCK } }),
      ...(dto.filter === "out" && { stock: 0 }),
      ...(dto.filter === "hidden" && { isActive: false }),
    };
    const base: Prisma.ProductWhereInput = {
      ...(dto.categoryId && { categoryId: dto.categoryId }),
      ...(like && { OR: [{ name: like }, { nameKm: like }, { origin: like }] }),
    };

    const [rows, total, all, low, out, hidden] = await this.prisma.$transaction([
      this.prisma.product.findMany({
        where,
        include: { category: true },
        orderBy: [{ name: "asc" }],
        skip: (dto.page - 1) * dto.limit,
        take: dto.limit,
      }),
      this.prisma.product.count({ where }),
      this.prisma.product.count({ where: base }),
      this.prisma.product.count({ where: { ...base, stock: { gt: 0, lte: LOW_STOCK } } }),
      this.prisma.product.count({ where: { ...base, stock: 0 } }),
      this.prisma.product.count({ where: { ...base, isActive: false } }),
    ]);

    return {
      items: rows.map(toAdminProduct),
      page: dto.page,
      limit: dto.limit,
      total,
      counts: { all, low, out, hidden },
    };
  }

  async findOne(id: string) {
    const p = await this.prisma.product.findUnique({ where: { id }, include: { category: true } });
    if (!p) throw new NotFoundException("Product not found");
    return toAdminProduct(p);
  }

  async create(dto: CreateProductDto) {
    await this.ensureCategory(dto.categoryId);
    const p = await this.prisma.product.create({
      data: { ...dto, isActive: dto.isActive ?? true },
      include: { category: true },
    });
    return toAdminProduct(p);
  }

  async update(id: string, dto: UpdateProductDto) {
    await this.findOne(id);
    if (dto.categoryId) await this.ensureCategory(dto.categoryId);
    const p = await this.prisma.product.update({ where: { id }, data: dto, include: { category: true } });
    return toAdminProduct(p);
  }

  /** Products that were ever ordered are hidden instead of deleted, so order history stays intact. */
  async remove(id: string) {
    const p = await this.findOne(id);
    const used = await this.prisma.orderItem.count({ where: { productId: id } });
    if (used > 0) {
      await this.prisma.product.update({ where: { id }, data: { isActive: false } });
      return { deleted: false, hidden: true, message: "Product has orders, so it was hidden instead" };
    }
    await this.prisma.product.delete({ where: { id } });
    await this.deleteImage(p.imageUrl);
    return { deleted: true, hidden: false, message: "Product deleted" };
  }

  async setImage(id: string, file: Express.Multer.File) {
    const current = await this.findOne(id);
    let jpeg: Buffer;
    try {
      jpeg = await sharp(file.buffer, { limitInputPixels: 40_000_000 })
        .rotate()
        .resize(1000, 1000, { fit: "cover" })
        .webp({ quality: 84, alphaQuality: 100 }) // WebP keeps transparent backgrounds
        .toBuffer();
    } catch {
      throw new BadRequestException("Invalid image file");
    }
    await fs.mkdir(this.imageDir, { recursive: true });
    const name = `${id}-${randomBytes(6).toString("hex")}.webp`;
    await fs.writeFile(join(this.imageDir, name), jpeg);

    const p = await this.prisma.product.update({
      where: { id },
      data: { imageUrl: `/uploads/products/${name}` },
      include: { category: true },
    });
    await this.deleteImage(current.imageUrl);
    return toAdminProduct(p);
  }

  private async ensureCategory(id: string) {
    const c = await this.prisma.category.findUnique({ where: { id } });
    if (!c) throw new BadRequestException("Category not found");
  }

  private async deleteImage(url: string | null) {
    if (!url || !url.startsWith("/uploads/products/")) return;
    await fs.unlink(join(this.imageDir, basename(url))).catch(() => undefined);
  }
}
