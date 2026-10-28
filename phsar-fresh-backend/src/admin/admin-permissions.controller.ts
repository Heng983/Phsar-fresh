import { Body, Controller, Get, Param, Put } from "@nestjs/common";
import { ApiProperty, ApiTags } from "@nestjs/swagger";
import { IsArray, IsString } from "class-validator";
import { AuthUser, CurrentUser } from "../auth/dto/current-user.decorator";
import { AdminOnly, Can } from "./admin.decorator";
import { PermissionsService } from "./permissions.service";

class SetPermissionsDto {
  @ApiProperty({ type: [String], example: ["orders.view", "orders.update"] })
  @IsArray() @IsString({ each: true })
  permissions: string[];
}

@ApiTags("admin")
@AdminOnly()
@Controller("admin")
export class AdminPermissionsController {
  constructor(private readonly permissions: PermissionsService) {}

  /** The signed-in admin's role and what it may do — the web app builds its menus from this. */
  @Get("me")
  async me(@CurrentUser() user: AuthUser) {
    return { role: user.role, permissions: await this.permissions.forRole(user.role) };
  }

  @Can("team.manage")
  @Get("permissions")
  matrix() {
    return this.permissions.matrix();
  }

  @Can("team.manage")
  @Put("permissions/:role")
  set(@Param("role") role: string, @Body() dto: SetPermissionsDto) {
    return this.permissions.setRole(role, dto.permissions);
  }
}
