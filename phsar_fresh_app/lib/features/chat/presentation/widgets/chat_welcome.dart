import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/pressable.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_bot_avatar.dart';

class ChatWelcome extends StatelessWidget {
  const ChatWelcome({super.key, required this.onPrompt, this.compact = false});

  final ValueChanged<String> onPrompt;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final prompts = [
      (
        id: 'meals',
        label: l10n.chatMealsLabel,
        prompt: l10n.chatMealsPrompt,
        icon: Icons.restaurant_outlined,
      ),
      (
        id: 'fresh',
        label: l10n.chatFreshLabel,
        prompt: l10n.chatFreshPrompt,
        icon: Icons.eco_outlined,
      ),
    ];
    return Center(
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 520),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            if (!compact) ...[
              const SizedBox(height: 16),
              const Center(child: ChatBotAvatar(size: 72)),
              const SizedBox(height: 22),
              Text(
                l10n.chatWelcomeTitle,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSize.headlineLarge,
                  fontWeight: FontWeight.w700,
                  height: 1.4,
                  color: AppColors.textPrimary,
                ),
              ),
              const SizedBox(height: 12),
              Text(
                l10n.chatWelcomeBody,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSize.footnote,
                  height: 1.6,
                  color: AppColors.textSecondary,
                ),
              ),
              const SizedBox(height: 30),
            ],
            Text(
              l10n.chatSuggestionsTitle,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontSize: AppFontSize.badge,
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 12),
            for (final prompt in prompts)
              Padding(
                padding: const EdgeInsets.only(bottom: 10),
                child: Pressable(
                  child: DecoratedBox(
                    decoration: AppDecorations.card(radius: AppRadius.lg),
                    child: Material(
                      color: Colors.transparent,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                      clipBehavior: Clip.antiAlias,
                      child: ListTile(
                        key: ValueKey('chat-prompt-${prompt.id}'),
                        onTap: () => onPrompt(prompt.prompt),
                        leading: Icon(
                          prompt.icon,
                          color: AppColors.primaryDark,
                        ),
                        title: Text(
                          prompt.label,
                          style: const TextStyle(
                            fontSize: AppFontSize.footnote,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        trailing: const Icon(
                          Icons.north_east_rounded,
                          size: 16,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
