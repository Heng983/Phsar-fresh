import { ApiProperty, ApiPropertyOptional, PartialType } from "@nestjs/swagger";
import { Transform } from "class-transformer";
import { IsOptional, IsString, MaxLength, MinLength } from "class-validator";

export class CreateCategoryDto {
  @ApiProperty({ example: "Vegetables" })
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString() @MinLength(2) @MaxLength(60)
  name: string;

  @ApiPropertyOptional({ example: "បន្លែ" })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() || null : value))
  @IsString() @MaxLength(60)
  nameKm?: string | null;
}

export class UpdateCategoryDto extends PartialType(CreateCategoryDto) {}
