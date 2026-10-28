import 'package:dio/dio.dart';
import 'package:phsar_fresh_app/core/config/api_config.dart';
import 'package:phsar_fresh_app/core/storage/token_storage.dart';

class ApiClient {
  /// [baseUrl] defaults to `API_BASE_URL`; tests pass a fake [adapter].
  ApiClient(this._tokens, {String? baseUrl, HttpClientAdapter? adapter}) {
    final url = baseUrl ?? ApiConfig.baseUrl;
    dio = Dio(_options(url));
    _bare = Dio(_options(url)); // no interceptors, used only for refreshing
    if (adapter != null) {
      dio.httpClientAdapter = adapter;
      _bare.httpClientAdapter = adapter;
    }
    dio.interceptors.add(
      InterceptorsWrapper(onRequest: _onRequest, onError: _onError),
    );
  }

  /// Turns a server path such as `/uploads/a.jpg` into a full URL.
  String? resolveUrl(String? path) {
    final value = path?.trim();
    if (value == null || value.isEmpty) return null;
    final uri = Uri.tryParse(value);
    if (uri == null) return null;
    return uri.hasScheme
        ? value
        : Uri.parse(dio.options.baseUrl).resolveUri(uri).toString();
  }

  final TokenStorage _tokens;
  late final Dio dio;
  late final Dio _bare;

  void close() {
    dio.close(force: true);
    _bare.close(force: true);
  }

  /// Called when the refresh token is rejected, so the app can show the login screen.
  void Function()? onSessionExpired;

  /// Use for endpoints that need no login (register, login, verify...).
  static Options get noAuth => Options(extra: {'skipAuth': true});

  // Only one refresh runs at a time, even if several requests fail together.
  Future<bool>? _refreshing;

  static BaseOptions _options(String baseUrl) => BaseOptions(
    baseUrl: baseUrl,
    connectTimeout: const Duration(seconds: 10),
    receiveTimeout: const Duration(seconds: 15),
    sendTimeout: const Duration(seconds: 15),
    headers: {'Content-Type': 'application/json', 'Accept': 'application/json'},
  );

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    if (options.extra['skipAuth'] != true) {
      final token = await _tokens.access;
      if (token != null) {
        options.headers['Authorization'] = 'Bearer $token';
      }
    }
    handler.next(options);
  }

  Future<void> _onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    final req = err.requestOptions;
    final is401 = err.response?.statusCode == 401;

    if (!is401 ||
        req.extra['skipAuth'] == true ||
        req.extra['retried'] == true) {
      return handler.next(err);
    }

    final refreshed = await (_refreshing ??= _refreshTokens().whenComplete(
      () => _refreshing = null,
    ));

    if (!refreshed) return handler.next(err);

    try {
      final token = await _tokens.access;
      req.headers['Authorization'] = 'Bearer $token';
      req.extra['retried'] = true;
      final response = await dio.fetch(req);
      handler.resolve(response);
    } on DioException catch (e) {
      handler.next(e);
    }
  }

  Future<bool> _refreshTokens() async {
    final refresh = await _tokens.refresh;
    if (refresh == null) return false;

    try {
      final res = await _bare.post(
        '/auth/refresh',
        data: {'refreshToken': refresh},
      );
      await _tokens.save(
        access: res.data['accessToken'] as String,
        refresh: res.data['refreshToken'] as String,
      );
      return true;
    } on DioException catch (e) {
      // Only log the user out if the server really rejected the token.
      // A network error should not sign them out.
      if (e.response?.statusCode == 401) {
        await _tokens.clear();
        onSessionExpired?.call();
      }
      return false;
    }
  }
}
