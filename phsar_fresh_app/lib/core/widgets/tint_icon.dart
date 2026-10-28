import 'package:flutter/material.dart';
import 'package:phsar_fresh_app/core/constants/app_colors.dart';

/// An icon on a soft coloured rounded square, used beside section titles.
class TintIcon extends StatelessWidget {
  const TintIcon({
    super.key,
    required this.icon,
    required this.tint,
    this.size = 34,
  });

  final IconData icon;
  final AppTint tint;
  final double size;

  @override
  Widget build(BuildContext context) => Container(
    width: size,
    height: size,
    decoration: BoxDecoration(
      color: tint.soft,
      borderRadius: BorderRadius.circular(size * .32),
    ),
    alignment: Alignment.center,
    child: Icon(icon, size: size * .56, color: tint.ink),
  );
}
