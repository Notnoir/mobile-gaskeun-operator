import 'package:flutter/material.dart';

class AppColors {
  // Primary Emerald Palette (per PRD & Stitch)
  static const Color primary = Color(0xFF006C49); // Dark Emerald Stitch
  static const Color primaryContainer = Color(0xFF10B981); // Emerald-500
  static const Color onPrimaryContainer = Color(0xFF00422B);
  static const Color primaryDark = Color(0xFF047857); // Emerald-700
  static const Color primaryLight = Color(0xFFD1FAE5); // Emerald-100
  static const Color primaryAccent = Color(0xFF34D399); // Emerald-400

  // Secondary & Accents
  static const Color secondary = Color(0xFF855300);
  static const Color secondaryContainer = Color(0xFFFEA619);
  static const Color tertiary = Color(0xFF416900);
  static const Color tertiaryContainer = Color(0xFF72B400);

  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFBA1A1A); // Red-600
  static const Color dangerLight = Color(0xFFFFDAD6);
  static const Color info = Color(0xFF0EA5E9); // Sky-500
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color success = Color(0xFF10B981);

  // Background & Surfaces (Stitch Modern Palette)
  static const Color background = Color(0xFFF8F9FF);
  static const Color surface = Color(0xFFF8F9FF);
  static const Color surfaceBright = Color(0xFFF8F9FF);
  static const Color surfaceContainer = Color(0xFFE5EEFF);
  static const Color surfaceContainerLow = Color(0xFFEFF4FF);
  static const Color surfaceContainerLowest = Color(0xFFFFFFFF);
  static const Color surfaceContainerHigh = Color(0xFFDCE9FF);
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color outline = Color(0xFF6C7A71);
  static const Color outlineVariant = Color(0xFFBBABF);

  // Text Colors
  static const Color textPrimary = Color(0xFF0B1C30);
  static const Color onSurface = Color(0xFF0B1C30);
  static const Color textSecondary = Color(0xFF3C4A42);
  static const Color onSurfaceVariant = Color(0xFF3C4A42);
  static const Color textMuted = Color(0xFF6C7A71);
  static const Color textLight = Color(0xFFFFFFFF);

  // Gradients
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [primary, primaryDark],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient cardGradient = LinearGradient(
    colors: [Color(0xFF059669), Color(0xFF065F46)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}
