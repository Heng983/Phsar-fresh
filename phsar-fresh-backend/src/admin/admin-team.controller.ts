import {
  BadRequestException, Body, ConflictException, Controller, Get, Injectable,
  NotFoundException, Param, ParseUUIDPipe, Patch, Post,
} from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { Prisma, User } from "@prisma/client";
import * as bcrypt from "bcryptjs";
import { AuthUser, CurrentUser } from "../auth/dto/current-user.decorator";
import { userStatusKey } from "../auth/jwt.strategy";
import { PrismaService } from "../prisma/prisma.service";
import { CacheService } from "../redis/redis.module";
import { AdminOnly, Can } from "./admin.decorator";
import { CreateTeamMemberDto, UpdateTeamMemberDto } from "./dto/admin-team.dto";
import { STAFF_ROLES } from "./permissions";

function toMember(u: User) {
  return {
    id: u.id,
    name: u.name,
    phone: u.phone,
    role: u.role,
    disabled: !!u.disabledAt,
    createdAt: u.createdAt,
  };
}

@Injectable()
export class AdminTeamService {
  constructor(private readonly prisma: PrismaService, private readonly cache: CacheService) {}

  async list() {
    const rows = await this.prisma.user.findMany({
      where: { role: { in: STAFF_ROLES } },
      orderBy: [{ disabledAt: { sort: "asc", nulls: "first" } }, { createdAt: "asc" }],
    });
    return rows.map(toMember);
  }

  async create(dto: CreateTeamMemberDto) {
    const existing = await this.prisma.user.findUnique({ where: { phone: dto.phone } });
    if (existing && STAFF_ROLES.includes(existing.role as never)) {
      throw new ConflictException("This phone number is already on the team");
    }
    const passwordHash = await bcrypt.hash(dto.password, 10);
    // An existing customer account with this phone is promoted instead of duplicated.
    const user = existing
      ? await this.prisma.user.update({
          where: { id: existing.id },
          data: { name: dto.name, role: dto.role, passwordHash, phoneVerified: true, disabledAt: null },
        })
      : await this.prisma.user.create({
          data: { name: dto.name, phone: dto.phone, role: dto.role, passwordHash, phoneVerified: true },
        });
    await this.cache.del(userStatusKey(user.id)); // a promoted customer gets the new role at once
    return toMember(user);
  }

  async update(id: string, dto: UpdateTeamMemberDto, me: AuthUser) {
    const user = await this.prisma.user.findUnique({ where: { id } });
    if (!user || !STAFF_ROLES.includes(user.role as never)) throw new NotFoundException("Team member not found");

    const self = id === me.id;
    if (self && dto.role && dto.role !== user.role) throw new BadRequestException("You can't change your own role");
    if (self && dto.disabled) throw new BadRequestException("You can't disable your own account");

    // Never leave the shop without an active super admin.
    const losesSuper = user.role === "SUPER_ADMIN" && !user.disabledAt && ((dto.role && dto.role !== "SUPER_ADMIN") || dto.disabled);
    if (losesSuper) {
      const others = await this.prisma.user.count({ where: { role: "SUPER_ADMIN", disabledAt: null, id: { not: id } } });
      if (others === 0) throw new BadRequestException("Keep at least one active super admin");
    }

    const data: Prisma.UserUpdateInput = {
      ...(dto.name !== undefined && { name: dto.name }),
      ...(dto.role && { role: dto.role }),
      ...(dto.password && { passwordHash: await bcrypt.hash(dto.password, 10) }),
      ...(dto.disabled !== undefined && { disabledAt: dto.disabled ? new Date() : null }),
    };
    const updated = await this.prisma.user.update({ where: { id }, data });
    // Their open access token now sees the new role / disabled flag right away.
    await this.cache.del(userStatusKey(id));

    // Disabling, a role change or a new password ends their other sessions.
    if (dto.disabled || (dto.role && dto.role !== user.role) || dto.password) {
      await this.prisma.refreshToken.updateMany({ where: { userId: id, revokedAt: null }, data: { revokedAt: new Date() } });
    }
    return toMember(updated);
  }
}

@ApiTags("admin")
@AdminOnly()
@Can("team.manage")
@Controller("admin/team")
export class AdminTeamController {
  constructor(private readonly team: AdminTeamService) {}

  @Get() list() { return this.team.list(); }
  @Post() create(@Body() dto: CreateTeamMemberDto) { return this.team.create(dto); }
  @Patch(":id")
  update(@Param("id", ParseUUIDPipe) id: string, @Body() dto: UpdateTeamMemberDto, @CurrentUser() me: AuthUser) {
    return this.team.update(id, dto, me);
  }
}
