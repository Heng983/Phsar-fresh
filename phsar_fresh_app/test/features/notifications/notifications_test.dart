import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/navigation/app_keys.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/features/market/presentation/pages/market_page.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_header.dart';
import 'package:phsar_fresh_app/features/notifications/data/notifications_repository.dart';
import 'package:phsar_fresh_app/features/notifications/domain/app_notification.dart';
import 'package:phsar_fresh_app/features/notifications/presentation/models/notification_content.dart';
import 'package:phsar_fresh_app/features/notifications/presentation/providers/notifications_provider.dart';
import 'package:phsar_fresh_app/features/notifications/presentation/widgets/notification_alerts.dart';
import 'package:phsar_fresh_app/features/orders/presentation/pages/orders_page.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import '../../support/market_test_fixtures.dart';
import '../../support/pump_helpers.dart';

class _FakeNotifications implements NotificationsRepository {
  _FakeNotifications(this.items);

  List<AppNotification> items;

  @override
  Future<List<AppNotification>> feed() async => items;
}

Map<String, dynamic> _orderJson(String id, String status, DateTime at) => {
  'id': 'order:$id',
  'type': 'ORDER',
  'at': at.toUtc().toIso8601String(),
  'order': {
    'id': 'abc123-$id',
    'code': 'PF-ABC123',
    'status': status,
    'totalCents': 700,
    'paymentMethod': 'CASH',
  },
};

AppNotification _order(String id, String status, DateTime at) =>
    AppNotification.tryParse(_orderJson(id, status, at))!;

void main() {
  test('Feed items parse; unknown ones are skipped', () {
    final at = DateTime(2026, 10, 27, 9);
    final order = _order('1', 'DELIVERING', at);
    expect(order.type, AppNotificationType.order);
    expect(order.orderUpdate, OrderUpdate.delivering);
    expect(order.orderCode, 'PF-ABC123');
    expect(order.at, at);
    expect(order.alerts, isTrue);
    expect(_order('2', 'PAID', at).alerts, isFalse);

    final promotion = AppNotification.tryParse({
      'id': 'promotion:p1',
      'type': 'PROMOTION',
      'at': at.toUtc().toIso8601String(),
      'promotion': {'id': 'p1', 'title': '30% off', 'titleKm': '៣០%'},
    })!;
    expect(promotion.type, AppNotificationType.promotion);
    expect(promotion.titleKm, '៣០%');

    expect(AppNotification.tryParse({'id': 'x', 'type': 'OTHER'}), isNull);
    expect(AppNotification.tryParse(_orderJson('3', 'UNKNOWN', at)), isNull);
  });

  test('Staff messages parse with their order and kind', () {
    final at = DateTime(2026, 10, 28, 10);
    final message = AppNotification.tryParse({
      'id': 'message:m1',
      'type': 'MESSAGE',
      'at': at.toUtc().toIso8601String(),
      'order': {'id': 'abc123-1', 'code': 'PF-ABC123'},
      'message': {'kind': 'PROBLEM', 'body': 'One item is out of stock.'},
    })!;
    expect(message.type, AppNotificationType.message);
    expect(message.messageKind, StaffMessageKind.problem);
    expect(message.orderCode, 'PF-ABC123');
    expect(message.body, 'One item is out of stock.');
    expect(message.alerts, isTrue);
    final l10n = lookupAppLocalizations(const Locale('en'));
    expect(message.heading(l10n), 'Problem with order PF-ABC123');
    expect(message.message(l10n), 'One item is out of stock.');

    expect(
      AppNotification.tryParse({
        'id': 'message:m2',
        'type': 'MESSAGE',
        'at': at.toUtc().toIso8601String(),
        'order': {'id': 'abc123-1', 'code': 'PF-ABC123'},
        'message': {'kind': 'INFO'},
      }),
      isNull,
    );
  });

  testWidgets('The bell lists updates, clears its dot and opens Orders', (
    tester,
  ) async {
    final now = DateTime.now();
    final repository = _FakeNotifications([
      _order('1', 'PREPARING', now.subtract(const Duration(minutes: 1))),
      AppNotification(
        id: 'promotion:p1',
        type: AppNotificationType.promotion,
        at: now.subtract(const Duration(hours: 2)),
        title: 'Welcome 30% off',
        body: 'Use code WELCOME',
      ),
    ]);
    setTestScreen(tester);
    await tester.pumpWidget(
      ProviderScope(
        overrides: [
          seededCartOverride,
          notificationsRepositoryProvider.overrideWithValue(repository),
        ],
        child: testApp(disableAnimations: true, home: const MarketPage()),
      ),
    );
    await tester.pumpAndSettle();
    Badge badge() => tester.widget<Badge>(
      find.descendant(
        of: find.byType(MarketHeader),
        matching: find.byType(Badge),
      ),
    );
    expect(badge().isLabelVisible, isTrue);
    expect(
      find.descendant(of: find.byType(Badge), matching: find.text('2')),
      findsOneWidget,
    );

    await tester.tap(find.byTooltip('Notifications'));
    await tester.pumpAndSettle();
    expect(find.text('Preparing your order'), findsOneWidget);
    expect(
      find.text('Order PF-ABC123 is being packed with fresh produce.'),
      findsOneWidget,
    );
    expect(find.text('Welcome 30% off'), findsOneWidget);
    expect(badge().isLabelVisible, isFalse);

    await tester.tap(find.byKey(const ValueKey('notification-order:1')));
    await tester.pumpAndSettle();
    expect(find.byType(OrdersPage), findsOneWidget);
    expect(badge().isLabelVisible, isFalse);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
  });

  testWidgets('A new order update pops up and opens the bell', (tester) async {
    final repository = _FakeNotifications([
      _order('1', 'PENDING', DateTime.now()),
    ]);
    final container = ProviderContainer(
      overrides: [
        seededCartOverride,
        notificationsRepositoryProvider.overrideWithValue(repository),
      ],
    );
    setTestScreen(tester);
    await tester.pumpWidget(
      UncontrolledProviderScope(
        container: container,
        child: MaterialApp(
          navigatorKey: appNavigatorKey,
          theme: AppTheme.lightThemeFor(isKhmer: false),
          supportedLocales: AppLocalizations.supportedLocales,
          localizationsDelegates: AppLocalizations.localizationsDelegates,
          builder: (context, child) => NotificationAlerts(child: child!),
          home: const MarketPage(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(SnackBar), findsNothing);

    repository.items = [
      _order('2', 'DELIVERING', DateTime.now()),
      ...repository.items,
    ];
    await container.read(notificationsProvider.notifier).refresh();
    await tester.pumpAndSettle();
    expect(
      find.text('Your rider is bringing order PF-ABC123.'),
      findsOneWidget,
    );

    await tester.tap(find.text('Your rider is bringing order PF-ABC123.'));
    await tester.pumpAndSettle();
    expect(find.text('On the way'), findsOneWidget);
    expect(find.text('Order placed'), findsOneWidget);
    expect(tester.takeException(), isNull);
    await tester.pumpWidget(const SizedBox());
    // Stops the 30 s poll before the test's pending-timer check.
    container.dispose();
  });
}
