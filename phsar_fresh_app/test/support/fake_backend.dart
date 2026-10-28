import 'dart:convert';
import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/network/api_client.dart';
import 'package:phsar_fresh_app/core/storage/token_storage.dart';

const fakeApiBase = 'http://api.test:3000/api/v1';

/// A reply from [FakeBackend]: an HTTP status and a JSON body.
typedef FakeReply = (int status, Object? body);

/// Answers requests in-process, the way the NestJS backend would.
class FakeBackend implements HttpClientAdapter {
  FakeBackend(this.handle);

  /// Return null to simulate a network failure.
  FakeReply? Function(RequestOptions request) handle;
  final requests = <RequestOptions>[];

  /// Paths requested, e.g. `POST /auth/login`.
  List<String> get calls => [for (final r in requests) '${r.method} ${r.path}'];

  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    requests.add(options);
    final reply = handle(options);
    if (reply == null) {
      throw DioException.connectionError(
        requestOptions: options,
        reason: 'offline',
      );
    }
    return ResponseBody.fromString(
      jsonEncode(reply.$2),
      reply.$1,
      headers: {
        Headers.contentTypeHeader: [Headers.jsonContentType],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

/// A client wired to [backend] with in-memory token storage.
({ApiClient client, TokenStorage tokens}) fakeApiClient(FakeBackend backend) {
  final tokens = TokenStorage.memory();
  final client = ApiClient(tokens, baseUrl: fakeApiBase, adapter: backend);
  addTearDown(client.close);
  return (client: client, tokens: tokens);
}

Map<String, Object?> backendUser({
  String name = 'Sok Dara',
  String? avatarUrl,
}) => {
  'id': 'user-1',
  'phone': '+85512345678',
  'name': name,
  'avatarUrl': avatarUrl,
  'role': 'CUSTOMER',
  'phoneVerified': true,
};

Map<String, Object?> tokenReply({
  String access = 'access-1',
  String refresh = 'refresh-1',
}) => {'accessToken': access, 'refreshToken': refresh, 'user': backendUser()};
