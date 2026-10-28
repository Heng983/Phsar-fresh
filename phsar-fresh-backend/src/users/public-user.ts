import { User } from "@prisma/client";

export function toPublicUser(user: User) {
  return {
    id: user.id,
    phone: user.phone,
    name: user.name,
    avatarUrl: user.avatarUrl,
    role: user.role,
    phoneVerified: user.phoneVerified,
  };
}
