import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/widgets/app_logo.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/profile/presentation/providers/profile_photo_provider.dart';
import 'package:skeletonizer/skeletonizer.dart';

class ProfileAvatar extends ConsumerWidget {
  const ProfileAvatar({
    super.key,
    this.initial,
    this.size = 82,
    this.preview,
    this.showDefault = false,
  });
  final String? initial;
  final double size;
  final Uint8List? preview;
  final bool showDefault;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(authSessionProvider).value?.user;
    final isGuest = user == null;
    final photoState = ref.watch(profilePhotoUrlProvider);
    // Do not reuse a previous account's URL while a new one is loading.
    final url = photoState.isLoading || photoState.hasError
        ? null
        : photoState.value;
    final fallback = ColoredBox(
      color: const Color(0xFFF2F8F1),
      child: Center(
        child: isGuest
            ? Icon(
                Icons.person_outline_rounded,
                key: const Key('profile-guest-avatar-icon'),
                size: size * .5,
                color: AppColors.primaryDark,
              )
            : initial == null
            ? AppLogo(size: size * .65, excludeFromSemantics: true)
            : Text(
                initial!,
                style: TextStyle(
                  fontSize: size * .4,
                  fontWeight: FontWeight.w700,
                  color: AppColors.primaryDark,
                ),
              ),
      ),
    );
    // A shimmering circle while the saved photo is on its way, instead of
    // the initial briefly showing before the photo.
    final loadingPhoto = Skeletonizer(
      key: const Key('profile-photo-loading'),
      child: fallback,
    );
    final waitingForUrl =
        !isGuest && preview == null && !showDefault && photoState.isLoading;
    return Semantics(
      label: context.l10n.profilePhoto,
      image: true,
      child: Container(
        width: size,
        height: size,
        padding: const EdgeInsets.all(4),
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withValues(alpha: .8),
          border: Border.all(color: const Color(0xFFD8EDE0), width: 1),
        ),
        child: ClipOval(
          child: isGuest
              ? fallback
              : waitingForUrl
              ? loadingPhoto
              : preview != null
              ? Image.memory(
                  preview!,
                  key: const Key('profile-photo-preview'),
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                )
              : !showDefault && url != null
              ? Image.network(
                  url,
                  key: const Key('profile-photo-image'),
                  fit: BoxFit.cover,
                  excludeFromSemantics: true,
                  errorBuilder: (_, _, _) => fallback,
                  loadingBuilder: (_, child, progress) =>
                      progress == null ? child : loadingPhoto,
                )
              : fallback,
        ),
      ),
    );
  }
}
