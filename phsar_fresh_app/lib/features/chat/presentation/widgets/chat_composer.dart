import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';

class ChatComposer extends StatefulWidget {
  const ChatComposer({
    super.key,
    required this.controller,
    required this.onChanged,
    required this.onSend,
    required this.canSend,
    this.helperText,
    this.maxLength = 2000,
  });

  final TextEditingController controller;
  final ValueChanged<String> onChanged;
  final VoidCallback onSend;
  final bool canSend;
  final String? helperText;
  final int maxLength;

  @override
  State<ChatComposer> createState() => _ChatComposerState();
}

class _ChatComposerState extends State<ChatComposer> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => Container(
    padding: const EdgeInsets.fromLTRB(16, 12, 16, 12),
    decoration: const BoxDecoration(
      color: AppColors.card,
      borderRadius: BorderRadius.vertical(top: Radius.circular(28)),
    ),
    child: Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Expanded(
              child: ListenableBuilder(
                listenable: _focusNode,
                builder: (context, child) => AnimatedContainer(
                  duration: MediaQuery.disableAnimationsOf(context)
                      ? Duration.zero
                      : const Duration(milliseconds: 160),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 3,
                  ),
                  decoration: BoxDecoration(
                    color: AppColors.card,
                    borderRadius: BorderRadius.circular(28),
                    border: Border.all(
                      color: _focusNode.hasFocus
                          ? AppColors.primary.withValues(alpha: .65)
                          : AppColors.border,
                    ),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.textPrimary.withValues(alpha: .025),
                        blurRadius: 16,
                        offset: const Offset(0, 4),
                      ),
                    ],
                  ),
                  child: child,
                ),
                child: TextField(
                  key: const Key('chat-message-input'),
                  controller: widget.controller,
                  focusNode: _focusNode,
                  onChanged: widget.onChanged,
                  onSubmitted: (_) => widget.onSend(),
                  onTapOutside: (_) => _focusNode.unfocus(),
                  minLines: 1,
                  maxLines: 4,
                  maxLength: widget.maxLength,
                  textCapitalization: TextCapitalization.sentences,
                  textInputAction: TextInputAction.send,
                  style: const TextStyle(
                    fontSize: AppFontSize.bodySmall,
                    height: 1.5,
                    color: AppColors.textPrimary,
                  ),
                  decoration: InputDecoration(
                    hintText: context.l10n.chatInputHint,
                    hintMaxLines: 1,
                    hintStyle: const TextStyle(
                      color: AppColors.textSecondary,
                      fontSize: AppFontSize.footnote,
                    ),
                    border: InputBorder.none,
                    counterText: '',
                    contentPadding: const EdgeInsets.symmetric(vertical: 11),
                  ),
                ),
              ),
            ),
            const SizedBox(width: 10),
            IconButton.filled(
              key: const Key('chat-send'),
              tooltip: context.l10n.chatSend,
              onPressed: widget.canSend ? widget.onSend : null,
              style: IconButton.styleFrom(
                backgroundColor: AppColors.primary,
                foregroundColor: Colors.white,
                disabledBackgroundColor: AppColors.lightGreen,
                disabledForegroundColor: AppColors.primaryDark.withValues(
                  alpha: .5,
                ),
                minimumSize: const Size(48, 48),
                shape: const CircleBorder(),
              ),
              icon: Transform.rotate(
                angle: -.4,
                child: const Icon(Icons.send_rounded, size: 22),
              ),
            ),
          ],
        ),
        if (widget.helperText != null)
          Padding(
            padding: const EdgeInsets.only(top: 9, bottom: 4),
            child: Text(
              widget.helperText!,
              textAlign: TextAlign.center,
              style: const TextStyle(
                color: AppColors.textSecondary,
                fontSize: AppFontSize.badge,
                height: 1.4,
              ),
            ),
          ),
      ],
    ),
  );
}
