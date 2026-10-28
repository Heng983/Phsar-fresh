import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

/// A pill-shaped tab switcher with a white indicator that slides between tabs.
class SegmentedTabs extends StatelessWidget {
  const SegmentedTabs({
    super.key,
    required this.labels,
    required this.selectedIndex,
    required this.onChanged,
    this.tabKeys,
    this.fontSize = AppFontSize.bodySmall,
    this.verticalPadding = 12,
    this.selectedColor = AppColors.primary,
  });

  final List<String> labels;
  final int selectedIndex;
  final ValueChanged<int> onChanged;
  final List<Key>? tabKeys;
  final double fontSize;
  final double verticalPadding;
  final Color selectedColor;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    final count = labels.length;
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: AppColors.inputBackground,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      child: Stack(
        children: [
          Positioned.fill(
            child: AnimatedAlign(
              duration: duration,
              curve: AppMotion.curve,
              alignment: AlignmentDirectional(
                count == 1 ? 0 : -1 + 2 * selectedIndex / (count - 1),
                0,
              ),
              child: FractionallySizedBox(
                widthFactor: 1 / count,
                heightFactor: 1,
                child: DecoratedBox(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    boxShadow: AppShadows.subtle,
                  ),
                ),
              ),
            ),
          ),
          Row(
            children: [
              for (var i = 0; i < count; i++)
                Expanded(child: _tab(context, i, duration)),
            ],
          ),
        ],
      ),
    );
  }

  Widget _tab(BuildContext context, int index, Duration duration) {
    final selected = index == selectedIndex;
    return Semantics(
      selected: selected,
      child: Material(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        child: InkWell(
          key: tabKeys?[index],
          borderRadius: BorderRadius.circular(AppRadius.sm),
          onTap: () => onChanged(index),
          child: Padding(
            padding: EdgeInsets.symmetric(
              vertical: verticalPadding,
              horizontal: 8,
            ),
            child: AnimatedDefaultTextStyle(
              duration: duration,
              style: DefaultTextStyle.of(context).style.merge(
                TextStyle(
                  fontSize: fontSize,
                  height: 1.4,
                  fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  color: selected ? selectedColor : AppColors.textSecondary,
                ),
              ),
              child: Text(labels[index], textAlign: TextAlign.center),
            ),
          ),
        ),
      ),
    );
  }
}
