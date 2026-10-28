import "server-only";
import { cookies } from "next/headers";
import { redirect, unstable_rethrow } from "next/navigation";
import { API_URL } from "./config";
import { getDict } from "@/i18n/server";
import { ACCESS_COOKIE } from "./session";

export class ApiError extends Error {
  constructor(public status: number, message: string) {
    super(message);
  }
}

/** NestJS sends { message: string | string[] } on errors. */
async function errorMessage(res: Response) {
  try {
    const body = await res.json();
    const m = body?.message;
    return Array.isArray(m) ? m.join(". ") : (m ?? res.statusText);
  } catch {
    return res.statusText || `Request failed (${res.status})`;
  }
}

/**
 * Calls the NestJS API from the server with the admin's access token.
 * The proxy refreshes the token before the page renders, so a 401 here
 * means the session is really over.
 */
export async function api<T>(path: string, init: RequestInit & { json?: unknown } = {}): Promise<T> {
  const token = (await cookies()).get(ACCESS_COOKIE)?.value;
  const headers = new Headers(init.headers);
  if (token) headers.set("Authorization", `Bearer ${token}`);
  let body = init.body;
  if (init.json !== undefined) {
    headers.set("Content-Type", "application/json");
    body = JSON.stringify(init.json);
  }

  let res: Response;
  try {
    res = await fetch(`${API_URL}${path}`, { ...init, headers, body, cache: "no-store" });
  } catch {
    throw new ApiError(503, (await getDict()).api.unreachable(API_URL));
  }

  if (res.status === 401) redirect("/login?reason=expired");
  if (!res.ok) throw new ApiError(res.status, await errorMessage(res));
  return (await res.json()) as T;
}

/** For Server Actions: returns { error } instead of throwing, so forms can show it. */
export async function attempt<T>(fn: () => Promise<T>): Promise<{ data?: T; error?: string }> {
  try {
    return { data: await fn() };
  } catch (e) {
    if (e instanceof ApiError) return { error: e.message };
    throw e; // redirects and real bugs keep bubbling
  }
}

/** Use when a failed call should just show a fallback (but auth redirects still happen). */
export async function orDefault<T>(p: Promise<T>, fallback: T): Promise<T> {
  try {
    return await p;
  } catch (e) {
    unstable_rethrow(e);
    return fallback;
  }
}
