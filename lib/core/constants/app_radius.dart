import 'package:flutter/material.dart';

class AppRadius {
  AppRadius._();

  // Border radius values
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 24.0;
  static const double xxl = 32.0;
  static const double full = 999.0;

  // BorderRadius presets
  static final BorderRadius radiusXs = BorderRadius.circular(xs);
  static final BorderRadius radiusSm = BorderRadius.circular(sm);
  static final BorderRadius radiusMd = BorderRadius.circular(md);
  static final BorderRadius radiusLg = BorderRadius.circular(lg);
  static final BorderRadius radiusXl = BorderRadius.circular(xl);
  static final BorderRadius radiusXxl = BorderRadius.circular(xxl);
  static final BorderRadius radiusFull = BorderRadius.circular(full);

  // Specific radius for components
  static const double buttonRadius = 12.0;
  static const double cardRadius = 16.0;
  static const double inputRadius = 12.0;
  static const double chipRadius = 20.0;
  static const double avatarRadius = 24.0;
  static const double bottomSheetRadius = 24.0;
  static const double dialogRadius = 16.0;

  // BorderRadius for common components
  static BorderRadius get button => BorderRadius.circular(buttonRadius);
  static BorderRadius get card => BorderRadius.circular(cardRadius);
  static BorderRadius get input => BorderRadius.circular(inputRadius);
  static BorderRadius get chip => BorderRadius.circular(chipRadius);
  static BorderRadius get avatar => BorderRadius.circular(avatarRadius);
  static BorderRadius get bottomSheet => BorderRadius.circular(bottomSheetRadius);
  static BorderRadius get dialog => BorderRadius.circular(dialogRadius);
}
