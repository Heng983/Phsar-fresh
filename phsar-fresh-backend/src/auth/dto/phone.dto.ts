import { ApiProperty } from "@nestjs/swagger";
import { Transform } from "class-transformer";
import { Matches } from "class-validator";
import { KH_PHONE_REGEX, normalizePhone } from "../../common/phone.util";

export class PhoneDto {
  @ApiProperty({ example: "012345678" })
  @Transform(({ value }) => normalizePhone(value))
  @Matches(KH_PHONE_REGEX, { message: "Invalid Cambodian phone number" })
  phone: string;
}
