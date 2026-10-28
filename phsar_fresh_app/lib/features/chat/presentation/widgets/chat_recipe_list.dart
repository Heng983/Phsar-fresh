import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/chat/domain/model/chat_message.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_product_card.dart';

/// A dish's ingredients under Ming Sros's reply: each with its amount and
/// the product to add, or a note when Phsar Fresh does not sell it.
class ChatRecipeList extends StatelessWidget {
  const ChatRecipeList({
    super.key,
    required this.recipe,
    required this.canAdd,
    required this.onAdd,
  });

  final ChatRecipe recipe;
  final bool Function(ChatProduct) canAdd;
  final ValueChanged<ChatProduct> onAdd;

  static const _labelStyle = TextStyle(
    fontSize: AppFontSize.caption,
    height: 1.4,
    fontWeight: FontWeight.w600,
    color: AppColors.textSecondary,
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return Column(
      key: const Key('chat-recipe'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          l10n.chatRecipeTitle(recipe.dish),
          style: const TextStyle(
            fontSize: AppFontSize.bodySmall,
            height: 1.4,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
        if (recipe.servings != null)
          Text(l10n.chatRecipeServings(recipe.servings!), style: _labelStyle),
        for (final (index, item) in recipe.items.indexed) ...[
          const SizedBox(height: 10),
          Text(
            [
              item.ingredient,
              if (item.quantity != null) item.quantity!,
            ].join(' · '),
            key: ValueKey('chat-recipe-item-$index'),
            style: _labelStyle,
          ),
          const SizedBox(height: 4),
          if (item.product case final product?)
            ChatProductCard(
              product: product,
              canAdd: canAdd(product),
              onAdd: () => onAdd(product),
            )
          else
            Row(
              children: [
                const Icon(
                  Icons.info_outline_rounded,
                  size: 16,
                  color: AppColors.textSecondary,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: Text(
                    l10n.chatRecipeNotSold,
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      height: 1.4,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ),
              ],
            ),
        ],
      ],
    );
  }
}
