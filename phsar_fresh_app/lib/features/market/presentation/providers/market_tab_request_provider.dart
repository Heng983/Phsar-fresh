import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/features/market/presentation/models/market_tab.dart';

/// Asks the market screen to switch tabs from elsewhere, e.g. a tapped
/// notification. The market screen clears it once handled.
class MarketTabRequestNotifier extends Notifier<MarketTab?> {
  @override
  MarketTab? build() => null;

  void open(MarketTab tab) => state = tab;

  void handled() => state = null;
}

final marketTabRequestProvider =
    NotifierProvider<MarketTabRequestNotifier, MarketTab?>(
      MarketTabRequestNotifier.new,
    );
