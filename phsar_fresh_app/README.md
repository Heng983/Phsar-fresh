# Phsar Fresh

Flutter shopping app with English/Khmer localization. Products, categories, accounts and profiles connect to the [Phsar Fresh backend](../../BackEnd/phsar-fresh-backend); orders and checkout are still previews.

## Run locally

```sh
flutter pub get
flutter run
```

No backend credentials are required to start the app. To use native Google Maps, copy `config.example.json` to the git-ignored `config.json`, fill in the platform Maps keys, and run:

```sh
flutter run --dart-define-from-file=config.json
```

### Connecting the backend

Start the backend (`docker compose up -d`, then `npm run start:dev` in `phsar-fresh-backend`), and set `API_BASE_URL` in `config.json`. The URL **must include `/api/v1`**:

| Running on | `API_BASE_URL` |
| --- | --- |
| iOS simulator | `http://localhost:3000/api/v1` |
| Android emulator | `http://10.0.2.2:3000/api/v1` |
| Physical phone (same Wi‑Fi) | `http://<your-computer-LAN-IP>:3000/api/v1` |

Without `API_BASE_URL` the app runs fully offline: it shows a built-in preview catalog, accounts show as unavailable, and chat uses demo replies.

See [Google Maps setup](docs/google_maps_setup.md) for platform configuration. Fully restart/rebuild after changing native plugins or Maps keys.

See [Project structure](docs/project_structure.md) for where each feature's code lives.

## Current behavior

- With `API_BASE_URL` set, Explore and Categories show the server's categories and products (`GET /categories`, `GET /products`): English/Khmer search, category browsing, an "In stock only" filter, sorting, and "Load more" paging. Sold-out products can't be added. AI chat suggestions can be added to the basket directly.
- Server products have one price and unit; pack sizes, farm stories, nutrition and reviews appear only for the offline preview catalog. Harvest deals are hidden because the server has no promotions yet.
- The basket is saved on this device. Server products are saved as a snapshot (shown instantly at launch); their prices must be confirmed by the server when real checkout is built.
- The basket and selected delivery location are saved on this device. Location permission is requested only when choosing to use GPS. Manual address entry remains available.
- Checkout is available to guests as a preview. Order submission and payments show the existing coming-soon message; no order is submitted or payment collected.
- The header profile icon (the logo for guests on shopping pages) opens Profile. Language, currency, and help remain accessible.
- With `API_BASE_URL` set: register with phone + password, confirm the SMS code, log in, stay signed in across restarts ("Remember me"), edit your name, upload or remove a profile photo, and sign out. Expired sessions refresh automatically.
- Not yet supported by the backend, so these show "unavailable": log in with an SMS code instead of a password, forgot password, changing phone/email, and Google/Facebook/Apple sign-in.
- AI Chat features Ming Sros (មីងស្រស់), the shopping assistant. With `API_BASE_URL` configured, it talks to your AI backend and shows suggested products as cards inside the reply. Without it, chat runs in demo mode with sample replies. Conversations and drafts survive tab changes during the session.

## How accounts are connected

The UI uses app-owned `AuthUser`, `AuthSession`, `AuthResult`, and `AuthFailure` models; no backend types reach widgets.

- `ApiCatalogRepository` (`features/catalog/data/`) reads categories and products; the offline `LocalCatalogRepository` serves the preview catalog in the same shape.
- `ApiAuthRepository` (`features/auth/data/`) implements `AuthRepository` against `/auth/*` and `/users/me`. `ApiProfilePhotoRepository` uploads photos to `/users/me/avatar`. Both are installed in `main.dart` when `API_BASE_URL` is set; otherwise the `Unavailable…` versions stay in place.
- One shared `ApiClient` (`core/network/api_providers.dart`) adds the access token and refreshes it once on a 401. If the refresh token is rejected, the user is signed out.
- `TokenStorage` keeps tokens and the last profile in memory, and in secure storage only when "Remember me" is on. The saved profile shows instantly on launch, then refreshes from `/auth/me` in the background.
- Backend errors become friendly messages: wrong password, wrong/expired code, phone already registered, too many attempts, and connection problems.

Checkout still has no authentication gate or order API; add server-side order validation when implementing real order submission.

## AI chat API

Set `API_BASE_URL` to your backend's HTTP(S) base URL in the git-ignored `config.json`, then fully restart with `flutter run --dart-define-from-file=config.json`. Startup and browsing also work without this setting. Existing saved tokens are attached by the API client; account sign-in remains disconnected.

`ChatApi` sends `POST /chat` with the newest `message` (max 500 characters) and up to the last 10 earlier turns as `history`, each with `role` (`user` or `model`) and `text` (max 1000 characters). Replies may take up to 60 seconds. The response contains a text `reply` and optional `products`, for example:

```json
{
  "reply": "Our pepper comes from Kampot.",
  "products": [
    {
      "id": "kampot-pepper",
      "name": "Kampot Black Pepper",
      "nameKm": "ម្រេចកំពត",
      "origin": "Kampot",
      "category": "spices",
      "unit": "100g",
      "priceCents": 450,
      "imageUrl": "/uploads/pepper.jpg",
      "inStock": true
    }
  ]
}
```

`priceCents` is an integer USD amount. Relative `imageUrl` paths are loaded from the API host. Khmer mode shows `nameKm` when provided. Malformed responses and request failures show localized retry controls, without adding error messages to the conversation history sent to the model. HTTP 429 shows a "sending too fast" message and HTTP 503 shows the unavailable message. Starting a new conversation cancels its pending request.

Demo mode runs automatically when `API_BASE_URL` is not set; force it on or off with `--dart-define=CHAT_DEMO_MODE=true|false`.

The basket still uses the local catalog. Add-to-cart is enabled only when a suggested product is in stock and its `id` and `priceCents` match a local catalog product (for example `greens` at 180). Other products are shown with a "Cannot add yet" note instead of adding a different local item. When connecting a backend catalog, update `_catalogProduct` in `ai_chat_page.dart` or pass `onAddToCart` to the standalone `ChatScreen(api: ..., onAddToCart: ...)`.

## Validation

```sh
flutter analyze --no-pub
flutter test --no-pub
```

Tests cover local shopping, navigation, layouts in both languages, offline startup, disconnected account actions, and backend-independent account/photo UI through injected test repositories. Chat tests use mocked HTTP responses and do not contact the live chat server. Tests do not send SMS, upload files, create real accounts, or contact an authentication service.
