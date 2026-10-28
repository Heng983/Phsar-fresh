import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/market/presentation/models/market_tab.dart';

class MarketBottomNav extends StatelessWidget {
  final MarketTab selectedTab;
  final int cartCount;
  final ValueChanged<MarketTab> onChanged;

  const MarketBottomNav({
    super.key,
    required this.selectedTab,
    required this.cartCount,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      top: false,
      child: Center(
        heightFactor: 1,
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
            child: DecoratedBox(
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(40),
                border: Border.all(color: AppDecorations.cardBorder),
                boxShadow: AppShadows.soft,
              ),
              child: Material(
                color: Colors.transparent,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    for (final tab in MarketTab.values)
                      Expanded(
                        child: _NavItem(
                          tab: tab,
                          selected: selectedTab == tab,
                          badgeCount: tab == MarketTab.cart ? cartCount : 0,
                          onTap: () => onChanged(tab),
                        ),
                      ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NavItem extends StatelessWidget {
  const _NavItem({
    required this.tab,
    required this.selected,
    required this.badgeCount,
    required this.onTap,
  });

  final MarketTab tab;
  final bool selected;
  final int badgeCount;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final duration = AppMotion.of(context, AppMotion.medium);
    final color = selected ? AppColors.primary : AppColors.textSecondary;
    return Semantics(
      selected: selected,
      child: InkWell(
        key: ValueKey('market-tab-${tab.name}'),
        onTap: onTap,
        borderRadius: BorderRadius.circular(32),
        splashColor: AppColors.primary.withValues(alpha: .06),
        highlightColor: Colors.transparent,
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AnimatedContainer(
                duration: duration,
                curve: AppMotion.curve,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 4,
                ),
                decoration: BoxDecoration(
                  color: selected
                      ? AppColors.lightGreen
                      : AppColors.lightGreen.withValues(alpha: 0),
                  borderRadius: BorderRadius.circular(AppRadius.md),
                ),
                child: Badge(
                  isLabelVisible: badgeCount > 0,
                  label: Text('$badgeCount'),
                  backgroundColor: AppColors.primary,
                  child: AnimatedSwitcher(
                    duration: duration,
                    child: Icon(
                      selected ? tab.selectedIcon : tab.icon,
                      key: ValueKey(selected),
                      size: 23,
                      color: color,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 3),
              AnimatedDefaultTextStyle(
                duration: duration,
                curve: AppMotion.curve,
                style: DefaultTextStyle.of(context).style.merge(
                  TextStyle(
                    fontSize: AppFontSize.badge,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w600,
                    color: color,
                  ),
                ),
                child: Text(
                  tab.label(context.l10n),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
