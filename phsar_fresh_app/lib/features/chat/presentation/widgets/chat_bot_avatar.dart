import 'package:flutter/material.dart';

import 'package:phsar_fresh_app/core/constants/app_colors.dart';

class ChatBotAvatar extends StatelessWidget {
  const ChatBotAvatar({super.key, this.size = 40});

  final double size;

  static const assetPath = 'assets/images/MingSros_avatar.png';

  @override
  Widget build(BuildContext context) => ExcludeSemantics(
    child: SizedBox(
      width: size,
      height: size,
      child: ClipOval(
        child: Image.asset(
          assetPath,
          key: const Key('ming-sros-avatar'),
          fit: BoxFit.cover,
          cacheWidth: (size * MediaQuery.devicePixelRatioOf(context)).ceil(),
          errorBuilder: (_, _, _) => const ColoredBox(
            color: AppColors.lightGreen,
            child: Icon(Icons.person_rounded, color: AppColors.primaryDark),
          ),
        ),
      ),
    ),
  );
}
