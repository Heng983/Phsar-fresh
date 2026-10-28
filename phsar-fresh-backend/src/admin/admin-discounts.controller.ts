import {
  BadRequestException, Body, ConflictException, Controller, Delete, Get, Injectable,
  NotFoundException, Param, ParseUUIDPipe, Patch, Post,
} from "@nestjs/common";
import { ApiTags } from "@nestjs/swagger";
import { DiscountCode, Prisma } from "@prisma/client";
import { PrismaService } from "../prisma/prisma.service";
import { codeStatus } from "../discounts/discount-rules";
import { AdminOnly, Can } from "./admin.decorator";
import { CreateDiscountCodeDto, UpdateDiscountCodeDto } from "./dto/admin-discount.dto";

type WithCount = DiscountCode & { _count: { redemptions: number } };
const toAdmin = ({ _count, ...c }: WithCount) => ({ ...c, status: codeStatus(c), uses: _count.redemptions });
const withUses = { _count: { select: { redemptions: true } } } satisfies Prisma.DiscountCodeInclude;

@Injectable()
export class AdminDiscountsService {
  constructor(private readonly prisma: PrismaService) {}

  async list() {
    const rows = await this.prisma.discountCode.findMany({ include: withUses, orderBy: [{ isActive: "desc" }, { createdAt: "desc" }] });
    return rows.map(toAdmin);
  }

  async findOne(id: string) {
    const c = await this.prisma.discountCode.findUnique({ where: { id }, include: withUses });
    if (!c) throw new NotFoundException("Discount code not found");
    return toAdmin(c);
  }

  async create(dto: CreateDiscountCodeDto) {
    const data = this.check(dto);
    try {
      return toAdmin(await this.prisma.discountCode.create({ data: data as Prisma.DiscountCodeCreateInput, include: withUses }));
    } catch (e) {
      throw this.duplicate(e);
    }
  }

  async update(id: string, dto: UpdateDiscountCodeDto) {
    const { status: _s, uses: _n, id: _id, createdAt: _c, updatedAt: _u, ...current } = await this.findOne(id);
    const data = this.check({ ...current, ...dto });
    try {
      return toAdmin(await this.prisma.discountCode.update({ where: { id }, data, include: withUses }));
    } catch (e) {
      throw this.duplicate(e);
    }
  }

  async remove(id: string) {
    await this.findOne(id);
    await this.prisma.discountCode.delete({ where: { id } });
    return { deleted: true };
  }

  private check(d: CreateDiscountCodeDto) {
    if (d.type === "PERCENT" && (d.value < 1 || d.value > 100)) {
      throw new BadRequestException("A percent discount must be between 1 and 100");
    }
    if (d.startsAt && d.endsAt && d.endsAt <= d.startsAt) {
      throw new BadRequestException("The end date must be after the start date");
    }
    return {
      ...d,
      maxDiscountCents: d.type === "PERCENT" ? (d.maxDiscountCents ?? null) : null,
      // A welcome code is always one use per customer.
      oncePerCustomer: d.newCustomersOnly ? true : d.oncePerCustomer,
    };
  }

  private duplicate(e: unknown) {
    if (e instanceof Prisma.PrismaClientKnownRequestError && e.code === "P2002") {
      return new ConflictException("Another discount code already uses this code");
    }
    return e;
  }
}

@ApiTags("admin")
@AdminOnly()
@Can("promotions.write")
@Controller("admin/discount-codes")
export class AdminDiscountsController {
  constructor(private readonly codes: AdminDiscountsService) {}

  @Get() list() { return this.codes.list(); }
  @Get(":id") findOne(@Param("id", ParseUUIDPipe) id: string) { return this.codes.findOne(id); }
  @Post() create(@Body() dto: CreateDiscountCodeDto) { return this.codes.create(dto); }
  @Patch(":id") update(@Param("id", ParseUUIDPipe) id: string, @Body() dto: UpdateDiscountCodeDto) { return this.codes.update(id, dto); }
  @Delete(":id") remove(@Param("id", ParseUUIDPipe) id: string) { return this.codes.remove(id); }
}
