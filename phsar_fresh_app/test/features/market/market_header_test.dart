import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:phsar_fresh_app/core/theme/app_theme.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/market/presentation/models/market_tab.dart';
import 'package:phsar_fresh_app/features/market/presentation/pages/market_page.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_bottom_nav.dart';
import 'package:phsar_fresh_app/features/profile/presentation/pages/profile_page.dart';
import 'package:phsar_fresh_app/generated/l10n/app_localizations.dart';

import '../../support/auth_test_repository.dart';

const firstPhoto = 'https://photos.example/profile-one.jpg';
const nextPhoto = 'https://photos.example/profile-two.jpg';
final headerAvatar = find.byKey(const Key('market-profile-avatar'));
final headerPhoto = find.descendant(
  of: headerAvatar,
  matching: find.byKey(const Key('profile-photo-image')),
);

Future<void> pumpHeaderMarket(
  WidgetTester tester,
  TestAuthRepository repository,
) async {
  tester.view.physicalSize = const Size(390, 844);
  tester.view.devicePixelRatio = 1;
  addTearDown(tester.view.resetPhysicalSize);
  addTearDown(tester.view.resetDevicePixelRatio);
  await tester.pumpWidget(
    ProviderScope(
      overrides: [authRepositoryProvider.overrideWithValue(repository)],
      child: MaterialApp(
        theme: AppTheme.lightTheme,
        supportedLocales: AppLocalizations.supportedLocales,
        localizationsDelegates: AppLocalizations.localizationsDelegates,
        home: const MarketPage(),
      ),
    ),
  );
  await tester.pumpAndSettle();
}

void main() {
  late TestAuthRepository repository;
  setUp(() {
    repository = TestAuthRepository(
      user: const AuthUser(
        id: 'test-account',
        displayName: 'Sophea',
        avatarUrl: firstPhoto,
      ),
    );
  });
  tearDown(() => repository.close());

  testWidgets('Avatar opens Profile and returns to every navigation tab', (
    tester,
  ) async {
    await pumpHeaderMarket(tester, repository);
    for (final tab in MarketTab.values) {
      await tester.tap(find.byKey(Key('market-tab-${tab.name}')));
      await tester.pumpAndSettle();
      expect(
        (tester.widget<Image>(headerPhoto).image as NetworkImage).url,
        firstPhoto,
      );
      await tester.tap(headerAvatar);
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsOneWidget);
      expect(find.byType(MarketPage, skipOffstage: false), findsOneWidget);
      expect(
        tester
            .widget<MarketBottomNav>(
              find.byType(MarketBottomNav, skipOffstage: false),
            )
            .selectedTab,
        tab,
      );
      await tester.pageBack();
      await tester.pumpAndSettle();
      expect(find.byType(ProfilePage), findsNothing);
      expect(tester.takeException(), isNull);
    }
  });

  testWidgets(
    'Header follows account photo changes, removal and account switch',
    (tester) async {
      await pumpHeaderMarket(tester, repository);
      repository.updateUser(avatarUrl: nextPhoto);
      await tester.pumpAndSettle();
      expect(
        (tester.widget<Image>(headerPhoto).image as NetworkImage).url,
        nextPhoto,
      );
      repository.updateUser(removeAvatar: true);
      await tester.pumpAndSettle();
      expect(headerPhoto, findsNothing);
      expect(
        find.descendant(of: headerAvatar, matching: find.text('S')),
        findsOneWidget,
      );
      repository.setUser(
        const AuthUser(id: 'another-account', displayName: 'Bopha'),
      );
      await tester.pumpAndSettle();
      expect(headerPhoto, findsNothing);
      expect(
        find.descendant(of: headerAvatar, matching: find.text('B')),
        findsOneWidget,
      );
      expect(tester.takeException(), isNull);
    },
  );

  testWidgets('Guest logo opens Profile without an account service', (
    tester,
  ) async {
    repository.setUser(null);
    await pumpHeaderMarket(tester, repository);
    expect(find.byKey(const Key('market-guest-logo')), findsOneWidget);
    expect(headerAvatar, findsNothing);
    await tester.tap(find.byKey(const Key('market-guest-profile')));
    await tester.pumpAndSettle();
    expect(find.byType(ProfilePage), findsOneWidget);
    expect(find.text('Welcome, Guest'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
}
