import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

final authSystemUiObserverProvider = Provider<AuthSystemUiObserver>(
  (ref) => AuthSystemUiObserver(),
);

/// Hides the iPhone status bar when the visible auth page is scrolled down.
class AuthSystemUiObserver extends NavigatorObserver {
  final _scrolledRoutes = <Route<dynamic>>{};
  Route<dynamic>? _topPageRoute;
  bool? _lastHidden;

  void updateScrollPosition(Route<dynamic> route, double offset) {
    final changed = offset > 0
        ? _scrolledRoutes.add(route)
        : _scrolledRoutes.remove(route);
    if (changed && route == _topPageRoute) _updateStatusBar();
  }

  void forgetRoute(Route<dynamic> route) {
    if (_scrolledRoutes.remove(route) && route == _topPageRoute) {
      _updateStatusBar();
    }
  }

  @override
  void didChangeTop(Route<dynamic> topRoute, Route<dynamic>? previousTopRoute) {
    if (topRoute is! PageRoute) return;
    _topPageRoute = topRoute;
    _updateStatusBar();
  }

  void _updateStatusBar() {
    if (kIsWeb || defaultTargetPlatform != TargetPlatform.iOS) return;
    final hideStatusBar = _scrolledRoutes.contains(_topPageRoute);
    if (_lastHidden == hideStatusBar) return;
    _lastHidden = hideStatusBar;
    SystemChrome.setEnabledSystemUIMode(
      SystemUiMode.manual,
      overlays: [
        if (!hideStatusBar) SystemUiOverlay.top,
        SystemUiOverlay.bottom,
      ],
    );
  }
}
