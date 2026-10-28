import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/cart/domain/model/cart_item.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';

import 'auth_test_repository.dart';

// Existing layout/pricing tests intentionally use this three-product basket.
// Production starts with an empty or restored basket.
const initialMarketCart = [
  MarketCartItem(product: greensProduct),
  MarketCartItem(product: fruitsProduct),
  MarketCartItem(product: eggsProduct),
];

final seededCartOverride = initialCartProvider.overrideWithValue(
  initialMarketCart,
);
final signedInCheckoutOverride = authSessionProvider.overrideWith(
  (ref) => Stream<AuthSession?>.value(testSession),
);
