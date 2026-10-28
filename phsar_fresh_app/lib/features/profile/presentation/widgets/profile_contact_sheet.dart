import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/account_contact.dart';
import 'package:phsar_fresh_app/features/auth/domain/validators/auth_validators.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/otp_code_field.dart';

class ProfileContactSheet extends ConsumerStatefulWidget {
  const ProfileContactSheet({
    super.key,
    required this.contact,
    required this.currentValue,
  });
  final AccountContact contact;
  final String currentValue;

  static Future<void> show(
    BuildContext context,
    AccountContact contact,
    String currentValue,
  ) => showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    useSafeArea: true,
    showDragHandle: true,
    backgroundColor: Colors.white,
    builder: (_) =>
        ProfileContactSheet(contact: contact, currentValue: currentValue),
  );

  @override
  ConsumerState<ProfileContactSheet> createState() =>
      _ProfileContactSheetState();
}

class _ProfileContactSheetState extends ConsumerState<ProfileContactSheet> {
  final _form = GlobalKey<FormState>();
  final _codeForm = GlobalKey<FormState>();
  final _value = TextEditingController();
  final _code = TextEditingController();
  Timer? _timer;
  bool _busy = false;
  String? _target;
  String? _error;
  String? _message;
  int _seconds = 0;

  bool get _phone => widget.contact == AccountContact.phone;

  @override
  void initState() {
    super.initState();
    if (!_phone) {
      final pending = ref.read(authSessionProvider).value?.user.pendingEmail;
      if (pending != null && pending.isNotEmpty) {
        _target = pending;
        _value.text = pending;
      }
    }
  }

  @override
  void dispose() {
    _timer?.cancel();
    _value.dispose();
    _code.dispose();
    super.dispose();
  }

  String _localPhone(String value) {
    final compact = value.replaceAll(RegExp(r'[\s-]'), '');
    if (compact.startsWith('+855')) return '0${compact.substring(4)}';
    if (RegExp(r'^855[1-9][0-9]{7,8}$').hasMatch(compact)) {
      return '0${compact.substring(3)}';
    }
    return compact;
  }

  String _normalize(String value) => _phone
      ? AuthValidators.normalizePhoneNumber(_localPhone(value))
      : value.trim().toLowerCase();

  bool _matches(String? value) =>
      _target != null &&
      value != null &&
      (_phone
          ? value.replaceFirst(RegExp(r'^\+'), '') ==
                _target!.replaceFirst(RegExp(r'^\+'), '')
          : value.toLowerCase() == _target);

