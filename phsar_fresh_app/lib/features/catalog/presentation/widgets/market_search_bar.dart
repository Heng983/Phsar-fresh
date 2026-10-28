import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

class MarketSearchBar extends StatelessWidget {
  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onFilters;
  final VoidCallback onVoiceSearch;
  final bool hasActiveFilters;

  const MarketSearchBar({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onFilters,
    required this.onVoiceSearch,
    required this.hasActiveFilters,
  });

  static const _radius = BorderRadius.all(Radius.circular(26));

  static OutlineInputBorder _outline(Color color, [double width = 1]) =>
      OutlineInputBorder(
        borderRadius: _radius,
        borderSide: BorderSide(color: color, width: width),
      );

  @override
  Widget build(BuildContext context) => Row(
    children: [
      Expanded(
        // Rebuilds on typing so the clear button shows and hides.
        child: ValueListenableBuilder<TextEditingValue>(
          valueListenable: controller,
          builder: (context, _, _) => TextField(
            key: const Key('market-search'),
            controller: controller,
            onChanged: onChanged,
            textInputAction: TextInputAction.search,
            onSubmitted: (_) => FocusScope.of(context).unfocus(),
            style: const TextStyle(
              fontSize: AppFontSize.bodySmall,
              color: AppColors.textPrimary,
            ),
            decoration: InputDecoration(
              hintText: context.l10n.marketSearchHint,
              hintStyle: const TextStyle(
                fontSize: AppFontSize.bodySmall,
                color: Color(0xFF7D887D),
              ),
              filled: true,
              fillColor: AppColors.card,
              contentPadding: const EdgeInsets.symmetric(vertical: 15),
              prefixIcon: const Icon(
                Icons.search_rounded,
                size: 22,
                color: AppColors.primary,
              ),
              // ✕ appears once there is something to clear.
              suffixIcon: controller.text.isEmpty
                  ? null
                  : IconButton(
                      tooltip: context.l10n.marketClearSearch,
                      onPressed: () {
                        controller.clear();
                        onChanged('');
                      },
                      icon: const Icon(
                        Icons.close_rounded,
                        size: 20,
                        color: AppColors.textSecondary,
                      ),
                    ),
              border: _outline(AppColors.border),
              enabledBorder: _outline(AppColors.border),
              focusedBorder: _outline(AppColors.primary, 1.5),
            ),
          ),
        ),
      ),
      const SizedBox(width: 8),
      Material(
        color: AppColors.card,
        shape: const CircleBorder(side: BorderSide(color: AppColors.border)),
        clipBehavior: Clip.antiAlias,
        child: IconButton(
          tooltip: context.l10n.marketFilters,
          onPressed: onFilters,
          padding: const EdgeInsets.all(14),
          icon: Badge(
            isLabelVisible: hasActiveFilters,
            backgroundColor: AppColors.primary,
            child: const Icon(
              Icons.tune,
              size: 22,
              color: AppColors.textPrimary,
            ),
          ),
        ),
      ),
    ],
  );
}
