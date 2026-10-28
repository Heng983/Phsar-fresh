import 'package:flutter/foundation.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/features/cart/data/cart_storage.dart';
import 'package:phsar_fresh_app/features/cart/data/voucher_repository.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_summary.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/voucher_rule.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_pack_option.dart';

/// Startup supplies device storage; previews and tests can use an in-memory cart.
final cartStorageProvider = Provider<CartStorage?>((ref) => null);

final initialCartProvider = Provider<List<MarketCartItem>>(
  (ref) => ref.watch(cartStorageProvider)?.read() ?? const [],
);

class MarketCartNotifier extends Notifier<List<MarketCartItem>> {
  Future<void> _pendingSave = Future.value();

  @override
  List<MarketCartItem> build() {
    final storage = ref.watch(cartStorageProvider);
    listenSelf((_, items) {
      if (storage == null) return;
      _pendingSave = _pendingSave.then((_) => storage.write(items)).catchError((
        Object error,
      ) {
        if (kDebugMode) {
          debugPrint('Basket storage failed: ${error.runtimeType}');
        }
      });
    });
    return ref.watch(initialCartProvider);
  }

  Future<void> flush() => _pendingSave;

  void add(MarketProduct product, {int quantity = 1, ProductPackOption? pack}) {
    if (quantity < 1) throw ArgumentError.value(quantity, 'quantity');
    final selectedPack = pack?.isDefault == true ? null : pack;
    final index = state.indexWhere(
      (item) =>
          item.product.id == product.id &&
          item.pack?.size == selectedPack?.size,
    );
    if (index < 0) {
      state = [
        ...state,
        MarketCartItem(
          product: product,
          quantity: quantity,
          pack: selectedPack,
        ),
      ];
    } else {
      state = [
        for (var i = 0; i < state.length; i++)
          i == index
              ? state[i].withQuantity(state[i].quantity + quantity)
              : state[i],
      ];
    }
  }

  /// Puts a removed line back where it was (for "Undo"). If the same
  /// product and pack was added again meanwhile, the quantities merge.
  void restore(MarketCartItem item, int index) {
    final exists = state.any(
      (line) =>
          line.product.id == item.product.id &&
          line.pack?.size == item.pack?.size,
    );
    if (exists) {
      add(item.product, quantity: item.quantity, pack: item.pack);
      return;
    }
    state = [...state]..insert(index.clamp(0, state.length), item);
  }

  /// Puts a whole basket back, e.g. after an unpaid ABA order is cancelled.
  void replaceAll(List<MarketCartItem> items) =>
      state = List.unmodifiable(items);

  /// Empties the basket, e.g. after an order is placed.
  void clear() => state = const [];

  void setQuantity(String id, int quantity, {ProductPackSize? packSize}) {
    state = [
      for (final item in state)
        if (item.product.id != id || item.pack?.size != packSize)
          item
        else if (quantity > 0)
          item.withQuantity(quantity),
    ];
  }
}

final marketCartProvider =
    NotifierProvider<MarketCartNotifier, List<MarketCartItem>>(
      MarketCartNotifier.new,
    );

final marketCartCountProvider = Provider<int>(
  (ref) => ref
      .watch(marketCartProvider)
      .fold(0, (total, item) => total + item.quantity),
);

/// The applied voucher code, or null. In local preview mode only KHMERFRESH
/// works; with a server, [applyCode] checks codes created in the admin panel.
class CartVoucherNotifier extends Notifier<String?> {
  VoucherRule? _rule;

  /// The applied code's rule; the discount is recalculated from it whenever
  /// the cart changes.
  VoucherRule? get rule => state == null ? null : _rule;

  @override
  String? build() {
    ref.listen(marketCartProvider, (_, items) {
      if (items.isEmpty) remove();
    });
    return null;
  }

  /// Local preview: accepts only the built-in KHMERFRESH offer.
  bool apply(String code) {
    final normalized = _normalize(code);
    if (normalized != CartSummary.voucherCode ||
        ref.read(marketCartProvider).isEmpty) {
      return false;
    }
    _rule = VoucherRule.offline;
    state = normalized;
    return true;
  }

  /// Checks [code] with the server when one is configured, otherwise falls
  /// back to [apply].
  Future<VoucherCheck> applyCode(String code) async {
    final client = ref.read(apiClientProvider);
    if (client == null) {
      return apply(code)
          ? const VoucherCheck.ok(VoucherRule.offline)
          : const VoucherCheck.refused(VoucherProblem.invalid);
    }
    final normalized = _normalize(code);
    // Straight from the basket: reading cartSummaryProvider here would loop,
    // because the summary itself depends on this voucher.
    final subtotal = CartSummary.calculate(
      ref.read(marketCartProvider),
    ).subtotalInCents;
    if (normalized.isEmpty || subtotal <= 0) {
      return const VoucherCheck.refused(VoucherProblem.invalid);
    }
    final result = await VoucherRepository(client).check(normalized, subtotal);
    if (!ref.mounted) return result;
    final rule = result.rule;
    if (rule != null) {
      _rule = rule;
      state = rule.code;
    }
    return result;
  }

  void remove() {
    _rule = null;
    state = null;
  }

  static String _normalize(String code) =>
      code.trim().toUpperCase().replaceAll(RegExp(r'\s+'), '');
}

final cartVoucherProvider = NotifierProvider<CartVoucherNotifier, String?>(
  CartVoucherNotifier.new,
);

/// The applied code's rule, or null.
final cartVoucherRuleProvider = Provider<VoucherRule?>((ref) {
  ref.watch(cartVoucherProvider);
  return ref.read(cartVoucherProvider.notifier).rule;
});

final cartSummaryProvider = Provider<CartSummary>(
  (ref) => CartSummary.calculate(
    ref.watch(marketCartProvider),
    voucher: ref.watch(cartVoucherRuleProvider),
  ),
);
