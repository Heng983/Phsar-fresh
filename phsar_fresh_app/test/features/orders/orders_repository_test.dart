import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/orders/data/orders_repository.dart';
import 'package:phsar_fresh_app/features/orders/domain/model/market_order.dart';

import '../../support/fake_backend.dart';

Map<String, Object?> product({int price = 250, bool inStock = true}) => {
  'id': 'p-mango',
  'name': 'Keo Romeat mango',
  'nameKm': 'ស្វាយកែវរមៀត',
  'unit': 'kg',
  'priceCents': price,
  'currency': 'USD',
  'imageUrl': '/uploads/products/mango.webp',
  'inStock': inStock,
  'category': {'id': 'c-fruit', 'name': 'Fruit', 'nameKm': 'ផ្លែឈើ'},
};

Map<String, Object?> order({
  required String id,
  required String status,
  required String method,
  Map<String, Object?>? payment,
  String? courier,
  String? deliveredAt,
  bool inStock = true,
}) => {
  'id': id,
  'status': status,
  'subtotalCents': 480,
  'discountCents': 100,
  'deliveryCents': 100,
  'totalCents': 480,
  'paymentMethod': method,
  'address': {'lat': 11.5, 'lng': 104.9, 'text': 'House 12, Street 302'},
  'payment': payment,
  'createdAt': '2026-10-27T03:00:00.000Z',
  'deliveredAt': deliveredAt,
  'courierName': courier,
  'items': [
    {
      'productId': 'p-mango',
      'name': 'Keo Romeat mango',
      'priceCents': 240, // paid price; today's price is 250
      'qty': 2,
      'product': product(inStock: inStock),
    },
  ],
};

void main() {
  test('Server orders become app orders with paid prices', () async {
    final backend = FakeBackend(
      (request) => (
        200,
        [
          order(
            id: '3f9a2c00-1111-4000-8000-000000000000',
            status: 'PENDING',
            method: 'ABA_PAY',
            payment: {
              'orderId': '3f9a2c00-1111-4000-8000-000000000000',
              'tranId': 'PF1',
              'status': 'PENDING',
              'amountCents': 480,
              'currency': 'USD',
              'expiresAt': '2026-10-27T03:15:00.000Z',
              'qrString': '000201',
            },
          ),
          order(
            id: 'aa11bb22-1111-4000-8000-000000000000',
            status: 'DELIVERED',
            method: 'CASH',
            courier: 'Chan Rithy',
            deliveredAt: '2026-10-27T04:00:00.000Z',
            inStock: false,
          ),
          {'id': 'broken'},
        ],
      ),
    );
    final orders = await OrdersRepository(fakeApiClient(backend).client).mine();

    expect(backend.calls, ['GET /orders']);
    expect(orders, hasLength(2), reason: 'unreadable orders are skipped');

    final unpaid = orders.first;
    expect(unpaid.id, 'PF-3F9A2C');
    expect(unpaid.serverId, '3f9a2c00-1111-4000-8000-000000000000');
    expect(unpaid.status, OrderStatus.awaitingPayment);
    expect(unpaid.isActive, isTrue);
    expect(unpaid.payment, CheckoutPayment.abaPay);
    expect(unpaid.khqr?.qrString, '000201');
    expect(unpaid.items.single.priceInCents, 240);
    expect(unpaid.reorderProducts['p-mango']?.priceInCents, 250);
    expect(unpaid.items.single.product.imageUrl, startsWith('http'));
    expect(unpaid.totalInCents, 480);
    expect(unpaid.address, 'House 12, Street 302');

    final delivered = orders.last;
    expect(delivered.status, OrderStatus.delivered);
    expect(delivered.courierName, 'Chan Rithy');
    expect(delivered.deliveredAt, isNotNull);
    expect(delivered.reorderProducts['p-mango']?.inStock, isFalse);
  });

  test('Signed out is reported as such', () async {
    final backend = FakeBackend(
      (request) => (401, {'message': 'Unauthorized'}),
    );
    await expectLater(
      OrdersRepository(fakeApiClient(backend).client).mine(),
      throwsA(
        isA<OrdersException>().having(
          (e) => e.problem,
          'problem',
          OrdersProblem.signIn,
        ),
      ),
    );
  });
}
