// Give an existing, verified account admin access:  npm run make-admin -- 012345678
import { createPrisma } from "./client";
import { normalizePhone } from "../src/common/phone.util";

const prisma = createPrisma();

async function main() {
  const raw = process.argv[2];
  if (!raw) throw new Error("Usage: npm run make-admin -- <phone>");
  const phone = normalizePhone(raw);
  const user = await prisma.user.findUnique({ where: { phone } });
  if (!user) throw new Error(`No account with phone ${phone}. Register it in the app first.`);
  await prisma.user.update({ where: { id: user.id }, data: { role: "SUPER_ADMIN", phoneVerified: true, disabledAt: null } });
  console.log(`${phone} is now a SUPER_ADMIN. Sign in again to get a token with the new role.`);
}

main().catch((e) => { console.error(e.message); process.exit(1); }).finally(() => prisma.$disconnect());
