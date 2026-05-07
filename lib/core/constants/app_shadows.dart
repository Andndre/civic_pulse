import 'package:flutter/material.dart';

class AppShadows {
  AppShadows._();

  // Elevation levels
  static const double none = 0.0;
  static const double xs = 1.0;
  static const double sm = 2.0;
  static const double md = 4.0;
  static const double lg = 8.0;
  static const double xl = 16.0;

  // Shadow colors (with opacity)
  static const Color shadowColor = Color(0xFF000000);

  // Shadow presets using BoxShadow
  static List<BoxShadow> get shadowNone => [];

  static List<BoxShadow> get shadowXs => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.05),
          blurRadius: 2,
          offset: const Offset(0, 1),
        ),
      ];

  static List<BoxShadow> get shadowSm => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.08),
          blurRadius: 4,
          offset: const Offset(0, 2),
        ),
      ];

  static List<BoxShadow> get shadowMd => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.10),
          blurRadius: 8,
          offset: const Offset(0, 4),
        ),
      ];

  static List<BoxShadow> get shadowLg => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.12),
          blurRadius: 16,
          offset: const Offset(0, 8),
        ),
      ];

  static List<BoxShadow> get shadowXl => [
        BoxShadow(
          color: shadowColor.withValues(alpha: 0.15),
          blurRadius: 24,
          offset: const Offset(0, 12),
        ),
      ];

  // Card shadow (most common)
  static List<BoxShadow> get card => shadowSm;

  // Elevated card
  static List<BoxShadow> get cardElevated => shadowMd;

  // Button pressed state
  static List<BoxShadow> get buttonPressed => shadowXs;

  // FAB shadow
  static List<BoxShadow> get fab => shadowLg;

  // Dialog shadow
  static List<BoxShadow> get dialog => shadowXl;
}
