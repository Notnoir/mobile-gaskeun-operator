import 'package:flutter/material.dart';

class AppColors {
  // Primary Emerald Palette (per PRD)
  static const Color primary = Color(0xFF10B981); // Emerald-500
  static const Color primaryDark = Color(0xFF047857); // Emerald-700
  static const Color primaryLight = Color(0xFFD1FAE5); // Emerald-100
  static const Color primaryAccent = Color(0xFF34D399); // Emerald-400

  // Secondary & Accents
  static const Color warning = Color(0xFFF59E0B); // Amber-500
  static const Color warningLight = Color(0xFFFEF3C7);
  static const Color danger = Color(0xFFEF4444); // Red-500
  static const Color dangerLight = Color(0xFFFEE2E2);
  static const Color info = Color(0xFF0EA5E9); // Sky-500
  static const Color infoLight = Color(0xFFE0F2FE);
  static const Color success = Color(0xFF10B981);

  // Background & Surfaces
  static const Color background = Color(0xFFF9FAFB); // Gray-50
  static const Color surface = Color(0xFFFFFFFF); // White
  static const Color cardBorder = Color(0xFFE5E7EB); // Gray-200

  // Text Colors
  static const Color textPrimary = Color(0xFF111827); // Gray-900
  static const Color textSecondary = Color(0xFF4B5563); // Gray-600
  static const Color textMuted = Color(0xFF9CA3AF); // Gray-400
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
