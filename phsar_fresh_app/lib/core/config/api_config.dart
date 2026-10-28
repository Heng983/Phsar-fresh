class ApiConfig {
  static const String _baseUrl = String.fromEnvironment('API_BASE_URL');

  static bool get isConfigured {
    final uri = Uri.tryParse(_baseUrl.trim());
    return uri != null &&
        (uri.scheme == 'https' || uri.scheme == 'http') &&
        uri.host.isNotEmpty;
  }

  static String get baseUrl {
    if (_baseUrl.isEmpty) {
      throw StateError(
        'API_BASE_URL is missing. Run with: '
        'flutter run --dart-define-from-file=config.json',
      );
    }
    return _baseUrl.trim();
  }
}
