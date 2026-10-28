import { Module } from "@nestjs/common";
import { AuthModule } from "../auth/auth.module";
import { AdminCategoriesController, AdminCategoriesService } from "./admin-categories.controller";
import { AdminOrdersController, AdminOrdersService } from "./admin-orders.controller";
import { AdminProductsController } from "./admin-products.controller";
import { AdminProductsService } from "./admin-products.service";
import { AdminStatsController, AdminStatsService } from "./admin-stats.controller";
import { AdminTeamController, AdminTeamService } from "./admin-team.controller";
import { AdminPermissionsController } from "./admin-permissions.controller";
import { PermissionsService } from "./permissions.service";
import { AdminPromotionsController, AdminPromotionsService } from "./admin-promotions.controller";
import { AdminDiscountsController, AdminDiscountsService } from "./admin-discounts.controller";

/** Everything under /api/v1/admin/* — requires a JWT with role SUPER_ADMIN, MANAGER or STAFF (see permissions.ts); what each role may do is editable by a Super admin. */
@Module({
  imports: [AuthModule],
  controllers: [AdminProductsController, AdminCategoriesController, AdminOrdersController, AdminStatsController, AdminTeamController, AdminPermissionsController, AdminPromotionsController, AdminDiscountsController],
  providers: [AdminProductsService, AdminCategoriesService, AdminOrdersService, AdminStatsService, AdminTeamService, PermissionsService, AdminPromotionsService, AdminDiscountsService],
})
export class AdminModule {}
