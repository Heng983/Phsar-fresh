import { ApiProperty, ApiPropertyOptional, PartialType } from "@nestjs/swagger";
import { DiscountType } from "@prisma/client";
import { Transform, Type } from "class-transformer";
import { IsBoolean, IsDate, IsEnum, IsInt, IsOptional, IsString, Matches, Max, MaxLength, Min, ValidateIf } from "class-validator";

const text = ({ value }: { value: unknown }) => {
  if (typeof value !== "string") return value;
  const v = value.trim();
  return v === "" ? null : v;
};
const date = ({ value }: { value: unknown }) => (value === "" || value === null || value === undefined ? null : new Date(value as string));

export class CreateDiscountCodeDto {
  @ApiProperty({ example: "KHMERFRESH", description: "Letters and digits, stored uppercase" })
  @Transform(({ value }) => (typeof value === "string" ? value.trim().toUpperCase() : value))
  @IsString() @Matches(/^[A-Z0-9_-]{3,24}$/, { message: "Use 3–24 letters, digits, - or _" })
  code: string;

  @ApiPropertyOptional() @IsOptional() @Transform(text) @IsString() @MaxLength(120)
  description?: string | null;

  @ApiPropertyOptional() @IsOptional() @Transform(text) @IsString() @MaxLength(120)
  descriptionKm?: string | null;

  @ApiProperty({ enum: DiscountType }) @IsEnum(DiscountType)
  type: DiscountType;

  @ApiProperty({ description: "PERCENT: 1–100. FIXED: US cents" })
  @Type(() => Number) @IsInt() @Min(1) @Max(10_000_000)
  value: number;

  @ApiPropertyOptional({ description: "Cap in cents, PERCENT only" })
  @IsOptional() @ValidateIf((_, v) => v !== null) @Type(() => Number) @IsInt() @Min(1) @Max(10_000_000)
  maxDiscountCents?: number | null;

  @ApiPropertyOptional({ description: "Minimum cart subtotal in cents" })
  @IsOptional() @Type(() => Number) @IsInt() @Min(0) @Max(10_000_000)
  minSubtotalCents?: number;

  @ApiPropertyOptional({ description: "Only an account's first order (a welcome code); implies once per customer" })
  @IsOptional() @IsBoolean()
  newCustomersOnly?: boolean;

  @ApiPropertyOptional({ description: "Each account may use the code once" })
  @IsOptional() @IsBoolean()
  oncePerCustomer?: boolean;

  @ApiPropertyOptional() @IsOptional() @Transform(date) @ValidateIf((_, v) => v !== null) @IsDate()
  startsAt?: Date | null;

  @ApiPropertyOptional() @IsOptional() @Transform(date) @ValidateIf((_, v) => v !== null) @IsDate()
  endsAt?: Date | null;

  @ApiPropertyOptional() @IsOptional() @IsBoolean()
  isActive?: boolean;
}

export class UpdateDiscountCodeDto extends PartialType(CreateDiscountCodeDto) {}
