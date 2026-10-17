import 'package:flutter/material.dart';

/// StudyMate AI — Design Tokens
/// Central color palette for both light and dark themes.
abstract final class AppColors {
  // ── Brand Colors & Accents ──────────────────────────────────────────────────
  static const electricViolet = Color(0xFF8B5CF6);
  static const electricVioletLight = Color(0xFFA78BFA);
  static const electricVioletDark = Color(0xFF6D28D9);
  static const brandAccent = Color(0xFF7C3AED);

  static const skyBlue = Color(0xFF38BDF8);
  static const coral = Color(0xFFF87171);
  static const teal = Color(0xFF2DD4BF);
  static const amber = Color(0xFFFBBF24);
  static const emerald = Color(0xFF34D399);

  // ── Stitch Academic Precision Dark Theme Surfaces ─────────────────────────
  static const darkBackground = Color(0xFF0F0F12);
  static const darkSurface = Color(0xFF141418);
  static const darkSurfaceVariant = Color(0xFF1B1B20);
  static const darkSurfaceContainer = Color(0xFF22222A);
  static const darkSurfaceContainerHigh = Color(0xFF2A2A34);
  static const darkSurfaceContainerLowest = Color(0xFF0B0B0E);
  static const darkBorder = Color(0xFF2E2E3C);
  static const darkBorderSubtle = Color(0xFF232330);

  // ── Stitch Academic Precision Dark Theme Text ─────────────────────────────
  static const darkTextPrimary = Color(0xFFEDEDF2);
  static const darkTextSecondary = Color(0xFF9E9EAF);
  static const darkTextTertiary = Color(0xFF6C6C82);

  // ── Light Theme Surfaces ──────────────────────────────────────────────────
  static const lightBackground = Color(0xFFF8F9FC);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFF1F5F9);
  static const lightSurfaceContainer = Color(0xFFE2E8F0);
  static const lightBorder = Color(0xFFCBD5E1);

  // ── Light Theme Text ──────────────────────────────────────────────────────
  static const lightTextPrimary = Color(0xFF0F172A);
  static const lightTextSecondary = Color(0xFF475569);
  static const lightTextTertiary = Color(0xFF64748B);

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);
  static const info = Color(0xFF38BDF8);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF7C3AED), Color(0xFF38BDF8)],
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
