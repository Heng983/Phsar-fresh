import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/segmented_tabs.dart';

class AuthModeTabs extends StatelessWidget {
  final bool isRegister;
  final ValueChanged<bool> onChanged;

  const AuthModeTabs({
    super.key,
    required this.isRegister,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) => SegmentedTabs(
    labels: [context.l10n.signIn, context.l10n.authRegister],
    selectedIndex: isRegister ? 1 : 0,
    onChanged: (index) => onChanged(index == 1),
    fontSize: AppFontSize.bodyLarge,
  );
}
