import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { PaymentMethod } from "@prisma/client";
import { Transform, Type } from "class-transformer";
import {
  ArrayMaxSize, ArrayMinSize, IsArray, IsEnum, IsInt, IsLatitude, IsLongitude, IsOptional, IsString,
  IsUUID, Max, MaxLength, Min, ValidateNested,
} from "class-validator";

const text = ({ value }: { value: unknown }) => {
  if (typeof value !== "string") return value;
  const v = value.trim();
  return v === "" ? undefined : v;
};

export class OrderItemDto {
  @ApiProperty() @IsUUID()
  productId: string;

  @ApiProperty({ minimum: 1, maximum: 99 }) @Type(() => Number) @IsInt() @Min(1) @Max(99)
  qty: number;
}

export class OrderAddressDto {
  @ApiProperty() @Type(() => Number) @IsLatitude()
  lat: number;

  @ApiProperty() @Type(() => Number) @IsLongitude()
  lng: number;

  @ApiPropertyOptional({ example: "House 12, Street 302, BKK1" }) @IsOptional() @Transform(text) @IsString() @MaxLength(300)
  text?: string;
}

export class CreateOrderDto {
  @ApiProperty({ type: [OrderItemDto] })
  @IsArray() @ArrayMinSize(1) @ArrayMaxSize(50) @ValidateNested({ each: true }) @Type(() => OrderItemDto)
  items: OrderItemDto[];

  @ApiProperty({ type: OrderAddressDto }) @ValidateNested() @Type(() => OrderAddressDto)
  address: OrderAddressDto;

  @ApiPropertyOptional({ enum: PaymentMethod }) @IsOptional() @IsEnum(PaymentMethod)
  paymentMethod?: PaymentMethod;

  @ApiPropertyOptional() @IsOptional() @Transform(text) @IsString() @MaxLength(32)
  voucherCode?: string;

  @ApiPropertyOptional() @IsOptional() @Transform(text) @IsString() @MaxLength(80)
  recipientName?: string;

  @ApiPropertyOptional() @IsOptional() @Transform(text) @IsString() @MaxLength(20)
  recipientPhone?: string;

  @ApiPropertyOptional({ description: "Delivery window and instructions" }) @IsOptional() @Transform(text) @IsString() @MaxLength(500)
  note?: string;
}
