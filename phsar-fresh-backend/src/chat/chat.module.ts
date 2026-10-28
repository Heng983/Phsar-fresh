import { Module } from "@nestjs/common";
import { ProductsModule } from "../products/products.module";
import { ChatController } from "./chat.controller";
import { ChatService } from "./chat.service";
import { GeminiService } from "./gemini/gemini.service";

@Module({
  imports: [ProductsModule],
  controllers: [ChatController],
  providers: [ChatService, GeminiService],
})
export class ChatModule {}
