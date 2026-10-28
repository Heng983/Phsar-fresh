import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/localization/localization_extension.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/auth/domain/validators/auth_validators.dart';

/// Six visual slots backed by one native field for paste and SMS autofill.
class OtpCodeField extends StatefulWidget {
  const OtpCodeField({
    super.key,
    required this.controller,
    required this.enabled,
    required this.onSubmitted,
  });

  final TextEditingController controller;
  final bool enabled;
  final VoidCallback onSubmitted;

  @override
  State<OtpCodeField> createState() => _OtpCodeFieldState();
}

class _OtpCodeFieldState extends State<OtpCodeField> {
  final _focusNode = FocusNode();

  @override
  void dispose() {
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final height = math.max(
      56.0,
      MediaQuery.textScalerOf(context).scale(24) + 24,
    );
    final errorColor = Theme.of(context).colorScheme.error;
    return FormField<String>(
      initialValue: widget.controller.text,
      validator: (_) => AuthValidators.isValidOtp(widget.controller.text.trim())
          ? null
          : context.l10n.authInvalidOtp,
      builder: (field) => Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          SizedBox(
            height: height,
            child: Stack(
              fit: StackFit.expand,
              children: [
                IgnorePointer(
                  child: ExcludeSemantics(
                    child: ListenableBuilder(
                      listenable: Listenable.merge([
                        widget.controller,
                        _focusNode,
                      ]),
                      builder: (context, _) {
                        final code = widget.controller.text;
                        final selected =
                            widget.controller.selection.extentOffset;
                        final activeIndex =
                            (selected < 0 ? code.length : selected).clamp(0, 5);
                        return Row(
                          textDirection: TextDirection.ltr,
                          children: List.generate(6, (index) {
                            final active =
                                widget.enabled &&
                                _focusNode.hasFocus &&
                                index == activeIndex;
                            final filled = index < code.length;
                            return Expanded(
                              child: Padding(
                                padding: EdgeInsets.only(
                                  right: index == 5 ? 0 : 7,
                                ),
                                child: AnimatedContainer(
                                  duration: const Duration(milliseconds: 160),
                                  height: height,
                                  alignment: Alignment.center,
                                  decoration: BoxDecoration(
                                    color: active
                                        ? Colors.white
                                        : AppColors.inputBackground,
                                    borderRadius: BorderRadius.circular(10),
                                    border: Border.all(
                                      color: field.hasError
                                          ? errorColor
                                          : active
                                          ? AppColors.primary
                                          : filled
                                          ? AppColors.primary.withValues(
                                              alpha: .2,
                                            )
                                          : Colors.transparent,
                                      width: active ? 1.5 : 1,
                                    ),
                                    boxShadow: active
                                        ? [
                                            BoxShadow(
                                              color: AppColors.primary
                                                  .withValues(alpha: .08),
                                              blurRadius: 8,
                                              offset: const Offset(0, 2),
                                            ),
                                          ]
                                        : null,
                                  ),
                                  child: filled
                                      ? Text(
                                          code[index],
                                          style: const TextStyle(
                                            fontSize: AppFontSize.headlineLarge,
                                            fontWeight: FontWeight.w600,
                                            color: AppColors.primaryDark,
                                          ),
                                        )
                                      : Container(
                                          width: active ? 2 : 5,
                                          height: active ? 22 : 5,
                                          decoration: BoxDecoration(
                                            color: active
                                                ? AppColors.primary
                                                : AppColors.inputHint,
                                            borderRadius: BorderRadius.circular(
                                              3,
                                            ),
                                          ),
                                        ),
                                ),
                              ),
                            );
                          }),
                        );
                      },
                    ),
                  ),
                ),
                Semantics(
                  label: context.l10n.authOtpCode,
                  child: TextField(
                    key: const Key('auth-otp'),
                    controller: widget.controller,
                    focusNode: _focusNode,
                    enabled: widget.enabled,
                    keyboardType: TextInputType.number,
                    textInputAction: TextInputAction.done,
                    textDirection: TextDirection.ltr,
                    textAlign: TextAlign.center,
                    textAlignVertical: TextAlignVertical.center,
                    autofillHints: const [AutofillHints.oneTimeCode],
                    autocorrect: false,
                    enableSuggestions: false,
                    showCursor: false,
                    style: const TextStyle(
                      color: Colors.transparent,
                      fontSize: AppFontSize.headlineLarge,
                    ),
                    decoration: const InputDecoration(
                      border: InputBorder.none,
                      enabledBorder: InputBorder.none,
                      focusedBorder: InputBorder.none,
                      disabledBorder: InputBorder.none,
                      filled: false,
                      contentPadding: EdgeInsets.zero,
                    ),
                    inputFormatters: [
                      FilteringTextInputFormatter.digitsOnly,
                      LengthLimitingTextInputFormatter(6),
                    ],
                    onChanged: field.didChange,
                    onSubmitted: (_) => widget.onSubmitted(),
                  ),
                ),
              ],
            ),
          ),
          if (field.hasError)
            Padding(
              padding: const EdgeInsets.only(top: 10),
              child: Semantics(
                liveRegion: true,
                child: Text(
                  field.errorText!,
                  style: TextStyle(
                    color: errorColor,
                    fontSize: AppFontSize.caption,
                    height: 1.4,
                  ),
                ),
              ),
            ),
        ],
      ),
    );
  }
}
