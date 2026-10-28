import { Body, Controller, HttpCode, Module, Post, Req, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiProperty, ApiTags } from "@nestjs/swagger";
import { Throttle } from "@nestjs/throttler";
import { Type } from "class-transformer";
import { IsInt, IsString, Max, MaxLength, Min, MinLength } from "class-validator";
import { AuthUser } from "../auth/dto/current-user.decorator";
import { OptionalJwtAuthGuard } from "../auth/optional-jwt.guard";
import { DiscountsService } from "./discounts.service";

export class CheckDiscountDto {
  @ApiProperty({ example: "KHMERFRESH" }) @IsString() @MinLength(2) @MaxLength(32)
  code: string;

  @ApiProperty({ description: "Cart subtotal in US cents", example: 1250 })
  @Type(() => Number) @IsInt() @Min(0) @Max(100_000_000)
  subtotalCents: number;
}

/**
 * Public: the cart checks a code before checkout. Guests may call it; a signed-in
 * customer's token lets welcome / once-per-customer codes be checked too.
 * Throttled to stop code guessing.
 */
@ApiTags("discounts")
@ApiBearerAuth()
@Controller("discount-codes")
export class DiscountsController {
  constructor(private readonly discounts: DiscountsService) {}

  @Post("check")
  @HttpCode(200)
  @UseGuards(OptionalJwtAuthGuard)
  @Throttle({ default: { ttl: 60_000, limit: 10 } })
  check(@Body() dto: CheckDiscountDto, @Req() req: { user?: AuthUser }) {
    return this.discounts.check(dto.code, dto.subtotalCents, req.user?.id ?? null);
  }
}

@Module({ controllers: [DiscountsController], providers: [DiscountsService], exports: [DiscountsService] })
export class DiscountsModule {}
