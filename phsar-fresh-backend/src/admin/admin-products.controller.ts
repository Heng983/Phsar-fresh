import {
  BadRequestException, Body, Controller, ForbiddenException, Delete, Get, Param, ParseUUIDPipe,
  Patch, Post, Query, UploadedFile, UseInterceptors,
} from "@nestjs/common";
import { FileInterceptor } from "@nestjs/platform-express";
import { ApiBody, ApiConsumes, ApiTags } from "@nestjs/swagger";
import { memoryStorage } from "multer";
import { AuthUser, CurrentUser } from "../auth/dto/current-user.decorator";
import { AdminOnly, Can } from "./admin.decorator";
import { PermissionsService } from "./permissions.service";
import { AdminProductsService } from "./admin-products.service";
import { AdminListProductsDto, CreateProductDto, UpdateProductDto } from "./dto/admin-product.dto";

@ApiTags("admin")
@AdminOnly()
@Controller("admin/products")
export class AdminProductsController {
  constructor(private readonly products: AdminProductsService, private readonly permissions: PermissionsService) {}

  @Can("products.view")
  @Get() list(@Query() dto: AdminListProductsDto) { return this.products.list(dto); }

  @Can("products.view")
  @Get(":id") findOne(@Param("id", ParseUUIDPipe) id: string) { return this.products.findOne(id); }

  @Can("products.write")
  @Post() create(@Body() dto: CreateProductDto) { return this.products.create(dto); }

  /** Staff may only change stock; everything else needs products.write. */
  @Can("products.stock")
  @Patch(":id")
  async update(@Param("id", ParseUUIDPipe) id: string, @Body() dto: UpdateProductDto, @CurrentUser() user: AuthUser) {
    if (!(await this.permissions.can(user.role, "products.write")) && Object.keys(dto).some((k) => k !== "stock")) {
      throw new ForbiddenException("Your role can only change stock");
    }
    return this.products.update(id, dto);
  }

  @Can("products.delete")
  @Delete(":id") remove(@Param("id", ParseUUIDPipe) id: string) { return this.products.remove(id); }

  @Can("products.write")
  @Post(":id/image")
  @ApiConsumes("multipart/form-data")
  @ApiBody({ schema: { type: "object", properties: { file: { type: "string", format: "binary" } } } })
  @UseInterceptors(FileInterceptor("file", { storage: memoryStorage(), limits: { fileSize: 5 * 1024 * 1024, files: 1 } }))
  uploadImage(@Param("id", ParseUUIDPipe) id: string, @UploadedFile() file?: Express.Multer.File) {
    if (!file) throw new BadRequestException('No image uploaded (field name must be "file")');
    return this.products.setImage(id, file);
  }
}
