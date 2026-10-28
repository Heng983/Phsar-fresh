# Phsar Fresh · ផ្សារស្រស់

A grocery delivery platform for Cambodia: customers shop fresh local produce in a bilingual (English / ខ្មែរ) mobile app, pay with **ABA KHQR** or cash on delivery, and follow their order to the door. The market team runs everything from a web admin panel.

| Folder | What it is | Built with |
| --- | --- | --- |
| [`phsar_fresh_app`](phsar_fresh_app) | Customer mobile app (iOS & Android) | Flutter, Riverpod, Dio, Google Maps |
| [`phsar-fresh-backend`](phsar-fresh-backend) | REST API | NestJS 12, TypeScript, PostgreSQL (Prisma 7), Redis |
| [`phsar_fresh_admin`](phsar_fresh_admin) | Admin panel for staff | Next.js 16 (App Router), React 19, TypeScript |

```
 Flutter app ──┐                     ┌── PostgreSQL (orders, products, users)
               ├──►  NestJS API  ────┤
 Next.js admin ┘   /api/v1           └── Redis (OTP codes, cache)
                       │
                       └──► ABA PayWay (KHQR payments + callback)
```

## Features

**Customer app**
- Browse and search products and categories in English or Khmer, with prices in USD or KHR
- Basket with swipe-to-remove and undo, discount and welcome codes
- Checkout with a map-pinned delivery address and delivery time slot
- Pay with ABA KHQR (QR code or ABA Mobile deep link) or cash on delivery
- Order tracking, order history and reorder
- Notifications for order updates, promotions and messages from the market team
- **Ming Sros (មីងស្រស់)**: an AI shopping assistant that suggests products
- Phone sign-up with SMS code, profile and photo

**Admin panel**
- Dashboard: revenue, orders, top products, low stock
- Products, stock, categories, photos; banners, deals and discount codes
- Orders: status flow (pending → preparing → out for delivery → delivered), activity log, new-order alerts with sound
- Message the customer about an order (quick templates); cancelling asks for a reason
- Team and roles (Super admin, Manager, Staff, Delivery) with editable permissions
- English / Khmer, light / dark theme, works on phone, tablet and laptop

**API**
- JWT access tokens and rotating refresh tokens; per-role permissions checked on every route
- Server-side prices and stock checks inside one transaction (no overselling)
- ABA PayWay KHQR with a signed callback and a test mode (`PAYWAY_MOCK=true`)
- Redis caching, rate limits, gzip, consistent error responses with request IDs

## Run it locally

You need **Node.js 22+**, **Docker Desktop** and a recent **Flutter** (Dart 3.12+).

### 1. API (`phsar-fresh-backend`)

```bash
cd phsar-fresh-backend
npm install
cp .env.example .env          # then fill in the secrets (see its README)
docker compose up -d          # PostgreSQL :5433, Redis :6380
npx prisma migrate deploy
npx prisma generate
npm run db:seed               # sample categories and products
npm run create-admin -- 012345678 "MyPassword123" "Your Name"
npm run start:dev             # http://localhost:3000/api/v1  (docs at /docs)
```

### 2. Admin panel (`phsar_fresh_admin`)

```bash
cd phsar_fresh_admin
npm install
cp .env.example .env.local
npm run dev                   # http://localhost:3001 — sign in with the admin you created
```

### 3. Mobile app (`phsar_fresh_app`)

```bash
cd phsar_fresh_app
flutter pub get
cp config.example.json config.json   # set API_BASE_URL (and Maps keys)
flutter run --dart-define-from-file=config.json
```

| Running on | `API_BASE_URL` |
| --- | --- |
| iOS simulator | `http://localhost:3000/api/v1` |
| Android emulator | `http://10.0.2.2:3000/api/v1` |
| Real phone (same Wi-Fi) | `http://<your-computer-IP>:3000/api/v1` |

Without `API_BASE_URL` the app runs offline with a built-in preview catalog.

Each folder's own README has the details.

## Secrets

Nothing secret is committed. Every part reads its settings from a git-ignored file, and the committed templates show what to fill in:

| Part | Your file (ignored) | Template (committed) |
| --- | --- | --- |
| API | `.env` | `.env.example` |
| Admin | `.env.local` | `.env.example` |
| App | `config.json` | `config.example.json` |

## Tests

```bash
cd phsar_fresh_app && flutter test     # widget and unit tests
cd phsar-fresh-backend && npm run build
cd phsar_fresh_admin && npm run build
```

## Author

Built by **Long Bunheng**, Software Development student at Norton University, Phnom Penh.
