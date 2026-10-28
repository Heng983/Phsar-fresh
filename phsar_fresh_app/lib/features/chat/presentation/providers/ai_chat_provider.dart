import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/localization/locale_provider.dart';
import 'package:phsar_fresh_app/features/chat/data/chat_api.dart';
import 'package:phsar_fresh_app/features/chat/data/demo_chat.dart';
import 'package:phsar_fresh_app/features/chat/domain/model/chat_message.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

enum AiChatError {
  unavailable,
  connection,
  rateLimited,
  invalidResponse,
  request,
}

class AiChatState {
  const AiChatState({
    this.messages = const [],
    this.draft = '',
    this.isLoading = false,
    this.error,
  });

  final List<ChatMessage> messages;
  final String draft;
  final bool isLoading;
  final AiChatError? error;
}

final aiChatProvider = NotifierProvider<AiChatNotifier, AiChatState>(
  AiChatNotifier.new,
);

class AiChatNotifier extends Notifier<AiChatState> {
  CancelToken? _pending;
  int _generation = 0;
  bool _disposed = false;

  @override
  AiChatState build() {
    ref.onDispose(() {
      _disposed = true;
      _pending?.cancel();
    });
    return const AiChatState();
  }

  void updateDraft(String draft) => state = AiChatState(
    messages: state.messages,
    draft: draft,
    isLoading: state.isLoading,
    error: state.error,
  );

  Future<void> send(String message) async {
    final text = message.trim();
    if (text.isEmpty || state.isLoading) return;
    state = AiChatState(
      messages: List.unmodifiable([
        ...state.messages,
        ChatMessage(isUser: true, text: text, sentAt: DateTime.now()),
      ]),
      isLoading: true,
    );
    await _requestReply();
  }

  Future<void> retry() async {
    if (state.isLoading || state.error == null || state.messages.isEmpty) {
      return;
    }
    state = AiChatState(
      messages: state.messages,
      draft: state.draft,
      isLoading: true,
    );
    await _requestReply();
  }

  Future<void> _requestReply() async {
    final generation = ++_generation;
    final cancelToken = CancelToken();
    _pending = cancelToken;
    var error = AiChatError.request;
    try {
      final isDemo = ref.read(chatDemoModeProvider);
      final api = isDemo ? null : ref.read(chatApiProvider);
      if (!isDemo && api == null) {
        error = AiChatError.unavailable;
      } else {
        // The newest message is always the user's turn awaiting a reply.
        final messages = state.messages;
        final reply = isDemo
            ? await Future<ChatMessage>.delayed(
                const Duration(milliseconds: 450),
                () => demoChatReply(
                  messages,
                  lookupAppLocalizations(ref.read(localeProvider)),
                ),
              )
            : await api!.send(
                message: messages.last.text,
                history: messages.sublist(0, messages.length - 1),
                cancelToken: cancelToken,
              );
        if (_disposed || generation != _generation) return;
        state = AiChatState(
          messages: List.unmodifiable([
            ...state.messages,
            ChatMessage(
              isUser: false,
              text: reply.text,
              products: reply.products,
              recipe: reply.recipe,
              sentAt: reply.sentAt ?? DateTime.now(),
            ),
          ]),
          draft: state.draft,
        );
        return;
      }
    } on FormatException {
      error = AiChatError.invalidResponse;
    } on DioException catch (exception) {
      error = switch ((exception.type, exception.response?.statusCode)) {
        (_, 429) => AiChatError.rateLimited,
        (_, 503) => AiChatError.unavailable,
        (
          DioExceptionType.connectionTimeout ||
              DioExceptionType.sendTimeout ||
              DioExceptionType.receiveTimeout ||
              DioExceptionType.connectionError,
          _,
        ) =>
          AiChatError.connection,
        _ => AiChatError.request,
      };
    } catch (_) {
      error = AiChatError.request;
    } finally {
      if (identical(_pending, cancelToken)) _pending = null;
    }
    if (_disposed || generation != _generation) return;
    state = AiChatState(
      messages: state.messages,
      draft: state.draft,
      error: error,
    );
  }

  void clear() {
    _generation++;
    _pending?.cancel();
    _pending = null;
    state = const AiChatState();
  }
}
