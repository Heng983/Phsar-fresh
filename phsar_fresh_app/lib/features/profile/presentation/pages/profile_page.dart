import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/app_version_provider.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/currency/app_currency.dart';
import 'package:phsar_fresh_app/core/currency/currency_provider.dart';
import 'package:phsar_fresh_app/core/localization/locale_provider.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/navigation/app_routes.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/core/widgets/app_snack_bar.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/catalog/presentation/providers/product_favorites_provider.dart';
import 'package:phsar_fresh_app/features/checkout/domain/model/checkout_preferences.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/providers/checkout_provider.dart';
import 'package:phsar_fresh_app/features/checkout/presentation/widgets/checkout_address_sheet.dart';
import 'package:phsar_fresh_app/features/location/presentation/providers/delivery_location_provider.dart';
import 'package:phsar_fresh_app/features/location/presentation/widgets/address_details_fields.dart';
import 'package:phsar_fresh_app/features/market/presentation/widgets/market_header.dart';
import 'package:phsar_fresh_app/features/orders/presentation/providers/orders_provider.dart';
import 'package:phsar_fresh_app/features/orders/presentation/widgets/orders_help_sheet.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_components.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_edit_sheet.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_sheets.dart';

class ProfilePage extends ConsumerStatefulWidget {
  const ProfilePage({
    super.key,
    required this.onViewOrders,
    required this.onExplore,
    this.showMarketHeader = true,
  });
  final VoidCallback onViewOrders;
  final VoidCallback onExplore;
  final bool showMarketHeader;

