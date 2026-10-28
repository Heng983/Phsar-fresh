import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/navigation/app_routes.dart';
import 'package:phsar_fresh_app/core/navigation/auth_system_ui_observer.dart';
import 'package:phsar_fresh_app/core/widgets/app_snack_bar.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_credentials.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_failure.dart';
import 'package:phsar_fresh_app/features/auth/presentation/pages/otp_verification_page.dart';
import 'package:phsar_fresh_app/features/auth/presentation/providers/auth_provider.dart';
import 'package:phsar_fresh_app/features/auth/presentation/utils/auth_error_messages.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/login_footer.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/login_form_card.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/login_header.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/social_sign_in_button.dart';

class LoginPage extends ConsumerStatefulWidget {
  final bool initiallyRegister;
  final bool forCheckout;
  final VoidCallback? onAuthenticated;
  final ValueChanged<AuthCredentials>? onSubmit;
  final ValueChanged<String>? onRequestOtp;
  final VoidCallback? onForgotPassword;
  final ValueChanged<SocialProvider>? onSocialSignIn;
  final VoidCallback? onTerms;
  final VoidCallback? onPrivacy;
  final VoidCallback? onSupport;

  const LoginPage({
    super.key,
    this.initiallyRegister = false,
    this.forCheckout = false,
    this.onAuthenticated,
    this.onSubmit,
    this.onRequestOtp,
    this.onForgotPassword,
    this.onSocialSignIn,
    this.onTerms,
    this.onPrivacy,
    this.onSupport,
  });

  @override
  ConsumerState<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends ConsumerState<LoginPage> {
  final _scrollController = ScrollController();
  AuthSystemUiObserver? _systemUiObserver;
  ModalRoute<dynamic>? _pageRoute;
  bool _isLoading = false;
  bool _awaitingSocial = false;
  bool _rememberMe = true;
  String? _error;
  String? _message;
  int _resendSeconds = 0;
  Timer? _resendTimer;

  @override
  void initState() {
    super.initState();
    _scrollController.addListener(_updateStatusBar);
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

  @override
  void dispose() {
    if (_pageRoute != null) _systemUiObserver?.forgetRoute(_pageRoute!);
    _scrollController.dispose();
    _resendTimer?.cancel();
    super.dispose();
  }

  void _startResendCooldown() {
    _resendTimer?.cancel();
    setState(() => _resendSeconds = 60);
    _resendTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (!mounted) {
        timer.cancel();
        return;
      }
      setState(() => _resendSeconds--);
      if (_resendSeconds == 0) timer.cancel();
    });
  }

  Future<void> _runAuth(Future<void> Function() action) async {
    if (_isLoading) return;
    setState(() {
      _isLoading = true;
      _error = null;
      _message = null;
    });
    try {
      await action();
    } catch (error, stack) {
      if (!mounted) return;
      setState(
        () => _error = AuthErrorMessages.forError(error, context.l10n, stack),
      );
    } finally {
      if (mounted) setState(() => _isLoading = false);
    }
  }

  Future<void> _submit(AuthCredentials credentials) async {
    _awaitingSocial = false;
    if (widget.onSubmit != null) {
      widget.onSubmit!(credentials);
      return;
    }
    await _runAuth(() async {
      try {
        final response = await ref
            .read(authRepositoryProvider)
            .submit(credentials);
        if (!mounted) return;
        if (response.session != null) {
          _completeAuthentication();
        } else if (credentials.action == AuthAction.register &&
            response.user != null) {
          _openVerification(credentials, codeSent: true);
        } else {
          setState(() => _error = context.l10n.authNoSession);
        }
      } on AuthFailure catch (error) {
        if (!mounted) return;
        if (error.reason == AuthFailureReason.phoneNotConfirmed) {
          _openVerification(credentials, codeSent: false);
        } else {
          rethrow;
        }
      }
    });
  }

  void _openVerification(
    AuthCredentials credentials, {
    required bool codeSent,
  }) {
    final navigator = Navigator.of(context);
    final returnToCheckout = widget.onAuthenticated != null;
    navigator.push<void>(
      MaterialPageRoute(
        settings: const RouteSettings(name: AppRoutes.verifyOtp),
        builder: (_) => OtpVerificationPage(
          phoneNumber: credentials.phoneNumber,
          rememberMe: credentials.rememberMe,
          codeSent: codeSent,
          onVerified: returnToCheckout ? () => navigator.pop() : null,
        ),
      ),
    );
  }

