import { Injectable } from "@nestjs/common";
import { randomBytes } from "crypto";
import { promises as fs } from "fs";
import { basename, join } from "path";

@Injectable()
export class StorageService {
  // Must match the static folder served at /uploads in main.ts.
  private readonly avatarDir = join(process.cwd(), "uploads", "avatars");

  async saveAvatar(userId: string, jpeg: Buffer): Promise<string> {
    await fs.mkdir(this.avatarDir, { recursive: true });
    const name = `${userId}-${randomBytes(6).toString("hex")}.jpg`;
    await fs.writeFile(join(this.avatarDir, name), jpeg);
    return `/uploads/avatars/${name}`;
  }

  async deleteAvatar(url: string | null | undefined): Promise<void> {
    if (!url || !url.startsWith("/uploads/avatars/")) return;
    await fs.unlink(join(this.avatarDir, basename(url))).catch(() => undefined);
  }
}