  @override
  ConsumerState<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends ConsumerState<ProfilePage> {
  bool _isSigningOut = false;

  Future<void> _signOut() async {
    if (_isSigningOut) return;
    setState(() => _isSigningOut = true);
    try {
      await ref.read(authRepositoryProvider).signOut();
      if (!mounted) return;
      Navigator.of(context).pushNamedAndRemoveUntil('/', (_) => false);
    } catch (_) {
      if (!mounted) return;
      AppSnackBar.show(context, message: context.l10n.authConnectionError);
    } finally {
      if (mounted) setState(() => _isSigningOut = false);
    }
  }

  Future<void> _editProfile(String name) async {
    final saved = await ProfileEditSheet.show(context, name);
    if (mounted && saved == true) {
      AppSnackBar.show(
        context,
        message: context.l10n.profileSaved,
        tone: AppSnackBarTone.success,
      );
    }
  }

  void _favorites() => showProfileSheet(
    context,
    ProfileFavoritesSheet(onExplore: widget.onExplore),
  );

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final locale = ref.watch(localeProvider);
    final currency = ref.watch(currencyProvider);
    final user = ref.watch(authSessionProvider).value?.user;
    final guest = user == null;
    final name = user?.displayName.trim() ?? '';
    final phone = user?.phone?.trim() ?? '';
    final hasPhone = phone.isNotEmpty;
    final orders = ref
        .watch(marketOrdersProvider)
        .where((order) => !order.isDemo)
        .length;
    final favorites = ref.watch(productFavoritesProvider).length;
    final delivery = ref.watch(checkoutProvider);
    final location = ref.watch(deliveryLocationProvider);
    final addressSummary = [
      location.addressName(l10n),
      location.fullAddress,
    ].whereType<String>().join(' · ');
    final payment = switch (delivery.payment) {
      CheckoutPayment.abaPay => l10n.checkoutAbaPay,
      CheckoutPayment.card => l10n.checkoutCard,
      CheckoutPayment.cash => l10n.checkoutCash,
    };
    return SingleChildScrollView(
      key: const PageStorageKey('market-profile-scroll'),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          if (widget.showMarketHeader) const MarketHeader(),
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 30),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                ProfileHero(
                  name: guest
                      ? l10n.marketGuest
                      : name.isEmpty
                      ? l10n.profileCustomer
                      : name,
                  subtitle: guest
                      ? l10n.marketGuestDescription
                      : hasPhone
                      ? formatPhoneForDisplay(phone)
                      : l10n.authAccountDescription,
                  subtitleIcon: !guest && hasPhone
                      ? Icons.phone_iphone_rounded
                      : null,
                  badge: guest
                      ? l10n.profileGuestBadge
                      : l10n.profileMemberBadge,
                  initial: !guest && name.isNotEmpty
                      ? name.characters.first.toUpperCase()
                      : null,
                  editLabel: l10n.profileEdit,
                  onEdit: guest ? null : () => _editProfile(name),
                ),
                if (!guest) ...[
                  const SizedBox(height: 20),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: ProfileStat(
                          key: const Key('profile-orders'),
                          icon: Icons.shopping_bag_outlined,
                          color: AppTints.sky.ink,
                          background: AppTints.sky.soft,
                          value: '$orders',
                          label: l10n.profileOrdersMade,
                          onTap: widget.onViewOrders,
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: ProfileStat(
                          key: const Key('profile-favorite-count'),
                          icon: Icons.favorite_border_rounded,
                          value: '$favorites',
                          label: l10n.profileSavedFavorites,
                          color: AppTints.chili.ink,
                          background: AppTints.chili.soft,
                          onTap: _favorites,
                        ),
                      ),
                    ],
                  ),
                  ProfileSection(
                    title: l10n.profileCommunity,
                    children: [
                      ProfileMenuTile(
                        key: const Key('profile-favorites'),
                        icon: Icons.favorite_border_rounded,
                        color: AppTints.chili.ink,
                        background: AppTints.chili.soft,
                        title: l10n.profileFavorites,
                        subtitle: l10n.profileFavoritesHint,
                        onTap: _favorites,
                      ),
                      ProfileMenuTile(
                        key: const Key('profile-address'),
                        icon: Icons.location_on_outlined,
                        background: AppTints.sky.soft,
                        color: AppTints.sky.ink,
                        title: l10n.profileDelivery,
                        subtitle: delivery.recipient.isEmpty
                            ? location.hasDetails
                                  ? addressSummary
                                  : l10n.profileDeliveryHint
                            : '${delivery.recipient} · $addressSummary',
                        onTap: () => CheckoutAddressSheet.show(context),
                      ),
                      ProfileMenuTile(
                        key: const Key('profile-payment'),
                        icon: Icons.account_balance_wallet_outlined,
                        background: AppTints.mango.soft,
                        color: AppTints.mango.ink,
                        title: l10n.profilePayment,
                        subtitle: payment,
                        onTap: () => showProfileSheet(
                          context,
                          const ProfilePaymentSheet(),
                        ),
                      ),
                    ],
                  ),
                ],
                ProfileSection(
                  title: l10n.profilePreferences,
                  children: [
                    _PreferenceGroup(
                      icon: Icons.translate_rounded,
                      tint: AppTints.eggplant,
                      title: l10n.marketLanguage,
                      subtitle: l10n.profileLanguageHint,
                      children: [
                        _choice(
                          key: const Key('profile-language-en'),
                          label: 'English',
                          selected: locale.languageCode == 'en',
                          onSelected: () =>
                              ref.read(localeProvider.notifier).setEnglish(),
                        ),
                        _choice(
                          key: const Key('profile-language-km'),
                          label: 'ភាសាខ្មែរ',
                          selected: locale.languageCode == 'km',
                          onSelected: () =>
                              ref.read(localeProvider.notifier).setKhmer(),
                        ),
                      ],
                    ),
                    _PreferenceGroup(
                      icon: Icons.currency_exchange_rounded,
                      tint: AppTints.lime,
                      title: l10n.marketCurrency,
                      subtitle: l10n.currencyExchangeRate,
                      children: [
                        _choice(
                          key: const Key('currency-usd'),
                          label: l10n.currencyUsd,
                          selected: currency == AppCurrency.usd,
                          onSelected: () => ref
                              .read(currencyProvider.notifier)
                              .select(AppCurrency.usd),
                        ),
                        _choice(
                          key: const Key('currency-khr'),
                          label: l10n.currencyKhr,
                          selected: currency == AppCurrency.khr,
                          onSelected: () => ref
                              .read(currencyProvider.notifier)
                              .select(AppCurrency.khr),
                        ),
                      ],
                    ),
                  ],
                ),
                ProfileSection(
                  title: l10n.profileSupport,
                  children: [
                    ProfileMenuTile(
                      key: const Key('profile-help'),
                      icon: Icons.support_agent_rounded,
                      color: AppTints.sky.ink,
                      background: AppTints.sky.soft,
                      title: l10n.profileHelp,
                      subtitle: l10n.profileHelpHint,
                      onTap: () => OrdersHelpSheet.show(context),
                    ),
                    ProfileMenuTile(
                      key: const Key('profile-sourcing'),
                      icon: Icons.eco_outlined,
                      background: AppTints.leaf.soft,
                      color: AppTints.leaf.ink,
                      title: l10n.profileSourcing,
                      subtitle: l10n.profileSourcingHint,
                      onTap: () => showProfileSheet(
                        context,
                        ProfileInfoSheet(
                          icon: Icons.eco_outlined,
                          title: l10n.profileSourcing,
                          body: l10n.profileSourcingBody,
                        ),
                      ),
                    ),
                    ProfileMenuTile(
                      key: const Key('profile-privacy'),
                      icon: Icons.shield_outlined,
                      background: AppTints.husk.soft,
                      color: AppTints.husk.ink,
                      title: l10n.profilePrivacy,
                      subtitle: l10n.profilePrivacyHint,
                      onTap: () => showProfileSheet(
                        context,
                        ProfileInfoSheet(
                          icon: Icons.shield_outlined,
                          title: l10n.profilePrivacy,
                          body: l10n.profilePrivacyBody,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 28),
                if (guest)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: Text(
                      l10n.profileGuestCta,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppFontSize.caption,
                      ),
                    ),
                  ),
                FilledButton.icon(
                  key: Key(guest ? 'profile-sign-in' : 'profile-sign-out'),
                  onPressed: _isSigningOut
                      ? null
                      : guest
                      ? () => Navigator.pushNamed(context, AppRoutes.login)
                      : _signOut,
                  style: FilledButton.styleFrom(
                    backgroundColor: guest
                        ? AppColors.primary
                        : const Color(0xFFFFE2DF),
                    foregroundColor: guest
                        ? Colors.white
                        : const Color(0xFFB62220),
                    disabledBackgroundColor: const Color(0xFFF3E7E5),
                    padding: const EdgeInsets.symmetric(
                      vertical: 17,
                      horizontal: 20,
                    ),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(14),
                    ),
                  ),
                  icon: _isSigningOut
                      ? const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : Icon(
                          guest ? Icons.login_rounded : Icons.logout_rounded,
                          size: 20,
                        ),
                  label: Text(
                    guest ? l10n.signIn : l10n.authSignOut,
                    style: const TextStyle(
                      fontSize: AppFontSize.bodySmall,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                const SizedBox(height: 24),
                // Read from the installed app, so it always matches the
                // version in pubspec.yaml.
                if (ref.watch(appVersionProvider).value
                    case final version?) ...[
                  Text(
                    l10n.profileVersion(version),
                    key: const Key('profile-version'),
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppFontSize.badge,
                      fontWeight: FontWeight.w600,
                      color: AppColors.textSecondary,
                      height: 1.6,
                    ),
                  ),
                  const SizedBox(height: 6),
                ],
                Text(
                  l10n.profileFooter,
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    fontSize: AppFontSize.badge,
                    color: AppColors.textSecondary,
                    height: 1.6,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _choice({
    required Key key,
    required String label,
    required bool selected,
    required VoidCallback onSelected,
  }) => ChoiceChip(
    key: key,
    label: Text(label),
    selected: selected,
    showCheckmark: false,
    selectedColor: AppColors.primaryDark,
    backgroundColor: AppColors.inputBackground,
    labelStyle: TextStyle(
      color: selected ? Colors.white : AppColors.textSecondary,
      fontSize: AppFontSize.caption,
      fontWeight: FontWeight.w600,
    ),
    shape: const StadiumBorder(side: BorderSide.none),
    side: BorderSide.none,
    onSelected: (_) => onSelected(),
  );
}

class _PreferenceGroup extends StatelessWidget {
  const _PreferenceGroup({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.children,
    this.tint = AppTints.leaf,
  });
  final AppTint tint;
  final IconData icon;
  final String title;
  final String subtitle;
  final List<Widget> children;

  @override
  Widget build(BuildContext context) => Padding(
    padding: const EdgeInsets.all(18),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Row(
          children: [
            ProfileIcon(icon: icon, background: tint.soft, color: tint.ink),
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
                      height: 1.4,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      fontSize: AppFontSize.caption,
                      height: 1.5,
                      color: AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 12),
        Wrap(spacing: 8, runSpacing: 6, children: children),
      ],
    ),
  );
}
