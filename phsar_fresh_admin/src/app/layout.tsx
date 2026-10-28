import type { Metadata } from "next";
// Fonts are bundled from npm (no request to Google at build or run time).
import "@fontsource-variable/figtree";
import "@fontsource/kantumruy-pro/khmer-400.css";
import "@fontsource/kantumruy-pro/khmer-500.css";
import "@fontsource/kantumruy-pro/khmer-600.css";
import "./globals.css";
import { getTheme } from "@/lib/theme";
import { LangProvider } from "@/i18n/client";
import { getLang } from "@/i18n/server";

export const metadata: Metadata = {
  title: { default: "Phsar Fresh Admin", template: "%s · Phsar Fresh Admin" },
  robots: { index: false, follow: false },
};

export default async function RootLayout({ children }: { children: React.ReactNode }) {
  const [theme, lang] = await Promise.all([getTheme(), getLang()]);
  return (
    <html lang={lang} data-theme={theme === "system" ? undefined : theme} suppressHydrationWarning>
      {/* suppressHydrationWarning: browser extensions add attributes to <html>/<body> before React loads */}
      <body suppressHydrationWarning>
        <LangProvider lang={lang}>{children}</LangProvider>
      </body>
    </html>
  );
}
