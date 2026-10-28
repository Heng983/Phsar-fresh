import { Body, Controller, Get, Headers, HttpCode, Module, Param, ParseUUIDPipe, Post, Res, UseGuards } from "@nestjs/common";
import { ApiBearerAuth, ApiExcludeEndpoint, ApiTags } from "@nestjs/swagger";
import { SkipThrottle } from "@nestjs/throttler";
import type { Response } from "express";
import { AuthUser, CurrentUser } from "../auth/dto/current-user.decorator";
import { JwtAuthGuard } from "../auth/jwt-auth.guard";
import { PaymentsService } from "./payments.service";
import { PaywayClient } from "./payway.client";

@ApiTags("payments")
@ApiBearerAuth()
@UseGuards(JwtAuthGuard)
@Controller("orders/:id/payment")
export class OrderPaymentController {
  constructor(private readonly payments: PaymentsService) {}

  /** Current payment of the order; asks PayWay while it's still pending. The app polls this. */
  @Get()
  status(@CurrentUser() user: AuthUser, @Param("id", ParseUUIDPipe) id: string) {
    return this.payments.status(user.id, id);
  }

  /** Test mode only (PAYWAY_MOCK=true): marks the current QR as paid. */
  @Post("test-pay")
  @HttpCode(200)
  testPay(@CurrentUser() user: AuthUser, @Param("id", ParseUUIDPipe) id: string) {
    return this.payments.testPay(user.id, id);
  }

  /** A new KHQR (the old one expired, or creating it failed). */
  @Post()
  renew(@CurrentUser() user: AuthUser, @Param("id", ParseUUIDPipe) id: string) {
    return this.payments.renew(user.id, id);
  }
}

/** ABA PayWay calls this after a payment (PAYWAY_CALLBACK_URL must point here, publicly reachable). */
@Controller("payments/payway")
@SkipThrottle()
export class PaywayCallbackController {
  constructor(private readonly payments: PaymentsService) {}

  @Post("callback")
  @HttpCode(200)
  @ApiExcludeEndpoint()
  async callback(
    @Body() body: Record<string, unknown>,
    @Headers("x-payway-hmac-sha512") signature: string | undefined,
    @Res({ passthrough: true }) res: Response,
  ) {
    const ok = await this.payments.callback(body ?? {}, signature);
    if (!ok) {
      res.status(401);
      return "Invalid signature";
    }
    return { ok: true };
  }
}

@Module({
  controllers: [OrderPaymentController, PaywayCallbackController],
  providers: [PaymentsService, PaywayClient],
  exports: [PaymentsService],
})
export class PaymentsModule {}
