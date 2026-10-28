import 'dart:async';

import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/features/cart/presentation/providers/cart_provider.dart';
import 'package:phsar_fresh_app/features/chat/data/chat_api.dart';
import 'package:phsar_fresh_app/features/chat/domain/model/chat_message.dart';
import 'package:phsar_fresh_app/features/chat/presentation/pages/ai_chat_page.dart';
import 'package:phsar_fresh_app/features/chat/presentation/providers/ai_chat_provider.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_bot_avatar.dart';
import 'package:phsar_fresh_app/features/chat/presentation/widgets/chat_welcome.dart';
import 'package:phsar_fresh_app/features/profile/presentation/pages/profile_page.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import '../../support/chat_test_api.dart';
import '../../support/pump_helpers.dart';

final chatInput = find.byKey(const Key('chat-message-input'));
final chatSend = find.byKey(const Key('chat-send'));

Future<void> openChat(WidgetTester tester) async {
  await tester.tap(find.byKey(const Key('market-tab-chat')));
  await tester.pumpAndSettle();
}

ProviderContainer chatContainer(WidgetTester tester) =>
    ProviderScope.containerOf(tester.element(find.byType(AiChatPage)));

Future<void> sendText(WidgetTester tester, String text) async {
  await tester.enterText(chatInput, text);
  await tester.testTextInput.receiveAction(TextInputAction.send);
  await tester.pumpAndSettle();
}

