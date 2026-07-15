import 'package:flutter/material.dart';

class AppColors {
  AppColors._();

  // Primary
  static const Color primary = Color(0xFF2196F3);
  static const Color primaryLight = Color(0xFF64B5F6);
  static const Color primaryDark = Color(0xFF1976D2);

  // Secondary
  static const Color secondary = Color(0xFFFFC107);
  static const Color secondaryLight = Color(0xFFFFE082);
  static const Color secondaryDark = Color(0xFFFFA000);

  // Background
  static const Color background = Color(0xFFF8F9FA);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceVariant = Color(0xFFF5F5F5);

  // Text
  static const Color textPrimary = Color(0xFF333333);
  static const Color textSecondary = Color(0xFF757575);
  static const Color textHint = Color(0xFF9E9E9E);
  static const Color textOnPrimary = Color(0xFFFFFFFF);

  // Semantic
  static const Color success = Color(0xFF4CAF50);
  static const Color successLight = Color(0x334CAF50);
  static const Color warning = Color(0xFFFF9800);
  static const Color warningLight = Color(0x33FF9800);
  static const Color danger = Color(0xFFF44336);
  static const Color dangerLight = Color(0x33F44336);
  static const Color info = Color(0xFF2196F3);
  static const Color infoLight = Color(0x332196F3);

  // Mood accents (DESIGN.md §3.2) — hanya untuk hero/banner besar,
  // maksimal 1 gradient per layar, tidak untuk teks/ikon kecil
  static const List<Color> moodSunrise = [Color(0xFFFF9A56), Color(0xFFFF6B8B)];
  static const List<Color> moodGrowth = [Color(0xFF43E97B), Color(0xFF38F9D7)];
  static const List<Color> moodFocus = [Color(0xFF667EEA), Color(0xFF764BA2)];
  static const Color celebrate = Color(0xFFFFD166);

  // Warna tetap per-dimensi PULSE (DESIGN.md §3.3) — berlaku di semua chart & badge
  static const Color pulseParticipation = Color(0xFF2196F3);
  static const Color pulseUnderstanding = Color(0xFF4CAF50);
  static const Color pulseLearning = Color(0xFFFF9800);
  static const Color pulseSocialEngagement = Color(0xFF9C27B0);

  // Chart Colors
  static const Color chartBlue = Color(0xFF2196F3);
  static const Color chartGreen = Color(0xFF4CAF50);
  static const Color chartYellow = Color(0xFFFFC107);
  static const Color chartPurple = Color(0xFF9C27B0);
  static const Color chartOrange = Color(0xFFFF5722);
  static const Color chartPink = Color(0xFFE91E63);
  static const Color chartCyan = Color(0xFF00BCD4);
  static const Color chartIndigo = Color(0xFF3F51B5);

  // Shimmer
  static const Color shimmerBase = Color(0xFFE0E0E0);
  static const Color shimmerHighlight = Color(0xFFF5F5F5);

  // Divider
  static const Color divider = Color(0xFFE0E0E0);

  // Status Dot Colors (for heatmap)
  static Color getStatusColor(double score) {
    if (score >= 0.7) return success;
    if (score >= 0.4) return warning;
    return danger;
  }

  static Color getStatusColorWithOpacity(double score) {
    if (score >= 0.7) return successLight;
    if (score >= 0.4) return warningLight;
    return dangerLight;
  }
}
