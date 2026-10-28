import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/locale_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/app_logo.dart';

class AppHeader extends ConsumerWidget {
  const AppHeader({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);

    final isEnglish = locale.languageCode == 'en';

    return SizedBox(
      width: double.infinity,
      child: Wrap(
        alignment: WrapAlignment.spaceBetween,
        spacing: 12,
        runSpacing: 12,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const AppLogo(size: 56),

              const SizedBox(width: 8),

              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.appName,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: AppFontSize.title,
                      fontWeight: FontWeight.w600,
                    ),
                  ),

                  Text(
                    context.l10n.appNameKhmer,
                    style: const TextStyle(
                      color: AppColors.primary,
                      fontSize: AppFontSize.bodySmall,
                    ),
                  ),
                ],
              ),
            ],
          ),
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 5),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(30),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withValues(alpha: .05),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                _LanguageButton(
                  text: '🇬🇧 EN',
                  selected: isEnglish,
                  onTap: () {
                    ref.read(localeProvider.notifier).setEnglish();
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(horizontal: 4),
                  child: Text('/', style: TextStyle(color: Colors.grey)),
                ),

                _LanguageButton(
                  text: 'ខ្មែរ 🇰🇭',
                  selected: !isEnglish,
                  onTap: () {
                    ref.read(localeProvider.notifier).setKhmer();
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _LanguageButton extends StatelessWidget {
  final String text;
  final bool selected;
  final VoidCallback onTap;

  const _LanguageButton({
    required this.text,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      borderRadius: BorderRadius.circular(20),
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
        child: Text(
          text,
          style: TextStyle(
            fontWeight: selected ? FontWeight.bold : FontWeight.normal,
            color: selected ? AppColors.primary : Colors.grey,
          ),
        ),
      ),
    );
  }
}
