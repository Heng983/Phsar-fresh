import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
// Core
import 'package:phsar_fresh_app/core/localization/locale_provider.dart';
import 'package:phsar_fresh_app/core/navigation/app_keys.dart';
import 'package:phsar_fresh_app/core/navigation/app_routes.dart';
import 'package:phsar_fresh_app/core/navigation/auth_system_ui_observer.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
// Authentication
import 'package:phsar_fresh_app/features/auth/presentation/pages/auth_landing_page.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/login_page.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/pages/checkout_page.dart';
// Market
import 'package:phsar_fresh_app/features/market/presentation/pages/market_page.dart';
import 'package:phsar_fresh_app/features/notifications/presentation/widgets/notification_alerts.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';
import 'package:skeletonizer/skeletonizer.dart';

/// Same soft shimmer in light and dark mode (the app has no dark theme).
PaintingEffect _skeletonEffect(Brightness _) => const ShimmerEffect(
  baseColor: Color(0xFFE4EADC),
  highlightColor: Color(0xFFF5F8F1),
);

class PhsarFreshApp extends ConsumerWidget {
  const PhsarFreshApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    final isKhmer = locale.languageCode == 'km';

    return MaterialApp(
      title: 'Phsar Fresh',
      debugShowCheckedModeBanner: false,

      navigatorKey: appNavigatorKey,

      navigatorObservers: [ref.watch(authSystemUiObserverProvider)],

      theme: AppTheme.lightThemeFor(isKhmer: isKhmer),

      // Khmer text never renders below 12 px, on top of the user's own
      // text-size setting. The builder is always present so switching
      // language never changes the widget tree above the navigator.
      builder: (context, child) {
        final media = MediaQuery.of(context);
        return MediaQuery(
          data: isKhmer
              ? media.copyWith(
                  textScaler: MinimumFontSizeTextScaler(media.textScaler),
                )
              : media,
          // Light green-grey shimmer for every skeleton, also when the
          // phone is in dark mode (the default would turn bones dark).
          child: SkeletonizerConfig(
            data: const SkeletonizerConfigData(
              brightness: Brightness.light,
              effectResolver: _skeletonEffect,
            ),
            child: NotificationAlerts(child: child!),
          ),
        );
      },

      locale: locale,

      supportedLocales: AppLocalizations.supportedLocales,

      localizationsDelegates: AppLocalizations.localizationsDelegates,

      home: const AuthLandingPage(),

      initialRoute: const String.fromEnvironment(
        'APP_INITIAL_ROUTE',
        defaultValue: '/',
      ),

      // Application routes
      routes: {
        AppRoutes.login: (_) => const LoginPage(),

        AppRoutes.register: (_) => const LoginPage(initiallyRegister: true),

        AppRoutes.market: (_) => const MarketPage(),

        AppRoutes.checkout: (_) => const CheckoutPage(),

        AppRoutes.explore: (_) => const MarketPage(initiallyExplore: true),

        AppRoutes.product: (_) => ProductDetailPage(product: greensProduct),
      },
    );
  }
}
