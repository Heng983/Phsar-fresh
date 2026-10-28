import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_avatar.dart';

class ProfileSurface extends StatelessWidget {
  const ProfileSurface({
    super.key,
    required this.child,
    this.padding = EdgeInsets.zero,
  });
  final Widget child;
  final EdgeInsetsGeometry padding;

  @override
  Widget build(BuildContext context) => Container(
    clipBehavior: Clip.antiAlias,
    decoration: AppDecorations.card(),
    child: Padding(padding: padding, child: child),
  );
}

class ProfileSection extends StatelessWidget {
  const ProfileSection({
    super.key,
    required this.title,
    required this.children,
  });
  final String title;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.only(top: 28),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Padding(
          padding: const EdgeInsets.only(left: 6, bottom: 12),
          child: Text(
            title,
            style: const TextStyle(
              fontSize: AppFontSize.footnote,
              fontWeight: FontWeight.w600,
              color: AppColors.textSecondary,
              height: 1.5,
            ),
          ),
        ),
        ProfileSurface(
          child: Column(
            children: [
              for (var i = 0; i < children.length; i++) ...[
                if (i > 0)
                  const Padding(
                    padding: EdgeInsets.symmetric(horizontal: 18),
                    child: Divider(height: 1, color: AppColors.inputBackground),
                  ),
                children[i],
              ],
            ],
          ),
        ),
      ],
    ),
  );
}

class ProfileIcon extends StatelessWidget {
  const ProfileIcon({
    super.key,
    required this.icon,
    this.color = AppColors.primary,
    this.background = AppColors.mint,
  });
  final IconData icon;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Container(
    width: 44,
    height: 44,
    decoration: BoxDecoration(color: background, shape: BoxShape.circle),
    child: Icon(icon, size: 23, color: color),
  );
}

class ProfileMenuTile extends StatelessWidget {
  const ProfileMenuTile({
    super.key,
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
    this.color = AppColors.primary,
    this.background = AppColors.mint,
  });
  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => Material(
    color: Colors.transparent,
    child: InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        child: Row(
          children: [
            ProfileIcon(icon: icon, color: color, background: background),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontSize: AppFontSize.bodySmall,
                      fontWeight: FontWeight.w600,
                      height: 1.45,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      color: AppColors.textSecondary,
                      height: 1.5,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 6),
            const Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ),
  );
}

class ProfileStat extends StatelessWidget {
  const ProfileStat({
    super.key,
    required this.icon,
    required this.value,
    required this.label,
    required this.onTap,
    this.color = AppColors.primary,
    this.background = AppColors.inputBackground,
  });
  final IconData icon;
  final String value;
  final String label;
  final VoidCallback onTap;
  final Color color;
  final Color background;

  @override
  Widget build(BuildContext context) => ProfileSurface(
    child: Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 18),
          child: Column(
            children: [
              ProfileIcon(icon: icon, color: color, background: background),
              const SizedBox(height: 10),
              Text(
                value,
                style: TextStyle(
                  fontSize: AppFontSize.headlineLarge,
                  fontWeight: FontWeight.w700,
                  height: context.lineHeight(1.2),
                ),
              ),
              const SizedBox(height: 5),
              Text(
                label,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  color: AppColors.textSecondary,
                  height: 1.5,
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}

/// "+85512567802" → "+855 12 567 802", like the phone hint at sign-in.
/// Anything that is not a Cambodian number is shown as given.
String formatPhoneForDisplay(String phone) {
  final digits = phone.replaceAll(RegExp(r'\D'), '');
  final match = RegExp(r'^855(\d{2})(\d{3})(\d{3,4})$').firstMatch(digits);
  if (match == null) return phone;
  return '+855 ${match[1]} ${match[2]} ${match[3]}';
}

/// Who is signed in: photo, name, contact line and a small community badge,
/// with the edit button beside them rather than on top of the photo.
class ProfileHero extends StatelessWidget {
  const ProfileHero({
    super.key,
    required this.name,
    required this.subtitle,
    required this.badge,
    required this.editLabel,
    this.subtitleIcon,
    this.initial,
    this.onEdit,
  });
  final String name;
  final String subtitle;
  final String badge;
  final String editLabel;

  /// Shown before [subtitle], e.g. a phone icon before the number.
  final IconData? subtitleIcon;
  final String? initial;
  final VoidCallback? onEdit;

  @override
  Widget build(BuildContext context) {
    // Measured at a real size: Khmer's minimum-size scaler would make
    // scale(1) look like very large text and force the stacked layout.
    final textScale =
        MediaQuery.textScalerOf(context).scale(AppFontSize.bodySmall) /
        AppFontSize.bodySmall;
    final edit = onEdit == null
        ? null
        : IconButton.filledTonal(
            key: const Key('profile-edit'),
            tooltip: editLabel,
            onPressed: onEdit,
            style: IconButton.styleFrom(
              backgroundColor: Colors.white.withValues(alpha: .18),
              foregroundColor: Colors.white,
              minimumSize: const Size(44, 44),
            ),
            icon: const Icon(Icons.edit_outlined, size: 20),
          );
    Widget details({required bool inlineEdit}) => Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.only(top: 6),
                child: Text(
                  name,
                  key: const Key('profile-name'),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: AppFontSize.headline,
                    height: context.lineHeight(1.25),
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
            // Only the name shares its line with the edit button, so the
            // phone number and badge get the full width.
            if (edit != null && inlineEdit) ...[const SizedBox(width: 8), edit],
          ],
        ),
        const SizedBox(height: 4),
        Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            if (subtitleIcon != null) ...[
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Icon(
                  subtitleIcon,
                  size: 16,
                  color: AppColors.lightGreen,
                ),
              ),
              const SizedBox(width: 5),
            ],
            Expanded(
              child: Text(
                subtitle,
                style: TextStyle(
                  fontSize: AppFontSize.bodySmall,
                  height: context.lineHeight(1.4),
                  color: AppColors.lightGreen,
                  fontFeatures: appFontFeatures,
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 10),
        Container(
          padding: const EdgeInsets.fromLTRB(8, 4, 10, 4),
          decoration: BoxDecoration(
            color: Colors.white.withValues(alpha: .16),
            borderRadius: BorderRadius.circular(20),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.spa_outlined, color: Colors.white, size: 14),
              const SizedBox(width: 5),
              Flexible(
                child: Text(
                  badge,
                  style: TextStyle(
                    fontSize: AppFontSize.caption,
                    height: context.lineHeight(1.35),
                    color: Colors.white,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
            ],
          ),
        ),
      ],
    );
    // A banana-leaf member card: the one deep-green surface on the page.
    return Container(
      clipBehavior: Clip.antiAlias,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(AppRadius.xl),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF0B8A43), AppColors.primaryDark],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.primaryDark.withValues(alpha: .18),
            blurRadius: 22,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Stack(
        children: [
          Positioned(
            right: -26,
            bottom: -34,
            child: Transform.rotate(
              angle: -.5,
              child: Icon(
                Icons.eco,
                size: 150,
                color: Colors.white.withValues(alpha: .07),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(18),
            child: LayoutBuilder(
              builder: (context, constraints) {
                final photo = ProfileAvatar(initial: initial, size: 72);
                // Narrow screens and large text: photo and edit on top, details
                // below, so the name keeps the full width.
                if (constraints.maxWidth < 300 || textScale > 1.3) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(children: [photo, const Spacer(), ?edit]),
                      const SizedBox(height: 14),
                      details(inlineEdit: false),
                    ],
                  );
                }
                return Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    photo,
                    const SizedBox(width: 14),
                    Expanded(child: details(inlineEdit: true)),
                  ],
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
