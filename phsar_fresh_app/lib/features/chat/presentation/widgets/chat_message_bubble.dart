import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/chat/domain/model/chat_message.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_bot_avatar.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_product_card.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_recipe_list.dart';

class ChatMessageBubble extends StatelessWidget {
  const ChatMessageBubble({
    super.key,
    required this.message,
    required this.canAdd,
    required this.onAdd,
    this.acknowledged = false,
  });

  final ChatMessage message;
  final bool Function(ChatProduct) canAdd;
  final ValueChanged<ChatProduct> onAdd;
  final bool acknowledged;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(bottom: 18),
    child: LayoutBuilder(
      builder: (context, constraints) => Align(
        alignment: message.isUser
            ? Alignment.centerRight
            : Alignment.centerLeft,
        child: Row(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (!message.isUser) ...[
              const Padding(
                padding: EdgeInsets.only(top: 2),
                child: ChatBotAvatar(size: 36),
              ),
              const SizedBox(width: 8),
            ],
            ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: message.isUser
                    ? math.min(380, constraints.maxWidth * .85)
                    : math.min(520, constraints.maxWidth - 44),
              ),
              child: Semantics(
                liveRegion: !message.isUser,
                child: Container(
                  padding: const EdgeInsets.fromLTRB(14, 13, 14, 9),
                  decoration: BoxDecoration(
                    color: message.isUser
                        ? AppColors.lightGreen
                        : AppColors.card,
                    borderRadius: BorderRadius.only(
                      topLeft: const Radius.circular(23),
                      topRight: const Radius.circular(23),
                      bottomLeft: const Radius.circular(23),
                      bottomRight: Radius.circular(message.isUser ? 6 : 23),
                    ),
                    boxShadow: message.isUser
                        ? null
                        : [
                            BoxShadow(
                              color: AppColors.textPrimary.withValues(
                                alpha: .025,
                              ),
                              blurRadius: 14,
                              offset: const Offset(0, 3),
                            ),
                          ],
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      if (message.text.isNotEmpty)
                        SelectableText(
                          message.text,
                          style: const TextStyle(
                            fontSize: AppFontSize.bodySmall,
                            height: 1.55,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      if (message.products.isNotEmpty) ...[
                        if (message.text.isNotEmpty) const SizedBox(height: 12),
                        for (var i = 0; i < message.products.length; i++)
                          Padding(
                            padding: EdgeInsets.only(top: i == 0 ? 0 : 8),
                            child: ChatProductCard(
                              product: message.products[i],
                              canAdd: canAdd(message.products[i]),
                              onAdd: () => onAdd(message.products[i]),
                            ),
                          ),
                      ],
                      if (message.recipe != null) ...[
                        if (message.text.isNotEmpty ||
                            message.products.isNotEmpty)
                          const SizedBox(height: 14),
                        ChatRecipeList(
                          recipe: message.recipe!,
                          canAdd: canAdd,
                          onAdd: onAdd,
                        ),
                      ],
                      if (message.sentAt != null || acknowledged)
                        Padding(
                          padding: const EdgeInsets.only(top: 6),
                          child: Align(
                            alignment: Alignment.centerRight,
                            child: Wrap(
                              spacing: 6,
                              crossAxisAlignment: WrapCrossAlignment.center,
                              alignment: WrapAlignment.end,
                              children: [
                                if (message.sentAt != null)
                                  Text(
                                    DateFormat.jm(
                                      context.l10n.localeName,
                                    ).format(message.sentAt!.toLocal()),
                                    style: const TextStyle(
                                      color: AppColors.textSecondary,
                                      fontSize: AppFontSize.badge,
                                      height: 1.4,
                                    ),
                                  ),
                                if (message.isUser && acknowledged)
                                  Icon(
                                    Icons.done_all_rounded,
                                    size: 16,
                                    color: AppColors.primaryDark,
                                    semanticLabel:
                                        context.l10n.chatReplyReceived,
                                  ),
                              ],
                            ),
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
    ),
  );
}
