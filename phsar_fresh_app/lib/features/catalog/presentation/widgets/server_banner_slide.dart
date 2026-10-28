import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/app_banner.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';

/// A picture banner made in the admin panel. Same size and style as the
/// built-in Ming Sros slide, so the carousel keeps one height.
class ServerBannerSlide extends StatelessWidget {
  final AppBanner banner;
  final double imageHeight;
  final bool compact;

  /// Null when the banner has no action (picture only).
  final VoidCallback? onTap;

  const ServerBannerSlide({
    super.key,
    required this.banner,
    required this.imageHeight,
    required this.compact,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final lang = Localizations.localeOf(context).languageCode;
    final title = banner.localizedTitle(lang);
    final body = banner.localizedBody(lang);
    final label = banner.localizedButton(lang);
    final text = Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            color: AppColors.primaryDark,
            fontSize: AppFontSize.bodySmall,
            height: 1.3,
            fontWeight: FontWeight.w700,
          ),
        ),
        if (body != null) ...[
          const SizedBox(height: 3),
          Text(
            body,
            maxLines: 2,
            overflow: TextOverflow.ellipsis,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSize.badge,
              height: 1.35,
            ),
          ),
        ],
      ],
    );
    final button = onTap == null || label == null
        ? null
        : FilledButton.icon(
            key: ValueKey('banner-action-${banner.id}'),
            onPressed: onTap,
            icon: Icon(
              banner.action == BannerAction.openChat
                  ? Icons.auto_awesome_rounded
                  : Icons.arrow_forward_rounded,
              size: 16,
            ),
            label: Text(
              label,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(fontSize: AppFontSize.badge, height: 1.4),
            ),
            style: FilledButton.styleFrom(
              backgroundColor: AppColors.loginButton,
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
              minimumSize: const Size(0, 44),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(9),
              ),
            ),
          );
    return Semantics(
      button: onTap != null,
      label: label ?? title,
      child: Material(
        color: Colors.white,
        borderRadius: AppRadius.leaf(30),
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: onTap,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: imageHeight,
                child: ExcludeSemantics(
                  child: MarketImage(path: banner.imageUrl),
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 11,
                  ),
                  child: Center(
                    child: button == null
                        ? Align(alignment: Alignment.centerLeft, child: text)
                        : compact
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
