import {
  Injectable,
  Logger,
  ServiceUnavailableException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { Content, GenerateContentResponse, GoogleGenAI } from "@google/genai";
import { SYSTEM_PROMPT } from "../chat.prompt";
import { CHAT_TOOLS } from "./gemini.tools";

@Injectable()
export class GeminiService {
  private readonly logger = new Logger(GeminiService.name);
  private readonly client?: GoogleGenAI;
  private readonly model: string;

  constructor(config: ConfigService) {
    const apiKey = config.get<string>("GEMINI_API_KEY");
    this.model = config.get<string>("GEMINI_MODEL") || "gemini-3.5-flash-lite";

    if (apiKey) {
      this.client = new GoogleGenAI({
        apiKey,
        httpOptions: { timeout: 30_000 },
      });
    } else {
      this.logger.warn(
        "GEMINI_API_KEY is not set: the chat assistant is disabled",
      );
    }
  }

  async generate(contents: Content[]): Promise<GenerateContentResponse> {
    if (!this.client) {
      throw new ServiceUnavailableException(
        "The assistant is not configured yet.",
      );
    }

    try {
      return await this.client.models.generateContent({
        model: this.model,
        contents,
        config: {
          systemInstruction: SYSTEM_PROMPT,
          tools: [{ functionDeclarations: CHAT_TOOLS }],
          temperature: 0.3, // low = more reliable tool calls
        },
      });
    } catch (err) {
      const status = (err as { status?: number }).status;
      this.logger.error(
        `Gemini request failed (status ${status ?? "none"}): ${(err as Error).message}`,
      );

      if (status === 429) {
        throw new ServiceUnavailableException(
          "The assistant is busy right now. Please try again in a minute.",
        );
      }
      throw new ServiceUnavailableException(
        "The assistant is unavailable. Please try again later.",
      );
    }
  }
}
