import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/catalog/data/market_catalog.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/market_product.dart';
import 'package:phsar_fresh_app/features/catalog/domain/model/product_category.dart';
import 'package:phsar_fresh_app/features/chat/data/chat_api.dart';
import 'package:phsar_fresh_app/features/chat/domain/model/chat_message.dart';
import 'package:phsar_fresh_app/features/chat/presentation/providers/ai_chat_provider.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_composer.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_header.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_message_bubble.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_welcome.dart';

class AiChatPage extends ConsumerStatefulWidget {
  const AiChatPage({super.key, this.keyboardOpen = false, this.onAddToCart});

  final bool keyboardOpen;
  final ValueChanged<ChatProduct>? onAddToCart;

  @override
  ConsumerState<AiChatPage> createState() => _AiChatPageState();
}

class _AiChatPageState extends ConsumerState<AiChatPage> {
  late final TextEditingController _controller;
  final _scroll = ScrollController();

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: ref.read(aiChatProvider).draft);
    if (ref.read(aiChatProvider).messages.isNotEmpty) _scrollDown();
  }

  @override
  void dispose() {
    _controller.dispose();
    _scroll.dispose();
    super.dispose();
  }

  void _send([String? prompt]) {
    if (ref.read(aiChatProvider).isLoading) return;
    final text = (prompt ?? _controller.text).trim();
    if (text.isEmpty) return;
    _controller.clear();
    unawaited(ref.read(aiChatProvider.notifier).send(text));
  }

  void _scrollDown({bool toStart = false}) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (!mounted || !_scroll.hasClients) return;
      _scroll.jumpTo(toStart ? 0 : _scroll.position.maxScrollExtent);
    });
  }

  void _newChat() {
    ref.read(aiChatProvider.notifier).clear();
    _controller.clear();
    FocusScope.of(context).unfocus();
    _scrollDown(toStart: true);
  }

  MarketProduct _basketProduct(ChatProduct product) =>
      marketProducts
          .where(
            (item) =>
                item.id == product.id &&
                item.priceInCents == product.priceCents,
          )
          .firstOrNull ??
      MarketProduct(
        id: product.id,
        name: product.name,
        nameKm: product.nameKm,
        origin: product.origin,
        unit: product.unit,
        priceInCents: product.priceCents,
        imageUrl: product.imageUrl,
        inStock: product.inStock,
        category: ProductCategory(id: product.category, name: product.category),
      );

  bool _canAdd(ChatProduct product) => product.inStock;

  void _addToCart(ChatProduct product) {
    if (!_canAdd(product)) return;
    if (widget.onAddToCart != null) {
      widget.onAddToCart!(product);
      return;
    }
    ref.read(marketCartProvider.notifier).add(_basketProduct(product));
    HapticFeedback.lightImpact();
  }

  String _errorMessage(AiChatError error) => switch (error) {
    AiChatError.unavailable => context.l10n.chatServiceUnavailable,
    AiChatError.connection => context.l10n.chatConnectionError,
    AiChatError.rateLimited => context.l10n.chatRateLimited,
    AiChatError.invalidResponse => context.l10n.chatInvalidResponse,
    AiChatError.request => context.l10n.chatRequestError,
  };

  @override
  Widget build(BuildContext context) {
    ref.listen(aiChatProvider, (previous, next) {
      if (previous?.messages.length != next.messages.length ||
          previous?.isLoading != next.isLoading ||
          previous?.error != next.error) {
        _scrollDown();
      }
    });
    final chat = ref.watch(aiChatProvider);
    ref.watch(marketCartProvider);
    final isDemo = ref.watch(chatDemoModeProvider);
    final apiAvailable = isDemo || ref.watch(chatApiProvider) != null;
    final l10n = context.l10n;
    final lastReplyIndex = chat.messages.lastIndexWhere(
      (message) => !message.isUser,
    );
    return ColoredBox(
      color: AppColors.background,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ChatHeader(
            canStartNewChat: chat.messages.isNotEmpty || chat.draft.isNotEmpty,
            onNewChat: _newChat,
            compact: widget.keyboardOpen,
          ),
          Expanded(
            child: ListView(
              key: const PageStorageKey('ai-chat-messages'),
              controller: _scroll,
              keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
              children: [
                if (chat.messages.isEmpty)
                  ChatWelcome(onPrompt: _send, compact: widget.keyboardOpen),
                for (var i = 0; i < chat.messages.length; i++)
                  ChatMessageBubble(
                    key: ValueKey('chat-message-$i'),
                    message: chat.messages[i],
                    acknowledged: chat.messages[i].isUser && i < lastReplyIndex,
                    canAdd: _canAdd,
                    onAdd: _addToCart,
                  ),
                if (chat.isLoading)
                  Semantics(
                    liveRegion: true,
                    child: Row(
                      key: const Key('chat-loading'),
                      children: [
                        const SizedBox(
                          width: 16,
                          height: 16,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.primaryDark,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: Text(
                            l10n.chatThinking,
                            style: const TextStyle(
                              fontSize: AppFontSize.caption,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                if (chat.error != null)
                  Semantics(
                    liveRegion: true,
                    child: Container(
                      key: const Key('chat-error'),
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppColors.card,
                        borderRadius: BorderRadius.circular(18),
                        border: Border.all(color: AppColors.border),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            _errorMessage(chat.error!),
                            style: const TextStyle(
                              fontSize: AppFontSize.footnote,
                              height: 1.5,
                            ),
                          ),
                          TextButton.icon(
                            key: const Key('chat-retry'),
                            onPressed: () => unawaited(
                              ref.read(aiChatProvider.notifier).retry(),
                            ),
                            icon: const Icon(Icons.refresh_rounded, size: 18),
                            style: TextButton.styleFrom(
                              foregroundColor: AppColors.primaryDark,
                            ),
                            label: Text(l10n.chatRetry),
                          ),
                        ],
                      ),
                    ),
                  ),
              ],
            ),
          ),
          ChatComposer(
            controller: _controller,
            onChanged: ref.read(aiChatProvider.notifier).updateDraft,
            onSend: _send,
            canSend: !chat.isLoading && chat.draft.trim().isNotEmpty,
            maxLength: ChatApi.maxMessageLength,
            helperText: isDemo
                ? l10n.chatDemoNotice
                : apiAvailable
                ? null
                : l10n.chatServiceUnavailable,
          ),
        ],
      ),
    );
  }
}

class ChatScreen extends StatelessWidget {
  const ChatScreen({super.key, required this.api, required this.onAddToCart});

  final ChatApi api;
  final ValueChanged<ChatProduct> onAddToCart;

  @override
  Widget build(BuildContext context) => ProviderScope(
    overrides: [
      chatDemoModeProvider.overrideWithValue(false),
      chatApiProvider.overrideWithValue(api),
      aiChatProvider.overrideWith(AiChatNotifier.new),
    ],
    child: Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: AiChatPage(
          keyboardOpen: MediaQuery.viewInsetsOf(context).bottom > 0,
          onAddToCart: onAddToCart,
        ),
      ),
    ),
  );
}
