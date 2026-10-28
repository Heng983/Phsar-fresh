import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';
import 'package:phsar_fresh_app/core/theme/app_type.dart';
import 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart';

export 'package:phsar_fresh_app/features/auth/domain/model/auth_session.dart'
    show SocialProvider;

class SocialSignInButton extends StatelessWidget {
  final String label;
  final SocialProvider provider;
  final VoidCallback onPressed;

  const SocialSignInButton({
    super.key,
    required this.label,
    required this.provider,
    required this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final isApple = provider == SocialProvider.apple;
    return Material(
      color: AppColors.inputBackground,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: onPressed,
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Row(
            children: [
              Container(
                width: 30,
                height: 30,
                decoration: BoxDecoration(
                  color: isApple ? AppColors.textPrimary : Colors.white,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: .04),
                      blurRadius: 3,
                      offset: const Offset(0, 2),
                    ),
                  ],
                ),
                child: Center(
                  child: switch (provider) {
                    SocialProvider.google => Image.asset(
                      'assets/images/google_logo.png',
                      width: 18,
                      height: 18,
                      fit: BoxFit.contain,
                      excludeFromSemantics: true,
                    ),
                    SocialProvider.facebook => const Icon(
                      Icons.facebook,
                      color: Color(0xFF1877F2),
                      size: 25,
                    ),
                    SocialProvider.apple => const Icon(
                      Icons.apple,
                      color: Colors.white,
                      size: 25,
                    ),
                  },
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  label,
                  style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: AppFontSize.bodySmall,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              const SizedBox(width: 6),
              const Icon(
                Icons.chevron_right,
                size: 20,
                color: AppColors.inputHint,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
