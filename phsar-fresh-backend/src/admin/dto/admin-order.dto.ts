import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { OrderStatus } from "@prisma/client";
import { Transform, Type } from "class-transformer";
import { IsEnum, IsIn, IsInt, IsISO8601, IsNotEmpty, IsOptional, IsString, Max, MaxLength, Min } from "class-validator";

export class AdminListOrdersDto {
  @ApiPropertyOptional({ enum: OrderStatus })
  @IsOptional() @IsEnum(OrderStatus)
  status?: OrderStatus;

  @ApiPropertyOptional({ description: "Order id start, customer name or phone" })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString() @MaxLength(80)
  q?: string;

  @ApiPropertyOptional({ default: 1 }) @IsOptional() @Type(() => Number) @IsInt() @Min(1)
  page: number = 1;

  @ApiPropertyOptional({ default: 20 }) @IsOptional() @Type(() => Number) @IsInt() @Min(1) @Max(100)
  limit: number = 20;
}

export class UpdateOrderStatusDto {
  @ApiProperty({ enum: OrderStatus })
  @IsEnum(OrderStatus)
  status: OrderStatus;

  /** When cancelling: the reason, sent to the customer's app. */
  @ApiPropertyOptional({ maxLength: 500 })
  @IsOptional()
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString() @MaxLength(500)
  message?: string;
}

export const MESSAGE_KINDS = ["INFO", "PROBLEM"] as const;

export class SendOrderMessageDto {
  @ApiProperty({ maxLength: 500 })
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString() @IsNotEmpty() @MaxLength(500)
  body: string;

  @ApiPropertyOptional({ enum: MESSAGE_KINDS, default: "INFO" })
  @IsOptional() @IsIn(MESSAGE_KINDS)
  kind: (typeof MESSAGE_KINDS)[number] = "INFO";
}

export class OrderAlertsDto {
  /** Orders that became actionable after this moment (ISO date). */
  @ApiProperty()
  @IsISO8601()
  since: string;
}
