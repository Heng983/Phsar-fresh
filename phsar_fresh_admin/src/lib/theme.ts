import "server-only";
import { cookies } from "next/headers";

export type ThemeChoice = "light" | "dark" | "system";

/** The admin's saved theme (cookie "pf_theme"); "system" follows the computer's setting. */
export async function getTheme(): Promise<ThemeChoice> {
  const v = (await cookies()).get("pf_theme")?.value;
  return v === "light" || v === "dark" ? v : "system";
}
