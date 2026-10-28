import { ApiProperty } from "@nestjs/swagger";
import { Transform } from "class-transformer";
import { IsString, Matches, MaxLength } from "class-validator";
import { KH_PHONE_REGEX, normalizePhone } from "../../common/phone.util";

export class LoginDto {
  @ApiProperty({ example: "012345678" })
  @Transform(({ value }) => normalizePhone(value))
  @Matches(KH_PHONE_REGEX, { message: "Invalid Cambodian phone number" })
  phone: string;

  @ApiProperty()
  @IsString()
  @MaxLength(64)
  password: string;
}
