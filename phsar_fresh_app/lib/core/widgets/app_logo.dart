import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/localization/localization_extension.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({super.key, this.size = 56, this.excludeFromSemantics = false});

  final double size;
  final bool excludeFromSemantics;

  @override
  Widget build(BuildContext context) => Image.asset(
    'assets/images/logo.png',
    width: size,
    height: size,
    fit: BoxFit.contain,
    semanticLabel: excludeFromSemantics ? null : context.l10n.appName,
    excludeFromSemantics: excludeFromSemantics,
  );
}
