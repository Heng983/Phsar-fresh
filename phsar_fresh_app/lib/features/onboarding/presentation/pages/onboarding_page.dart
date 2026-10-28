import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/navigation/app_routes.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/onboarding/domain/model/feature_item.dart';
import 'package:phsar_fresh_app/features/onboarding/presentation/widgets/app_header.dart';
import 'package:phsar_fresh_app/features/onboarding/presentation/widgets/feature_card.dart';
import 'package:phsar_fresh_app/features/onboarding/presentation/widgets/hero_banner.dart';
import 'package:phsar_fresh_app/features/onboarding/presentation/widgets/primary_button.dart';

class OnboardingPage extends StatelessWidget {
  const OnboardingPage({super.key});

  @override
  Widget build(BuildContext context) {
    final features = [
      FeatureItem(
        icon: Icons.verified,
        title: context.l10n.organicTitle,
        description: context.l10n.organicDescription,
        iconBackgroundColor: AppColors.lightGreen,
        iconColor: AppColors.primary,
        badge: context.l10n.gapBadge,
        badgeColor: const Color(0xFF1D8B47),
      ),
      FeatureItem(
        icon: Icons.delivery_dining,
        title: context.l10n.deliveryTitle,
        description: context.l10n.deliveryDescription,
        iconBackgroundColor: AppColors.lightOrange,
        iconColor: AppColors.orange,
        badge: context.l10n.deliveryTime,
        badgeColor: AppColors.orange,
      ),

      FeatureItem(
        icon: Icons.handshake_outlined,
        title: context.l10n.fairTradeTitle,
        description: context.l10n.fairTradeDescription,
        iconBackgroundColor: const Color(0xFFDDF1EA),
        iconColor: const Color(0xFF00785E),
      ),
    ];
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          physics: const BouncingScrollPhysics(),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                const AppHeader(),
                const SizedBox(height: 24),
                const HeroBanner(),
                const SizedBox(height: 34),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(
                        text: context.l10n.mainTitle,
                        style: const TextStyle(color: AppColors.primary),
                      ),
                      const TextSpan(text: ' —'),
                    ],
                  ),
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppFontSize.hero,
                    fontWeight: FontWeight.bold,
                    height: context.lineHeight(1.1),
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  context.l10n.mainSubtitle,
                  style: TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppFontSize.hero,
                    fontWeight: FontWeight.bold,
                    height: context.lineHeight(1.15),
                  ),
                ),
                const SizedBox(height: 18),
                Text(
                  context.l10n.khmerTagline,
                  style: const TextStyle(
                    color: AppColors.primary,
                    fontSize: AppFontSize.body,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 14),
                Text(
                  context.l10n.mainDescription,
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    fontSize: AppFontSize.title,
                    height: 1.6,
                  ),
                ),
                const SizedBox(height: 28),
                ...features.map(
                  (feature) => Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: FeatureCard(item: feature),
                  ),
                ),
                const SizedBox(height: 8),
                PrimaryButton(
                  title: context.l10n.getStarted,
                  onPressed: () {
                    Navigator.pushNamed(context, AppRoutes.explore);
                  },
                ),
                const SizedBox(height: 28),
                Center(
                  child: Wrap(
                    alignment: WrapAlignment.center,
                    crossAxisAlignment: WrapCrossAlignment.center,
                    children: [
                      Text(
                        '${context.l10n.alreadyAccount} ',
                        style: const TextStyle(
                          color: AppColors.textSecondary,
                          fontSize: AppFontSize.price,
                        ),
                      ),
                      GestureDetector(
                        onTap: () {
                          Navigator.pushNamed(context, AppRoutes.login);
                        },
                        child: Text(
                          context.l10n.signIn,
                          style: const TextStyle(
                            color: AppColors.primary,
                            fontSize: AppFontSize.price,
                            fontWeight: FontWeight.bold,
                            decoration: TextDecoration.underline,
                            decorationColor: AppColors.primary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                Center(
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      const Icon(
                        Icons.grass,
                        size: 20,
                        color: Color(0xFF7C8977),
                      ),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          context.l10n.farmFooter,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: Color(0xFF7C8977),
                            fontWeight: FontWeight.w600,
                            fontSize: AppFontSize.bodySmall,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 30),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
