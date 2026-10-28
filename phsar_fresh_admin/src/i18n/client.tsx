"use client";

import { useRouter } from "next/navigation";
import { createContext, useContext, useTransition, type ReactNode } from "react";
import { DICTS, LANG_COOKIE, type Lang } from "./dict";

const LangContext = createContext<Lang>("en");

export function LangProvider({ lang, children }: { lang: Lang; children: ReactNode }) {
  return <LangContext.Provider value={lang}>{children}</LangContext.Provider>;
}

export const useLang = () => useContext(LangContext);
export const useDict = () => DICTS[useContext(LangContext)];

/** EN | ខ្មែរ switch. Saves the choice in a cookie and re-renders the page on the server. */
export function LangToggle({ compact }: { compact?: boolean }) {
  const lang = useLang();
  const router = useRouter();
  const [pending, start] = useTransition();
  function choose(next: Lang) {
    if (next === lang) return;
    document.cookie = `${LANG_COOKIE}=${next}; path=/; max-age=31536000; samesite=lax`;
    start(() => router.refresh());
  }
  return (
    <div className={`pf-theme${compact ? " is-compact" : ""}`} role="radiogroup" aria-label="Language / ភាសា" aria-busy={pending}>
      <button type="button" role="radio" aria-checked={lang === "en"} className={`pf-theme-opt${lang === "en" ? " is-active" : ""}`} onClick={() => choose("en")} style={compact ? { width: 40 } : undefined}>
        EN
      </button>
      <button type="button" role="radio" aria-checked={lang === "km"} className={`pf-theme-opt pf-km${lang === "km" ? " is-active" : ""}`} onClick={() => choose("km")} style={compact ? { width: 48 } : undefined}>
        ខ្មែរ
      </button>
    </div>
  );
}
