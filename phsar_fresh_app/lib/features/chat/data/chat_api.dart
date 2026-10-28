import 'dart:convert';

import 'package:dio/dio.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/config/api_config.dart';
import 'package:phsar_fresh_app/core/network/api_providers.dart';
import 'package:phsar_fresh_app/features/chat/domain/model/chat_message.dart';

/// Client for the Ming Sros AI endpoint, `POST /chat`.
///
/// Request: `{message, history: [{role: user|model, text}]}`.
/// Response: `{reply, products: [...], recipe: {dish, servings, items} | null}`.
class ChatApi {
  ChatApi(this.dio);

  final Dio dio;

  /// Server limits for one request.
  static const maxMessageLength = 500;
  static const maxHistoryTurns = 10;
  static const maxHistoryTextLength = 1000;

  /// The AI can take a while, so allow more time than normal requests.
  static const replyTimeout = Duration(seconds: 60);

  /// Sends [message] with the earlier conversation in [history] (oldest first).
  Future<ChatMessage> send({
    required String message,
    List<ChatMessage> history = const [],
    CancelToken? cancelToken,
  }) async {
    final turns = history.where((turn) => turn.text.trim().isNotEmpty).toList();
    final recent = turns.length > maxHistoryTurns
        ? turns.sublist(turns.length - maxHistoryTurns)
        : turns;
    final response = await dio.post<dynamic>(
      '/chat',
      cancelToken: cancelToken,
      options: Options(receiveTimeout: replyTimeout),
      data: {
        'message': _limit(message, maxMessageLength),
        'history': [
          for (final turn in recent)
            {
              'role': turn.isUser ? 'user' : 'model',
              'text': _limit(turn.text, maxHistoryTextLength),
            },
        ],
      },
    );
    final dynamic data = response.data is String
        ? jsonDecode(response.data as String)
        : response.data;
    if (data is! Map<String, dynamic>) {
      throw const FormatException('Invalid chat response');
    }
    final reply = data['reply'] ?? '';
    final products = data['products'] ?? const [];
    final recipe = data['recipe'];
    if (reply is! String ||
        products is! List ||
        (recipe != null && recipe is! Map<String, dynamic>)) {
      throw const FormatException('Invalid chat response');
    }
    final baseUri = Uri.tryParse(dio.options.baseUrl);
    final parsed = products
        .map((value) {
          if (value is! Map<String, dynamic>) {
            throw const FormatException('Invalid chat product');
          }
          return ChatProduct.fromJson(value, baseUri: baseUri);
        })
        .toList(growable: false);
    final parsedRecipe = recipe == null
        ? null
        : ChatRecipe.fromJson(recipe as Map<String, dynamic>, baseUri: baseUri);
    if (reply.trim().isEmpty && parsed.isEmpty && parsedRecipe == null) {
      throw const FormatException('Empty chat response');
    }
    return ChatMessage(
      isUser: false,
      text: reply,
      products: List.unmodifiable(parsed),
      recipe: parsedRecipe,
      sentAt: DateTime.now(),
    );
  }

  /// Cuts [text] to [max] UTF-16 units without splitting an emoji in half.
  static String _limit(String text, int max) {
    if (text.length <= max) return text;
    var end = max;
    final last = text.codeUnitAt(end - 1);
    if (last >= 0xD800 && last <= 0xDBFF) end--;
    return text.substring(0, end);
  }
}

/// Sample replies run when no API is configured. Force either mode with
/// `--dart-define=CHAT_DEMO_MODE=true|false`.
final chatDemoModeProvider = Provider<bool>(
  (ref) => const bool.hasEnvironment('CHAT_DEMO_MODE')
      ? const bool.fromEnvironment('CHAT_DEMO_MODE')
      : !ApiConfig.isConfigured,
);

final chatApiProvider = Provider<ChatApi?>((ref) {
  if (ref.watch(chatDemoModeProvider)) return null;
  final client = ref.watch(apiClientProvider);
  return client == null ? null : ChatApi(client.dio);
});
