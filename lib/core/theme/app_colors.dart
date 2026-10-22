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
  static const darkBackground = Color(0xFF090A0D); // Deep Obsidian Canvas
  static const darkSurface = Color(0xFF111217); // Level 1 Surface
  static const darkCard = Color(0xFF16171E); // Card background
  static const darkSurfaceVariant = Color(0xFF16171E); // Level 2 Card Surface
  static const darkSurfaceContainer = Color(0xFF1D1E26); // Level 3 Raised
  static const darkSurfaceContainerHigh = Color(0xFF242630); // Level 4 Hover/Active
  static const darkSurfaceContainerLowest = Color(0xFF0C0D11);
  static const darkBorder = Color(0xFF232530); // Subtle 1px hairline border
  static const darkBorderSubtle = Color(0xFF1A1B23); // Whisper border

  // ── Stitch Academic Precision Dark Theme Text ─────────────────────────────
  static const darkTextPrimary = Color(0xFFEEEEF0); // 95% opacity white
  static const darkTextSecondary = Color(0xFF9496A1); // 60% opacity calm stone
  static const darkTextTertiary = Color(0xFF5A5C66); // 35% muted caption/folio

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
