import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:phsar_fresh_app/core/storage/app_settings_storage.dart';

class CurrencyNotifier extends Notifier<AppCurrency> {
  @override
  AppCurrency build() =>
      ref.watch(appSettingsStorageProvider)?.readCurrency() ?? AppCurrency.usd;

  /// Switches at once; saving happens in the background.
  void select(AppCurrency currency) {
    state = currency;
    unawaited(ref.read(appSettingsStorageProvider)?.writeCurrency(currency));
  }
}

final currencyProvider = NotifierProvider<CurrencyNotifier, AppCurrency>(
  CurrencyNotifier.new,
);
