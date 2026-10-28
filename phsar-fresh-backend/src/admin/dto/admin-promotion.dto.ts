import { ApiProperty, ApiPropertyOptional, PartialType } from "@nestjs/swagger";
import { PromotionAction, PromotionKind } from "@prisma/client";
import { Transform, Type } from "class-transformer";
import { IsBoolean, IsDate, IsEnum, IsInt, IsOptional, IsString, IsUUID, Max, MaxLength, Min, MinLength, ValidateIf } from "class-validator";

const text = ({ value }: { value: unknown }) => {
  if (typeof value !== "string") return value;
  const v = value.trim();
  return v === "" ? null : v;
};
const date = ({ value }: { value: unknown }) => (value === "" || value === null || value === undefined ? null : new Date(value as string));

export class CreatePromotionDto {
  @ApiProperty({ enum: PromotionKind }) @IsEnum(PromotionKind)
  kind: PromotionKind;

  @ApiProperty({ example: "Meet Ming Sros, your AI kitchen helper" })
  @Transform(text) @IsString() @MinLength(2) @MaxLength(80)
  title: string;

  @ApiPropertyOptional() @IsOptional() @Transform(text) @IsString() @MaxLength(80)
  titleKm?: string | null;

  @ApiPropertyOptional() @IsOptional() @Transform(text) @IsString() @MaxLength(160)
  body?: string | null;

  @ApiPropertyOptional() @IsOptional() @Transform(text) @IsString() @MaxLength(160)
  bodyKm?: string | null;

  @ApiPropertyOptional({ example: "Ask Ming Sros" }) @IsOptional() @Transform(text) @IsString() @MaxLength(24)
  buttonLabel?: string | null;

  @ApiPropertyOptional() @IsOptional() @Transform(text) @IsString() @MaxLength(24)
  buttonLabelKm?: string | null;

  @ApiPropertyOptional({ enum: PromotionAction }) @IsOptional() @IsEnum(PromotionAction)
  action?: PromotionAction;

  @ApiPropertyOptional() @IsOptional() @ValidateIf((_, v) => v !== null) @IsUUID()
  categoryId?: string | null;

  @ApiPropertyOptional() @IsOptional() @ValidateIf((_, v) => v !== null) @IsUUID()
  productId?: string | null;

  @ApiPropertyOptional({ description: "US cents; deals only" })
  @IsOptional() @ValidateIf((_, v) => v !== null) @Type(() => Number) @IsInt() @Min(0) @Max(10_000_000)
  dealPriceCents?: number | null;

  @ApiPropertyOptional() @IsOptional() @Transform(date) @ValidateIf((_, v) => v !== null) @IsDate()
  startsAt?: Date | null;

  @ApiPropertyOptional() @IsOptional() @Transform(date) @ValidateIf((_, v) => v !== null) @IsDate()
  endsAt?: Date | null;

  @ApiPropertyOptional({ default: true }) @IsOptional() @IsBoolean()
  isActive?: boolean;

  @ApiPropertyOptional({ default: 0, description: "Lower shows first" })
  @IsOptional() @Type(() => Number) @IsInt() @Min(0) @Max(999)
  sortOrder?: number;
}

export class UpdatePromotionDto extends PartialType(CreatePromotionDto) {}
