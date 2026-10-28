import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

extension LocalizationExtension on BuildContext {
  AppLocalizations get l10n {
    return AppLocalizations.of(this)!;
  }
}
