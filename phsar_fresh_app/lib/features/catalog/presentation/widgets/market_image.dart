import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';

/// A product or category photo: a bundled `assets/` path, a network URL, or
/// null (shows a leaf placeholder, as do images that fail to load).
class MarketImage extends StatelessWidget {
  final String? path;
  final String? semanticLabel;

  /// [BoxFit.contain] keeps tall packshots (bottles, jars) whole.
  final BoxFit fit;

  const MarketImage({
    super.key,
    required this.path,
    this.semanticLabel,
    this.fit = BoxFit.cover,
  });

  static const _placeholder = ColoredBox(
    color: AppColors.lightGreen,
    child: Center(child: Icon(Icons.eco, color: AppColors.primary, size: 36)),
  );

  @override
  Widget build(BuildContext context) {
    final source = path?.trim() ?? '';
    if (source.isEmpty) {
      return Semantics(
        label: semanticLabel,
        image: semanticLabel != null,
        child: const SizedBox.expand(child: _placeholder),
      );
    }
    Widget error(BuildContext _, Object _, StackTrace? _) => _placeholder;
    return source.startsWith('assets/')
        ? Image.asset(
            source,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            semanticLabel: semanticLabel,
            errorBuilder: error,
          )
        : Image.network(
            source,
            fit: fit,
            width: double.infinity,
            height: double.infinity,
            semanticLabel: semanticLabel,
            errorBuilder: error,
          );
  }
}
