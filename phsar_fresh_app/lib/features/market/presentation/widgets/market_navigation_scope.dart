import 'package:flutter/widgets.dart';

/// Lets shared headers open Profile without replacing a navigation tab.
class MarketNavigationScope extends InheritedWidget {
  const MarketNavigationScope({
    super.key,
    required this.onOpenProfile,
    required super.child,
  });

  final VoidCallback onOpenProfile;

  static MarketNavigationScope? maybeOf(BuildContext context) =>
      context.dependOnInheritedWidgetOfExactType<MarketNavigationScope>();

  @override
  bool updateShouldNotify(MarketNavigationScope oldWidget) =>
      onOpenProfile != oldWidget.onOpenProfile;
}
