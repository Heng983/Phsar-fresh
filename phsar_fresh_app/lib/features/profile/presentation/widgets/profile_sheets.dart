import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/models/catalog_content.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/pages/product_detail_page.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/product_favorites_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/widgets/market_image.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_payment_section.dart';

Future<void> showProfileSheet(BuildContext context, Widget child) =>
    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      useSafeArea: true,
      backgroundColor: Colors.white,
      builder: (_) => SafeArea(
        top: false,
        child: SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            20,
            8,
            20,
            MediaQuery.viewInsetsOf(context).bottom + 24,
          ),
          child: child,
        ),
      ),
    );

class ProfileInfoSheet extends StatelessWidget {
  const ProfileInfoSheet({
    super.key,
    required this.icon,
    required this.title,
    required this.body,
  });
  final IconData icon;
  final String title;
  final String body;

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Align(
        alignment: Alignment.centerLeft,
        child: CircleAvatar(
          backgroundColor: AppColors.mint,
          child: Icon(icon, color: AppColors.primary),
        ),
      ),
      const SizedBox(height: 16),
      Text(
        title,
        style: const TextStyle(
          fontSize: AppFontSize.headlineLarge,
          fontWeight: FontWeight.w700,
          height: 1.4,
        ),
      ),
      const SizedBox(height: 12),
      Text(
        body,
        style: const TextStyle(
          color: AppColors.textSecondary,
          height: 1.7,
          fontSize: AppFontSize.bodySmall,
        ),
      ),
      const SizedBox(height: 24),
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.marketClose),
      ),
    ],
  );
}

class ProfilePaymentSheet extends StatelessWidget {
  const ProfilePaymentSheet({super.key});

  @override
  Widget build(BuildContext context) => Column(
    crossAxisAlignment: CrossAxisAlignment.stretch,
    children: [
      Text(
        context.l10n.profilePayment,
        style: const TextStyle(
          fontSize: AppFontSize.headlineLarge,
          fontWeight: FontWeight.w700,
        ),
      ),
      const SizedBox(height: 10),
      Text(
        context.l10n.profilePaymentHint,
        style: const TextStyle(
          color: AppColors.textSecondary,
          height: 1.6,
          fontSize: AppFontSize.footnote,
        ),
      ),
      const SizedBox(height: 22),
      const CheckoutPaymentSection(),
      const SizedBox(height: 16),
      FilledButton(
        onPressed: () => Navigator.pop(context),
        child: Text(context.l10n.marketClose),
      ),
    ],
  );
}

class ProfileFavoritesSheet extends ConsumerWidget {
  const ProfileFavoritesSheet({super.key, this.onExplore});
  final VoidCallback? onExplore;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final favorites = ref.watch(productFavoritesProvider);
    final products = favorites.values.toList();
    final currency = ref.watch(currencyProvider);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.profileFavorites,
          style: const TextStyle(
            fontSize: AppFontSize.headlineLarge,
            height: 1.4,
            fontWeight: FontWeight.w700,
          ),
        ),
        const SizedBox(height: 18),
        if (products.isEmpty) ...[
          const Padding(
            padding: EdgeInsets.all(16),
            child: Icon(
              Icons.favorite_border_rounded,
              color: AppColors.primary,
              size: 42,
            ),
          ),
          Text(
            l10n.profileFavoritesEmpty,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppFontSize.title,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            l10n.profileFavoritesEmptyHint,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSize.footnote,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 22),
          if (onExplore != null)
            FilledButton(
              key: const Key('profile-explore-favorites'),
              onPressed: () {
                Navigator.pop(context);
                onExplore!();
              },
              child: Text(l10n.profileExplore),
            ),
        ] else ...[
          for (final product in products)
            ListTile(
              key: ValueKey('profile-favorite-${product.id}'),
              contentPadding: const EdgeInsets.symmetric(vertical: 6),
              leading: ClipRRect(
                borderRadius: BorderRadius.circular(12),
                child: SizedBox(
                  width: 52,
                  height: 52,
                  child: MarketImage(path: product.imageUrl),
                ),
              ),
              title: Text(
                product.title(l10n),
                style: const TextStyle(
                  fontSize: AppFontSize.bodySmall,
                  fontWeight: FontWeight.w600,
                ),
              ),
              subtitle: Text(
                currency.format(product.priceInCents, l10n.localeName),
                style: const TextStyle(color: AppColors.primary),
              ),
              trailing: IconButton(
                key: ValueKey('profile-remove-${product.id}'),
                tooltip: l10n.profileRemoveFavorite,
                onPressed: () => ref
                    .read(productFavoritesProvider.notifier)
                    .remove(product.id),
                icon: const Icon(
                  Icons.favorite_rounded,
                  color: AppColors.primary,
                ),
              ),
              onTap: () => ProductDetailPage.open(context, product),
            ),
          const SizedBox(height: 16),
          FilledButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.marketClose),
          ),
        ],
      ],
    );
  }
}