  void _cooldown() {
    _timer?.cancel();
    _seconds = 60;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _seconds--);
      if (_seconds == 0) timer.cancel();
    });
  }

  Future<void> _run(
    Future<void> Function() action, {
    bool verifying = false,
  }) async {
    if (_busy) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _busy = true;
      _error = null;
      _message = null;
    });
    try {
      await action();
    } catch (_) {
      if (mounted) {
        setState(
          () => _error = verifying
              ? context.l10n.profileCodeError
              : context.l10n.profileContactError,
        );
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _send() async {
    if (!_form.currentState!.validate()) return;
    final target = _normalize(_value.text);
    await _run(() async {
      await ref
          .read(authRepositoryProvider)
          .requestContactChange(widget.contact, target);
      if (!mounted) return;
      setState(() {
        _target = target;
        _code.clear();
        _cooldown();
      });
    });
  }

  Future<void> _verify() async {
    if (!_codeForm.currentState!.validate()) return;
    await _run(() async {
      final complete = await ref
          .read(authRepositoryProvider)
          .verifyPhoneChange(_target!, _code.text.trim());
      if (!complete && mounted) {
        setState(() {
          _code.clear();
          _message = context.l10n.profileMoreVerification;
        });
      }
    }, verifying: true);
  }

  Future<void> _resend() async {
    if (_seconds > 0) return;
    await _run(() async {
      await ref
          .read(authRepositoryProvider)
          .resendContactChange(widget.contact, _target!);
      if (!mounted) return;
      setState(() {
        _code.clear();
        _cooldown();
      });
    });
  }

  Future<void> _refresh() => _run(() async {
    await ref.read(authRepositoryProvider).refreshAccount();
    if (!mounted) return;
    final user = ref.read(authSessionProvider).value?.user;
    if (!_matches(_phone ? user?.phone : user?.email)) {
      setState(() => _message = context.l10n.profileStillPending);
    }
  });

  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (_, next) {
      if (next.hasError && _target != null) {
        setState(() => _error = context.l10n.profileContactError);
      }
    });
    final l10n = context.l10n;
    final user = ref.watch(authSessionProvider).value?.user;
    final complete = _matches(_phone ? user?.phone : user?.email);
    return SafeArea(
      top: false,
      child: SingleChildScrollView(
        padding: EdgeInsets.fromLTRB(
          24,
          8,
          24,
          MediaQuery.viewInsetsOf(context).bottom + 24,
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          mainAxisSize: MainAxisSize.min,
          children: [
            Align(
              alignment: Alignment.centerLeft,
              child: CircleAvatar(
                backgroundColor: AppColors.mint,
                child: Icon(
                  complete
                      ? Icons.check_rounded
                      : _phone
                      ? Icons.phone_iphone_rounded
                      : Icons.mail_outline_rounded,
                  color: AppColors.primary,
                ),
              ),
            ),
            const SizedBox(height: 14),
            Text(
              _phone ? l10n.profileChangePhone : l10n.profileChangeEmail,
              style: const TextStyle(
                fontSize: AppFontSize.headlineLarge,
                fontWeight: FontWeight.w700,
                height: 1.4,
              ),
            ),
            const SizedBox(height: 10),
            if (complete) ...[
              Text(
                l10n.profileContactUpdated,
                key: const Key('profile-contact-success'),
                style: const TextStyle(
                  color: AppColors.primaryDark,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 8),
              Text(
                _target!,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  height: 1.5,
                ),
              ),
              const SizedBox(height: 22),
              FilledButton(
                onPressed: () => Navigator.pop(context),
                child: Text(l10n.marketClose),
              ),
            ] else if (_target == null) ...[
              Text(
                _phone
                    ? l10n.profilePhoneChangeHint
                    : l10n.profileEmailChangeHint,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  fontSize: AppFontSize.footnote,
                  height: 1.6,
                ),
              ),
              const SizedBox(height: 22),
              Form(
                key: _form,
                child: TextFormField(
                  key: Key(
                    _phone ? 'profile-phone-input' : 'profile-email-input',
                  ),
                  controller: _value,
                  enabled: !_busy,
                  autocorrect: false,
                  keyboardType: _phone
                      ? TextInputType.phone
                      : TextInputType.emailAddress,
                  autofillHints: [
                    _phone
                        ? AutofillHints.telephoneNumber
                        : AutofillHints.email,
                  ],
                  textInputAction: TextInputAction.done,
                  maxLength: _phone ? 24 : 254,
                  decoration: InputDecoration(
                    labelText: _phone
                        ? l10n.profileNewPhone
                        : l10n.profileNewEmail,
                    hintText: _phone ? '+855 12 345 678' : 'name@example.com',
                    filled: true,
                    fillColor: AppColors.inputBackground,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(14),
                      borderSide: BorderSide.none,
                    ),
                    errorMaxLines: 3,
                  ),
                  validator: (value) {
                    final valid = _phone
                        ? AuthValidators.isValidPhoneNumber(
                            _localPhone(value ?? ''),
                          )
                        : RegExp(
                            r'^[^\s@]+@[^\s@]+\.[^\s@]+$',
                          ).hasMatch((value ?? '').trim());
                    if (!valid) {
                      return _phone
                          ? l10n.authInvalidPhone
                          : l10n.profileInvalidEmail;
                    }
                    if (_normalize(value!) == _normalize(widget.currentValue)) {
                      return l10n.profileSameContact;
                    }
                    return null;
                  },
                  onFieldSubmitted: (_) => _send(),
                ),
              ),
              const SizedBox(height: 12),
              FilledButton.icon(
                key: const Key('profile-contact-send'),
                onPressed: _busy ? null : _send,
                icon: _busy
                    ? _spinner()
                    : const Icon(Icons.send_outlined, size: 18),
                label: Text(l10n.profileSendConfirmation),
              ),
            ] else ...[
              Text(
                l10n.profilePending,
                style: const TextStyle(
                  fontSize: AppFontSize.caption,
                  color: AppColors.orange,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 6),
              Text(
                _target!,
                style: const TextStyle(
                  fontSize: AppFontSize.bodyLarge,
                  height: 1.5,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 14),
              Text(
                _phone ? l10n.profilePhoneSent : l10n.profileEmailSent,
                style: const TextStyle(
                  color: AppColors.textSecondary,
                  height: 1.6,
                  fontSize: AppFontSize.footnote,
                ),
              ),
              if (!_phone)
                Padding(
                  padding: const EdgeInsets.only(top: 10),
                  child: Text(
                    l10n.profileEmailChangeHint,
                    style: const TextStyle(
                      color: AppColors.textSecondary,
                      height: 1.6,
                      fontSize: AppFontSize.caption,
                    ),
                  ),
                ),
              const SizedBox(height: 20),
              if (_phone) ...[
                Form(
                  key: _codeForm,
                  child: OtpCodeField(
                    controller: _code,
                    enabled: !_busy,
                    onSubmitted: _verify,
                  ),
                ),
                const SizedBox(height: 18),
                FilledButton.icon(
                  key: const Key('profile-contact-verify'),
                  onPressed: _busy ? null : _verify,
                  icon: _busy
                      ? _spinner()
                      : const Icon(Icons.verified_user_outlined, size: 18),
                  label: Text(l10n.profileVerifyPhone),
                ),
              ] else
                FilledButton.icon(
                  key: const Key('profile-contact-refresh'),
                  onPressed: _busy ? null : _refresh,
                  icon: _busy
                      ? _spinner()
                      : const Icon(Icons.refresh_rounded, size: 18),
                  label: Text(l10n.profileCheckStatus),
                ),
              const SizedBox(height: 8),
              TextButton(
                key: const Key('profile-contact-resend'),
                onPressed: _busy || _seconds > 0 ? null : _resend,
                child: Text(
                  _seconds > 0
                      ? l10n.authResendIn(_seconds)
                      : l10n.profileResendConfirmation,
                ),
              ),
              TextButton(
                key: const Key('profile-contact-change'),
                onPressed: _busy || _seconds > 0
                    ? null
                    : () => setState(() {
                        _target = null;
                        _code.clear();
                        _error = null;
                        _message = null;
                      }),
                child: Text(l10n.profileUseDifferentContact),
              ),
            ],
            if (_error != null)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _error!,
                  key: const Key('profile-contact-error'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    height: 1.5,
                  ),
                ),
              ),
            if (_message != null && !complete)
              Padding(
                padding: const EdgeInsets.only(top: 12),
                child: Text(
                  _message!,
                  key: const Key('profile-contact-message'),
                  style: const TextStyle(
                    color: AppColors.textSecondary,
                    height: 1.5,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _spinner() => const SizedBox(
    width: 18,
    height: 18,
    child: CircularProgressIndicator(strokeWidth: 2),
  );
}
