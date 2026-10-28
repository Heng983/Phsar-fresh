import "server-only";
import { cookies } from "next/headers";
import { DICTS, LANG_COOKIE, isLang, type Lang } from "./dict";

/** The admin's chosen language (cookie "pf_lang"); English by default. */
export async function getLang(): Promise<Lang> {
  const v = (await cookies()).get(LANG_COOKIE)?.value;
  return isLang(v) ? v : "en";
}

export async function getDict() {
  return DICTS[await getLang()];
}
