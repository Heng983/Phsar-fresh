export const API_URL = process.env.API_URL ?? "http://localhost:3000/api/v1";
export const ASSET_URL = process.env.NEXT_PUBLIC_ASSET_URL ?? "http://localhost:3000";
export const LOW_STOCK = 10; // keep in sync with LOW_STOCK in the backend's admin.decorator.ts

/** Product images are either full URLs (seed data) or /uploads/... paths on the API server. */
export function assetUrl(url: string | null | undefined): string | null {
  if (!url) return null;
  return /^https?:\/\//.test(url) ? url : `${ASSET_URL}${url}`;
}
