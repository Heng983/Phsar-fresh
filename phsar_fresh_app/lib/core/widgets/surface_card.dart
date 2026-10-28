import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/theme/app_decorations.dart';

class SurfaceCard extends StatelessWidget {
  final Widget child;
  final EdgeInsetsGeometry padding;

  const SurfaceCard({
    super.key,
    required this.child,
    this.padding = const EdgeInsets.all(16),
  });

  @override
  Widget build(BuildContext context) => Container(
    padding: padding,
    decoration: AppDecorations.card(),
    child: child,
  );
}
