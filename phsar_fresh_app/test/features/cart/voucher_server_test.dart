import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/features/cart/data/voucher_repository.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';

import '../../support/fake_backend.dart';

void main() {
  ProviderContainer containerWith(FakeBackend backend) {
    final api = fakeApiClient(backend);
    final container = ProviderContainer(
      overrides: [apiClientProvider.overrideWithValue(api.client)],
    );
    addTearDown(container.dispose);
    container.read(marketCartProvider.notifier).add(greensProduct, quantity: 4);
    return container;
  }

  test('A server code is checked against the basket and applied', () async {
    final backend = FakeBackend(
      (request) => (
        200,
        {
          'code': 'WELCOME',
          'type': 'PERCENT',
          'value': 50,
          'maxDiscountCents': 100,
          'minSubtotalCents': 0,
          'discountCents': 100,
        },
      ),
    );
    final container = containerWith(backend);
    final subtotal = container.read(cartSummaryProvider).subtotalInCents;

    final result = await container
        .read(cartVoucherProvider.notifier)
        .applyCode(' welcome ');

    expect(result.isOk, isTrue);
    expect(backend.calls, ['POST /discount-codes/check']);
    expect(backend.requests.single.data, {
      'code': 'WELCOME',
      'subtotalCents': subtotal,
    });
    expect(container.read(cartVoucherProvider), 'WELCOME');
    // 50% capped at $1.00.
    expect(container.read(cartSummaryProvider).discountInCents, 100);
  });

  test('A refused welcome code explains why and is not applied', () async {
    final backend = FakeBackend(
      (request) => (
        422,
        {'statusCode': 422, 'reason': 'NOT_NEW_CUSTOMER', 'message': 'x'},
      ),
    );
    final container = containerWith(backend);

    final result = await container
        .read(cartVoucherProvider.notifier)
        .applyCode('WELCOME');

    expect(result.problem, VoucherProblem.notNewCustomer);
    expect(container.read(cartVoucherProvider), isNull);
    expect(container.read(cartSummaryProvider).discountInCents, 0);
  });

  test('An offline server reports a network problem', () async {
    final container = containerWith(FakeBackend((request) => null));
    final result = await container
        .read(cartVoucherProvider.notifier)
        .applyCode('WELCOME');
    expect(result.problem, VoucherProblem.network);
  });
}
