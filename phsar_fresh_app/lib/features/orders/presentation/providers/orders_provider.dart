import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/data/product_details.dart';
import 'package:phsar_fresh_app/features/orders/data/market_orders.dart';
import 'package:phsar_fresh_app/features/orders/data/orders_repository.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';

final ordersReferenceTimeProvider = Provider<DateTime>((ref) => DateTime.now());

final ordersRepositoryProvider = Provider<OrdersRepository?>((ref) {
  final client = ref.watch(apiClientProvider);
  return client == null ? null : OrdersRepository(client);
});

/// The signed-in customer's orders from the server. Reloads when they sign
/// in or out, every 30 s while an order is still on its way, and on
/// [RemoteOrdersNotifier.refresh] (pull to refresh, after checkout).
class RemoteOrdersNotifier extends AsyncNotifier<List<MarketOrder>> {
  static const _pollEvery = Duration(seconds: 30);
  Timer? _poll;

  @override
  Future<List<MarketOrder>> build() async {
    ref.onDispose(() => _poll?.cancel());
    final repository = ref.watch(ordersRepositoryProvider);
    if (repository == null) return const [];
    // Waits for the saved session on startup instead of flashing "sign in".
    final userId = (await ref.watch(authSessionProvider.future))?.user.id;
    if (userId == null) throw const OrdersException(OrdersProblem.signIn);
    final orders = await repository.mine();
    _schedule(orders);
    return orders;
  }

  void _schedule(List<MarketOrder> orders) {
    _poll?.cancel();
    if (orders.any((order) => order.isActive)) {
      _poll = Timer(_pollEvery, refresh);
    }
  }

  /// Fetches again; keeps the orders on screen if this attempt fails.
  Future<void> refresh() async {
    final repository = ref.read(ordersRepositoryProvider);
    if (repository == null) return;
    try {
      final orders = await repository.mine();
      if (!ref.mounted) return;
      state = AsyncData(orders);
      _schedule(orders);
    } on OrdersException catch (error, stack) {
      if (!ref.mounted) return;
      if (!state.hasValue || error.problem == OrdersProblem.signIn) {
        state = AsyncError(error, stack);
      }
    }
  }
}

final remoteOrdersProvider =
    AsyncNotifierProvider<RemoteOrdersNotifier, List<MarketOrder>>(
      RemoteOrdersNotifier.new,
    );

/// Real orders when the app talks to the server; preview orders otherwise.
final marketOrdersProvider = Provider<List<MarketOrder>>((ref) {
  if (ref.watch(apiClientProvider) == null) {
    return List.unmodifiable(
      sampleMarketOrders(ref.watch(ordersReferenceTimeProvider)),
    );
  }
  return ref.watch(remoteOrdersProvider).value ?? const [];
});

final activeOrdersProvider = Provider<List<MarketOrder>>((ref) {
  final orders =
      ref.watch(marketOrdersProvider).where((order) => order.isActive).toList()
        ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
  return List.unmodifiable(orders);
});

final pastOrdersProvider = Provider<List<MarketOrder>>((ref) {
  final orders =
      ref.watch(marketOrdersProvider).where((order) => !order.isActive).toList()
        ..sort((a, b) => b.placedAt.compareTo(a.placedAt));
  return List.unmodifiable(orders);
});

enum OrdersView { active, history }

class OrdersViewNotifier extends Notifier<OrdersView> {
  @override
  OrdersView build() => OrdersView.active;

  void select(OrdersView view) => state = view;
}

final ordersViewProvider = NotifierProvider<OrdersViewNotifier, OrdersView>(
  OrdersViewNotifier.new,
);

final reorderProvider = Provider<int Function(MarketOrder)>(
  (ref) => (order) {
    final cart = ref.read(marketCartProvider.notifier);
    var added = 0;
    // Re-add at today's catalog prices, never the old order's prices.
    // Real orders will need the same re-pricing from the server.
    for (final item in order.items) {
      // Server orders carry today's product; preview orders use the catalog.
      if (order.reorderProducts.isNotEmpty) {
        final current = order.reorderProducts[item.product.id];
        if (current == null || !current.inStock) continue;
        cart.add(current, quantity: item.quantity);
        added += item.quantity;
        continue;
      }
      final product = marketProducts
          .where((product) => product.id == item.product.id)
          .firstOrNull;
      if (product == null || !product.inStock) continue;
      final pack = item.pack == null
          ? null
          : productDetailFor(
              product,
            ).packs.where((pack) => pack.size == item.pack!.size).firstOrNull;
      if (item.pack != null && pack == null) continue;
      cart.add(product, quantity: item.quantity, pack: pack);
      added += item.quantity;
    }
    return added;
  },
);
