import {
  BadRequestException, Body, ConflictException, Controller, Delete, Get,
  Injectable, NotFoundException, Param, ParseUUIDPipe, Patch, Post,
  UploadedFile, UseInterceptors,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { ApiBody, ApiConsumes, ApiTags } from "@nestjs/swagger";
import { Prisma } from "@prisma/client";
import { randomBytes } from "crypto";
import { promises as fs } from "fs";
import { memoryStorage } from "multer";
import { basename, join } from "path";
import sharp from "sharp";
import { PrismaService } from "../prisma/prisma.service";
import { AdminOnly, Can } from "./admin.decorator";
import { CreateCategoryDto, UpdateCategoryDto } from "./dto/admin-category.dto";

@Injectable()
export class AdminCategoriesService {
  // Must match the static folder served at /uploads in main.ts.
  private readonly imageDir = join(process.cwd(), "uploads", "categories");

  constructor(private readonly prisma: PrismaService) {}

  async list() {
    const rows = await this.prisma.category.findMany({
      orderBy: { name: "asc" },
      include: {
        _count: { select: { products: true } },
        products: { where: { imageUrl: { not: null } }, select: { imageUrl: true }, orderBy: { name: "asc" }, take: 10 },
      },
    });
    return rows.map((c) => {
      const fallback = c.products.map((p) => p.imageUrl).find((u) => !!u && !u.includes("placehold.co")) ?? null;
      return {
        id: c.id,
        name: c.name,
        nameKm: c.nameKm,
        productCount: c._count.products,
        imageUrl: c.imageUrl, // the uploaded photo (null = none)
        coverUrl: c.imageUrl ?? fallback, // what the app shows
        coverSource: c.imageUrl ? "uploaded" : fallback ? "product" : "none",
      };
    });
  }

  async create(dto: CreateCategoryDto) {
    try {
      return await this.prisma.category.create({ data: dto });
    } catch (e) {
      throw this.mapError(e);
    }
  }

  async update(id: string, dto: UpdateCategoryDto) {
    try {
      return await this.prisma.category.update({ where: { id }, data: dto });
    } catch (e) {
      throw this.mapError(e);
    }
  }

  async remove(id: string) {
    const count = await this.prisma.product.count({ where: { categoryId: id } });
    if (count > 0) throw new BadRequestException(`Move or delete its ${count} products first`);
    const current = await this.prisma.category.findUnique({ where: { id } });
    try {
      await this.prisma.category.delete({ where: { id } });
    } catch (e) {
      throw this.mapError(e);
    }
    await this.deleteFile(current?.imageUrl);
    return { deleted: true };
  }

  /**
   * Square 600×600 WebP. The whole picture is fitted inside (nothing cropped) and
   * transparency is kept, so a cut-out PNG stays cut-out on the app's tile colour.
   */
  async setImage(id: string, file: Express.Multer.File) {
    const current = await this.prisma.category.findUnique({ where: { id } });
    if (!current) throw new NotFoundException("Category not found");
    let image: Buffer;
    try {
      image = await sharp(file.buffer, { limitInputPixels: 40_000_000 })
        .rotate()
        .resize(600, 600, { fit: "contain", background: { r: 0, g: 0, b: 0, alpha: 0 } })
        .webp({ quality: 85, alphaQuality: 100 })
        .toBuffer();
    } catch {
      throw new BadRequestException("Invalid image file");
    }
    await fs.mkdir(this.imageDir, { recursive: true });
    const name = `${id}-${randomBytes(6).toString("hex")}.webp`;
    await fs.writeFile(join(this.imageDir, name), image);
    const updated = await this.prisma.category.update({ where: { id }, data: { imageUrl: `/uploads/categories/${name}` } });
    await this.deleteFile(current.imageUrl);
    return updated;
  }

  async removeImage(id: string) {
    const current = await this.prisma.category.findUnique({ where: { id } });
    if (!current) throw new NotFoundException("Category not found");
    const updated = await this.prisma.category.update({ where: { id }, data: { imageUrl: null } });
    await this.deleteFile(current.imageUrl);
    return updated;
  }

  private async deleteFile(url: string | null | undefined) {
    if (!url || !url.startsWith("/uploads/categories/")) return;
    await fs.unlink(join(this.imageDir, basename(url))).catch(() => undefined);
  }

  private mapError(e: unknown) {
    if (e instanceof Prisma.PrismaClientKnownRequestError) {
      if (e.code === "P2002") return new ConflictException("A category with this name already exists");
      if (e.code === "P2025") return new NotFoundException("Category not found");
    }
    return e;
  }
}

@ApiTags("admin")
@AdminOnly()
@Controller("admin/categories")
export class AdminCategoriesController {
  constructor(private readonly categories: AdminCategoriesService) {}

  @Can("products.view")
  @Get() list() { return this.categories.list(); }

  @Can("categories.write")
  @Post() create(@Body() dto: CreateCategoryDto) { return this.categories.create(dto); }

  @Can("categories.write")
  @Patch(":id") update(@Param("id", ParseUUIDPipe) id: string, @Body() dto: UpdateCategoryDto) {
    return this.categories.update(id, dto);
  }

  @Can("categories.write")
  @Delete(":id") remove(@Param("id", ParseUUIDPipe) id: string) { return this.categories.remove(id); }

  @Can("categories.write")
  @Post(":id/image")
  @ApiConsumes("multipart/form-data")
  @ApiBody({ schema: { type: "object", properties: { file: { type: "string", format: "binary" } } } })
  @UseInterceptors(FileInterceptor("file", { storage: memoryStorage(), limits: { fileSize: 5 * 1024 * 1024, files: 1 } }))
  uploadImage(@Param("id", ParseUUIDPipe) id: string, @UploadedFile() file?: Express.Multer.File) {
    if (!file) throw new BadRequestException('No image uploaded (field name must be "file")');
    return this.categories.setImage(id, file);
  }

  @Can("categories.write")
  @Delete(":id/image")
  removeImage(@Param("id", ParseUUIDPipe) id: string) { return this.categories.removeImage(id); }
}
