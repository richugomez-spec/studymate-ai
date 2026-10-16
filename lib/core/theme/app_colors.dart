import 'package:flutter/material.dart';

/// StudyMate AI — Design Tokens
/// Central color palette for both light and dark themes.
abstract final class AppColors {
  // ── Brand Colors ──────────────────────────────────────────────────────────
  static const electricViolet = Color(0xFF7B61FF);
  static const electricVioletLight = Color(0xFF9D87FF);
  static const electricVioletDark = Color(0xFF5B41E8);

  static const skyBlue = Color(0xFF61C9FF);
  static const coral = Color(0xFFFF6B6B);
  static const teal = Color(0xFF4ECDC4);
  static const amber = Color(0xFFFFB347);
  static const emerald = Color(0xFF43D197);

  // ── Dark Theme Surfaces ───────────────────────────────────────────────────
  static const darkBackground = Color(0xFF0D0D12);
  static const darkSurface = Color(0xFF16161E);
  static const darkSurfaceVariant = Color(0xFF1E1E2A);
  static const darkSurfaceContainer = Color(0xFF252535);
  static const darkBorder = Color(0xFF2A2A3D);

  // ── Dark Theme Text ───────────────────────────────────────────────────────
  static const darkTextPrimary = Color(0xFFF0F0FF);
  static const darkTextSecondary = Color(0xFF8B8BA7);
  static const darkTextTertiary = Color(0xFF5A5A72);

  // ── Light Theme Surfaces ──────────────────────────────────────────────────
  static const lightBackground = Color(0xFFF8F7FF);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF0EFF9);
  static const lightSurfaceContainer = Color(0xFFE8E6F5);
  static const lightBorder = Color(0xFFE0DEF0);

  // ── Light Theme Text ──────────────────────────────────────────────────────
  static const lightTextPrimary = Color(0xFF1A1A2E);
  static const lightTextSecondary = Color(0xFF6B6B8A);
  static const lightTextTertiary = Color(0xFF9B9BB5);

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const success = Color(0xFF4ECDC4);
  static const warning = Color(0xFFFFB347);
  static const error = Color(0xFFFF6B6B);
  static const info = Color(0xFF61C9FF);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [electricViolet, skyBlue],
  );

  static const darkCardGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [darkSurface, darkSurfaceVariant],
  );

  static const streakGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFFFF6B35), Color(0xFFFF8E53)],
  );

  static const successGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF4ECDC4), Color(0xFF43D197)],
  );

  // ── Subject Colors ────────────────────────────────────────────────────────
  static const subjectColors = [
    Color(0xFF7B61FF), // violet
    Color(0xFF61C9FF), // sky
    Color(0xFF4ECDC4), // teal
    Color(0xFFFF6B6B), // coral
    Color(0xFFFFB347), // amber
    Color(0xFF43D197), // emerald
    Color(0xFFFF61D2), // pink
    Color(0xFF61FFB3), // mint
  ];
}
