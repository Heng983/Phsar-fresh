# Phsar Fresh Backend

The API for Phsar Fresh: NestJS + TypeScript, with PostgreSQL (Prisma) and Redis. It serves the Flutter app in `../phsar_fresh_app` and the web admin in `../phsar_fresh_admin`.

## Requirements

- Node.js 22 or newer
- Docker Desktop (runs PostgreSQL and Redis)

## Setup

```bash
# 1. Install packages
npm install

# 2. Create your settings file
cp .env.example .env
```

Open `.env` and fill in the secrets. Generate each one with this command, using a **different** value for each:

```bash
openssl rand -hex 48
```

Or print both lines at once, ready to paste:

```bash
echo "JWT_ACCESS_SECRET=$(openssl rand -hex 48)"; echo "OTP_SECRET=$(openssl rand -hex 48)"
```

Then pick a database password and use it in **both** places:

```env
POSTGRES_PASSWORD=my-db-password
DATABASE_URL=postgresql://phsar:my-db-password@localhost:5433/phsar_fresh
```

```bash
# 3. Start PostgreSQL (port 5433) and Redis (port 6380)
docker compose up -d

# 4. Create the database tables
npm run prisma:migrate

# 5. Add the sample categories and products (safe to run again)
npm run db:seed

# 6. Create your first admin account (for the web admin)
npm run create-admin -- 012345678 "MyPassword123" "Your Name"

# 7. Start the API
npm run start:dev
```

- API: http://localhost:3000/api/v1
- Swagger docs: http://localhost:3000/docs (turned off when `NODE_ENV=production`)

## Settings (`.env`)

| Variable | Required | What it is |
| --- | :-: | --- |
| `POSTGRES_PASSWORD` | ✓ | Database password, used by `docker-compose.yml` when it creates the database |
| `DATABASE_URL` | ✓ | PostgreSQL connection; its password must match `POSTGRES_PASSWORD` |
| `REDIS_URL` | ✓ | Redis connection (`redis://localhost:6380`) |
| `JWT_ACCESS_SECRET` | ✓ | Signs access tokens. Changing it signs everyone out |
| `OTP_SECRET` | ✓ | Protects the SMS codes stored in Redis |
| `GEMINI_API_KEY` | | Google Gemini key for the AI chat. Without it, chat is turned off. Get one at https://aistudio.google.com/apikey |
| `PAYWAY_MOCK` | | `true` simulates payments, so no ABA account is needed. Ignored in production |
| `PAYWAY_MERCHANT_ID`, `PAYWAY_API_KEY` | | ABA PayWay credentials (needed when `PAYWAY_MOCK` isn't `true`) |
| `PAYWAY_BASE_URL` | | `https://checkout-sandbox.payway.com.kh` for testing |
| `PAYWAY_CALLBACK_URL` | | Public URL that PayWay calls after a payment (see below) |
| `PAYWAY_QR_LIFETIME_MINUTES` | | How long a payment QR stays valid (default 15, minimum 3) |
| `JWT_ACCESS_EXPIRES` | | Access token lifetime (default `15m`) |
| `REFRESH_TTL_DAYS` | | How long a sign-in lasts (default `30`) |
| `DELIVERY_FEE_CENTS` | | Delivery fee in US cents (default `100` = $1.00) |
| `PORT` | | API port (default `3000`) |

Never commit `.env`; it is git-ignored. Only `.env.example` belongs in the repo.

## Development notes

**SMS codes.** No SMS is sent while `NODE_ENV` isn't `production`. The code is printed in the API terminal instead:

```
[DEV SMS] to +85512345678: Your Phsar Fresh code is 482913. It expires in 1 minutes.
```

**Payments.** With `PAYWAY_MOCK=true`, orders paid with ABA Pay show a test QR, and the app shows a "Simulate payment" button (`POST /orders/:id/payment/test-pay`). No money moves.

To test the real ABA PayWay sandbox, set `PAYWAY_MOCK=false` and your sandbox credentials. PayWay must be able to reach `PAYWAY_CALLBACK_URL` from the internet, so on your own computer use a tunnel (for example ngrok) and set:

```env
PAYWAY_CALLBACK_URL=https://<your-tunnel>/api/v1/payments/payway/callback
```

Without a callback, the app still finds out about payments by asking PayWay while the QR is on screen.

**Admin accounts.** `create-admin` creates or resets an account directly, without SMS. To promote an account that already signed up in the app:

```bash
npm run make-admin -- 012345678
```

Roles: `SUPER_ADMIN` (default), `MANAGER`, `STAFF`, `DRIVER`. Add one as the last argument of `create-admin`.

**Uploaded images.** Avatars and admin photos are saved in `uploads/` and served at `/uploads/...`. This folder is git-ignored.

## Scripts

| Command | What it does |
| --- | --- |
| `npm run start:dev` | Start the API and restart it on code changes |
| `npm run build` / `npm run start:prod` | Build into `dist/`, then run the build |
| `npm run prisma:migrate` | Apply migrations (and create a new one after editing `schema.prisma`) |
| `npm run prisma:generate` | Regenerate the Prisma client |
| `npm run prisma:studio` | Browse the database in the browser |
| `npm run db:seed` | Add or update the sample catalog |
| `npm run create-admin` / `npm run make-admin` | Admin accounts (see above) |

## Before going to production

- Set `NODE_ENV=production`. This turns off Swagger, the dev SMS log and payment simulation.
- **SMS is not built yet.** `src/sms/sms.service.ts` throws in production, so sign-up codes can't be sent until you connect an SMS provider there.
- Use `npx prisma migrate deploy` instead of `prisma:migrate`.
- Limit CORS to your own domains in `src/main.ts` (it currently allows any origin).
- Use real PayWay credentials and a public HTTPS `PAYWAY_CALLBACK_URL`.

## Structure

```
prisma/
  schema.prisma        database models
  migrations/          SQL migrations
  seed.ts              sample catalog
  create-admin.ts      create or reset an admin account
src/
  auth/ otp/ sms/      phone + password sign-up, SMS codes, tokens
  users/               profile and avatar
  products/ categories/ promotions/ discounts/
  orders/ payments/    checkout and ABA PayWay (KHQR)
  chat/                AI assistant (Gemini)
  admin/               routes for the web admin, with role permissions
  notifications/
```
