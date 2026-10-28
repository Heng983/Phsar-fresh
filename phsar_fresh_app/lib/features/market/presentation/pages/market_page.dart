import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/cart/presentation/pages/cart_page.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/categories_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/explore_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/catalog_provider.dart';
import 'package:phsar_fresh_app/features/chat/presentation/pages/ai_chat_page.dart';
import 'package:phsar_fresh_app/features/market/presentation/models/market_tab.dart';
import 'package:phsar_fresh_app/features/market/presentation/providers/market_tab_request_provider.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_bottom_nav.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_mini_cart_bar.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_navigation_scope.dart';
import 'package:phsar_fresh_app/features/orders/presentation/pages/orders_page.dart';
import 'package:phsar_fresh_app/features/profile/presentation/pages/profile_page.dart';

class MarketPage extends ConsumerStatefulWidget {
  final bool initiallyExplore;

  const MarketPage({super.key, this.initiallyExplore = false});

  @override
  ConsumerState<MarketPage> createState() => _MarketPageState();
}

class _MarketPageState extends ConsumerState<MarketPage> {
  late MarketTab _selectedTab;

  @override
  void initState() {
    super.initState();
    _selectedTab = widget.initiallyExplore
        ? MarketTab.explore
        : MarketTab.categories;
  }

  void _selectTab(MarketTab tab) {
    FocusScope.of(context).unfocus();
    setState(() => _selectedTab = tab);
  }

  void _browseCategory(String categoryId) {
    ref.read(marketFilterProvider.notifier)
      ..reset()
      ..selectCategory(categoryId);
    _selectTab(MarketTab.categories);
  }

  Future<void> _openProfile() async {
    FocusScope.of(context).unfocus();
    final destination = await Navigator.of(context).push<MarketTab>(
      MaterialPageRoute(
        settings: const RouteSettings(name: '/profile'),
        builder: (context) => Scaffold(
          appBar: AppBar(
            leading: const BackButton(key: Key('profile-back')),
            backgroundColor: AppColors.background,
            surfaceTintColor: Colors.transparent,
            foregroundColor: AppColors.primaryDark,
            title: Text(
              context.l10n.marketProfile,
              style: const TextStyle(
                fontSize: AppFontSize.headline,
                fontWeight: FontWeight.w700,
              ),
            ),
          ),
          body: SafeArea(
            top: false,
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: 720),
                child: ProfilePage(
                  showMarketHeader: false,
                  onViewOrders: () => Navigator.pop(context, MarketTab.orders),
                  onExplore: () => Navigator.pop(context, MarketTab.explore),
                ),
              ),
            ),
          ),
        ),
      ),
    );
    if (mounted && destination != null) _selectTab(destination);
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(marketTabRequestProvider, (_, tab) {
      if (tab == null) return;
      ref.read(marketTabRequestProvider.notifier).handled();
      _selectTab(tab);
    });
    final cartCount = ref.watch(marketCartCountProvider);
    // The basket shortcut only shows while browsing products.
    final showMiniCart =
        cartCount > 0 &&
        (_selectedTab == MarketTab.explore ||
            _selectedTab == MarketTab.categories);
    final chatKeyboardOpen =
        _selectedTab == MarketTab.chat &&
        MediaQuery.viewInsetsOf(context).bottom > 0;
    final page = switch (_selectedTab) {
      MarketTab.explore => ExplorePage(
        onCategory: _browseCategory,
        onOpenChat: () => _selectTab(MarketTab.chat),
      ),
      MarketTab.categories => const CategoriesPage(),
      MarketTab.cart => CartPage(
        onContinueShopping: () => _selectTab(MarketTab.categories),
      ),
      MarketTab.orders => OrdersPage(
        onContinueShopping: () => _selectTab(MarketTab.categories),
        onViewCart: () => _selectTab(MarketTab.cart),
      ),
      MarketTab.chat => AiChatPage(keyboardOpen: chatKeyboardOpen),
    };
    return MarketNavigationScope(
      onOpenProfile: _openProfile,
      child: Scaffold(
        backgroundColor: AppColors.background,
        body: SafeArea(
          bottom: false,
          child: Center(
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 720),
              child: AnimatedSwitcher(
                duration: AppMotion.of(context, AppMotion.medium),
                switchInCurve: AppMotion.curve,
                switchOutCurve: Curves.easeIn,
                layoutBuilder: (current, previous) => Stack(
                  alignment: Alignment.topCenter,
                  children: [...previous, ?current],
                ),
                transitionBuilder: (child, animation) => FadeTransition(
                  opacity: animation,
                  child: SlideTransition(
                    position: Tween(
                      begin: const Offset(0, .015),
                      end: Offset.zero,
                    ).animate(animation),
                    child: child,
                  ),
                ),
                child: KeyedSubtree(key: ValueKey(_selectedTab), child: page),
              ),
            ),
          ),
        ),
        bottomNavigationBar: chatKeyboardOpen
            ? null
            : Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  // SizeTransition (not AnimatedSize): the Scaffold lays out
                  // its bottom bar in a way AnimatedSize cannot re-dirty.
                  AnimatedSwitcher(
                    duration: AppMotion.of(context, AppMotion.medium),
                    switchInCurve: AppMotion.curve,
                    switchOutCurve: Curves.easeIn,
                    transitionBuilder: (child, animation) => SizeTransition(
                      sizeFactor: animation,
                      alignment: Alignment.bottomCenter,
                      child: FadeTransition(opacity: animation, child: child),
                    ),
                    child: showMiniCart
                        ? MarketMiniCartBar(
                            key: const ValueKey('mini-cart-shown'),
                            onOpen: () => _selectTab(MarketTab.cart),
                          )
                        : const SizedBox(
                            key: ValueKey('mini-cart-hidden'),
                            width: double.infinity,
                          ),
                  ),
                  MarketBottomNav(
                    selectedTab: _selectedTab,
                    cartCount: cartCount,
                    onChanged: _selectTab,
                  ),
                ],
              ),
      ),
    );
  }
}
