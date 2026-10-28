import { Body, Controller, HttpCode, Post } from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { Throttle } from "@nestjs/throttler";
import { ChatService } from "./chat.service";
import { ChatRequestDto } from "./dto/chat-request.dto";

/** Public, like the catalog: guests can ask Ming Sros too. */
@ApiTags("chat")
@Controller("chat")
export class ChatController {
  constructor(private readonly chat: ChatService) {}

  // Every message is a paid Gemini call, so far fewer than the global limit.
  @Throttle({ default: { limit: 10, ttl: 60_000 } })
  @Post()
  @HttpCode(200)
  reply(@Body() dto: ChatRequestDto) {
    return this.chat.reply(dto.message, dto.history);
  }
}
