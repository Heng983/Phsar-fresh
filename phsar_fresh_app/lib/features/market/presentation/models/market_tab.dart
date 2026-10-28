import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

/// Reorder these values to change the bottom-navigation order.
enum MarketTab { explore, categories, cart, orders, chat }

extension MarketTabContent on MarketTab {
  String label(AppLocalizations l10n) => switch (this) {
    MarketTab.explore => l10n.marketExplore,
    MarketTab.categories => l10n.marketCategories,
    MarketTab.cart => l10n.marketCart,
    MarketTab.orders => l10n.marketOrders,
    MarketTab.chat => l10n.marketChat,
  };

  IconData get icon => switch (this) {
    MarketTab.explore => Icons.storefront_outlined,
    MarketTab.categories => Icons.grid_view_outlined,
    MarketTab.cart => Icons.shopping_cart_outlined,
    MarketTab.orders => Icons.receipt_long_outlined,
    MarketTab.chat => Icons.chat_bubble_outline_rounded,
  };

  IconData get selectedIcon => switch (this) {
    MarketTab.explore => Icons.storefront_rounded,
    MarketTab.categories => Icons.grid_view_rounded,
    MarketTab.cart => Icons.shopping_cart_rounded,
    MarketTab.orders => Icons.receipt_long_rounded,
    MarketTab.chat => Icons.chat_bubble_rounded,
  };
}
