// Prisma client for the scripts in this folder (seed, create-admin,
// make-admin), which run outside Nest and so load .env themselves.
import "dotenv/config";
import { PrismaPg } from "@prisma/adapter-pg";
import { PrismaClient } from "@prisma/client";

export const createPrisma = () =>
  new PrismaClient({ adapter: new PrismaPg({ connectionString: process.env.DATABASE_URL }) });