void main() {
  testWidgets('Ming Sros portrait loads from the bundled asset', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: AppTheme.lightTheme,
        home: const Scaffold(body: ChatBotAvatar(size: 72)),
      ),
    );
    final portrait = find.byKey(const Key('ming-sros-avatar'));
    final provider = tester.widget<Image>(portrait).image;
    Object? imageError;
    await tester.runAsync(
      () => precacheImage(
        provider,
        tester.element(portrait),
        onError: (error, _) => imageError = error,
      ),
    );
    await tester.pumpAndSettle();
    expect(imageError, isNull);
    final image = tester.widget<RawImage>(
      find.descendant(of: portrait, matching: find.byType(RawImage)),
    );
    expect(image.image, isNotNull);
    expect(find.byIcon(Icons.person_rounded), findsNothing);
    expect(tester.takeException(), isNull);
  });

  for (final language in ['en', 'km']) {
    testWidgets('Offline demo supports meals, cart, and recipes in $language', (
      tester,
    ) async {
      final requests = <RequestOptions>[];
      await pumpMarket(
        tester,
        language: language,
        width: 320,
        scale: 1.5,
        demoChat: true,
        chatApi: testChatApi(
          (_) => {'reply': 'Unexpected live reply'},
          requests: requests,
        ),
      );
      await openChat(tester);
      final context = tester.element(find.byType(AiChatPage));
      final l10n = AppLocalizations.of(context)!;
      final container = chatContainer(tester);
      expect(find.text(l10n.chatDemoNotice), findsOneWidget);
      await sendText(tester, language == 'km' ? 'សួស្តី' : 'Hello');
      expect(
        container.read(aiChatProvider).messages.last.text,
        l10n.chatDemoGreeting,
      );
      await sendText(tester, l10n.chatMealsPrompt);
      final meal = container.read(aiChatProvider).messages.last;
      expect(meal.text, l10n.chatDemoMealReply);
      expect(meal.products.map((product) => product.id), [
        'rice',
        'greens',
        'eggs',
      ]);
      final before = container.read(marketCartCountProvider);
      final addRice = find.byKey(const Key('chat-add-rice'));
      await tester.ensureVisible(addRice);
      await tester.pumpAndSettle();
      await tester.tap(addRice);
      await tester.pumpAndSettle();
      expect(container.read(marketCartCountProvider), before + 1);
      tester.view.viewInsets = const FakeViewPadding(bottom: 300);
      addTearDown(tester.view.resetViewInsets);
      await sendText(
        tester,
        language == 'km'
            ? 'ប្រាប់របៀបធ្វើម្ហូបផង'
            : 'Can you show a recipe too?',
      );
      expect(
        container.read(aiChatProvider).messages.last.text,
        l10n.chatDemoRecipeReply,
      );
      expect(tester.getBottomLeft(chatInput).dy, lessThanOrEqualTo(512));
      await sendText(tester, 'Something outside the demo');
      expect(
        container.read(aiChatProvider).messages.last.text,
        l10n.chatFallbackReply,
      );
      expect(container.read(aiChatProvider).error, isNull);
      expect(requests, isEmpty);
      expect(tester.takeException(), isNull);
    });
  }

  testWidgets(
    'Default demo cancels a pending sample when starting a new chat',
    (tester) async {
      await pumpMarket(tester);
      await openChat(tester);
      expect(chatContainer(tester).read(chatDemoModeProvider), isTrue);
      await tester.enterText(chatInput, 'Plan a meal');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byKey(const Key('chat-loading')), findsOneWidget);
      await tester.tap(find.byKey(const Key('chat-new-conversation')));
      await tester.pumpAndSettle();
      await tester.pump(const Duration(milliseconds: 500));
      expect(chatContainer(tester).read(aiChatProvider).messages, isEmpty);
      expect(find.byType(ChatWelcome), findsOneWidget);
      await sendText(tester, 'What ingredients do I need for beef lok lak?');
      final l10n = AppLocalizations.of(
        tester.element(find.byType(AiChatPage)),
      )!;
      expect(
        chatContainer(tester).read(aiChatProvider).messages.last.text,
        l10n.chatDemoLokLakReply,
      );
      await sendText(tester, 'Show a recipe too');
      expect(
        chatContainer(tester).read(aiChatProvider).messages.last.text,
        l10n.chatDemoLokLakRecipe,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'API conversation and unfinished message survive tabs and Profile',
    (tester) async {
      final requests = <RequestOptions>[];
      final api = testChatApi(
        (_) => {'reply': 'Try rice with greens.'},
        requests: requests,
      );
      await pumpMarket(tester, signedIn: true, chatApi: api);
      await openChat(tester);
      expect(find.byType(ChatWelcome), findsOneWidget);
      expect(tester.widget<IconButton>(chatSend).onPressed, isNull);
      await sendText(tester, '  What can I cook?  ');
      final container = chatContainer(tester);
      final sent = container.read(aiChatProvider).messages;
      expect(sent.map((message) => message.text), [
        'What can I cook?',
        'Try rice with greens.',
      ]);
      expect(requests.single.path, '/chat');
      expect(requests.single.data, {
        'message': 'What can I cook?',
        'history': <Object?>[],
      });
      expect(sent.every((message) => message.sentAt != null), isTrue);
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
      expect(find.byType(ChatBotAvatar), findsNWidgets(2));

      await tester.enterText(chatInput, 'A question for later');
      await tester.tap(find.byKey(const Key('market-tab-orders')));
      await tester.pumpAndSettle();
      await openChat(tester);
      expect(
        tester.widget<TextField>(chatInput).controller!.text,
        'A question for later',
      );
      await tester.tap(find.byKey(const Key('market-profile-avatar')));
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(container.read(aiChatProvider).messages, same(sent));
      expect(
        tester.widget<TextField>(chatInput).controller!.text,
        'A question for later',
      );
      await tester.tap(find.byKey(const Key('chat-new-conversation')));
      await tester.pumpAndSettle();
      expect(container.read(aiChatProvider).messages, isEmpty);
      expect(find.byType(ChatWelcome), findsOneWidget);
      expect(tester.widget<TextField>(chatInput).controller!.text, isEmpty);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Missing API is an unavailable state, not a fake assistant answer',
    (tester) async {
      await pumpMarket(tester, demoChat: false);
      await openChat(tester);
      await tester.enterText(chatInput, '   ');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pumpAndSettle();
      expect(chatContainer(tester).read(aiChatProvider).messages, isEmpty);
      await sendText(tester, 'Hello');
      final state = chatContainer(tester).read(aiChatProvider);
      expect(state.messages, hasLength(1));
      expect(state.messages.single.isUser, isTrue);
      expect(state.error, AiChatError.unavailable);
      expect(find.byIcon(Icons.done_all_rounded), findsNothing);
      expect(find.byKey(const Key('chat-error')), findsOneWidget);
      expect(find.byKey(const Key('chat-loading')), findsNothing);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Failed requests can retry without duplicating user text or sending errors in history',
    (tester) async {
      var fail = true;
      final requests = <RequestOptions>[];
      final api = testChatApi((options) {
        if (fail) {
          throw DioException(
            requestOptions: options,
            type: DioExceptionType.connectionError,
          );
        }
        return {'reply': 'Here is a meal idea.'};
      }, requests: requests);
      await pumpMarket(tester, chatApi: api);
      await openChat(tester);
      await sendText(tester, 'Help me plan a meal');
      final container = chatContainer(tester);
      expect(container.read(aiChatProvider).error, AiChatError.connection);
      fail = false;
      await tester.tap(find.byKey(const Key('chat-retry')));
      await tester.pumpAndSettle();
      expect(requests, hasLength(2));
      expect(requests.last.data, requests.first.data);
      expect(container.read(aiChatProvider).messages, hasLength(2));
      expect(container.read(aiChatProvider).error, isNull);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Clearing a pending conversation ignores its late reply and prevents duplicate sends',
    (tester) async {
      final pending = Completer<Object?>();
      final requests = <RequestOptions>[];
      final api = testChatApi((_) => pending.future, requests: requests);
      await pumpMarket(tester, chatApi: api);
      await openChat(tester);
      await tester.enterText(chatInput, 'Plan a meal');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump(const Duration(milliseconds: 50));
      expect(find.byKey(const Key('chat-loading')), findsOneWidget);
      expect(find.byIcon(Icons.done_all_rounded), findsNothing);
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump();
      expect(requests, hasLength(1));
      final container = chatContainer(tester);
      await tester.tap(find.byKey(const Key('chat-new-conversation')));
      await tester.pumpAndSettle();
      pending.complete({'reply': 'An old reply'});
      await tester.pumpAndSettle();
      expect(container.read(aiChatProvider).messages, isEmpty);
      expect(container.read(aiChatProvider).isLoading, isFalse);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Leaving chat while a response is pending does not update a disposed widget',
    (tester) async {
      final pending = Completer<Object?>();
      await pumpMarket(tester, chatApi: testChatApi((_) => pending.future));
      await openChat(tester);
      await tester.enterText(chatInput, 'Plan a meal');
      await tester.testTextInput.receiveAction(TextInputAction.send);
      await tester.pump(const Duration(milliseconds: 50));
      await tester.tap(find.byKey(const Key('market-tab-orders')));
      await tester.pumpAndSettle();
      pending.complete({'reply': 'Your meal idea'});
      await tester.pumpAndSettle();
      await openChat(tester);
      expect(
        chatContainer(tester).read(aiChatProvider).messages.last.text,
        'Your meal idea',
      );
      expect(find.byIcon(Icons.done_all_rounded), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets(
    'Suggested products support safe cart additions and current currency',
    (tester) async {
      await pumpMarket(tester, chatApi: testChatApi((_) => productReply()));
      await openChat(tester);
      await sendText(tester, 'What ingredients do I need?');
      final container = chatContainer(tester);
      final before = container.read(marketCartCountProvider);
      IconButton button(String id) =>
          tester.widget<IconButton>(find.byKey(Key('chat-add-$id')));
      final addGreens = find.byKey(const Key('chat-add-greens'));
      await tester.ensureVisible(addGreens);
      await tester.pumpAndSettle();
      expect(find.text('Fresh greens'), findsOneWidget);
      expect(find.text('Battambang · kg'), findsOneWidget);
      expect(button('greens').onPressed, isNotNull);
      // Any in-stock suggestion can be added; only sold-out ones cannot.
      expect(button('42').onPressed, isNotNull);
      expect(button('eggs').onPressed, isNotNull);
      expect(button('rice').onPressed, isNull);
      await tester.tap(addGreens);
      await tester.pumpAndSettle();
      expect(container.read(marketCartCountProvider), before + 1);
      // A server product joins the basket at the price shown in chat.
      final addServerProduct = find.byKey(const Key('chat-add-42'));
      await tester.ensureVisible(addServerProduct);
      await tester.pumpAndSettle();
      await tester.tap(addServerProduct);
      await tester.pumpAndSettle();
      final added = container
          .read(marketCartProvider)
          .singleWhere((item) => item.product.id == '42');
      expect(added.product.name, 'Another product');
      expect(added.priceInCents, 200);
      container.read(currencyProvider.notifier).select(AppCurrency.khr);
      await tester.pumpAndSettle();
      expect(find.text(AppCurrency.khr.format(180, 'en')), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('A recipe reply lists ingredients with Add and not-sold notes', (
    tester,
  ) async {
    final greens = (productReply()['products']! as List).first;
    await pumpMarket(
      tester,
      chatApi: testChatApi(
        (_) => {
          'reply': 'Lok lak needs beef and greens.',
          'recipe': {
            'dish': 'Beef Lok Lak',
            'servings': 2,
            'items': [
              {
                'ingredient': 'Greens',
                'quantity': '1 bunch',
                'product': greens,
              },
              {'ingredient': 'Lime', 'product': null},
            ],
          },
        },
      ),
    );
    await openChat(tester);
    await sendText(tester, 'What do I need for lok lak?');
    expect(find.text('Ingredients for Beef Lok Lak'), findsOneWidget);
    expect(find.text('For 2 people'), findsOneWidget);
    expect(find.text('Greens · 1 bunch'), findsOneWidget);
    expect(find.text('Lime'), findsOneWidget);
    expect(find.text('Not sold at Phsar Fresh'), findsOneWidget);
    final add = find.byKey(const ValueKey('chat-add-greens'));
    await tester.ensureVisible(add);
    await tester.pumpAndSettle();
    expect(tester.widget<IconButton>(add).onPressed, isNotNull);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Khmer mode shows the Khmer product name from the server', (
    tester,
  ) async {
    await pumpMarket(
      tester,
      language: 'km',
      chatApi: testChatApi((_) => productReply()),
    );
    await openChat(tester);
    await sendText(tester, 'បន្លែ');
    expect(find.text('បន្លែស្រស់'), findsOneWidget);
    expect(find.text('Fresh greens'), findsNothing);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Sending too fast shows a friendly wait message with retry', (
    tester,
  ) async {
    var limited = true;
    final api = testChatApi((options) {
      if (limited) {
        throw DioException(
          requestOptions: options,
          type: DioExceptionType.badResponse,
          response: Response(requestOptions: options, statusCode: 429),
        );
      }
      return {'reply': 'Thanks for waiting.'};
    });
    await pumpMarket(tester, chatApi: api);
    await openChat(tester);
    await sendText(tester, 'Hello');
    final container = chatContainer(tester);
    final l10n = AppLocalizations.of(tester.element(find.byType(AiChatPage)))!;
    expect(container.read(aiChatProvider).error, AiChatError.rateLimited);
    expect(find.text(l10n.chatRateLimited), findsOneWidget);
    limited = false;
    await tester.tap(find.byKey(const Key('chat-retry')));
    await tester.pumpAndSettle();
    expect(
      container.read(aiChatProvider).messages.last.text,
      'Thanks for waiting.',
    );
    expect(tester.takeException(), isNull);
  });

  testWidgets('The composer stops at the server message limit', (tester) async {
    await pumpMarket(tester, chatApi: testChatApi((_) => {'reply': 'OK'}));
    await openChat(tester);
    await tester.enterText(chatInput, 'x' * 600);
    await tester.pump();
    expect(
      tester.widget<TextField>(chatInput).controller!.text,
      hasLength(ChatApi.maxMessageLength),
    );
  });

  testWidgets('Invalid server data shows a retry message without crashing', (
    tester,
  ) async {
    await pumpMarket(tester, chatApi: testChatApi((_) => {'reply': 42}));
    await openChat(tester);
    await sendText(tester, 'Hello');
    final state = chatContainer(tester).read(aiChatProvider);
    expect(state.error, AiChatError.invalidResponse);
    expect(state.messages, hasLength(1));
    expect(find.byKey(const Key('chat-error')), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('Disposing the whole chat cancels its pending request safely', (
    tester,
  ) async {
    final pending = Completer<Object?>();
    await pumpMarket(tester, chatApi: testChatApi((_) => pending.future));
    await openChat(tester);
    await tester.enterText(chatInput, 'Plan a meal');
    await tester.testTextInput.receiveAction(TextInputAction.send);
    await tester.pump(const Duration(milliseconds: 50));
    expect(find.byKey(const Key('chat-loading')), findsOneWidget);
    await tester.pumpWidget(const SizedBox());
    pending.complete({'reply': 'A late reply'});
    await tester.pumpAndSettle();
    expect(tester.takeException(), isNull);
  });

  testWidgets(
    'Standalone ChatScreen preserves the supplied API and cart callback',
    (tester) async {
      ChatProduct? added;
      await tester.pumpWidget(
        MaterialApp(
          theme: AppTheme.lightTheme,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          supportedLocales: AppLocalizations.supportedLocales,
          home: ChatScreen(
            api: testChatApi(
              (_) => {
                'products': [
                  chatProductJson(42, name: 'Backend rice', priceCents: 300),
                ],
              },
            ),
            onAddToCart: (product) => added = product,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await sendText(tester, 'Rice please');
      final button = find.byKey(const Key('chat-add-42'));
      await tester.ensureVisible(button);
      await tester.pumpAndSettle();
      await tester.tap(button);
      await tester.pumpAndSettle();
      expect(added?.id, '42');
      expect(tester.takeException(), isNull);
    },
  );

  for (final language in ['en', 'km']) {
    for (final layout in [
      (width: 320.0, scale: 1.5),
      (width: 375.0, scale: 1.0),
      (width: 720.0, scale: 1.0),
    ]) {
      testWidgets(
        'Chat and product suggestions fit $language at ${layout.width}px / ${layout.scale}',
        (tester) async {
          await pumpMarket(
            tester,
            language: language,
            width: layout.width,
            scale: layout.scale,
            chatApi: testChatApi((_) => productReply()),
          );
          await openChat(tester);
          final prompt = find.byKey(const Key('chat-prompt-meals'));
          await tester.ensureVisible(prompt);
          await tester.pumpAndSettle();
          await tester.tap(prompt);
          await tester.pumpAndSettle();
          final container = chatContainer(tester);
          final l10n = AppLocalizations.of(
            tester.element(find.byType(AiChatPage)),
          )!;
          expect(
            container.read(aiChatProvider).messages.first.text,
            l10n.chatMealsPrompt,
          );
          expect(tester.takeException(), isNull);
          tester.view.viewInsets = const FakeViewPadding(bottom: 300);
          addTearDown(tester.view.resetViewInsets);
          await tester.enterText(chatInput, 'Hello');
          await tester.pumpAndSettle();
          expect(tester.getBottomLeft(chatInput).dy, lessThanOrEqualTo(512));
          expect(chatSend.hitTestable(), findsOneWidget);
          await tester.tap(chatSend);
          await tester.pumpAndSettle();
          expect(container.read(aiChatProvider).messages, hasLength(4));
          expect(tester.takeException(), isNull);
          tester.view.resetViewInsets();
          FocusManager.instance.primaryFocus?.unfocus();
          await tester.pumpAndSettle();
          final addGreens = find.byKey(const Key('chat-add-greens')).last;
          await tester.ensureVisible(addGreens);
          await tester.pumpAndSettle();
          expect(addGreens.hitTestable(), findsOneWidget);
          expect(tester.takeException(), isNull);
          await tester.pumpWidget(const SizedBox());
        },
      );
    }
  }
}
