import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/chat/data/chat_api.dart';

/// Exercises the real ChatApi serializer/parser without contacting a server.
ChatApi testChatApi(
  FutureOr<Object?> Function(RequestOptions) respond, {
  List<RequestOptions>? requests,
}) {
  final dio = Dio(BaseOptions(baseUrl: 'https://chat.example'));
  addTearDown(() => dio.close(force: true));
  dio.interceptors.add(
    InterceptorsWrapper(
      onRequest: (options, handler) async {
        requests?.add(options);
        try {
          final data = await respond(options);
          handler.resolve(
            Response<dynamic>(
              data: data,
              requestOptions: options,
              statusCode: 200,
            ),
          );
        } on DioException catch (error) {
          handler.reject(error);
        }
      },
    ),
  );
  return ChatApi(dio);
}

Map<String, Object?> chatProductJson(
  Object id, {
  String name = 'Product',
  int priceCents = 100,
  bool inStock = true,
  String? nameKm,
  String? origin,
  String? imageUrl,
}) => {
  'id': id,
  'name': name,
  'nameKm': ?nameKm,
  'origin': ?origin,
  'category': 'vegetables',
  'unit': 'kg',
  'priceCents': priceCents,
  'imageUrl': ?imageUrl,
  'inStock': inStock,
};

/// One addable product plus each reason a product cannot be added:
/// unknown ID, out of stock, and a price that differs from the catalog.
Map<String, Object?> productReply({String reply = 'Try rice with greens.'}) => {
  'reply': reply,
  'products': [
    chatProductJson(
      'greens',
      name: 'Fresh greens',
      nameKm: 'បន្លែស្រស់',
      origin: 'Battambang',
      priceCents: 180,
    ),
    chatProductJson(42, name: 'Another product', priceCents: 200),
    chatProductJson('rice', name: 'Rice', priceCents: 220, inStock: false),
    chatProductJson('eggs', name: 'Eggs', priceCents: 9900),
  ],
};
