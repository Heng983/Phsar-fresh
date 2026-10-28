import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// Keeps the chosen language and currency across app restarts.
class AppSettingsStorage {
  AppSettingsStorage(this.preferences);

  final SharedPreferences preferences;
  static const languageKey = 'phsar_fresh.language.v1';
  static const currencyKey = 'phsar_fresh.currency.v1';
  static const supportedLanguages = {'en', 'km'};

  /// The saved language code, or null when none (or an unknown one) is saved.
  String? readLanguage() {
    final saved = preferences.getString(languageKey);
    return supportedLanguages.contains(saved) ? saved : null;
  }

  Future<void> writeLanguage(String languageCode) =>
      preferences.setString(languageKey, languageCode);

  AppCurrency? readCurrency() {
    final saved = preferences.getString(currencyKey);
    return AppCurrency.values.where((value) => value.name == saved).firstOrNull;
  }

  Future<void> writeCurrency(AppCurrency currency) =>
      preferences.setString(currencyKey, currency.name);
}

/// None by default (tests, previews); `main.dart` installs the device's.
final appSettingsStorageProvider = Provider<AppSettingsStorage?>((ref) => null);
