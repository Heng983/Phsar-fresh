export function normalizePhone(input: unknown): string {
  if (typeof input !== "string") return "";
  const p = input.replace(/[\s\-().]/g, "");

  if (p.startsWith("+855")) return p;
  if (p.startsWith("855")) return `+${p}`;
  if (p.startsWith("0")) return `+855${p.slice(1)}`;
  return `+855${p}`;
}

export const KH_PHONE_REGEX = /^\+855[1-9]\d{7,8}$/;
