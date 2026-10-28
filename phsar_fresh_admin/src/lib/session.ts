/** Cookie names and JWT helpers shared by the proxy, server actions and pages. */
export const ACCESS_COOKIE = "pf_access";
export const REFRESH_COOKIE = "pf_refresh";
export const REFRESH_MAX_AGE = 30 * 24 * 60 * 60; // matches REFRESH_TTL_DAYS on the backend

export type Role = "CUSTOMER" | "DRIVER" | "SUPER_ADMIN" | "MANAGER" | "STAFF";
export interface TokenPayload {
  sub: string;
  role: Role;
  exp: number;
}

export interface AuthUser {
  id: string;
  phone: string | null;
  name: string | null;
  avatarUrl: string | null;
  role: Role;
}

export interface TokenPair {
  accessToken: string;
  refreshToken: string;
  user: AuthUser;
}

/**
 * Reads the JWT payload WITHOUT verifying the signature.
 * That's fine here: it only decides redirects in the UI. Every API call is
 * verified by NestJS with the real secret, so a forged token gets nothing.
 */
export function decodeToken(token: string | undefined): TokenPayload | null {
  if (!token) return null;
  try {
    const part = token.split(".")[1];
    const json = atob(part.replace(/-/g, "+").replace(/_/g, "/"));
    const payload = JSON.parse(json) as TokenPayload;
    return typeof payload.exp === "number" ? payload : null;
  } catch {
    return null;
  }
}

/** Seconds the token is still valid for (0 when expired or unreadable). */
export function secondsLeft(token: string | undefined): number {
  const p = decodeToken(token);
  return p ? Math.max(0, Math.floor(p.exp - Date.now() / 1000)) : 0;
}

export const cookieOptions = {
  httpOnly: true,
  sameSite: "lax" as const,
  secure: process.env.NODE_ENV === "production",
  path: "/",
};
