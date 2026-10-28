import { Controller, Get, Param, ParseUUIDPipe, Query } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { ListProductsDto } from "./dto/list-product.dto";
import { PopularProductsDto } from "./dto/popular-products.dto";
import { ProductsService } from "./products.service";

/** Public: guests can browse products without logging in. */
@ApiTags("products")
@Controller("products")
export class ProductsController {
  constructor(private readonly products: ProductsService) {}

  @Get()
  list(@Query() dto: ListProductsDto) {
    return this.products.list(dto);
  }

  /** Declared before ":id" so "popular" is not read as a product id. */
  @Get("popular")
  popular(@Query() dto: PopularProductsDto) {
    return this.products.popular(dto);
  }

  @Get(":id")
  findOne(@Param("id", ParseUUIDPipe) id: string) {
    return this.products.findOne(id);
  }
}
