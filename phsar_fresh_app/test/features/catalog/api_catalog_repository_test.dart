import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/catalog/data/api_catalog_repository.dart';

import '../../support/fake_backend.dart';

Map<String, Object?> backendProduct({
  String id = 'p-1',
  String? imageUrl,
  bool inStock = true,
}) => {
  'id': id,
  'name': 'Kampot Pepper',
  'nameKm': 'ម្រេចកំពត',
  'description': 'Black pepper from Kampot.',
  'origin': 'Kampot',
  'unit': '100 g',
  'priceCents': 450,
  'currency': 'USD',
  'imageUrl': imageUrl,
  'inStock': inStock,
  'category': {'id': 'c-1', 'name': 'Spices', 'nameKm': 'គ្រឿងទេស'},
};

void main() {
  test('Categories are read with Khmer names and resolved images', () async {
    final backend = FakeBackend(
      (_) => (
        200,
        [
          {
            'id': 'c-1',
            'name': 'Spices',
            'nameKm': 'គ្រឿងទេស',
            'productCount': 3,
            'imageUrl': '/uploads/spices.jpg',
          },
          {
            'id': 'c-2',
            'name': 'Meat',
            'nameKm': null,
            'productCount': 0,
            'imageUrl': null,
          },
        ],
      ),
    );
    final api = fakeApiClient(backend);
    final categories = await ApiCatalogRepository(api.client).categories();
    expect(backend.calls, ['GET /categories']);
    expect(categories.first.localizedName('km'), 'គ្រឿងទេស');
    expect(categories.first.productCount, 3);
    expect(
      categories.first.imageUrl,
      'http://api.test:3000/uploads/spices.jpg',
    );
    expect(categories.last.localizedName('km'), 'Meat');
    expect(categories.last.imageUrl, isNull);
  });

  test('Product requests send search, category, stock and paging', () async {
    final backend = FakeBackend(
      (_) => (
        200,
        {
          'items': [backendProduct(imageUrl: '/uploads/pepper.jpg')],
          'page': 2,
          'limit': 50,
          'total': 51,
          'hasMore': false,
        },
      ),
    );
    final api = fakeApiClient(backend);
    final page = await ApiCatalogRepository(api.client).products(
      (search: '  pepper ', categoryId: 'c-1', inStockOnly: true),
      page: 2,
      limit: 500,
    );

    expect(backend.requests.single.queryParameters, {
      'q': 'pepper',
      'categoryId': 'c-1',
      'inStock': true,
      'page': 2,
      'limit': ApiCatalogRepository.maxPageSize,
    });
    expect(page.hasMore, isFalse);
    final pepper = page.items.single;
    expect(pepper.localizedName('km'), 'ម្រេចកំពត');
    expect(pepper.localizedSummary('en'), 'Black pepper from Kampot.');
    expect(pepper.priceInCents, 450);
    expect(pepper.unit, '100 g');
    expect(pepper.category.name, 'Spices');
    expect(pepper.imageUrl, 'http://api.test:3000/uploads/pepper.jpg');
  });

  test('Browsing sends no empty filters', () async {
    final backend = FakeBackend(
      (_) => (200, {'items': <Object?>[], 'hasMore': false}),
    );
    final api = fakeApiClient(backend);
    await ApiCatalogRepository(
      api.client,
    ).products((search: '', categoryId: null, inStockOnly: false));
    expect(backend.requests.single.queryParameters, {'page': 1, 'limit': 20});
  });

  test('Malformed product data is rejected', () async {
    for (final body in <Object?>[
      [],
      {'items': 'wrong', 'hasMore': false},
      {
        'items': [
          {...backendProduct(), 'priceCents': '4.50'},
        ],
        'hasMore': false,
      },
      {
        'items': [
          {...backendProduct()}..remove('category'),
        ],
        'hasMore': false,
      },
    ]) {
      final api = fakeApiClient(FakeBackend((_) => (200, body)));
      await expectLater(
        ApiCatalogRepository(
          api.client,
        ).products((search: '', categoryId: null, inStockOnly: false)),
        throwsA(isA<FormatException>()),
      );
    }
  });

  test('Promotions are read from the server and bad entries skipped', () async {
    final backend = FakeBackend(
      (_) => (
        200,
        [
          {
            'id': 'd-1',
            'title': 'Pepper deal',
            'titleKm': 'ម្រេចបញ្ចុះតម្លៃ',
            'originalPriceCents': 600,
            'endsAt': '2026-10-24T17:00:00.000Z',
            'product': backendProduct(imageUrl: '/uploads/pepper.jpg'),
          },
          {'id': 'd-2', 'title': 'Broken'},
        ],
      ),
    );
    final api = fakeApiClient(backend);
    final promotions = await ApiCatalogRepository(api.client).promotions();
    expect(backend.calls, ['GET /promotions']);
    final deal = promotions.single;
    expect(deal.id, 'd-1');
    expect(deal.title, 'Pepper deal');
    expect(deal.titleKm, 'ម្រេចបញ្ចុះតម្លៃ');
    expect(deal.originalPriceInCents, 600);
    expect(deal.product.priceInCents, 450);
    expect(deal.product.imageUrl, 'http://api.test:3000/uploads/pepper.jpg');
    expect(deal.endsAt, DateTime.utc(2026, 10, 24, 17));
  });

  test('Promotions are empty while the server has no endpoint', () async {
    final api = fakeApiClient(
      FakeBackend((_) => (404, {'message': 'Cannot GET /api/v1/promotions'})),
    );
    expect(await ApiCatalogRepository(api.client).promotions(), isEmpty);
  });

  test('Other promotion errors are reported', () async {
    final api = fakeApiClient(FakeBackend((_) => (500, {'message': 'boom'})));
    await expectLater(
      ApiCatalogRepository(api.client).promotions(),
      throwsA(isA<Exception>()),
    );
  });

  test('Popular products come from the best sellers endpoint', () async {
    final backend = FakeBackend(
      (_) => (200, [backendProduct(id: 'p-2'), backendProduct(id: 'p-1')]),
    );
    final api = fakeApiClient(backend);
    final popular = await ApiCatalogRepository(api.client).popularProducts();
    expect(backend.calls, ['GET /products/popular']);
    expect(backend.requests.single.queryParameters, {'limit': 8});
    expect(popular.map((product) => product.id), ['p-2', 'p-1']);
  });

  test(
    'Popular products fall back to the product list without the endpoint',
    () async {
      final backend = FakeBackend(
        (request) => request.path == '/products/popular'
            ? (404, {'message': 'Cannot GET /api/v1/products/popular'})
            : (
                200,
                {
                  'items': [backendProduct(id: 'p-9')],
                  'hasMore': true,
                },
              ),
      );
      final api = fakeApiClient(backend);
      final popular = await ApiCatalogRepository(api.client).popularProducts();
      expect(backend.calls, ['GET /products/popular', 'GET /products']);
      expect(backend.requests.last.queryParameters, {'page': 1, 'limit': 8});
      expect(popular.map((product) => product.id), ['p-9']);
    },
  );
}
