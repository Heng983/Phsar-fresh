import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/market/presentation/pages/market_page.dart';
import 'package:phsar_fresh_app/features/onboarding/presentation/pages/onboarding_page.dart';

class AuthLandingPage extends ConsumerWidget {
  const AuthLandingPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return ref
        .watch(authSessionProvider)
        .when(
          skipError: true,
          data: (session) => session == null
              ? const OnboardingPage()
              // A signed-in restart always opens on Explore.
              : const MarketPage(initiallyExplore: true),
          loading: () =>
              const Scaffold(body: Center(child: CircularProgressIndicator())),
          error: (_, _) => const OnboardingPage(),
        );
  }
}
