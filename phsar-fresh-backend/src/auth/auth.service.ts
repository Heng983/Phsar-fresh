import {
  ConflictException,
  ForbiddenException,
  Injectable,
  UnauthorizedException,
} from "@nestjs/common";
import { ConfigService } from "@nestjs/config";
import { JwtService } from "@nestjs/jwt";
import { User } from "@prisma/client";
import * as bcrypt from "bcryptjs";
import { createHash, randomBytes } from "crypto";
import { OtpService } from "../otp/otp.service";
import { PrismaService } from "../prisma/prisma.service";
import { UsersService } from "../users/users.service";
import { LoginDto } from "./dto/login.dto";
import { RegisterDto } from "./dto/register.dto";
import { VerifyOtpDto } from "./dto/verify-otp.dto";
import { toPublicUser } from "../users/public-user";

// Used so a wrong phone and a wrong password take the same time to reject.
const DUMMY_HASH = bcrypt.hashSync("dummy-password-for-timing", 10);

@Injectable()
export class AuthService {
  private readonly refreshTtlMs: number;

  constructor(
    private readonly users: UsersService,
    private readonly prisma: PrismaService,
    private readonly otp: OtpService,
    private readonly jwt: JwtService,
    config: ConfigService,
  ) {
    const days = Number(config.get("REFRESH_TTL_DAYS") ?? 30);
    this.refreshTtlMs = days * 24 * 60 * 60 * 1000;
  }

  // ---------------------------------------------------------------- register
  async register(dto: RegisterDto) {
    const existing = await this.users.findByPhone(dto.phone);
    if (existing?.phoneVerified) {
      throw new ConflictException("This phone number is already registered");
    }

    const passwordHash = await bcrypt.hash(dto.password, 10);

    if (existing) {
      // Registered before but never verified: let them start again.
      await this.users.update(existing.id, {
        passwordHash,
        name: dto.name ?? existing.name,
      });
    } else {
      await this.users.create({
        phone: dto.phone,
        passwordHash,
        name: dto.name,
      });
    }

    await this.otp.send(dto.phone);
    return { message: "Verification code sent", phone: dto.phone };
  }

  // -------------------------------------------------------------- resend otp
  async resendOtp(phone: string) {
    const user = await this.users.findByPhone(phone);
    // Same answer whether or not the number exists (no account probing).
    if (user && !user.phoneVerified) {
      await this.otp.send(phone);
    }
    return { message: "If the number is registered, a code was sent" };
  }

  // -------------------------------------------------------------- verify otp
  async verifyOtp(dto: VerifyOtpDto) {
    const user = await this.users.findByPhone(dto.phone);
    if (!user) {
      throw new UnauthorizedException("Invalid code");
    }

    await this.otp.verify(dto.phone, dto.code);

    const verified = user.phoneVerified
      ? user
      : await this.users.update(user.id, { phoneVerified: true });

    return this.issueTokens(verified);
  }

  // ------------------------------------------------------------------- login
  async login(dto: LoginDto) {
    const user = await this.users.findByPhone(dto.phone);

    const ok = await bcrypt.compare(
      dto.password,
      user?.passwordHash ?? DUMMY_HASH,
    );
    if (!user || !user.passwordHash || !ok) {
      throw new UnauthorizedException("Wrong phone number or password");
    }

    if (!user.phoneVerified) {
      throw new ForbiddenException(
        "Phone number is not verified. Request a new code.",
      );
    }

    return this.issueTokens(user);
  }

  // ----------------------------------------------------------------- refresh
  async refresh(refreshToken: string) {
    const tokenHash = this.hashToken(refreshToken);
    const stored = await this.prisma.refreshToken.findUnique({
      where: { tokenHash },
      include: { user: true },
    });

    if (!stored || stored.revokedAt || stored.expiresAt < new Date()) {
      // A revoked token being reused can mean theft: end all sessions.
      if (stored?.revokedAt) {
        await this.prisma.refreshToken.updateMany({
          where: { userId: stored.userId, revokedAt: null },
          data: { revokedAt: new Date() },
        });
      }
      throw new UnauthorizedException("Invalid refresh token");
    }

    // Rotation: the old token can be used only once.
    await this.prisma.refreshToken.update({
      where: { id: stored.id },
      data: { revokedAt: new Date() },
    });

    return this.issueTokens(stored.user);
  }

  // ------------------------------------------------------------------ logout
  async logout(refreshToken: string) {
    await this.prisma.refreshToken.updateMany({
      where: { tokenHash: this.hashToken(refreshToken), revokedAt: null },
      data: { revokedAt: new Date() },
    });
    return { message: "Logged out" };
  }

  // --------------------------------------------------------------------- me
  async me(userId: string) {
    const user = await this.users.findById(userId);
    if (!user) throw new UnauthorizedException();
    return this.publicUser(user);
  }

  // ----------------------------------------------------------------- helpers
  private async issueTokens(user: User) {
    if (user.disabledAt) {
      throw new ForbiddenException("This account is disabled. Ask a super admin.");
    }
    const accessToken = await this.jwt.signAsync({
      sub: user.id,
      role: user.role,
    });

    const refreshToken = randomBytes(48).toString("base64url");
    await this.prisma.refreshToken.create({
      data: {
        userId: user.id,
        tokenHash: this.hashToken(refreshToken),
        expiresAt: new Date(Date.now() + this.refreshTtlMs),
      },
    });

    return { accessToken, refreshToken, user: this.publicUser(user) };
  }

  private hashToken(token: string): string {
    return createHash("sha256").update(token).digest("hex");
  }

  private publicUser(user: User) {
    return toPublicUser(user);
  }
}
