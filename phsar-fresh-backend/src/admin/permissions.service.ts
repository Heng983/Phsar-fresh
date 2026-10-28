import { BadRequestException, Injectable } from "@nestjs/common";
import { Role } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import {
  DEFAULT_PERMISSIONS, EDITABLE_ROLES, EditableRole, isStaffRole, normalize,
  Permission, PERMISSIONS, SUPER_ADMIN_ONLY,
} from "./permissions";

/**
 * Reads role permissions from the DB, cached in memory for a minute (cleared
 * at once when saved here; other server copies pick a change up within 60 s).
 */
@Injectable()
export class PermissionsService {
  private static readonly TTL_MS = 60_000;
  private cache: Partial<Record<EditableRole, Permission[]>> | null = null;
  private loadedAt = 0;

  constructor(private readonly prisma: PrismaService) {}

  private async load() {
    if (this.cache && Date.now() - this.loadedAt < PermissionsService.TTL_MS) return this.cache;
    const rows = await this.prisma.rolePermission.findMany();
    const cache: Partial<Record<EditableRole, Permission[]>> = {};
    for (const role of EDITABLE_ROLES) {
      const row = rows.find((r) => r.role === role);
      cache[role] = row ? normalize(row.permissions) : DEFAULT_PERMISSIONS[role];
    }
    this.cache = cache;
    this.loadedAt = Date.now();
    return cache;
  }

  async forRole(role: Role | string | undefined): Promise<Permission[]> {
    if (!isStaffRole(role)) return [];
    if (role === "SUPER_ADMIN") return [...PERMISSIONS];
    return (await this.load())[role] ?? [];
  }

  async can(role: Role | string | undefined, permission: Permission): Promise<boolean> {
    return (await this.forRole(role)).includes(permission);
  }

  /** Everything the Team & roles page needs to draw the matrix. */
  async matrix() {
    const data = await this.load();
    return {
      permissions: PERMISSIONS,
      superAdminOnly: SUPER_ADMIN_ONLY,
      roles: { SUPER_ADMIN: [...PERMISSIONS], MANAGER: data.MANAGER ?? [], STAFF: data.STAFF ?? [], DRIVER: data.DRIVER ?? [] },
      defaults: DEFAULT_PERMISSIONS,
    };
  }

  async setRole(role: string, permissions: string[]) {
    if (!EDITABLE_ROLES.includes(role as EditableRole)) {
      throw new BadRequestException("Only MANAGER, STAFF and DRIVER permissions can be changed");
    }
    const clean = normalize(permissions);
    await this.prisma.rolePermission.upsert({
      where: { role: role as EditableRole },
      update: { permissions: clean },
      create: { role: role as EditableRole, permissions: clean },
    });
    this.cache = null;
    return this.matrix();
  }
}
