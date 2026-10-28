import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_decorations.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_credentials.dart';
import 'package:phsar_fresh_app/features/auth/domain/validators/auth_validators.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/auth_mode_tabs.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/auth_text_field.dart';
import 'package:phsar_fresh_app/features/auth/presentation/widgets/social_sign_in_button.dart';

class LoginFormCard extends StatefulWidget {
  final bool initiallyRegister;
  final bool initiallyUseOtp;
  final bool isLoading;
  final String? errorMessage;
  final String? statusMessage;
  final int resendSeconds;
  final VoidCallback? onModeChanged;
  final ValueChanged<AuthCredentials> onSubmit;
  final ValueChanged<String> onRequestOtp;
  final VoidCallback? onForgotPassword;
  final ValueChanged<SocialProvider> onSocialSignIn;
  final ValueChanged<bool>? onRememberMeChanged;

  const LoginFormCard({
    super.key,
    this.initiallyRegister = false,
    this.initiallyUseOtp = false,
    this.isLoading = false,
    this.errorMessage,
    this.statusMessage,
    this.resendSeconds = 0,
    this.onModeChanged,
    required this.onSubmit,
    required this.onRequestOtp,
    this.onForgotPassword,
    required this.onSocialSignIn,
    this.onRememberMeChanged,
  });

  @override
  State<LoginFormCard> createState() => _LoginFormCardState();
}

class _LoginFormCardState extends State<LoginFormCard> {
  final _formKey = GlobalKey<FormState>();
  final _feedbackKey = GlobalKey();
  final _phoneController = TextEditingController();
  final _secretController = TextEditingController();
  final _confirmController = TextEditingController();
  late bool _isRegister;
  bool _useOtp = false;
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  bool _rememberMe = true;
  bool _showErrors = false;

  void _setRememberMe(bool value) {
    setState(() => _rememberMe = value);
    widget.onRememberMeChanged?.call(value);
  }

  @override
  void initState() {
    super.initState();
    _isRegister = widget.initiallyRegister;
    _useOtp = !_isRegister && widget.initiallyUseOtp;
  }

  @override
  void didUpdateWidget(covariant LoginFormCard oldWidget) {
    super.didUpdateWidget(oldWidget);
    if ((widget.errorMessage != oldWidget.errorMessage &&
            widget.errorMessage != null) ||
        (widget.statusMessage != oldWidget.statusMessage &&
            widget.statusMessage != null)) {
      _revealFeedback();
    }
  }

