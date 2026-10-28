import { ApiProperty, ApiPropertyOptional, PartialType } from "@nestjs/swagger";
import { Transform, Type } from "class-transformer";
import {
  IsBoolean,
  IsIn,
  IsInt,
  IsOptional,
  IsString,
  IsUUID,
  Max,
  MaxLength,
  Min,
  MinLength,
} from "class-validator";

const trim = ({ value }: { value: unknown }) =>
  typeof value === "string" ? value.trim() : value;
const emptyToNull = ({ value }: { value: unknown }) => {
  if (typeof value !== "string") return value;
  const v = value.trim();
  return v === "" ? null : v;
};

export class CreateProductDto {
  @ApiProperty() @IsUUID() categoryId: string;

  @ApiProperty({ example: "Kampot black pepper" })
  @Transform(trim) @IsString() @MinLength(2) @MaxLength(120)
  name: string;

  @ApiPropertyOptional({ example: "ម្រេចខ្មៅកំពត" })
  @IsOptional() @Transform(emptyToNull) @IsString() @MaxLength(120)
  nameKm?: string | null;

  @ApiPropertyOptional()
  @IsOptional() @Transform(emptyToNull) @IsString() @MaxLength(2000)
  description?: string | null;

  @ApiPropertyOptional({ example: "Kampot, Cambodia" })
  @IsOptional() @Transform(emptyToNull) @IsString() @MaxLength(120)
  origin?: string | null;

  @ApiProperty({ example: 650, description: "US cents (650 = $6.50)" })
  @Type(() => Number) @IsInt() @Min(0) @Max(10_000_000)
  priceCents: number;

  @ApiProperty({ example: 40 })
  @Type(() => Number) @IsInt() @Min(0) @Max(1_000_000)
  stock: number;

  @ApiProperty({ example: "kg" })
  @Transform(trim) @IsString() @MinLength(1) @MaxLength(20)
  unit: string;

  @ApiPropertyOptional({ default: true })
  @IsOptional() @IsBoolean()
  isActive?: boolean;
}

export class UpdateProductDto extends PartialType(CreateProductDto) {}

export class AdminListProductsDto {
  @ApiPropertyOptional() @IsOptional() @Transform(trim) @IsString() @MaxLength(80)
  q?: string;

  @ApiPropertyOptional() @IsOptional() @IsUUID()
  categoryId?: string;

  @ApiPropertyOptional({ enum: ["all", "low", "out", "hidden"], default: "all" })
  @IsOptional() @IsIn(["all", "low", "out", "hidden"])
  filter: "all" | "low" | "out" | "hidden" = "all";

  @ApiPropertyOptional({ default: 1 }) @IsOptional() @Type(() => Number) @IsInt() @Min(1)
  page: number = 1;

  @ApiPropertyOptional({ default: 20 }) @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(100)
  limit: number = 20;
}
