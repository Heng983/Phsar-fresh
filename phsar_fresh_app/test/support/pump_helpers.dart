import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/config/google_maps_config.dart';
import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/locale_provider.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/login_page.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/cart/presentation/pages/cart_page.dart';
import 'package:phsar_fresh_app/features/catalog/data/catalog_repository.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/chat/data/chat_api.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/pages/checkout_page.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/delivery_location_map.dart';
import 'package:phsar_fresh_app/features/market/presentation/pages/market_page.dart';
import 'package:phsar_fresh_app/features/profile/data/profile_photo_picker.dart';
import 'package:phsar_fresh_app/features/profile/data/profile_photo_repository.dart';
import 'package:phsar_fresh_app/features/profile/domain/model/avatar_image.dart';
import 'package:phsar_fresh_app/features/profile/presentation/pages/profile_page.dart';
import 'package:phsar_fresh_app/features/profile/presentation/providers/profile_photo_provider.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import 'auth_test_repository.dart';
import 'location_test_fixtures.dart';
import 'market_test_fixtures.dart';

/// Shared widget-test setup: screen size, theme, locale and text scale.
void setTestScreen(
  WidgetTester tester, {
  double width = 375,
  double height = 812,
}) {
  tester.view.physicalSize = Size(width, height);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
}

Widget testApp({
  required Widget home,
  String language = 'en',
  double scale = 1,
  bool disableAnimations = false,
}) => MaterialApp(
  theme: AppTheme.lightThemeFor(isKhmer: language == 'km'),
  locale: Locale(language),
  supportedLocales: AppLocalizations.supportedLocales,
  localizationsDelegates: AppLocalizations.localizationsDelegates,
  builder: (context, child) => MediaQuery(
    data: MediaQuery.of(context).copyWith(
      textScaler: TextScaler.linear(scale),
      disableAnimations: disableAnimations,
    ),
    child: child!,
  ),
  home: home,
);

Future<void> pumpMarket(
  WidgetTester tester, {
  double width = 375,
  String language = 'en',
  double scale = 1,
  bool explore = false,
  bool signedIn = false,
  bool disableAnimations = true,
  ChatApi? chatApi,
  bool? demoChat,
  CatalogRepository? catalog,
  bool settle = true,
}) async {
  setTestScreen(tester, width: width);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        seededCartOverride,
        chatApiProvider.overrideWithValue(chatApi),
        if (demoChat != null || chatApi != null)
          chatDemoModeProvider.overrideWithValue(demoChat ?? false),
        googleMapsConfiguredProvider.overrideWithValue(true),
        deliveryGoogleMapBuilderProvider.overrideWithValue(buildTestGoogleMap),
        if (signedIn) signedInCheckoutOverride,
        localeProvider.overrideWith(() => _TestLocale(Locale(language))),
        if (catalog != null)
          catalogRepositoryProvider.overrideWithValue(catalog),
      ],
      child: testApp(
        language: language,
        scale: scale,
        disableAnimations: disableAnimations,
        home: MarketPage(initiallyExplore: explore),
      ),
    ),
  );
  if (settle) await tester.pumpAndSettle();
}

class _TestLocale extends LocaleNotifier {
  final Locale locale;
  _TestLocale(this.locale);
  @override
  Locale build() => locale;
}

Future<ProviderContainer> pumpCart(
  WidgetTester tester, {
  double width = 390,
  double scale = 1,
  String language = 'en',
  VoidCallback? onContinueShopping,
}) async {
  setTestScreen(tester, width: width, height: 844);
  final container = ProviderContainer(
    overrides: [seededCartOverride, signedInCheckoutOverride],
  );
  addTearDown(container.dispose);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: testApp(
        language: language,
        scale: scale,
        home: Scaffold(
          body: SafeArea(
            child: CartPage(onContinueShopping: onContinueShopping ?? () {}),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<ProviderContainer> pumpCheckout(
  WidgetTester tester, {
  double width = 390,
  double scale = 1,
  String language = 'en',
  AppCurrency currency = AppCurrency.usd,
}) async {
  setTestScreen(tester, width: width, height: 844);
  final container = ProviderContainer(
    overrides: [seededCartOverride, signedInCheckoutOverride],
  );
  addTearDown(container.dispose);
  container.read(currencyProvider.notifier).select(currency);
  await tester.pumpWidget(
    UncontrolledProviderScope(
      container: container,
      child: testApp(
        language: language,
        scale: scale,
        home: const CheckoutPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return container;
}

Future<void> pumpDetail(
  WidgetTester tester, {
  double width = 375,
  String language = 'en',
  double scale = 1,
  MarketProduct product = greensProduct,
}) async {
  setTestScreen(tester, width: width);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [seededCartOverride],
      child: testApp(
        language: language,
        scale: scale,
        home: ProductDetailPage(product: product),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

Future<void> pumpLogin(
  WidgetTester tester, {
  double width = 375,
  String language = 'en',
  double textScale = 1,
  LoginPage page = const LoginPage(),
}) async {
  setTestScreen(tester, width: width);
  await tester.pumpWidget(
    ProviderScope(
      child: testApp(language: language, scale: textScale, home: page),
    ),
  );
  await tester.pumpAndSettle();
}

Future<ProviderContainer> pumpAccount(
  WidgetTester tester,
  TestAuthRepository repository, {
  ProfilePhotoRepository? photoRepository,
  ProfilePhotoPicker? photoPicker,
  double width = 390,
  double scale = 1,
  String language = 'en',
}) async {
  setTestScreen(tester, width: width, height: 844);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [
        profilePhotoPickerProvider.overrideWithValue(
          photoPicker ?? _IdlePhotoPicker(),
        ),
        authRepositoryProvider.overrideWithValue(repository),
        profilePhotoRepositoryProvider.overrideWithValue(
          photoRepository ?? TestProfilePhotoRepository(repository),
        ),
      ],
      child: testApp(
        language: language,
        scale: scale,
        home: Scaffold(
          body: SafeArea(
            child: ProfilePage(onViewOrders: () {}, onExplore: () {}),
          ),
        ),
      ),
    ),
  );
  await tester.pumpAndSettle();
  return ProviderScope.containerOf(tester.element(find.byType(ProfilePage)));
}

class _IdlePhotoPicker extends ProfilePhotoPicker {
  @override
  Future<PreparedAvatar?> recover() async => null;
  @override
  Future<PreparedAvatar?> pick(ProfilePhotoSource source) async => null;
}

Future<void> reveal(WidgetTester tester, Finder finder) async {
  await tester.ensureVisible(finder);
  await tester.pumpAndSettle();
}

Future<void> revealAndTap(WidgetTester tester, Finder finder) async {
  await reveal(tester, finder);
  await tester.tap(finder);
  await tester.pumpAndSettle();
}

Future<void> submit(WidgetTester tester) async {
  final button = find.byKey(const Key('auth-submit'));
  await tester.ensureVisible(button);
  await tester.tap(button);
  await tester.pumpAndSettle();
}
