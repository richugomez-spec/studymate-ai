import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'app_colors.dart';
import 'app_radius.dart';
import 'app_typography.dart';

/// Shared Material 3 design system for the app's light and dark workspaces.
abstract final class AppTheme {
  static final ColorScheme _darkScheme = ColorScheme.fromSeed(
    seedColor: AppColors.brandAccent,
    brightness: Brightness.dark,
  ).copyWith(
    primary: AppColors.electricVioletLight,
    onPrimary: const Color(0xFF07172B),
    primaryContainer: const Color(0xFF1B426B),
    onPrimaryContainer: const Color(0xFFD6E8FF),
    secondary: AppColors.skyBlue,
    onSecondary: const Color(0xFF082136),
    secondaryContainer: const Color(0xFF123B55),
    onSecondaryContainer: const Color(0xFFD5F4FF),
    tertiary: AppColors.teal,
    surface: AppColors.darkSurface,
    onSurface: AppColors.darkTextPrimary,
    surfaceContainerLowest: AppColors.darkSurfaceContainerLowest,
    surfaceContainerLow: AppColors.darkSurface,
    surfaceContainer: AppColors.darkCard,
    surfaceContainerHigh: AppColors.darkSurfaceContainer,
    surfaceContainerHighest: AppColors.darkSurfaceVariant,
    onSurfaceVariant: AppColors.darkTextSecondary,
    outline: AppColors.darkBorder,
    outlineVariant: AppColors.darkBorderSubtle,
    shadow: Colors.black,
    scrim: Colors.black87,
    inverseSurface: AppColors.lightSurface,
    onInverseSurface: AppColors.lightTextPrimary,
    inversePrimary: AppColors.electricVioletDark,
  );

  static final ColorScheme _lightScheme = ColorScheme.fromSeed(
    seedColor: AppColors.brandAccent,
    brightness: Brightness.light,
  ).copyWith(
    primary: AppColors.electricVioletDark,
    onPrimary: Colors.white,
    primaryContainer: const Color(0xFFDCEBFF),
    onPrimaryContainer: const Color(0xFF153E70),
    secondary: const Color(0xFF087FA8),
    onSecondary: Colors.white,
    secondaryContainer: const Color(0xFFD8F3FC),
    onSecondaryContainer: const Color(0xFF123B50),
    tertiary: const Color(0xFF168B80),
    surface: AppColors.lightSurface,
    onSurface: AppColors.lightTextPrimary,
    surfaceContainerLowest: Colors.white,
    surfaceContainerLow: const Color(0xFFF8FBFF),
    surfaceContainer: const Color(0xFFF1F6FC),
    surfaceContainerHigh: AppColors.lightSurfaceVariant,
    surfaceContainerHighest: AppColors.lightSurfaceVariant,
    onSurfaceVariant: AppColors.lightTextSecondary,
    outline: AppColors.lightBorder,
    outlineVariant: const Color(0xFFDCE6F1),
    shadow: const Color(0xFF233B59),
    scrim: const Color(0x6614263D),
    inverseSurface: AppColors.darkSurface,
    onInverseSurface: AppColors.darkTextPrimary,
    inversePrimary: AppColors.electricVioletLight,
  );

  static ThemeData get darkTheme => _buildTheme(Brightness.dark, _darkScheme);
  static ThemeData get lightTheme =>
      _buildTheme(Brightness.light, _lightScheme);

