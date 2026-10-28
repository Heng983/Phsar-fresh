import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/features/chat/data/chat_api.dart';
import 'package:phsar_fresh_app/features/chat/domain/model/chat_message.dart';

import '../../support/chat_test_api.dart';

void main() {
  test('Chat API parses the recipe ingredients with their products', () async {
    final greens = (productReply()['products']! as List).first;
    final api = testChatApi(
      (_) => {
        'reply': 'Lok lak needs beef and greens.',
        'products': const [],
        'recipe': {
          'dish': 'Beef Lok Lak',
          'servings': 2,
          'items': [
            {'ingredient': 'Greens', 'quantity': '1 bunch', 'product': greens},
            {'ingredient': 'Lime', 'quantity': '', 'product': null},
          ],
        },
      },
    );
    final reply = await api.send(message: 'What do I need for lok lak?');
    final recipe = reply.recipe!;
    expect(recipe.dish, 'Beef Lok Lak');
    expect(recipe.servings, 2);
    expect(recipe.items.first.quantity, '1 bunch');
    expect(recipe.items.first.product!.priceCents, 180);
    expect(recipe.items.last.quantity, isNull);
    expect(recipe.items.last.product, isNull);
  });

  test('A malformed recipe is rejected', () async {
    final api = testChatApi(
      (_) => {
        'reply': 'Here you go',
        'recipe': {'dish': 'Soup', 'items': 'garlic'},
      },
    );
    await expectLater(
      api.send(message: 'Soup?'),
      throwsA(isA<FormatException>()),
    );
  });

  test(
    'Chat API sends the message with model/user history and parses products',
    () async {
      final requests = <RequestOptions>[];
      final api = testChatApi((_) => productReply(), requests: requests);
      final reply = await api.send(
        message: 'What ingredients?',
        history: const [
          ChatMessage(isUser: true, text: 'Plan a meal'),
          ChatMessage(isUser: false, text: 'How about rice?'),
          ChatMessage(isUser: false, text: '  '),
        ],
      );
      final request = requests.single;
      expect(request.method, 'POST');
      expect(request.path, '/chat');
      expect(request.receiveTimeout, ChatApi.replyTimeout);
      expect(request.data, {
        'message': 'What ingredients?',
        'history': [
          {'role': 'user', 'text': 'Plan a meal'},
          {'role': 'model', 'text': 'How about rice?'},
        ],
      });
      expect(reply.isUser, isFalse);
      expect(reply.text, 'Try rice with greens.');
      final greens = reply.products.first;
      expect(greens.priceCents, 180);
      expect(greens.origin, 'Battambang');
      expect(greens.displayName('km'), 'បន្លែស្រស់');
      expect(greens.displayName('en'), 'Fresh greens');
      expect(reply.products[1].id, '42');
      expect(reply.products[1].displayName('km'), 'Another product');
      expect(reply.products[2].inStock, isFalse);
    },
  );

  test('History is limited to the last 10 turns of 1000 characters', () async {
    final requests = <RequestOptions>[];
    final api = testChatApi((_) => {'reply': 'OK'}, requests: requests);
    final long = 'a' * 999 + '😀';
    await api.send(
      message: 'b' * 600,
      history: [
        for (var i = 0; i < 11; i++)
          ChatMessage(isUser: i.isEven, text: i == 10 ? long : 'turn $i'),
      ],
    );
    final data = requests.single.data as Map<String, dynamic>;
    final history = data['history'] as List;
    expect(data['message'], 'b' * ChatApi.maxMessageLength);
    expect(history, hasLength(ChatApi.maxHistoryTurns));
    expect(history.first, {'role': 'model', 'text': 'turn 1'});
    // The emoji would be split at 1000 units, so it is dropped whole.
    expect((history.last as Map)['text'], 'a' * 999);
  });

  test('Relative image paths resolve against the API host', () async {
    final api = testChatApi(
      (_) => {
        'reply': '',
        'products': [
          chatProductJson('a', imageUrl: '/uploads/a.jpg'),
          chatProductJson('b', imageUrl: 'https://cdn.example/b.jpg'),
          chatProductJson('c', imageUrl: '  '),
        ],
      },
    );
    final reply = await api.send(message: 'Images?');
    expect(reply.products.map((product) => product.imageUrl), [
      'https://chat.example/uploads/a.jpg',
      'https://cdn.example/b.jpg',
      null,
    ]);
  });

  test(
    'A reply without products and a product-only reply are both accepted',
    () async {
      final text = await testChatApi(
        (_) => '{"reply":"Hello"}',
      ).send(message: 'Hello');
      expect(text.text, 'Hello');
      expect(text.products, isEmpty);
      final products = await testChatApi(
        (_) => productReply(reply: ''),
      ).send(message: 'Ingredients?');
      expect(products.text, isEmpty);
      expect(products.products, isNotEmpty);
    },
  );

  final malformed = <Object?>[
    null,
    [],
    {'reply': 3},
    {'reply': 'Hello', 'products': 'wrong type'},
    {'reply': '', 'products': []},
    {
      'products': [null],
    },
    {
      'products': [
        {...chatProductJson('greens'), 'priceCents': 'unknown'},
      ],
    },
    {
      'products': [
        {...chatProductJson('greens'), 'priceCents': 1.5},
      ],
    },
    {
      'products': [
        {...chatProductJson('greens'), 'id': null},
      ],
    },
    {
      'products': [
        {...chatProductJson('greens'), 'inStock': 'yes'},
      ],
    },
    {
      'products': [
        {...chatProductJson('greens')}..remove('unit'),
      ],
    },
  ];
  for (var i = 0; i < malformed.length; i++) {
    test(
      'Malformed response $i is rejected before reaching the product UI',
      () async {
        final api = testChatApi((_) => malformed[i]);
        await expectLater(
          api.send(message: 'Hello'),
          throwsA(isA<FormatException>()),
        );
      },
    );
  }

  test(
    'Transport errors remain available for the page to show a retry state',
    () async {
      final api = testChatApi(
        (options) => throw DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        ),
      );
      await expectLater(
        api.send(message: 'Hello'),
        throwsA(isA<DioException>()),
      );
    },
  );
}