  void _revealFeedback() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final feedbackContext = _feedbackKey.currentContext;
      if (mounted && feedbackContext != null) {
        Scrollable.ensureVisible(feedbackContext, alignment: .1);
      }
    });
  }

  @override
  void dispose() {
    _phoneController.dispose();
    _secretController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  void _changeMode({required bool isRegister, bool useOtp = false}) {
    if (widget.isLoading) return;
    FocusScope.of(context).unfocus();
    final phoneNumber = _phoneController.text;
    _formKey.currentState?.reset();
    _phoneController.text = phoneNumber;
    _secretController.clear();
    _confirmController.clear();
    setState(() {
      _isRegister = isRegister;
      _useOtp = useOtp;
      _obscurePassword = true;
      _obscureConfirmPassword = true;
      _showErrors = false;
    });
    widget.onModeChanged?.call();
  }

  String? _validatePhone(String? value) {
    return AuthValidators.isValidPhoneNumber(value ?? '')
        ? null
        : context.l10n.authInvalidPhone;
  }

  String? _validateSecret(String? value) {
    final secret = value ?? '';
    if (_useOtp) {
      return AuthValidators.isValidOtp(secret)
          ? null
          : context.l10n.authInvalidOtp;
    }
    if (secret.isEmpty) return context.l10n.authRequiredPassword;
    if (_isRegister && secret.length < 8) return context.l10n.authShortPassword;
    return null;
  }

  void _submit() {
    if (widget.isLoading) return;
    setState(() => _showErrors = true);
    if (!_formKey.currentState!.validate()) return;
    FocusScope.of(context).unfocus();
    widget.onSubmit(
      AuthCredentials(
        action: _isRegister
            ? AuthAction.register
            : _useOtp
            ? AuthAction.verifyOtp
            : AuthAction.signIn,
        phoneNumber: AuthValidators.normalizePhoneNumber(_phoneController.text),
        secret: _secretController.text,
        rememberMe: _rememberMe,
      ),
    );
  }

  void _requestOtp() {
    if (widget.isLoading || widget.resendSeconds > 0) return;
    if (_validatePhone(_phoneController.text) != null) {
      setState(() => _showErrors = true);
      _formKey.currentState!.validate();
      return;
    }
    FocusScope.of(context).unfocus();
    widget.onRequestOtp(
      AuthValidators.normalizePhoneNumber(_phoneController.text),
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    const labelStyle = TextStyle(
      color: AppColors.textSecondary,
      fontSize: AppFontSize.bodySmall,
      fontWeight: FontWeight.w500,
    );

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(color: AppDecorations.cardBorder),
        boxShadow: AppShadows.soft,
      ),
      child: AbsorbPointer(
        absorbing: widget.isLoading,
        child: AutofillGroup(
          child: Form(
            key: _formKey,
            autovalidateMode: _showErrors
                ? AutovalidateMode.onUserInteraction
                : AutovalidateMode.disabled,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AuthModeTabs(
                  isRegister: _isRegister,
                  onChanged: (value) => _changeMode(isRegister: value),
                ),
                SizedBox(key: _feedbackKey),
                if (widget.statusMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        widget.statusMessage!,
                        key: const Key('auth-status'),
                        style: const TextStyle(color: AppColors.primaryDark),
                      ),
                    ),
                  ),
                if (widget.errorMessage != null)
                  Padding(
                    padding: const EdgeInsets.only(top: 16),
                    child: Semantics(
                      liveRegion: true,
                      child: Text(
                        widget.errorMessage!,
                        key: const Key('auth-error'),
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.error,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 24),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  runSpacing: 4,
                  children: [
                    Text(l10n.authPhoneNumber, style: labelStyle),
                    Text(
                      'Smart / Cellcard / Metfone',
                      style: const TextStyle(
                        color: AppColors.primaryDark,
                        fontSize: AppFontSize.caption,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  key: const Key('auth-phone'),
                  controller: _phoneController,
                  label: l10n.authPhoneNumber,
                  hintText: l10n.authPhoneHint,
                  validator: _validatePhone,
                  keyboardType: TextInputType.phone,
                  autofillHints: const [AutofillHints.telephoneNumberNational],
                  prefixIcon: Container(
                    margin: const EdgeInsets.all(6),
                    padding: const EdgeInsets.symmetric(horizontal: 10),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          '🇰🇭',
                          style: TextStyle(fontSize: AppFontSize.bodyLarge),
                        ),
                        SizedBox(width: 6),
                        Text(
                          '+855',
                          style: TextStyle(
                            fontSize: AppFontSize.footnote,
                            fontWeight: FontWeight.w600,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  suffixIcon: const Icon(Icons.phone_iphone_outlined, size: 20),
                ),
                const SizedBox(height: 18),
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        _useOtp ? l10n.authOtpCode : l10n.authPassword,
                        style: labelStyle,
                      ),
                    ),
                    if (!_isRegister)
                      _textAction(
                        _useOtp ? l10n.authUsePassword : l10n.authUseOtp,
                        () => _changeMode(isRegister: false, useOtp: !_useOtp),
                      ),
                  ],
                ),
                const SizedBox(height: 8),
                AuthTextField(
                  key: ValueKey(_useOtp ? 'auth-otp' : 'auth-password'),
                  controller: _secretController,
                  label: _useOtp ? l10n.authOtpCode : l10n.authPassword,
                  hintText: _useOtp ? l10n.authOtpHint : l10n.authPasswordHint,
                  validator: _validateSecret,
                  keyboardType: _useOtp
                      ? TextInputType.number
                      : TextInputType.visiblePassword,
                  textInputAction: _isRegister
                      ? TextInputAction.next
                      : TextInputAction.done,
                  autofillHints: [
                    _useOtp
                        ? AutofillHints.oneTimeCode
                        : _isRegister
                        ? AutofillHints.newPassword
                        : AutofillHints.password,
                  ],
                  obscureText: !_useOtp && _obscurePassword,
                  prefixIcon: Icon(
                    _useOtp ? Icons.sms_outlined : Icons.lock_outline,
                    size: 20,
                    color: AppColors.inputHint,
                  ),
                  suffixIcon: _useOtp
                      ? null
                      : IconButton(
                          tooltip: _obscurePassword
                              ? l10n.authShowPassword
                              : l10n.authHidePassword,
                          onPressed: () => setState(
                            () => _obscurePassword = !_obscurePassword,
                          ),
                          icon: Icon(
                            _obscurePassword
                                ? Icons.visibility_outlined
                                : Icons.visibility_off_outlined,
                            size: 22,
                          ),
                        ),
                  onFieldSubmitted: _isRegister ? null : (_) => _submit(),
                ),
                if (_isRegister) ...[
                  const SizedBox(height: 18),
                  Text(l10n.authConfirmPassword, style: labelStyle),
                  const SizedBox(height: 8),
                  AuthTextField(
                    key: const Key('auth-confirm-password'),
                    controller: _confirmController,
                    label: l10n.authConfirmPassword,
                    hintText: l10n.authConfirmPasswordHint,
                    validator: (value) =>
                        value != _secretController.text || (value ?? '').isEmpty
                        ? l10n.authPasswordMismatch
                        : null,
                    keyboardType: TextInputType.visiblePassword,
                    textInputAction: TextInputAction.done,
                    obscureText: _obscureConfirmPassword,
                    prefixIcon: const Icon(
                      Icons.lock_outline,
                      size: 20,
                      color: AppColors.inputHint,
                    ),
                    suffixIcon: IconButton(
                      tooltip: _obscureConfirmPassword
                          ? l10n.authShowPassword
                          : l10n.authHidePassword,
                      onPressed: () => setState(
                        () =>
                            _obscureConfirmPassword = !_obscureConfirmPassword,
                      ),
                      icon: Icon(
                        _obscureConfirmPassword
                            ? Icons.visibility_outlined
                            : Icons.visibility_off_outlined,
                        size: 22,
                      ),
                    ),
                    onFieldSubmitted: (_) => _submit(),
                  ),
                ],
                if (_useOtp)
                  Padding(
                    padding: const EdgeInsets.only(top: 8),
                    child: Text(
                      l10n.authOtpSignInHelp,
                      style: const TextStyle(
                        color: AppColors.textSecondary,
                        fontSize: AppFontSize.caption,
                      ),
                    ),
                  ),
                if (_useOtp)
                  Align(
                    alignment: Alignment.centerRight,
                    child: _textAction(
                      widget.resendSeconds > 0
                          ? l10n.authResendIn(widget.resendSeconds)
                          : l10n.authSendCode,
                      widget.resendSeconds > 0 ? null : _requestOtp,
                    ),
                  ),
                const SizedBox(height: 12),
                Wrap(
                  alignment: WrapAlignment.spaceBetween,
                  crossAxisAlignment: WrapCrossAlignment.center,
                  spacing: 8,
                  children: [
                    InkWell(
                      borderRadius: BorderRadius.circular(6),
                      onTap: () => _setRememberMe(!_rememberMe),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          SizedBox(
                            width: 24,
                            height: 40,
                            child: Checkbox(
                              value: _rememberMe,
                              semanticLabel: l10n.authRememberMe,
                              activeColor: AppColors.primary,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                              ),
                              onChanged: (value) =>
                                  _setRememberMe(value ?? false),
                            ),
                          ),
                          const SizedBox(width: 6),
                          Text(
                            l10n.authRememberMe,
                            style: const TextStyle(
                              fontSize: AppFontSize.footnote,
                              color: AppColors.textSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    if (!_isRegister)
                      _textAction(
                        l10n.authForgotPassword,
                        widget.onForgotPassword ??
                            () => _changeMode(isRegister: false, useOtp: true),
                        color: AppColors.orange,
                        underline: false,
                      ),
                  ],
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  key: const Key('auth-submit'),
                  onPressed: widget.isLoading ? null : _submit,
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.loginButton,
                    foregroundColor: Colors.white,
                    minimumSize: const Size.fromHeight(52),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 14,
                      vertical: 14,
                    ),
                    elevation: 4,
                    shadowColor: AppColors.loginButton.withValues(alpha: .4),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.md),
                    ),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (widget.isLoading)
                        const SizedBox(
                          key: Key('auth-loading'),
                          width: 23,
                          height: 23,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      else
                        const Icon(Icons.shopping_basket_outlined, size: 23),
                      const SizedBox(width: 8),
                      Flexible(
                        child: Text(
                          _isRegister
                              ? l10n.authCreateAccount
                              : _useOtp
                              ? l10n.authVerifyCode
                              : l10n.authLoginToShop,
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
                const SizedBox(height: 26),
                Row(
                  children: [
                    const Expanded(child: Divider(color: AppColors.divider)),
                    Flexible(
                      flex: 3,
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 12),
                        child: Text(
                          l10n.authContinueWith,
                          textAlign: TextAlign.center,
                          style: const TextStyle(
                            color: AppColors.textSecondary,
                            fontSize: AppFontSize.caption,
                            fontWeight: FontWeight.w500,
                          ),
                        ),
                      ),
                    ),
                    const Expanded(child: Divider(color: AppColors.divider)),
                  ],
                ),
                const SizedBox(height: 18),
                SocialSignInButton(
                  key: const Key('auth-continue-apple'),
                  label: l10n.authContinueApple,
                  provider: SocialProvider.apple,
                  onPressed: () => widget.onSocialSignIn(SocialProvider.apple),
                ),
                const SizedBox(height: 10),
                SocialSignInButton(
                  label: l10n.authContinueGoogle,
                  provider: SocialProvider.google,
                  onPressed: () => widget.onSocialSignIn(SocialProvider.google),
                ),
                const SizedBox(height: 10),
                SocialSignInButton(
                  label: l10n.authContinueFacebook,
                  provider: SocialProvider.facebook,
                  onPressed: () =>
                      widget.onSocialSignIn(SocialProvider.facebook),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _textAction(
    String label,
    VoidCallback? onPressed, {
    Color color = AppColors.primary,
    bool underline = true,
  }) {
    return TextButton(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        foregroundColor: color,
        minimumSize: const Size(0, 32),
        padding: const EdgeInsets.symmetric(vertical: 4),
        tapTargetSize: MaterialTapTargetSize.shrinkWrap,
      ),
      child: Text(
        label,
        style: TextStyle(
          fontSize: AppFontSize.caption,
          fontWeight: FontWeight.w600,
          decoration: underline
              ? TextDecoration.underline
              : TextDecoration.none,
          decorationColor: color,
        ),
      ),
    );
  }
}
