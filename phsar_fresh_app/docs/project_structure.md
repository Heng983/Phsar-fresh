# Project structure

The app is organised by feature. Each feature owns its own layers:

```
lib/features/<feature>/
  data/            storage, API clients, demo fixtures
  domain/model/    plain Dart models (no Flutter widgets)
  presentation/
    models/        l10n labels and display helpers for domain models
    pages/         full screens
    providers/     Riverpod state
    widgets/       UI pieces used by that feature's pages
```

Inside `lib/` always import with `package:phsar_fresh_app/...` (enforced by the
`always_use_package_imports` lint). Tests mirror this layout under `test/`.

## Where things live

| Folder | What it owns |
| --- | --- |
| `lib/app.dart`, `lib/main.dart` | `MaterialApp`, routes, startup storage overrides |
| `core/config/` | `ApiConfig`, `GoogleMapsConfig` (values from `--dart-define`) |
| `core/network/` | Dio `ApiClient` with token refresh, `ApiException` |
| `core/storage/` | Secure `TokenStorage` |
| `core/constants/`, `core/theme/` | Colours and theme |
| `core/currency/`, `core/localization/` | Currency and language selection |
| `core/navigation/` | Route names, iOS status-bar observer |
| `core/widgets/` | App-wide widgets: `AppLogo`, `AppSnackBar`, `SurfaceCard`, `EmptyState` |
| `features/onboarding/` | First-run onboarding screen |
| `features/auth/` | Sign-in, registration, OTP, `AuthRepository`, validators |
| `features/market/` | The tabbed shell (`MarketPage`), bottom nav, shared header, notifications |
| `features/catalog/` | Products, categories, search/filters, Explore, Categories, product details, favorites, promotions |
| `features/cart/` | Cart state, persistence, voucher, totals, Cart page |
| `features/checkout/` | Checkout preferences and page |
| `features/orders/` | Order history, status timeline, reorder |
| `features/location/` | Delivery location model, storage, GPS/geocoding, map and address sheet |
| `features/chat/` | Ming Sros AI chat: `ChatApi`, demo replies, chat page |
| `features/profile/` | Profile page, account editing, profile photo picker/crop/upload |

Dependencies point from shell → features → `core`. `core` never imports a
feature. `cart` builds on `catalog`; `orders`, `checkout` and `chat` build on
`cart` and `catalog`.

## Tabs

To change the tab order, reorder the values in
`features/market/presentation/models/market_tab.dart`. Labels, icons, page
selection and the cart badge use those tab names. `MarketPage` maps each tab to
its page.

## Catalog

Products and categories come from a `CatalogRepository`
(`catalog/data/catalog_repository.dart`):

- `ApiCatalogRepository` — the backend's `GET /categories` and `GET /products`
  (search `q`, `categoryId`, `inStock`, `page`, `limit` ≤ 50). Installed in
  `main.dart` when `API_BASE_URL` is set.
- `LocalCatalogRepository` — the offline preview catalog in
  `catalog/data/market_catalog.dart`, shaped like the server's data. Tests use it.

`MarketProduct` and `ProductCategory` (`catalog/domain/model/`) match the
server's JSON, with English and optional Khmer text. Organic / new-arrival /
popular flags, packs, farms, nutrition and reviews are preview-only extras; the
UI hides sections that have no data rather than inventing it.

`productListProvider(request)` loads one paged list per search/category/stock
combination (searches against the server wait 350 ms after typing stops).
`categoriesProvider` loads categories. Pages show loading, error-with-retry,
empty and "Load more" states through `ProductListSliver`.

- Promotion slides and prices: `catalog/data/market_promotions.dart`; claims and
  the deal deadline: `catalog/presentation/providers/promotion_provider.dart`.
- Search, filters and sort for Explore and Categories (kept independent):
  `catalog/presentation/providers/catalog_provider.dart`.
- Search UI: `market_search_section.dart`, `market_search_bar.dart`,
  `market_filter_sheet.dart`. Deal carousel: `market_harvest_deal.dart` and
  `harvest_deal_banner.dart`.

English and Khmer text belongs in `lib/l10n/app_en.arb` and `lib/l10n/app_km.arb`;
regenerate with `flutter gen-l10n` after editing translations.

### Product details

Product cards on Explore and Categories open `ProductDetailPage.open()` and
keep the current search, filters and tab when returning. Category cards (and
the category chips) show that category's products.

The detail page widgets live in `catalog/presentation/widgets/product/`: image
gallery, info, farm, pack selector, quantity selector (1–99), nutrition, reviews
and purchase bar.

`catalog/data/product_details.dart` holds demo farm, nutrition, review and pack
data. Replace those fixtures with verified supplier and customer records when
connecting an API. KHR amounts use the demo rate of 4,100 KHR per USD and show
an approximation marker.

To preview the detail screen directly:

```sh
flutter run --dart-define=APP_INITIAL_ROUTE=/product
```

## Cart

Cart lines are identified by product and pack size (`cart/domain/model/cart_item.dart`).
A product's default pack merges with its catalog cart line; other sizes stay
separate and use their own prices.

`cart/domain/model/cart_summary.dart` calculates quantities, subtotal, discount
and delivery in integer cents. `cart/presentation/providers/cart_provider.dart`
owns the cart, its device persistence, the applied voucher and the summary. The
demo offer `KHMERFRESH` saves up to $1.50; delivery costs $1.00 for a nonempty
basket. Vouchers do not stack and clear when the basket becomes empty. Replace
local pricing with server quotes when connecting checkout.

Order submission and payment are not connected.
