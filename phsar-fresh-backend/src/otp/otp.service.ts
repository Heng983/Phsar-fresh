import {
  BadRequestException,
  HttpException,
  HttpStatus,
  Inject,
  Injectable,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import Redis from "ioredis";
import { createHmac, randomInt, timingSafeEqual } from "crypto";
import { REDIS } from "../redis/redis.module";
import { SmsService } from "../sms/sms.service";

@Injectable()
export class OtpService {
  private readonly TTL_SECONDS = 60; // code valid for 1 minutes
  private readonly RESEND_SECONDS = 60; // wait 60s between requests
  private readonly MAX_ATTEMPTS = 5;
  private readonly secret: string;

  constructor(
    @Inject(REDIS) private readonly redis: Redis,
    private readonly sms: SmsService,
    config: ConfigService,
  ) {
    this.secret = config.getOrThrow<string>("OTP_SECRET");
  }

  private hash(phone: string, code: string): string {
    return createHmac("sha256", this.secret)
      .update(`${phone}:${code}`)
      .digest("hex");
  }

  async send(phone: string): Promise<void> {
    const cooldownKey = `otp:cooldown:${phone}`;

    if (await this.redis.exists(cooldownKey)) {
      throw new HttpException(
        "Please wait before requesting another code",
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const code = randomInt(0, 1_000_000).toString().padStart(6, "0");

    await this.redis
      .multi()
      .set(`otp:code:${phone}`, this.hash(phone, code), "EX", this.TTL_SECONDS)
      .set(`otp:attempts:${phone}`, 0, "EX", this.TTL_SECONDS)
      .set(cooldownKey, 1, "EX", this.RESEND_SECONDS)
      .exec();

    try {
      await this.sms.send(
        phone,
        `Your Phsar Fresh code is ${code}. It expires in 1 minutes.`,
      );
    } catch {
      await this.redis.del(cooldownKey, `otp:code:${phone}`);
      throw new HttpException("Could not send SMS", HttpStatus.BAD_GATEWAY);
    }
  }

  async verify(phone: string, code: string): Promise<void> {
    const codeKey = `otp:code:${phone}`;
    const attemptsKey = `otp:attempts:${phone}`;

    const stored = await this.redis.get(codeKey);
    if (!stored) {
      throw new BadRequestException("Code expired or not requested");
    }

    const attempts = await this.redis.incr(attemptsKey);
    if (attempts > this.MAX_ATTEMPTS) {
      await this.redis.del(codeKey, attemptsKey);
      throw new HttpException(
        "Too many attempts. Request a new code.",
        HttpStatus.TOO_MANY_REQUESTS,
      );
    }

    const a = Buffer.from(stored);
    const b = Buffer.from(this.hash(phone, code));
    if (a.length !== b.length || !timingSafeEqual(a, b)) {
      throw new BadRequestException("Invalid code");
    }

    await this.redis.del(codeKey, attemptsKey); // one-time use
  }
}
