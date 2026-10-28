import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

/// Carousel slide inviting shoppers to ask the Ming Sros AI assistant.
/// Sized like a harvest deal slide so the carousel keeps one height.
class MingSrosPromoSlide extends StatelessWidget {
  final double imageHeight;
  final bool compact;
  final VoidCallback onOpen;

  const MingSrosPromoSlide({
    super.key,
    required this.imageHeight,
    required this.compact,
    required this.onOpen,
  });

  static const assetPath = 'assets/images/MingSros_banner.png';

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.exploreMingSrosTitle,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: AppFontSize.bodySmall,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          l10n.exploreMingSrosBody,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppFontSize.badge,
            height: 1.35,
          ),
        ),
      ],
    );
    final button = FilledButton.icon(
      key: const Key('ming-sros-open'),
      onPressed: onOpen,
      icon: const Icon(Icons.auto_awesome_rounded, size: 16),
      label: Text(
        l10n.exploreMingSrosAction,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: const TextStyle(fontSize: AppFontSize.badge, height: 1.4),
      ),
      style: FilledButton.styleFrom(
        backgroundColor: AppColors.loginButton,
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
        minimumSize: const Size(0, 44),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      ),
    );
    return Semantics(
      button: true,
      label: l10n.exploreMingSrosAction,
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.leaf(30),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onOpen,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageHeight,
                child: ExcludeSemantics(
                  child: Image.asset(
                    assetPath,
                    fit: BoxFit.cover,
                    cacheWidth: 1000,
                    errorBuilder: (_, _, _) =>
                        const ColoredBox(color: AppColors.lightGreen),
                  ),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  child: Center(
                    child: compact
                        ? Column(
                            mainAxisSize: MainAxisSize.min,
                            crossAxisAlignment: CrossAxisAlignment.stretch,
                            children: [text, const SizedBox(height: 8), button],
                          )
                        : Row(
                            children: [
                              Expanded(child: text),
                              const SizedBox(width: 10),
                              button,
                            ],
                          ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
