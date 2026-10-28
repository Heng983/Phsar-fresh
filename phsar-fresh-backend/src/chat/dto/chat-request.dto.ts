import { ApiProperty, ApiPropertyOptional } from "@nestjs/swagger";
import { Transform, Type } from "class-transformer";
import {
  ArrayMaxSize,
  IsArray,
  IsIn,
  IsNotEmpty,
  IsOptional,
  IsString,
  MaxLength,
  ValidateNested,
} from "class-validator";

/** Same limits as the app (ChatApi): each message is a paid Gemini call. */
export class ChatTurnDto {
  @ApiProperty({ enum: ["user", "model"] })
  @IsIn(["user", "model"])
  role!: "user" | "model";

  @ApiProperty({ maxLength: 1000 })
  @IsString()
  @MaxLength(1000)
  text!: string;
}

export class ChatRequestDto {
  @ApiProperty({ example: "What do I need for beef lok lak?", maxLength: 500 })
  @Transform(({ value }) => (typeof value === "string" ? value.trim() : value))
  @IsString()
  @IsNotEmpty()
  @MaxLength(500)
  message!: string;

  @ApiPropertyOptional({
    type: [ChatTurnDto],
    description: "Earlier turns, oldest first (at most 10)",
  })
  @IsOptional()
  @IsArray()
  @ArrayMaxSize(10)
  @ValidateNested({ each: true })
  @Type(() => ChatTurnDto)
  history: ChatTurnDto[] = [];
}