  Future<void> _requestOtp(String phone) async {
    if (widget.onRequestOtp != null) {
      widget.onRequestOtp!(phone);
      return;
    }
    if (_resendSeconds > 0) return;
    await _runAuth(() async {
      await ref
          .read(authRepositoryProvider)
          .requestOtp(phone, shouldCreateUser: widget.forCheckout);
      if (!mounted) return;
      setState(() => _message = context.l10n.authCodeSent(phone));
      _startResendCooldown();
    });
  }

  void _showUnavailable(BuildContext context) {
    AppSnackBar.show(context, message: context.l10n.authUnavailable);
  }

  void _completeAuthentication() {
    _awaitingSocial = false;
    if (widget.onAuthenticated != null) {
      widget.onAuthenticated!();
    } else {
      Navigator.of(
        context,
      ).pushNamedAndRemoveUntil(AppRoutes.market, (_) => false);
    }
  }

  Future<void> _socialSignIn(SocialProvider provider) async {
    await _runAuth(() async {
      _awaitingSocial = true;
      try {
        final launched = await ref
            .read(authRepositoryProvider)
            .signInWithProvider(provider, rememberMe: _rememberMe);
        if (!launched) {
          throw const AuthFailure(AuthFailureReason.unavailable);
        }
        if (mounted) setState(() => _message = context.l10n.authSocialPending);
      } catch (_) {
        _awaitingSocial = false;
        rethrow;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    ref.listen(authSessionProvider, (_, next) {
      if (!_awaitingSocial) return;
      if (next.hasError) {
        setState(() {
          _awaitingSocial = false;
          _message = null;
          _error = context.l10n.authUnavailable;
        });
      } else if (next.value != null) {
        _completeAuthentication();
      }
    });
    void unavailable() => _showUnavailable(context);

    return Scaffold(
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
                height: 290,
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
                  // Fades into the page instead of ending in a hard line.
                  position: DecorationPosition.background,
                  child: const DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        begin: Alignment.topCenter,
                        end: Alignment.bottomCenter,
                        stops: [.55, 1],
                        colors: [Color(0x00F4F7EF), AppColors.background],
                      ),
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
                      children: [
                        LoginHeader(
                          title: widget.forCheckout
                              ? context.l10n.authCheckoutTitle
                              : null,
                          description: widget.forCheckout
                              ? context.l10n.authCheckoutDescription
                              : null,
                          showTagline: !widget.forCheckout,
                        ),
                        const SizedBox(height: 20),
                        LoginFormCard(
                          initiallyRegister: widget.initiallyRegister,
                          initiallyUseOtp: widget.forCheckout,
                          isLoading: _isLoading,
                          errorMessage: _error,
                          statusMessage:
                              _message ??
                              (ref.watch(authRepositoryProvider).isAvailable
                                  ? null
                                  : context.l10n.authServicesPaused),
                          resendSeconds: _resendSeconds,
                          onSubmit: _submit,
                          onRequestOtp: _requestOtp,
                          onModeChanged: () => setState(() {
                            _error = null;
                            _message = null;
                          }),
                          onForgotPassword: widget.onForgotPassword,
                          onSocialSignIn:
                              widget.onSocialSignIn ?? _socialSignIn,
                          onRememberMeChanged: (value) => _rememberMe = value,
                        ),
                        if (!widget.forCheckout) ...[
                          const SizedBox(height: 12),
                          TextButton(
                            key: const Key('browse-market'),
                            onPressed: _isLoading
                                ? null
                                : () => Navigator.pushNamed(
                                    context,
                                    AppRoutes.market,
                                  ),
                            child: Text(context.l10n.marketBrowseGuest),
                          ),
                        ],
                        const SizedBox(height: 40),
                        LoginFooter(
                          onTerms: widget.onTerms ?? unavailable,
                          onPrivacy: widget.onPrivacy ?? unavailable,
                          onSupport: widget.onSupport ?? unavailable,
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
    );
  }
}
