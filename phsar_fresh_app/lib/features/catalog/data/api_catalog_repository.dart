import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/features/catalog/data/catalog_repository.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/app_banner.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_promotion.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_query.dart';

/// Reads `GET /categories`, `GET /products` and `GET /promotions`
/// (public, no sign-in needed).
class ApiCatalogRepository implements CatalogRepository {
  const ApiCatalogRepository(this._client);

  final ApiClient _client;

  /// The server accepts at most 50 products per page.
  static const maxPageSize = 50;

  @override
  bool get isRemote => true;

  @override
  Future<List<ProductCategory>> categories() async {
    final response = await _client.dio.get<dynamic>('/categories');
    final data = _decode(response.data);
    if (data is! List) throw const FormatException('Invalid categories');
    return [
      for (final item in data)
        ProductCategory.fromJson(_map(item), resolveUrl: _client.resolveUrl),
    ];
  }

  @override
  Future<ProductPage> products(
    ProductRequest request, {
    int page = 1,
    int limit = 20,
  }) async {
    final search = request.search.trim();
    final response = await _client.dio.get<dynamic>(
      '/products',
      queryParameters: {
        if (search.isNotEmpty)
          'q': search.length > 80 ? search.substring(0, 80) : search,
        'categoryId': ?request.categoryId,
        if (request.inStockOnly) 'inStock': true,
        'page': page,
        'limit': limit.clamp(1, maxPageSize),
      },
    );
    final data = _map(_decode(response.data));
    final items = data['items'];
    final hasMore = data['hasMore'];
    if (items is! List || hasMore is! bool) {
      throw const FormatException('Invalid product page');
    }
    return ProductPage(
      items: [
        for (final item in items)
          MarketProduct.fromJson(_map(item), resolveUrl: _client.resolveUrl),
      ],
      page: page,
      hasMore: hasMore,
    );
  }

  /// `GET /products/popular`; before the server has it (404), the first page
  /// of `GET /products` (in stock first).
  @override
  Future<List<MarketProduct>> popularProducts({int limit = 8}) async {
    final Response<dynamic> response;
    try {
      response = await _client.dio.get<dynamic>(
        '/products/popular',
        queryParameters: {'limit': limit.clamp(1, 20)},
      );
    } on DioException catch (error) {
      if (error.response?.statusCode != 404) rethrow;
      final page = await products((
        search: '',
        categoryId: null,
        inStockOnly: false,
      ), limit: limit);
      return page.items;
    }
    final data = _decode(response.data);
    if (data is! List) throw const FormatException('Invalid popular products');
    return [
      for (final item in data)
        MarketProduct.fromJson(_map(item), resolveUrl: _client.resolveUrl),
    ];
  }

  /// Active deals; none while the server has no promotions endpoint (404).
  /// A malformed deal is skipped so the others still show.
  @override
  Future<List<MarketPromotion>> promotions() async {
    final Response<dynamic> response;
    try {
      response = await _client.dio.get<dynamic>('/promotions');
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return const [];
      rethrow;
    }
    final data = _decode(response.data);
    if (data is! List) throw const FormatException('Invalid promotions');
    final promotions = <MarketPromotion>[];
    for (final item in data) {
      try {
        promotions.add(
          MarketPromotion.fromJson(_map(item), resolveUrl: _client.resolveUrl),
        );
      } on FormatException {
        continue;
      }
    }
    return List.unmodifiable(promotions);
  }

  /// Live banners from the admin panel; none while the server has no
  /// banners endpoint (404). A malformed banner is skipped.
  @override
  Future<List<AppBanner>> banners() async {
    final Response<dynamic> response;
    try {
      response = await _client.dio.get<dynamic>('/banners');
    } on DioException catch (error) {
      if (error.response?.statusCode == 404) return const [];
      rethrow;
    }
    final data = _decode(response.data);
    if (data is! List) throw const FormatException('Invalid banners');
    final banners = <AppBanner>[];
    for (final item in data) {
      try {
        banners.add(
          AppBanner.fromJson(_map(item), resolveUrl: _client.resolveUrl),
        );
      } on FormatException {
        continue;
      }
    }
    return List.unmodifiable(banners);
  }

  static Object? _decode(Object? data) =>
      data is String ? jsonDecode(data) : data;

  static Map<String, dynamic> _map(Object? value) {
    if (value is! Map<String, dynamic>) {
      throw const FormatException('Unexpected response');
    }
    return value;
  }
}
