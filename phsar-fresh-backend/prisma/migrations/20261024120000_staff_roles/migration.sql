-- Admin panel roles. Existing ADMIN accounts become SUPER_ADMIN (data kept, nothing dropped).
ALTER TYPE "Role" RENAME VALUE 'ADMIN' TO 'SUPER_ADMIN';
ALTER TYPE "Role" ADD VALUE 'MANAGER';
ALTER TYPE "Role" ADD VALUE 'STAFF';

-- Disabled team members can't sign in.
ALTER TABLE "User" ADD COLUMN "disabledAt" TIMESTAMP(3);
