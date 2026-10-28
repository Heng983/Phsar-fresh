import { Module } from "@nestjs/common";
import { ConfigModule } from "@nestjs/config";
import { APP_GUARD, APP_INTERCEPTOR } from "@nestjs/core";
import { ThrottlerGuard, ThrottlerModule } from "@nestjs/throttler";
import { AuthModule } from "./auth/auth.module";
import { PrismaModule } from "./prisma/prisma.module";
import { RedisModule } from "./redis/redis.module";
import { CategoriesModule } from "./categories/categories.module";
import { ProductsModule } from "./products/products.module";
import { AdminModule } from "./admin/admin.module";
import { PromotionsModule } from "./promotions/promotions.controller";
import { ChatModule } from "./chat/chat.module";
import { DiscountsModule } from "./discounts/discounts.controller";
import { OrdersModule } from "./orders/orders.controller";
import { PaymentsModule } from "./payments/payments.controller";
import { NotificationsModule } from "./notifications/notifications.controller";
import { CacheBustInterceptor } from "./common/cache-bust.interceptor";
import { validateEnv } from "./common/env.validation";

@Module({
  imports: [
    ConfigModule.forRoot({ isGlobal: true, validate: validateEnv }),
    // Per client IP. Generous by default because many phones share one IP on
    // Cambodian mobile networks; login, OTP, codes and chat have their own
    // tighter limits. Override with THROTTLE_LIMIT.
    ThrottlerModule.forRoot([{ ttl: 60_000, limit: Number(process.env.THROTTLE_LIMIT ?? 300) }]),
    PrismaModule,
    RedisModule,
    AuthModule,
    ProductsModule,
    CategoriesModule,
    AdminModule,
    PromotionsModule,
    ChatModule,
    DiscountsModule,
    OrdersModule,
    PaymentsModule,
    NotificationsModule,
  ],
  providers: [
    { provide: APP_GUARD, useClass: ThrottlerGuard },
    { provide: APP_INTERCEPTOR, useClass: CacheBustInterceptor },
  ],
})
export class AppModule {}
