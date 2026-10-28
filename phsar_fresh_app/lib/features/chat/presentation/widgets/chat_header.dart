import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_bot_avatar.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_profile_button.dart';

class ChatHeader extends StatelessWidget {
  const ChatHeader({
    super.key,
    required this.canStartNewChat,
    required this.onNewChat,
    required this.compact,
  });

  final bool canStartNewChat;
  final VoidCallback onNewChat;
  final bool compact;

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(20, 12, 16, 14),
    decoration: const BoxDecoration(
      border: Border(bottom: BorderSide(color: AppColors.border)),
    ),
    child: Row(
      children: [
        const ChatBotAvatar(size: 40),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Semantics(
                header: true,
                child: Text(
                  context.l10n.chatTitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.primaryDark,
                    fontSize: AppFontSize.headline,
                    fontWeight: FontWeight.w700,
                    height: 1.4,
                  ),
                ),
              ),
              if (!compact) ...[
                const SizedBox(height: 2),
                Text(
                  context.l10n.chatSubtitle,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppFontSize.caption,
                    height: 1.4,
                  ),
                ),
              ],
            ],
          ),
        ),
        const SizedBox(width: 8),
        IconButton(
          key: const Key('chat-new-conversation'),
          tooltip: context.l10n.chatNewConversation,
          onPressed: canStartNewChat ? onNewChat : null,
          style: IconButton.styleFrom(
            foregroundColor: AppColors.primaryDark,
            disabledForegroundColor: AppColors.textSecondary.withValues(
              alpha: .35,
            ),
            minimumSize: const Size(44, 44),
          ),
          icon: const Icon(Icons.edit_square, size: 21),
        ),
        const SizedBox(width: 4),
        const MarketProfileButton(size: 44, showGuestLogo: false),
      ],
    ),
  );
}
