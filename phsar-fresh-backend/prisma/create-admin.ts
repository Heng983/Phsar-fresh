// Create (or reset) an admin account directly in the database — no SMS code needed.
//   npm run create-admin -- 012345678 "MyPassword123" "Long Bunheng" [SUPER_ADMIN|MANAGER|STAFF|DRIVER]
import { createPrisma } from "./client";
import * as bcrypt from "bcryptjs";
import { KH_PHONE_REGEX, normalizePhone } from "../src/common/phone.util";

const prisma = createPrisma();

async function main() {
  const [rawPhone, password, name, roleArg] = process.argv.slice(2);
  const role = (roleArg ?? "SUPER_ADMIN").toUpperCase();
  if (!["SUPER_ADMIN", "MANAGER", "STAFF", "DRIVER"].includes(role)) throw new Error("Role must be SUPER_ADMIN, MANAGER, STAFF or DRIVER");
  if (!rawPhone || !password) {
    throw new Error('Usage: npm run create-admin -- <phone> "<password>" ["<name>"]');
  }
  const phone = normalizePhone(rawPhone);
  if (!KH_PHONE_REGEX.test(phone)) throw new Error(`"${rawPhone}" is not a valid Cambodian phone number`);
  if (password.length < 8 || password.length > 64) throw new Error("Password must be 8–64 characters");

  const passwordHash = await bcrypt.hash(password, 10);
  const user = await prisma.user.upsert({
    where: { phone },
    update: { passwordHash, role: role as "SUPER_ADMIN", phoneVerified: true, disabledAt: null, ...(name && { name }) },
    create: { phone, passwordHash, role: role as "SUPER_ADMIN", phoneVerified: true, name: name ?? "Admin" },
  });

  console.log(`✔ ${role} ready: ${user.phone} (${user.name ?? "no name"})`);
  console.log("  Sign in at http://localhost:3001/login with this phone and password.");
}

main()
  .catch((e) => { console.error(`✖ ${e.message}`); process.exit(1); })
  .finally(() => prisma.$disconnect());
