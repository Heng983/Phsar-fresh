import 'package:flutter/material.dart';

class FeatureItem {
  final IconData icon;
  final String title;
  final String description;
  final Color iconBackgroundColor;
  final Color iconColor;
  final String? badge;
  final Color? badgeColor;

  const FeatureItem({
    required this.icon,
    required this.title,
    required this.description,
    required this.iconBackgroundColor,
    required this.iconColor,
    this.badge,
    this.badgeColor,
  });
}
