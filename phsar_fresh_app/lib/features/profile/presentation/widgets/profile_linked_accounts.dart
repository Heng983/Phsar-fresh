import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/profile/presentation/widgets/profile_components.dart';

class ProfileLinkedAccounts extends ConsumerStatefulWidget {
  const ProfileLinkedAccounts({super.key});

  @override
  ConsumerState<ProfileLinkedAccounts> createState() =>
      _ProfileLinkedAccountsState();
}

class _ProfileLinkedAccountsState extends ConsumerState<ProfileLinkedAccounts>
    with WidgetsBindingObserver {
  bool _busy = false;
  SocialProvider? _pending;
  String? _error;
  String? _message;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed &&
        _pending != null &&
        !_busy &&
        !_linked(ref.read(authSessionProvider).value?.user, _pending!)) {
      unawaited(_refresh());
    }
  }

  bool _linked(AuthUser? user, SocialProvider provider) =>
      user?.linkedProviders.contains(provider) ?? false;

  Future<void> _link(SocialProvider provider) async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _pending = null;
      _error = null;
      _message = null;
    });
    try {
      final launched = await ref
          .read(authRepositoryProvider)
          .linkAccount(provider);
      if (!mounted) return;
      setState(() {
        if (launched) {
          _pending = provider;
        } else {
          _error = context.l10n.profileLinkError;
        }
      });
    } on AuthFailure catch (error) {
      if (!mounted) return;
      setState(
        () => _error = switch (error.reason) {
          AuthFailureReason.unavailable => context.l10n.profileLinkUnavailable,
          AuthFailureReason.identityInUse => context.l10n.profileIdentityInUse,
          _ => context.l10n.profileLinkError,
        },
      );
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.profileLinkError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _refresh() async {
    if (_busy) return;
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      await ref.read(authRepositoryProvider).refreshAccount();
      if (!mounted) return;
      setState(() => _message = context.l10n.profileLinkNotComplete);
    } catch (_) {
      if (mounted) setState(() => _error = context.l10n.profileLinkError);
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (_, next) {
      if (next.hasError && _pending != null) {
        setState(() => _error = context.l10n.profileLinkError);
      }
    });
    final l10n = context.l10n;
    final user = ref.watch(authSessionProvider).value?.user;
    final pending = _pending != null && !_linked(user, _pending!);
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Text(
          l10n.profileLinkedAccounts,
          style: const TextStyle(
            fontSize: AppFontSize.bodyLarge,
            fontWeight: FontWeight.w700,
            height: 1.4,
          ),
        ),
        const SizedBox(height: 6),
        Text(
          l10n.profileLinkedAccountsHint,
          style: const TextStyle(
            color: AppColors.textSecondary,
            fontSize: AppFontSize.caption,
            height: 1.6,
          ),
        ),
        const SizedBox(height: 14),
        for (final provider in [
          SocialProvider.google,
          SocialProvider.facebook,
        ]) ...[
          ProfileSurface(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      CircleAvatar(
                        backgroundColor: AppColors.inputBackground,
                        child: provider == SocialProvider.google
                            ? Image.asset(
                                'assets/images/google_logo.png',
                                width: 24,
                                height: 24,
                                fit: BoxFit.contain,
                                excludeFromSemantics: true,
                              )
                            : const Icon(
                                Icons.facebook,
                                color: Color(0xFF1877F2),
                                size: 28,
                              ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              provider == SocialProvider.google
                                  ? 'Google'
                                  : 'Facebook',
                              style: const TextStyle(
                                fontWeight: FontWeight.w600,
                                fontSize: AppFontSize.bodySmall,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              _linked(user, provider)
                                  ? l10n.profileConnected
                                  : l10n.profileNotLinked,
                              key: ValueKey(
                                'profile-link-status-${provider.name}',
                              ),
                              style: TextStyle(
                                color: _linked(user, provider)
                                    ? AppColors.primary
                                    : AppColors.textSecondary,
                                fontSize: AppFontSize.caption,
                                height: 1.5,
                              ),
                            ),
                          ],
                        ),
                      ),
                      if (_linked(user, provider))
                        const Icon(
                          Icons.check_circle_rounded,
                          color: AppColors.primary,
                          size: 22,
                        ),
                    ],
                  ),
                  if (!_linked(user, provider))
                    Align(
                      alignment: Alignment.centerRight,
                      child: TextButton.icon(
                        key: ValueKey('profile-link-${provider.name}'),
                        onPressed: _busy || user == null
                            ? null
                            : () => _link(provider),
                        icon: const Icon(Icons.add_link_rounded, size: 18),
                        label: Text(l10n.profileLinkAccount),
                      ),
                    ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
        ],
        if (pending) ...[
          Text(
            l10n.profileFinishLinking,
            key: const Key('profile-link-pending'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSize.caption,
              height: 1.6,
            ),
          ),
          TextButton.icon(
            key: const Key('profile-link-refresh'),
            onPressed: _busy ? null : _refresh,
            icon: const Icon(Icons.refresh_rounded, size: 18),
            label: Text(l10n.profileCheckStatus),
          ),
        ],
        if (_busy)
          const Padding(
            padding: EdgeInsets.symmetric(vertical: 8),
            child: LinearProgressIndicator(),
          ),
        if (_error != null)
          Text(
            _error!,
            key: const Key('profile-link-error'),
            style: TextStyle(
              color: Theme.of(context).colorScheme.error,
              height: 1.5,
              fontSize: AppFontSize.caption,
            ),
          ),
        if (_message != null && pending)
          Text(
            _message!,
            key: const Key('profile-link-message'),
            style: const TextStyle(
              color: AppColors.textSecondary,
              height: 1.5,
              fontSize: AppFontSize.caption,
            ),
          ),
      ],
    );
  }
}
