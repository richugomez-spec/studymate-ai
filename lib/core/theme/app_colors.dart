import 'package:flutter/material.dart';

/// StudyMate AI — Design Tokens
/// Central color palette for both light and dark themes.
abstract final class AppColors {
  // ── Brand Colors & Accents ──────────────────────────────────────────────────
  // Legacy names remain stable for existing widgets; the brand palette is now
  // blue so all existing feature accents update with the shared design system.
  static const electricViolet = Color(0xFF4D91F7);
  static const electricVioletLight = Color(0xFF8AB9FF);
  static const electricVioletDark = Color(0xFF2769C2);
  static const brandAccent = Color(0xFF3C82E8);

  static const skyBlue = Color(0xFF56C7F2);
  static const coral = Color(0xFFF87171);
  static const teal = Color(0xFF49D0C2);
  static const amber = Color(0xFFFBBF24);
  static const emerald = Color(0xFF34D399);

  // ── Stitch Academic Precision Dark Theme Surfaces ─────────────────────────
  static const darkBackground = Color(0xFF081528);
  static const darkSurface = Color(0xFF0D1C31);
  static const darkCard = Color(0xFF11243B);
  static const darkSurfaceVariant = Color(0xFF132A44);
  static const darkSurfaceContainer = Color(0xFF193553);
  static const darkSurfaceContainerHigh = Color(0xFF214263);
  static const darkSurfaceContainerLowest = Color(0xFF09172A);
  static const darkBorder = Color(0xFF23405E);
  static const darkBorderSubtle = Color(0xFF192F49);

  // ── Stitch Academic Precision Dark Theme Text ─────────────────────────────
  static const darkTextPrimary = Color(0xFFEAF2FC);
  static const darkTextSecondary = Color(0xFFA7B9D0);
  static const darkTextTertiary = Color(0xFF7188A4);

  // ── Light Theme Surfaces ──────────────────────────────────────────────────
  static const lightBackground = Color(0xFFF2F7FD);
  static const lightSurface = Color(0xFFFFFFFF);
  static const lightSurfaceVariant = Color(0xFFEAF2FC);
  static const lightSurfaceContainer = Color(0xFFD9E7F7);
  static const lightBorder = Color(0xFFCFDDEE);

  // ── Light Theme Text ──────────────────────────────────────────────────────
  static const lightTextPrimary = Color(0xFF12243B);
  static const lightTextSecondary = Color(0xFF4D627D);
  static const lightTextTertiary = Color(0xFF71859E);

  // ── Semantic Colors ───────────────────────────────────────────────────────
  static const success = Color(0xFF34D399);
  static const warning = Color(0xFFFBBF24);
  static const error = Color(0xFFF87171);
  static const info = Color(0xFF38BDF8);

  // ── Gradients ─────────────────────────────────────────────────────────────
  static const primaryGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [Color(0xFF367FE3), Color(0xFF56C7F2)],
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
    Color(0xFF4D91F7), // blue
    Color(0xFF56C7F2), // sky
    Color(0xFF49D0C2), // teal
    Color(0xFFF27C72), // coral
    Color(0xFFF0B65A), // amber
    Color(0xFF43C996), // emerald
    Color(0xFF6E9FE8), // periwinkle blue
    Color(0xFF61CBA7), // mint
  ];
}
