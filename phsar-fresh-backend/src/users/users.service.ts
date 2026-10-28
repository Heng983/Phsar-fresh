import {
  BadRequestException,
  Injectable,
  NotFoundException,
} from "@nestjs/common";
import { Prisma } from "@prisma/client";
import sharp from "sharp";
import { PrismaService } from "../prisma/prisma.service";
import { StorageService } from "../storage/storage.service";
import { UpdateProfileDto } from "./dto/update-profile.dto";
import { toPublicUser } from "./public-user";

@Injectable()
export class UsersService {
  constructor(
    private readonly prisma: PrismaService,
    private readonly storage: StorageService,
  ) {}

  findByPhone(phone: string) {
    return this.prisma.user.findUnique({ where: { phone } });
  }

  findById(id: string) {
    return this.prisma.user.findUnique({ where: { id } });
  }

  create(data: Prisma.UserCreateInput) {
    return this.prisma.user.create({ data });
  }

  update(id: string, data: Prisma.UserUpdateInput) {
    return this.prisma.user.update({ where: { id }, data });
  }

  // ------------------------------------------------------------------ profile
  async updateProfile(userId: string, dto: UpdateProfileDto) {
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { ...(dto.name !== undefined && { name: dto.name }) },
    });
    return toPublicUser(user);
  }

  async setAvatar(userId: string, file: Express.Multer.File) {
    const current = await this.findById(userId);
    if (!current) throw new NotFoundException("User not found");
    let jpeg: Buffer;
    try {
      jpeg = await sharp(file.buffer, { limitInputPixels: 40_000_000 })
        .rotate()
        .resize(512, 512, { fit: "cover" })
        .jpeg({ quality: 82 })
        .toBuffer();
    } catch {
      throw new BadRequestException("Invalid image file");
    }

    const url = await this.storage.saveAvatar(userId, jpeg);
    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { avatarUrl: url },
    });

    await this.storage.deleteAvatar(current.avatarUrl); // remove the old file
    return toPublicUser(user);
  }

  async removeAvatar(userId: string) {
    const current = await this.findById(userId);
    if (!current) throw new NotFoundException("User not found");

    const user = await this.prisma.user.update({
      where: { id: userId },
      data: { avatarUrl: null },
    });
    await this.storage.deleteAvatar(current.avatarUrl);
    return toPublicUser(user);
  }
}
