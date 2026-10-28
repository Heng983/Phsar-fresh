import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/widgets/app_logo.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_navigation_scope.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_avatar.dart';

class MarketProfileButton extends ConsumerWidget {
  const MarketProfileButton({
    super.key,
    this.size = 56,
    this.showGuestLogo = true,
  });

  final double size;
  final bool showGuestLogo;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).value?.user;
    final name = user?.displayName.trim() ?? '';
    return IconButton(
      key: Key(user == null ? 'market-guest-profile' : 'market-profile-avatar'),
      tooltip: context.l10n.marketProfile,
      onPressed: MarketNavigationScope.maybeOf(context)?.onOpenProfile,
      style: IconButton.styleFrom(
        padding: EdgeInsets.zero,
        minimumSize: Size(size, size),
        maximumSize: Size(size, size),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
        shape: const CircleBorder(),
      ),
      icon: user == null && showGuestLogo
          ? AppLogo(key: const Key('market-guest-logo'), size: size)
          : ProfileAvatar(
              key: ValueKey(user?.id),
              size: size,
              initial: name.isEmpty
                  ? null
                  : name.characters.first.toUpperCase(),
            ),
    );
  }
}
