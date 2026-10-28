import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/navigation/app_routes.dart';
import 'package:phsar_fresh_app/core/navigation/auth_system_ui_observer.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_credentials.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/auth/presentation/utils/auth_error_messages.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/login_header.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/otp_code_field.dart';

class OtpVerificationPage extends ConsumerStatefulWidget {
  const OtpVerificationPage({
    super.key,
    required this.phoneNumber,
    required this.rememberMe,
    this.codeSent = true,
    this.onVerified,
  });

  final String phoneNumber;
  final bool rememberMe;
  final bool codeSent;
  final VoidCallback? onVerified;

  @override
  ConsumerState<OtpVerificationPage> createState() =>
      _OtpVerificationPageState();
}

class _OtpVerificationPageState extends ConsumerState<OtpVerificationPage> {
  final _formKey = GlobalKey<FormState>();
  final _codeController = TextEditingController();
  final _scrollController = ScrollController();
  AuthSystemUiObserver? _systemUiObserver;
  ModalRoute<dynamic>? _pageRoute;
  Timer? _resendTimer;
  int _resendSeconds = 0;
  bool _isVerifying = false;
  bool _isResending = false;
  bool _showErrors = false;
  late bool _codeSent;
  String? _error;

  bool get _isLoading => _isVerifying || _isResending;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateStatusBar);
    _codeSent = widget.codeSent;
    if (_codeSent) _startResendCooldown();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    final route = ModalRoute.of(context);
    if (_pageRoute != null && _pageRoute != route) {
      _systemUiObserver?.forgetRoute(_pageRoute!);
    }
    _pageRoute = route;
    _systemUiObserver = ref.read(authSystemUiObserverProvider);
    _updateStatusBar();
  }

  void _updateStatusBar() {
    if (_pageRoute != null) {
      _systemUiObserver?.updateScrollPosition(
        _pageRoute!,
        _scrollController.hasClients ? _scrollController.offset : 0,
      );
    }
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    _resendSeconds = 60;
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendSeconds--);
      if (_resendSeconds == 0) timer.cancel();
    });
  }

  @override
  void dispose() {
    if (_pageRoute != null) _systemUiObserver?.forgetRoute(_pageRoute!);
    _scrollController.dispose();
    _resendTimer?.cancel();
    _codeController.dispose();
    super.dispose();
  }

  Future<void> _verify() async {
    if (_isLoading) return;
    setState(() => _showErrors = true);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isVerifying = true;
      _error = null;
    });
    try {
      final response = await ref
          .read(authRepositoryProvider)
          .submit(
            AuthCredentials(
              action: AuthAction.verifyOtp,
              phoneNumber: widget.phoneNumber,
              secret: _codeController.text.trim(),
              rememberMe: widget.rememberMe,
            ),
          );
      if (!mounted) return;
      if (response.session == null) {
        setState(() => _error = context.l10n.authNoSession);
        return;
      }
      if (widget.onVerified != null) {
        widget.onVerified!();
      } else {
        Navigator.of(
          context,
        ).pushNamedAndRemoveUntil(AppRoutes.market, (_) => false);
      }
    } catch (error, stack) {
      if (mounted) {
        setState(
          () => _error = AuthErrorMessages.forError(error, context.l10n, stack),
        );
      }
    } finally {
      if (mounted) setState(() => _isVerifying = false);
    }
  }

  Future<void> _resend() async {
    if (_isLoading || _resendSeconds > 0) return;
    FocusScope.of(context).unfocus();
    setState(() {
      _isResending = true;
      _error = null;
    });
    try {
      await ref
          .read(authRepositoryProvider)
          .resendSignupOtp(widget.phoneNumber);
      if (!mounted) return;
      _codeController.clear();
      _formKey.currentState?.reset();
      setState(() {
        _showErrors = false;
        _codeSent = true;
        _startResendCooldown();
      });
    } catch (error, stack) {
      if (mounted) {
        setState(
          () => _error = AuthErrorMessages.forError(error, context.l10n, stack),
        );
      }
    } finally {
      if (mounted) setState(() => _isResending = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    return PopScope(
      canPop: !_isLoading,
      child: Scaffold(
        body: SingleChildScrollView(
          controller: _scrollController,
          physics: const AlwaysScrollableScrollPhysics(),
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: 300,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.bottomLeft,
                        end: Alignment.topRight,
                        colors: [
                          AppColors.lightOrange.withValues(alpha: .2),
                          AppColors.inputBackground,
                          AppColors.mint,
                        ],
                      ),
                    ),
                  ),
                ),
                Center(
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 600),
                    child: Padding(
                      padding: const EdgeInsets.fromLTRB(16, 18, 16, 28),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          LoginHeader(
                            title: l10n.authVerifyPhone,
                            description: l10n.authOtpWelcome,
                            showTagline: false,
                          ),
                          const SizedBox(height: 24),
                          Center(
                            child: ConstrainedBox(
                              constraints: const BoxConstraints(maxWidth: 480),
                              child: _verificationCard(context),
                            ),
                          ),
                          const SizedBox(height: 14),
                          Center(
                            child: TextButton.icon(
                              key: const Key('auth-change-phone'),
                              onPressed: _isLoading
                                  ? null
                                  : () => Navigator.of(context).pop(),
                              icon: const Icon(Icons.edit_outlined, size: 17),
                              label: Text(l10n.authChangeNumber),
                              style: TextButton.styleFrom(
                                minimumSize: const Size(0, 48),
                              ),
                            ),
                          ),
                          const SizedBox(height: 20),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Icon(
                                Icons.eco_outlined,
                                size: 16,
                                color: AppColors.primary,
                              ),
                              const SizedBox(width: 6),
                              Flexible(
                                child: Text(
                                  l10n.authFreshProduce,
                                  textAlign: TextAlign.center,
                                  style: const TextStyle(
                                    color: AppColors.textSecondary,
                                    fontSize: AppFontSize.caption,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                if (Navigator.canPop(context))
                  Positioned(
                    top: 8,
                    left: 8,
                    child: IconButton(
                      tooltip: MaterialLocalizations.of(
                        context,
                      ).backButtonTooltip,
                      onPressed: _isLoading
                          ? null
                          : () => Navigator.of(context).pop(),
                      icon: const Icon(
                        Icons.arrow_back,
                        size: 20,
                        color: AppColors.primary,
                      ),
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _verificationCard(BuildContext context) {
    final l10n = context.l10n;
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: .06),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Center(
            child: Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: AppColors.mint,
                borderRadius: BorderRadius.circular(14),
              ),
              child: const Icon(
                Icons.mark_chat_read_outlined,
                color: AppColors.primary,
                size: 25,
              ),
            ),
          ),
          const SizedBox(height: 16),
          Text(
            l10n.authEnterVerificationCode,
            textAlign: TextAlign.center,
            style: const TextStyle(
              fontSize: AppFontSize.title,
              fontWeight: FontWeight.w600,
              color: AppColors.textPrimary,
              height: 1.35,
            ),
          ),
          const SizedBox(height: 10),
          Text(
            _codeSent
                ? l10n.authOtpInstructions
                : l10n.authPhoneConfirmationRequired,
            key: const Key('auth-status'),
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSize.footnote,
              height: 1.6,
            ),
          ),
          const SizedBox(height: 14),
          Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              decoration: BoxDecoration(
                color: AppColors.inputBackground,
                borderRadius: BorderRadius.circular(10),
              ),
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Icon(
                    Icons.phone_iphone_outlined,
                    size: 17,
                    color: AppColors.primary,
                  ),
                  const SizedBox(width: 8),
                  Flexible(
                    child: Text(
                      widget.phoneNumber,
                      textDirection: TextDirection.ltr,
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: AppFontSize.bodySmall,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 24),
          Text(
            l10n.authOtpCode,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSize.footnote,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 10),
          Form(
            key: _formKey,
            autovalidateMode: _showErrors
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: AutofillGroup(
              child: OtpCodeField(
                controller: _codeController,
                enabled: !_isLoading,
                onSubmitted: _verify,
              ),
            ),
          ),
          if (_error != null) ...[
            const SizedBox(height: 16),
            Semantics(
              liveRegion: true,
              child: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(
                    context,
                  ).colorScheme.error.withValues(alpha: .06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Text(
                  _error!,
                  key: const Key('auth-error'),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.error,
                    fontSize: AppFontSize.footnote,
                    height: 1.5,
                  ),
                ),
              ),
            ),
          ],
          const SizedBox(height: 24),
          ElevatedButton(
            key: const Key('auth-submit'),
            onPressed: _isLoading ? null : _verify,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.loginButton,
              foregroundColor: Colors.white,
              minimumSize: const Size.fromHeight(52),
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
              elevation: 4,
              shadowColor: AppColors.loginButton.withValues(alpha: .4),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.md),
              ),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                if (_isVerifying)
                  const SizedBox(
                    key: Key('auth-loading'),
                    width: 22,
                    height: 22,
                    child: CircularProgressIndicator(
                      strokeWidth: 2,
                      color: Colors.white,
                    ),
                  )
                else
                  const Icon(Icons.verified_user_outlined, size: 22),
                const SizedBox(width: 8),
                Flexible(
                  child: Text(
                    l10n.authVerifyCode,
                    textAlign: TextAlign.center,
                    style: const TextStyle(
                      fontSize: AppFontSize.bodyLarge,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),
          Text(
            l10n.authDidNotReceiveCode,
            textAlign: TextAlign.center,
            style: const TextStyle(
              color: AppColors.textSecondary,
              fontSize: AppFontSize.footnote,
            ),
          ),
          TextButton(
            key: const Key('auth-resend-code'),
            onPressed: _isLoading || _resendSeconds > 0 ? null : _resend,
            style: TextButton.styleFrom(
              minimumSize: const Size(0, 44),
              disabledForegroundColor: AppColors.textSecondary,
            ),
            child: _isResending
                ? const SizedBox(
                    width: 20,
                    height: 20,
                    child: CircularProgressIndicator(strokeWidth: 2),
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        _resendSeconds > 0
                            ? Icons.schedule_outlined
                            : Icons.refresh_rounded,
                        size: 16,
                      ),
                      const SizedBox(width: 6),
                      Flexible(
                        child: Text(
                          _resendSeconds > 0
                              ? l10n.authResendIn(_resendSeconds)
                              : _codeSent
                              ? l10n.authResendCode
                              : l10n.authSendCode,
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ],
                  ),
          ),
        ],
      ),
    );
  }
}
