import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/storage/app_settings_storage.dart';

class LocaleNotifier extends Notifier<Locale> {
  @override
  Locale build() =>
      Locale(ref.watch(appSettingsStorageProvider)?.readLanguage() ?? 'en');

  void setEnglish() => _select('en');

  void setKhmer() => _select('km');

  /// Switches at once; saving happens in the background.
  void _select(String languageCode) {
    state = Locale(languageCode);
    unawaited(
      ref.read(appSettingsStorageProvider)?.writeLanguage(languageCode),
    );
  }
}

final localeProvider = NotifierProvider<LocaleNotifier, Locale>(
  LocaleNotifier.new,
);
