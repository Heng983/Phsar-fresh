import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Transform } from "class-transformer";
import { IsBoolean, IsIn, IsOptional, IsString, Matches, MaxLength, MinLength } from "class-validator";
import { KH_PHONE_REGEX, normalizePhone } from "../../common/phone.util";
import { STAFF_ROLES, StaffRole } from "../permissions";

const trim = ({ value }: { value: unknown }) => (typeof value === "string" ? value.trim() : value);

export class CreateTeamMemberDto {
  @ApiProperty({ example: "Sok Dara" })
  @Transform(trim) @IsString() @MinLength(2) @MaxLength(60)
  name: string;

  @ApiProperty({ example: "012345678" })
  @Transform(({ value }) => normalizePhone(value))
  @Matches(KH_PHONE_REGEX, { message: "Invalid Cambodian phone number" })
  phone: string;

  @ApiProperty()
  @IsString() @MinLength(8, { message: "Password must be at least 8 characters" }) @MaxLength(64)
  password: string;

  @ApiProperty({ enum: STAFF_ROLES })
  @IsIn(STAFF_ROLES)
  role: StaffRole;
}

export class UpdateTeamMemberDto {
  @ApiPropertyOptional() @IsOptional() @Transform(trim) @IsString() @MinLength(2) @MaxLength(60)
  name?: string;

  @ApiPropertyOptional({ enum: STAFF_ROLES }) @IsOptional() @IsIn(STAFF_ROLES)
  role?: StaffRole;

  @ApiPropertyOptional({ description: "Set a new password" })
  @IsOptional() @IsString() @MinLength(8, { message: "Password must be at least 8 characters" }) @MaxLength(64)
  password?: string;

  @ApiPropertyOptional({ description: "true = can't sign in" }) @IsOptional() @IsBoolean()
  disabled?: boolean;
}
