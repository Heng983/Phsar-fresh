import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';
import 'package:phsar_fresh_app/features/chat/domain/model/chat_message.dart';

/// A product suggested by Ming Sros, shown inside the reply bubble.
class ChatProductCard extends ConsumerWidget {
  const ChatProductCard({
    super.key,
    required this.product,
    required this.canAdd,
    required this.onAdd,
  });

  final ChatProduct product;
  final bool canAdd;
  final VoidCallback onAdd;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final price = ref
        .watch(currencyProvider)
        .format(product.priceCents, l10n.localeName);
    final details = [
      if (product.origin?.trim().isNotEmpty ?? false) product.origin!.trim(),
      if (product.unit.trim().isNotEmpty) product.unit.trim(),
    ].join(' · ');
    final status = product.inStock ? null : l10n.chatOutOfStock;
    return Container(
      key: ValueKey('chat-product-${product.id}'),
      padding: const EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: AppColors.background,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppDecorations.cardBorder),
      ),
      child: Row(
        children: [
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.sm),
            child: SizedBox(
              width: 52,
              height: 52,
              child: MarketImage(path: product.imageUrl),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  product.displayName(l10n.localeName),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    fontSize: AppFontSize.footnote,
                    height: 1.4,
                    fontWeight: FontWeight.w600,
                    color: AppColors.textPrimary,
                  ),
                ),
                if (details.isNotEmpty)
                  Text(
                    details,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(
                      fontSize: AppFontSize.badge,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                const SizedBox(height: 2),
                Text(
                  price,
                  style: const TextStyle(
                    fontSize: AppFontSize.footnote,
                    height: 1.4,
                    fontWeight: FontWeight.w700,
                    color: AppColors.primaryDark,
                  ),
                ),
                if (status != null)
                  Text(
                    status,
                    style: const TextStyle(
                      fontSize: AppFontSize.badge,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          IconButton.filled(
            key: ValueKey('chat-add-${product.id}'),
            tooltip: status ?? l10n.exploreAddToCart,
            onPressed: canAdd ? onAdd : null,
            style: IconButton.styleFrom(
              backgroundColor: AppColors.primaryDark,
              foregroundColor: Colors.white,
              disabledBackgroundColor: AppColors.inputBackground,
              disabledForegroundColor: AppColors.textSecondary,
              minimumSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.add_shopping_cart_rounded, size: 20),
          ),
        ],
      ),
    );
  }
}
