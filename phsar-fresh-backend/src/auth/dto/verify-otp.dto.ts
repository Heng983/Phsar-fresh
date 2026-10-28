import { ApiProperty } from "@nestjs/swagger";
import { Transform } from "class-transformer";
import { IsString, Length, Matches } from "class-validator";
import { KH_PHONE_REGEX, normalizePhone } from "../../common/phone.util";

export class VerifyOtpDto {
  @ApiProperty({ example: "012345678" })
  @Transform(({ value }) => normalizePhone(value))
  @Matches(KH_PHONE_REGEX, { message: "Invalid Cambodian phone number" })
  phone: string;

  @ApiProperty({ example: "123456" })
  @IsString()
  @Length(6, 6)
  @Matches(/^\d{6}$/, { message: "Code must be 6 digits" })
  code: string;
}
