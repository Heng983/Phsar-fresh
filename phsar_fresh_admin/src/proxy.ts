import { NextResponse, type NextRequest } from "next/server";
import { isStaffRole } from "@/lib/permissions";
import { API_URL } from "@/lib/config";
import {
  ACCESS_COOKIE, REFRESH_COOKIE, REFRESH_MAX_AGE, cookieOptions,
  decodeToken, secondsLeft, type TokenPair,
} from "@/lib/session";

/**
 * Runs before every admin page:
 *  1. no session            → /login
 *  2. access token expiring  → swap the refresh token for a new pair (NestJS rotates it)
 *  3. not a team role        → /login?reason=forbidden
 */
export async function proxy(request: NextRequest) {
  const access = request.cookies.get(ACCESS_COOKIE)?.value;
  const refresh = request.cookies.get(REFRESH_COOKIE)?.value;
  const { pathname, search } = request.nextUrl;
  const isLogin = pathname === "/login";

  const toLogin = (reason?: string) => {
    if (isLogin) return NextResponse.next();
    const url = new URL("/login", request.url);
    if (pathname !== "/") url.searchParams.set("from", pathname + search);
    if (reason) url.searchParams.set("reason", reason);
    const res = NextResponse.redirect(url);
    res.cookies.delete(ACCESS_COOKIE);
    res.cookies.delete(REFRESH_COOKIE);
    return res;
  };

  // Still valid for more than 30 s: nothing to do.
  if (secondsLeft(access) > 30) {
    const role = decodeToken(access)?.role;
    if (!isStaffRole(role)) return toLogin("forbidden");
    if (isLogin) return NextResponse.redirect(new URL("/", request.url));
    return NextResponse.next();
  }

  if (!refresh) return toLogin();

  let pair: TokenPair;
  try {
    const res = await fetch(`${API_URL}/auth/refresh`, {
      method: "POST",
      headers: { "Content-Type": "application/json" },
      body: JSON.stringify({ refreshToken: refresh }),
      cache: "no-store",
    });
    if (!res.ok) return toLogin(res.status === 403 ? "disabled" : "expired");
    pair = (await res.json()) as TokenPair;
  } catch {
    // API down: let the page render and show its own "can't reach the API" message.
    return NextResponse.next();
  }

  if (!isStaffRole(pair.user.role)) return toLogin("forbidden");

  // Hand the new tokens to this render (request) and to the browser (response).
  request.cookies.set(ACCESS_COOKIE, pair.accessToken);
  request.cookies.set(REFRESH_COOKIE, pair.refreshToken);
  const res = isLogin
    ? NextResponse.redirect(new URL("/", request.url))
    : NextResponse.next({ request: { headers: request.headers } });
  res.cookies.set(ACCESS_COOKIE, pair.accessToken, { ...cookieOptions, maxAge: secondsLeft(pair.accessToken) });
  res.cookies.set(REFRESH_COOKIE, pair.refreshToken, { ...cookieOptions, maxAge: REFRESH_MAX_AGE });
  return res;
}

export const config = {
  // everything except Next's own files and static assets
  matcher: ["/((?!_next/static|_next/image|favicon.ico|.*\\.(?:png|jpg|jpeg|svg|webp|ico)$).*)"],
};