  static ThemeData _buildTheme(Brightness brightness, ColorScheme scheme) {
    final isDark = brightness == Brightness.dark;
    final textTheme =
        isDark ? AppTypography.darkTextTheme() : AppTypography.lightTextTheme();
    final canvas =
        isDark ? AppColors.darkBackground : AppColors.lightBackground;
    final card = isDark ? AppColors.darkCard : AppColors.lightSurface;
    final outline = isDark ? AppColors.darkBorder : AppColors.lightBorder;
    final accent = scheme.primary;

    final controlShape = RoundedRectangleBorder(borderRadius: AppRadius.mdAll);
    final cardShape = RoundedRectangleBorder(
      borderRadius: AppRadius.xlAll,
      side: BorderSide(color: outline.withOpacity(isDark ? .72 : .9)),
    );

    return ThemeData(
      useMaterial3: true,
      brightness: brightness,
      colorScheme: scheme,
      scaffoldBackgroundColor: canvas,
      canvasColor: canvas,
      textTheme: textTheme,
      visualDensity: VisualDensity.standard,
      splashColor: accent.withOpacity(.12),
      highlightColor: accent.withOpacity(.07),
      hoverColor: accent.withOpacity(isDark ? .12 : .07),
      focusColor: accent.withOpacity(.15),
      pageTransitionsTheme: const PageTransitionsTheme(
        builders: {
          TargetPlatform.android: _WorkspacePageTransitions(),
          TargetPlatform.iOS: _WorkspacePageTransitions(),
          TargetPlatform.windows: _WorkspacePageTransitions(),
          TargetPlatform.macOS: _WorkspacePageTransitions(),
          TargetPlatform.linux: _WorkspacePageTransitions(),
        },
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: canvas,
        foregroundColor: scheme.onSurface,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 1,
        shadowColor: scheme.shadow.withOpacity(.12),
        centerTitle: false,
        titleTextStyle: textTheme.titleLarge?.copyWith(
          fontWeight: FontWeight.w700,
          letterSpacing: -.25,
        ),
        iconTheme: IconThemeData(color: scheme.onSurface),
        systemOverlayStyle: isDark
            ? SystemUiOverlayStyle.light
                .copyWith(statusBarColor: Colors.transparent)
            : SystemUiOverlayStyle.dark
                .copyWith(statusBarColor: Colors.transparent),
      ),
      cardTheme: CardTheme(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: isDark ? 1.5 : 1,
        shadowColor: scheme.shadow.withOpacity(isDark ? .20 : .08),
        shape: cardShape,
        margin: EdgeInsets.zero,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
          backgroundColor: WidgetStateProperty.resolveWith((states) =>
              states.contains(WidgetState.disabled)
                  ? scheme.onSurface.withOpacity(.12)
                  : accent),
          overlayColor:
              WidgetStatePropertyAll(scheme.onPrimary.withOpacity(.12)),
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          shape: WidgetStatePropertyAll(controlShape),
          elevation: WidgetStateProperty.resolveWith(
              (states) => states.contains(WidgetState.hovered) ? 3 : 0),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: .1)),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: ButtonStyle(
          foregroundColor: WidgetStatePropertyAll(scheme.onPrimary),
          backgroundColor: WidgetStatePropertyAll(accent),
          overlayColor:
              WidgetStatePropertyAll(scheme.onPrimary.withOpacity(.12)),
          minimumSize: const WidgetStatePropertyAll(Size(0, 48)),
          padding: const WidgetStatePropertyAll(
              EdgeInsets.symmetric(horizontal: 20, vertical: 12)),
          shape: WidgetStatePropertyAll(controlShape),
          textStyle: WidgetStatePropertyAll(textTheme.labelLarge
              ?.copyWith(fontWeight: FontWeight.w700, letterSpacing: .1)),
        ),
      ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: accent,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 11),
          shape: controlShape,
        ),
      ),
      outlinedButtonTheme: OutlinedButtonThemeData(
        style: OutlinedButton.styleFrom(
          foregroundColor: accent,
          side: BorderSide(color: accent.withOpacity(.55)),
          padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
          shape: controlShape,
        ),
      ),
      iconButtonTheme: IconButtonThemeData(
        style: IconButton.styleFrom(
          foregroundColor: scheme.onSurfaceVariant,
          hoverColor: accent.withOpacity(.10),
          highlightColor: accent.withOpacity(.14),
          shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: accent,
        foregroundColor: scheme.onPrimary,
        elevation: 3,
        hoverElevation: 6,
        focusElevation: 4,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: scheme.surfaceContainerHigh,
        contentPadding:
            const EdgeInsets.symmetric(horizontal: 16, vertical: 15),
        hintStyle:
            textTheme.bodyMedium?.copyWith(color: scheme.onSurfaceVariant),
        labelStyle: textTheme.bodyMedium,
        floatingLabelStyle:
            TextStyle(color: accent, fontWeight: FontWeight.w600),
        border: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: outline),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: outline.withOpacity(.8)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: accent, width: 1.6),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: AppRadius.lgAll,
          borderSide: BorderSide(color: scheme.error, width: 1.6),
        ),
      ),
      dialogTheme: DialogTheme(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 16,
        shadowColor: scheme.shadow.withOpacity(.24),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xxlAll),
        titleTextStyle: textTheme.titleLarge,
        contentTextStyle: textTheme.bodyMedium,
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor:
            isDark ? const Color(0xFF203750) : const Color(0xFF183451),
        contentTextStyle: textTheme.bodyMedium?.copyWith(color: Colors.white),
        actionTextColor: AppColors.skyBlue,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        insetPadding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
        elevation: 8,
      ),
      bottomSheetTheme: BottomSheetThemeData(
        backgroundColor: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 12,
        modalBackgroundColor: scheme.surfaceContainerLow,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: scheme.surface,
        surfaceTintColor: Colors.transparent,
        indicatorColor: accent.withOpacity(isDark ? .2 : .12),
        indicatorShape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        iconTheme: WidgetStateProperty.resolveWith((states) => IconThemeData(
              color: states.contains(WidgetState.selected)
                  ? accent
                  : scheme.onSurfaceVariant,
              size: 22,
            )),
        labelTextStyle: WidgetStateProperty.resolveWith(
            (states) => textTheme.labelSmall?.copyWith(
                  color: states.contains(WidgetState.selected)
                      ? accent
                      : scheme.onSurfaceVariant,
                  fontWeight: states.contains(WidgetState.selected)
                      ? FontWeight.w700
                      : FontWeight.w500,
                )),
        height: 72,
        elevation: 4,
        shadowColor: scheme.shadow.withOpacity(.08),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: scheme.surface,
        indicatorColor: accent.withOpacity(.14),
        selectedIconTheme: IconThemeData(color: accent),
        unselectedIconTheme: IconThemeData(color: scheme.onSurfaceVariant),
        selectedLabelTextStyle: textTheme.labelMedium?.copyWith(color: accent),
      ),
      listTileTheme: ListTileThemeData(
        iconColor: scheme.onSurfaceVariant,
        textColor: scheme.onSurface,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.mdAll),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      ),
      chipTheme: ChipThemeData(
        backgroundColor: scheme.surfaceContainerHigh,
        selectedColor: accent.withOpacity(.16),
        disabledColor: scheme.onSurface.withOpacity(.08),
        labelStyle: textTheme.labelMedium,
        secondaryLabelStyle: textTheme.labelMedium?.copyWith(color: accent),
        side: BorderSide(color: outline.withOpacity(.7)),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.fullAll),
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
        showCheckmark: false,
      ),
      sliderTheme: SliderThemeData(
        activeTrackColor: accent,
        inactiveTrackColor: accent.withOpacity(.2),
        thumbColor: accent,
        overlayColor: accent.withOpacity(.13),
        valueIndicatorColor: scheme.primaryContainer,
        valueIndicatorTextStyle: textTheme.labelSmall?.copyWith(
          color: scheme.onPrimaryContainer,
        ),
      ),
      switchTheme: SwitchThemeData(
        thumbColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? scheme.onPrimary
                : scheme.outline),
        trackColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? accent.withOpacity(.62)
                : scheme.surfaceContainerHighest),
      ),
      checkboxTheme: CheckboxThemeData(
        fillColor: WidgetStateProperty.resolveWith((states) =>
            states.contains(WidgetState.selected)
                ? accent
                : Colors.transparent),
        checkColor: WidgetStatePropertyAll(scheme.onPrimary),
        side: BorderSide(color: scheme.outline),
        shape: RoundedRectangleBorder(borderRadius: AppRadius.xsAll),
      ),
      radioTheme: RadioThemeData(
        fillColor: WidgetStatePropertyAll(accent),
      ),
      popupMenuTheme: PopupMenuThemeData(
        color: scheme.surfaceContainerLow,
        surfaceTintColor: Colors.transparent,
        elevation: 10,
        shape: RoundedRectangleBorder(borderRadius: AppRadius.lgAll),
        textStyle: textTheme.bodyMedium,
      ),
      tooltipTheme: TooltipThemeData(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF28415C) : const Color(0xFF1C3857),
          borderRadius: AppRadius.smAll,
        ),
        textStyle: const TextStyle(color: Colors.white, fontSize: 12),
        waitDuration: const Duration(milliseconds: 450),
      ),
      progressIndicatorTheme: ProgressIndicatorThemeData(
        color: accent,
        linearTrackColor: accent.withOpacity(.16),
        circularTrackColor: accent.withOpacity(.16),
        refreshBackgroundColor: scheme.surfaceContainerHigh,
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant.withOpacity(.8),
        thickness: 1,
        space: 1,
      ),
      scrollbarTheme: ScrollbarThemeData(
        thumbColor: WidgetStatePropertyAll(scheme.outline.withOpacity(.55)),
        radius: const Radius.circular(20),
        thickness: const WidgetStatePropertyAll(6),
      ),
    );
  }
}

class _WorkspacePageTransitions extends PageTransitionsBuilder {
  const _WorkspacePageTransitions();

  @override
  Widget buildTransitions<T>(
    PageRoute<T> route,
    BuildContext context,
    Animation<double> animation,
    Animation<double> secondaryAnimation,
    Widget child,
  ) {
    final eased =
        CurvedAnimation(parent: animation, curve: Curves.easeOutCubic);
    return FadeTransition(
      opacity: eased,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, .018),
          end: Offset.zero,
        ).animate(eased),
        child: child,
      ),
    );
  }
}
