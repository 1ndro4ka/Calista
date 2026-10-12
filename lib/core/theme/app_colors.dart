import 'package:flutter/material.dart';

/// Central design tokens for Calista application.
/// Clean, restrained light-theme palette without neon, acid, or flashy gradients.
abstract final class AppColors {
  // Primary brand colors (Restrained Deep Slate & Indigo-Blue Accent)
  static const Color primary = Color(0xFF1E293B); // Slate 800
  static const Color primaryDark = Color(0xFF0F172A); // Slate 900
  static const Color primaryLight = Color(0xFF334155); // Slate 700

  static const Color accent = Color(0xFF2563EB); // Royal Blue 600
  static const Color accentLight = Color(0xFFEFF6FF); // Royal Blue 50
  static const Color accentHover = Color(0xFF1D4ED8); // Royal Blue 700

  // Backgrounds & Surfaces
  static const Color background = Color(0xFFF8FAFC); // Slate 50
  static const Color surface = Color(0xFFFFFFFF);
  static const Color surfaceElevated = Color(0xFFFFFFFF);
  static const Color surfaceSubtle = Color(0xFFF1F5F9); // Slate 100

  // Borders & Dividers
  static const Color border = Color(0xFFE2E8F0); // Slate 200
  static const Color borderSubtle = Color(0xFFEDF2F7);
  static const Color borderFocused = Color(0xFF2563EB);

  // Typography / Text Colors
  static const Color textPrimary = Color(0xFF0F172A); // Slate 900
  static const Color textSecondary = Color(0xFF475569); // Slate 600
  static const Color textTertiary = Color(0xFF94A3B8); // Slate 400
  static const Color textInverse = Color(0xFFFFFFFF);

  // Status & Semantic Feedback
  static const Color success = Color(0xFF059669); // Emerald 600
  static const Color successLight = Color(0xFFECFDF5);
  static const Color warning = Color(0xFFD97706); // Amber 600
  static const Color warningLight = Color(0xFFFFFBEB);
  static const Color error = Color(0xFFDC2626); // Red 600
  static const Color errorLight = Color(0xFFFEF2F2);
  static const Color info = Color(0xFF0284C7); // Sky 600
  static const Color infoLight = Color(0xFFF0F9FF);

  // Skeleton / Shimmer
  static const Color shimmerBase = Color(0xFFE2E8F0);
  static const Color shimmerHighlight = Color(0xFFF8FAFC);

  // Overlays
  static const Color scrim = Color(0x33000000);
}
