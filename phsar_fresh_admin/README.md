# Phsar Fresh Admin

The web admin for Phsar Fresh: Next.js 16 (App Router) + TypeScript, talking to the NestJS API in `../phsar-fresh-backend`.

| Phase | Where |
| --- | --- |
| 1. Admin authentication | `/login`, `src/proxy.ts`, `src/app/auth-actions.ts` |
| 2. Products & categories | `/products`, `/products/new`, `/products/[id]`, `/categories` |
| 3. Orders | `/orders` (list + detail panel, status updates) |
| 4. Analytics | `/dashboard` (revenue, orders, top products, hourly trend, low stock) |
| 5. Live updates | `src/components/order-alerts.tsx` (Socket.io: bell, pop-ups, sound, auto-refreshing lists) |

## Run it

```bash
# 1. backend (in ../phsar-fresh-backend)
docker compose up -d
npm run start:dev                     # API on http://localhost:3000/api/v1
npx prisma migrate deploy             # applies the staff-roles migration
npm run create-admin -- 012345678 "MyPassword123" "Your Name"   # first super admin

# 2. admin (this folder)
npm install
npm run dev                           # http://localhost:3001
```

Settings live in `.env.local` (copy of `.env.example`):

- `API_URL`: the NestJS API, used only on the server
- `NEXT_PUBLIC_ASSET_URL`: where `/uploads/...` images are served (the NestJS server)
- `NEXT_PUBLIC_SOCKET_URL`: the NestJS server for live updates (optional; defaults to `NEXT_PUBLIC_ASSET_URL`)

## How sign-in works

1. The login form posts to a Server Action, which calls `POST /auth/login`.
2. Only team roles (`SUPER_ADMIN`, `MANAGER`, `STAFF`) are let in. Anyone else's refresh token is revoked straight away.
3. The access token (15 min) and refresh token (30 days, or the browser session if "Keep me signed in" is off) are stored in **httpOnly cookies**, so page JavaScript can't read them.
4. `src/proxy.ts` runs before every page. When the access token has less than 30 seconds left, it calls `POST /auth/refresh` (NestJS rotates the refresh token) and passes the new tokens to both the page and the browser.
5. Every API call goes from the Next.js server to NestJS with `Authorization: Bearer …`. NestJS checks the signature and the role's permission on every route (`@AdminOnly()` + `@Can(...)`), so the browser never talks to the API directly for data.

## Live updates

While the panel is open, the browser keeps a Socket.io connection to the API (`/admin` namespace):

1. A Server Action asks NestJS for a one-minute, one-use ticket (`POST /admin/orders/live-ticket`). The login token never leaves its httpOnly cookie.
2. The browser connects with that ticket; a new one is fetched on every reconnect.
3. `order:new` rings the bell with a pop-up and sound. `order:changed` refreshes the page data (order list, sidebar counts, drivers' deliveries), once per burst.
4. The bell panel shows **● Live** or **Reconnecting…**. While disconnected it checks `GET /admin/orders/alerts` every 10 seconds and catches up on missed orders when it reconnects.

In production, add the panel's address to `CORS_ORIGINS` in the backend's `.env`.

## Roles

| | Super admin | Manager | Staff |
| --- | :-: | :-: | :-: |
| Dashboard & revenue | ✓ | ✓ | – |
| Edit products, prices, photos, visibility | ✓ | ✓ | – |
| Update stock counts | ✓ | ✓ | ✓ |
| Delete products | ✓ | ✓ | – |
| Manage categories | ✓ | ✓ | – |
| Move orders forward | ✓ | ✓ | ✓ |
| Cancel orders | ✓ | ✓ | – |
| Team & roles (add members, change roles, reset passwords, disable) | ✓ | – | – |

Those are the defaults. A Super admin can change what Managers and Staff may do on **Team & roles → What each role can do** (saved in the `RolePermission` table). Super admin always has everything, and managing the team stays Super admin only. The backend checks these on every request; the web app reads them from `GET /admin/me` to build its menus. Each admin lands on the first page they can open (Dashboard → Orders → Products).

## Structure

```
src/
  proxy.ts               session check + token refresh before every page
  app/
    login/               sign-in page
    auth-actions.ts      login / logout Server Actions
    (admin)/             everything behind sign-in, sharing the sidebar layout
      dashboard/ products/ categories/ orders/
      alerts-actions.ts  new-order check and live-connection ticket
  components/            design-system components (ui, fields, client, charts, icon)
    order-alerts.tsx     Socket.io connection, bell, pop-ups and sound
  lib/                   api client, session helpers, types, formatting
```

Styling comes from the Phsar Fresh Admin design system: tokens and component classes are in `src/app/globals.css`, with light and dark themes.
