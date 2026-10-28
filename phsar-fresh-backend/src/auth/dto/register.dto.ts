import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Transform } from "class-transformer";
import {
  IsOptional,
  IsString,
  Matches,
  MaxLength,
  MinLength,
} from "class-validator";
import { KH_PHONE_REGEX, normalizePhone } from "../../common/phone.util";

export class RegisterDto {
  @ApiProperty({ example: "012345678" })
  @Transform(({ value }) => normalizePhone(value))
  @Matches(KH_PHONE_REGEX, { message: "Invalid Cambodian phone number" })
  phone: string;

  @ApiProperty({ example: "MyPass1234", minLength: 8 })
  @IsString()
  @MinLength(8, { message: "Password must be at least 8 characters" })
  @MaxLength(64)
  password: string;

  @ApiPropertyOptional({ example: "Sok Dara" })
  @IsOptional()
  @IsString()
  @MaxLength(80)
  name?: string;
}
