import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/locale_provider.dart';
import 'package:phsar_fresh_app/core/storage/app_settings_storage.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// A fresh app start on the device's saved preferences.
Future<ProviderContainer> startApp() async {
  final preferences = await SharedPreferences.getInstance();
  final container = ProviderContainer(
    overrides: [
      appSettingsStorageProvider.overrideWithValue(
        AppSettingsStorage(preferences),
      ),
    ],
  );
  addTearDown(container.dispose);
  return container;
}

void main() {
  setUp(() => SharedPreferences.setMockInitialValues({}));

  test('First launch uses English and US dollars', () async {
    final app = await startApp();
    expect(app.read(localeProvider).languageCode, 'en');
    expect(app.read(currencyProvider), AppCurrency.usd);
  });

  test('Language and currency are kept after a restart', () async {
    final first = await startApp();
    first.read(localeProvider.notifier).setKhmer();
    first.read(currencyProvider.notifier).select(AppCurrency.khr);
    await pumpEventQueue();

    final restarted = await startApp();
    expect(restarted.read(localeProvider).languageCode, 'km');
    expect(restarted.read(currencyProvider), AppCurrency.khr);

    restarted.read(localeProvider.notifier).setEnglish();
    restarted.read(currencyProvider.notifier).select(AppCurrency.usd);
    await pumpEventQueue();

    final again = await startApp();
    expect(again.read(localeProvider).languageCode, 'en');
    expect(again.read(currencyProvider), AppCurrency.usd);
  });

  test('Unknown saved values fall back to the defaults', () async {
    SharedPreferences.setMockInitialValues({
      AppSettingsStorage.languageKey: 'fr',
      AppSettingsStorage.currencyKey: 'eur',
    });
    final app = await startApp();
    expect(app.read(localeProvider).languageCode, 'en');
    expect(app.read(currencyProvider), AppCurrency.usd);
  });
}
