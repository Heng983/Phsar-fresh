import 'dart:ui' show ImageFilter, TileMode;

import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';

class ProductImageGallery extends StatefulWidget {
  final List<String> images;
  final String title;
  final VoidCallback onCopy;

  /// Wraps the first photo so it flies in from the tapped card.
  final Object? heroTag;

  const ProductImageGallery({
    super.key,
    required this.images,
    required this.title,
    required this.onCopy,
    this.heroTag,
  });

  @override
  State<ProductImageGallery> createState() => _ProductImageGalleryState();
}

class _ProductImageGalleryState extends State<ProductImageGallery> {
  int _index = 0;

  Widget _hero(int index, Widget child) {
    final tag = widget.heroTag;
    return tag == null || index != 0 ? child : Hero(tag: tag, child: child);
  }

  @override
  Widget build(BuildContext context) => AspectRatio(
    aspectRatio: 1.05,
    child: ClipRRect(
      // The bottom edge echoes the leaf shape used for produce photos.
      borderRadius: const BorderRadius.only(
        bottomLeft: Radius.circular(36),
        bottomRight: Radius.circular(12),
      ),
      child: Stack(
        fit: StackFit.expand,
        children: [
          PageView.builder(
            key: const Key('product-image-gallery'),
            itemCount: widget.images.isEmpty ? 1 : widget.images.length,
            onPageChanged: (index) => setState(() => _index = index),
            itemBuilder: (_, index) {
              final path = widget.images.isEmpty ? null : widget.images[index];
              // The whole product stays visible (tall bottles, wide photos);
              // a soft blur of the same photo fills the space around it.
              return Stack(
                fit: StackFit.expand,
                children: [
                  ExcludeSemantics(
                    child: ImageFiltered(
                      imageFilter: ImageFilter.blur(
                        sigmaX: 28,
                        sigmaY: 28,
                        tileMode: TileMode.mirror,
                      ),
                      child: MarketImage(path: path),
                    ),
                  ),
                  _hero(
                    index,
                    MarketImage(
                      path: path,
                      semanticLabel: widget.title,
                      fit: BoxFit.contain,
                    ),
                  ),
                ],
              );
            },
          ),
          Positioned(
            top: 12,
            left: 12,
            child: _GalleryAction(
              tooltip: MaterialLocalizations.of(context).backButtonTooltip,
              onPressed: () => Navigator.maybePop(context),
              icon: Icons.arrow_back_rounded,
            ),
          ),
          Positioned(
            top: 12,
            right: 12,
            child: _GalleryAction(
              buttonKey: const Key('product-copy'),
              tooltip: context.l10n.productCopy,
              onPressed: widget.onCopy,
              icon: Icons.share_outlined,
              iconSize: 21,
            ),
          ),
          if (widget.images.length > 1)
            Positioned(
              bottom: 14,
              left: 0,
              right: 0,
              child: Center(
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 10,
                    vertical: 7,
                  ),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      for (var index = 0; index < widget.images.length; index++)
                        Container(
                          margin: const EdgeInsets.symmetric(horizontal: 3),
                          width: 7,
                          height: 7,
                          decoration: BoxDecoration(
                            color: index == _index
                                ? Colors.white
                                : Colors.white38,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                ),
              ),
            ),
        ],
      ),
    ),
  );
}

/// Round brand-green button floating over the photo. The shadow keeps it
/// readable on both white and dark photos.
class _GalleryAction extends StatelessWidget {
  final Key? buttonKey;
  final String tooltip;
  final VoidCallback onPressed;
  final IconData icon;
  final double iconSize;

  const _GalleryAction({
    this.buttonKey,
    required this.tooltip,
    required this.onPressed,
    required this.icon,
    this.iconSize = 22,
  });

  @override
  Widget build(BuildContext context) => DecoratedBox(
    decoration: BoxDecoration(
      shape: BoxShape.circle,
      boxShadow: [
        BoxShadow(
          color: AppColors.primaryDark.withValues(alpha: 0.28),
          blurRadius: 12,
          offset: const Offset(0, 4),
        ),
      ],
    ),
    child: IconButton.filled(
      key: buttonKey,
      tooltip: tooltip,
      onPressed: onPressed,
      style: IconButton.styleFrom(
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
        fixedSize: const Size.square(44),
      ),
      icon: Icon(icon, size: iconSize),
    ),
  );
}
