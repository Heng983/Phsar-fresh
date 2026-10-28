import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/navigation/app_routes.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/app_snack_bar.dart';
import 'package:phsar_fresh_app/core/widgets/segmented_tabs.dart';
import 'package:phsar_fresh_app/core/widgets/surface_card.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_header.dart';
import 'package:phsar_fresh_app/features/orders/data/market_orders.dart';
import 'package:phsar_fresh_app/features/orders/data/orders_repository.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';
import 'package:phsar_fresh_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/active_order_card.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/orders_help_sheet.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/past_order_card.dart';
import 'package:skeletonizer/skeletonizer.dart';

class OrdersPage extends ConsumerStatefulWidget {
  final VoidCallback onContinueShopping;
  final VoidCallback onViewCart;

  const OrdersPage({
    super.key,
    required this.onContinueShopping,
    required this.onViewCart,
  });

  @override
  ConsumerState<OrdersPage> createState() => _OrdersPageState();
}

class _OrdersPageState extends ConsumerState<OrdersPage> {
  final _scrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Opening the tab always shows fresh statuses.
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || ref.read(apiClientProvider) == null) return;
      if (ref.read(remoteOrdersProvider).hasValue) {
        ref.read(remoteOrdersProvider.notifier).refresh();
      }
    });
  }

  @override
  void dispose() {
    _scrollController.dispose();
    super.dispose();
  }

  void _selectView(OrdersView view) {
    ref.read(ordersViewProvider.notifier).select(view);
    if (_scrollController.hasClients) _scrollController.jumpTo(0);
  }

  void _reorder(BuildContext context, WidgetRef ref, MarketOrder order) {
    final added = ref.read(reorderProvider)(order);
    if (added > 0) widget.onViewCart();
    AppSnackBar.show(
      context,
      message: added > 0
          ? context.l10n.ordersReorderAdded
          : context.l10n.ordersItemsUnavailable,
      tone: added > 0 ? AppSnackBarTone.success : AppSnackBarTone.info,
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final orders = ref.watch(marketOrdersProvider);
    final active = ref.watch(activeOrdersProvider);
    final history = ref.watch(pastOrdersProvider);
    final view = ref.watch(ordersViewProvider);
    final historyOnly = view == OrdersView.history;
    final remote = ref.watch(apiClientProvider) != null;
    final remoteState = remote ? ref.watch(remoteOrdersProvider) : null;
    // While loading, signed out or offline, a single card replaces the lists.
    Widget? blocker;
    if (remoteState != null && !remoteState.hasValue) {
      final error = remoteState.error;
      blocker = remoteState.isLoading
          // Shimmering cards shaped like real orders instead of a spinner.
          ? Skeletonizer(
              key: const Key('orders-loading'),
              child: IgnorePointer(
                child: Column(
                  children: [
                    for (final order in sampleMarketOrders(
                      DateTime.now(),
                    ).take(2))
                      Padding(
                        padding: const EdgeInsets.only(bottom: 12),
                        child: PastOrderCard(order: order, onReorder: () {}),
                      ),
                  ],
                ),
              ),
            )
          : error is OrdersException && error.problem == OrdersProblem.signIn
          ? _OrdersMessageCard(
              key: const Key('orders-sign-in'),
              icon: Icons.lock_outline_rounded,
              title: l10n.ordersSignInTitle,
              description: l10n.ordersSignInBody,
              action: l10n.signIn,
              onAction: () => Navigator.pushNamed(context, AppRoutes.login),
            )
          : _OrdersMessageCard(
              key: const Key('orders-error'),
              icon: Icons.cloud_off_rounded,
              title: l10n.ordersLoadFailed,
              description: l10n.ordersLoadFailedBody,
              action: l10n.ordersRetry,
              onAction: () => ref.invalidate(remoteOrdersProvider),
            );
    }
    final scroll = SingleChildScrollView(
      controller: _scrollController,
      key: const PageStorageKey('market-orders-scroll'),
      physics: remote ? const AlwaysScrollableScrollPhysics() : null,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const MarketHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 8, 20, 28),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),
                Wrap(
                  spacing: 12,
                  runSpacing: 8,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  children: [
                    Text(
                      l10n.ordersTitle,
                      style: TextStyle(
                        fontSize: AppFontSize.displayLarge,
                        fontWeight: FontWeight.w700,
                        height: context.lineHeight(1.25),
                      ),
                    ),
                    if (active.isNotEmpty)
                      Container(
                        padding: const EdgeInsets.symmetric(
                          horizontal: 11,
                          vertical: 7,
                        ),
                        decoration: BoxDecoration(
                          color: AppColors.lightGreen,
                          borderRadius: BorderRadius.circular(24),
                        ),
                        child: Text(
                          l10n.ordersActiveCount(active.length),
                          style: const TextStyle(
                            color: AppColors.primaryDark,
                            fontSize: AppFontSize.badge,
                            fontWeight: FontWeight.w700,
                          ),
                        ),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                Text(
                  l10n.ordersSubtitle,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppFontSize.footnote,
                    height: 1.6,
                  ),
                ),
                if (orders.any((order) => order.isDemo))
                  Padding(
                    padding: const EdgeInsets.only(top: 12),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Icon(
                          Icons.info_outline_rounded,
                          size: 15,
                          color: AppColors.orange,
                        ),
                        const SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            l10n.ordersSampleNotice,
                            style: const TextStyle(
                              color: AppColors.orange,
                              fontSize: AppFontSize.badge,
                              height: 1.5,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                const SizedBox(height: 20),
                // Tabs only once orders are known: "Active (0)" while
                // loading or signed out would be misleading.
                if (blocker == null) ...[
                  SegmentedTabs(
                    labels: [
                      l10n.ordersActiveTab(active.length),
                      l10n.ordersHistoryTab(history.length),
                    ],
                    selectedIndex: OrdersView.values.indexOf(view),
                    onChanged: (index) => _selectView(OrdersView.values[index]),
                    tabKeys: [
                      for (final tab in OrdersView.values)
                        ValueKey('orders-tab-${tab.name}'),
                    ],
                    fontSize: AppFontSize.footnote,
                    verticalPadding: 13,
                    selectedColor: AppColors.primaryDark,
                  ),
                  const SizedBox(height: 20),
                ],
                ?blocker,
                if (blocker == null && !historyOnly) ...[
                  for (final order in active)
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: ActiveOrderCard(
                        key: ValueKey('active-order-${order.id}'),
                        order: order,
                      ),
                    ),
                  if (active.isEmpty)
                    _OrdersEmptyCard(
                      title: orders.isEmpty
                          ? l10n.marketNoOrders
                          : l10n.ordersNoActive,
                      description: orders.isEmpty
                          ? l10n.marketNoOrdersDescription
                          : l10n.ordersNoActiveDescription,
                      onShop: widget.onContinueShopping,
                    ),
                ],
                if (blocker == null && (historyOnly || history.isNotEmpty)) ...[
                  if (!historyOnly) const SizedBox(height: 10),
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          historyOnly
                              ? l10n.ordersHistoryTitle
                              : l10n.ordersRecentPurchases,
                          style: const TextStyle(
                            fontSize: AppFontSize.headline,
                            fontWeight: FontWeight.w700,
                            height: 1.4,
                          ),
                        ),
                      ),
                      if (!historyOnly)
                        TextButton(
                          key: const Key('orders-see-history'),
                          onPressed: () => _selectView(OrdersView.history),
                          child: Text(
                            l10n.ordersSeeAll,
                            style: const TextStyle(
                              fontSize: AppFontSize.caption,
                            ),
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  for (final order in historyOnly ? history : history.take(2))
                    Padding(
                      padding: const EdgeInsets.only(bottom: 16),
                      child: PastOrderCard(
                        key: ValueKey('past-order-${order.id}'),
                        order: order,
                        onReorder: () => _reorder(context, ref, order),
                      ),
                    ),
                  if (history.isEmpty)
                    _OrdersEmptyCard(
                      title: l10n.ordersNoHistory,
                      description: l10n.ordersNoHistoryDescription,
                      onShop: widget.onContinueShopping,
                    ),
                ],
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.inputBackground,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Row(
                        children: [
                          const CircleAvatar(
                            backgroundColor: AppColors.lightGreen,
                            child: Icon(
                              Icons.support_agent_rounded,
                              color: AppColors.primary,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  l10n.ordersHelpTitle,
                                  style: const TextStyle(
                                    fontSize: AppFontSize.bodyLarge,
                                    fontWeight: FontWeight.w700,
                                    height: 1.4,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  l10n.ordersHelpSubtitle,
                                  style: const TextStyle(
                                    fontSize: AppFontSize.caption,
                                    color: AppColors.textSecondary,
                                    height: 1.5,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      TextButton(
                        key: const Key('orders-help'),
                        onPressed: () => OrdersHelpSheet.show(context),
                        style: TextButton.styleFrom(
                          backgroundColor: Colors.white,
                          foregroundColor: AppColors.primaryDark,
                          padding: const EdgeInsets.symmetric(vertical: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(l10n.ordersGetHelp),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
    if (!remote) return scroll;
    return RefreshIndicator(
      onRefresh: () => ref.read(remoteOrdersProvider.notifier).refresh(),
      child: scroll,
    );
  }
}

class _OrdersMessageCard extends StatelessWidget {
  final IconData icon;
  final String title;
  final String description;
  final String? action;
  final VoidCallback? onAction;

  const _OrdersMessageCard({
    super.key,
    required this.icon,
    required this.title,
    required this.description,
    this.action,
    this.onAction,
  });

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.lightGreen,
          child: Icon(icon, size: 27, color: AppColors.primary),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: AppFontSize.headline,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppFontSize.footnote,
            height: 1.6,
          ),
        ),
        if (action != null && onAction != null) ...[
          const SizedBox(height: 16),
          FilledButton(
            key: const Key('orders-retry'),
            onPressed: onAction,
            child: Text(action!),
          ),
        ],
      ],
    ),
  );
}

class _OrdersEmptyCard extends StatelessWidget {
  final String title;
  final String description;
  final VoidCallback onShop;

  const _OrdersEmptyCard({
    required this.title,
    required this.description,
    required this.onShop,
  });

  @override
  Widget build(BuildContext context) => SurfaceCard(
    padding: const EdgeInsets.all(24),
    child: Column(
      children: [
        const CircleAvatar(
          radius: 28,
          backgroundColor: AppColors.lightGreen,
          child: Icon(
            Icons.shopping_bag_outlined,
            size: 27,
            color: AppColors.primary,
          ),
        ),
        const SizedBox(height: 16),
        Text(
          title,
          textAlign: TextAlign.center,
          style: const TextStyle(
            fontSize: AppFontSize.headline,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 8),
        Text(
          description,
          textAlign: TextAlign.center,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppFontSize.footnote,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 16),
        FilledButton(
          onPressed: onShop,
          child: Text(
            context.l10n.marketContinueShopping,
            textAlign: TextAlign.center,
          ),
        ),
      ],
    ),
  );
}
