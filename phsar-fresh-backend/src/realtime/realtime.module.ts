import { Global, Module } from "@nestjs/common";
import { PermissionsService } from "../admin/permissions.service";
import { AdminGateway } from "./admin.gateway";
import { RealtimeService } from "./realtime.service";

/** Socket.io for the admin panel; RealtimeService is available everywhere. */
@Global()
@Module({
  providers: [RealtimeService, AdminGateway, PermissionsService],
  exports: [RealtimeService],
})
export class RealtimeModule {}
