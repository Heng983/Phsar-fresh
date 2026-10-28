import { Injectable, Logger } from "@nestjs/common";

@Injectable()
export class SmsService {
  private readonly logger = new Logger(SmsService.name);

  async send(phone: string, message: string): Promise<void> {
    if (process.env.NODE_ENV !== "production") {
      // DEV ONLY: the code is printed in the terminal, no SMS is sent.
      this.logger.warn(`[DEV SMS] to ${phone}: ${message}`);
      return;
    }

    // PRODUCTION: call your SMS provider's API here.
    throw new Error("SMS provider is not configured");
  }
}
