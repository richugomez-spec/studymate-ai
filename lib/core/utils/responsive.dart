import 'package:flutter/material.dart';

/// StudyMate AI — Responsive Utility
///
/// Single source of truth for all breakpoint-driven layout decisions.
/// Every screen and widget should use this instead of hardcoded sizes.
class Responsive {
  Responsive._();

  // ── Breakpoints ────────────────────────────────────────────────────────────
  static const double _mobileMax = 600;
  static const double _tabletMax = 1024;

  static bool isMobile(BuildContext context) =>
      MediaQuery.sizeOf(context).width < _mobileMax;

  static bool isTablet(BuildContext context) {
    final w = MediaQuery.sizeOf(context).width;
    return w >= _mobileMax && w < _tabletMax;
  }

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= _tabletMax;

  static bool isMobileW(double width) => width < _mobileMax;
  static bool isTabletW(double width) =>
      width >= _mobileMax && width < _tabletMax;
  static bool isDesktopW(double width) => width >= _tabletMax;

  // ── Screen dimensions ──────────────────────────────────────────────────────
  static double screenWidth(BuildContext context) =>
      MediaQuery.sizeOf(context).width;

  static double screenHeight(BuildContext context) =>
      MediaQuery.sizeOf(context).height;

  // ── Responsive value selector ──────────────────────────────────────────────
  /// Returns [mobile], [tablet], or [desktop] value based on screen width.
  static T value<T>(
    BuildContext context, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktop(context)) return desktop;
    if (isTablet(context)) return tablet ?? desktop;
    return mobile;
  }

  static T valueW<T>(
    double width, {
    required T mobile,
    T? tablet,
    required T desktop,
  }) {
    if (isDesktopW(width)) return desktop;
    if (isTabletW(width)) return tablet ?? desktop;
    return mobile;
  }

  // ── Padding ────────────────────────────────────────────────────────────────
  static EdgeInsets pagePadding(BuildContext context) => EdgeInsets.symmetric(
        horizontal: value(context,
            mobile: 16.0, tablet: 24.0, desktop: 32.0),
        vertical: 20,
      );

  static EdgeInsets pagePaddingW(double width) => EdgeInsets.symmetric(
        horizontal: valueW(width, mobile: 16.0, tablet: 24.0, desktop: 32.0),
        vertical: 20,
      );

  static double horizontalPadding(BuildContext context) =>
      value(context, mobile: 16.0, tablet: 24.0, desktop: 32.0);

  static double horizontalPaddingW(double width) =>
      valueW(width, mobile: 16.0, tablet: 24.0, desktop: 32.0);

  // ── Typography ─────────────────────────────────────────────────────────────
  static double displayFont(BuildContext context) =>
      value(context, mobile: 22.0, tablet: 26.0, desktop: 30.0);

  static double headingFont(BuildContext context) =>
      value(context, mobile: 18.0, tablet: 21.0, desktop: 24.0);

  static double titleFont(BuildContext context) =>
      value(context, mobile: 15.0, tablet: 17.0, desktop: 18.0);

  static double bodyFont(BuildContext context) =>
      value(context, mobile: 13.0, tablet: 14.0, desktop: 14.0);

  static double captionFont(BuildContext context) =>
      value(context, mobile: 11.0, tablet: 12.0, desktop: 12.0);

  static double labelFont(BuildContext context) =>
      value(context, mobile: 10.0, tablet: 11.0, desktop: 11.0);

  // Width-based font helpers (for use inside LayoutBuilder)
  static double displayFontW(double width) =>
      valueW(width, mobile: 22.0, tablet: 26.0, desktop: 30.0);

  static double headingFontW(double width) =>
      valueW(width, mobile: 18.0, tablet: 21.0, desktop: 24.0);

  static double titleFontW(double width) =>
      valueW(width, mobile: 15.0, tablet: 17.0, desktop: 18.0);

  static double bodyFontW(double width) =>
      valueW(width, mobile: 13.0, tablet: 14.0, desktop: 14.0);

  static double captionFontW(double width) =>
      valueW(width, mobile: 11.0, tablet: 12.0, desktop: 12.0);

  // ── Icon sizes ─────────────────────────────────────────────────────────────
  static double iconSm(BuildContext context) =>
      value(context, mobile: 16.0, tablet: 18.0, desktop: 18.0);

  static double iconMd(BuildContext context) =>
      value(context, mobile: 20.0, tablet: 22.0, desktop: 24.0);

  static double iconLg(BuildContext context) =>
      value(context, mobile: 24.0, tablet: 28.0, desktop: 32.0);

  // ── Grid cross-axis count ──────────────────────────────────────────────────
  static int gridColumns(BuildContext context,
      {int mobile = 2, int tablet = 3, int desktop = 4}) =>
      value(context, mobile: mobile, tablet: tablet, desktop: desktop);

  static int gridColumnsW(double width,
      {int mobile = 2, int tablet = 3, int desktop = 4}) =>
      valueW(width, mobile: mobile, tablet: tablet, desktop: desktop);

  // ── Max content width (to prevent content stretching too wide on big screens)
  static double maxContentWidth(BuildContext context) =>
      value(context, mobile: double.infinity, tablet: 760.0, desktop: 960.0);

  static BoxConstraints contentConstraints(BuildContext context) =>
      BoxConstraints(
          maxWidth: value(context,
              mobile: double.infinity, tablet: 760.0, desktop: 960.0));

  // ── Card / dialog helpers ──────────────────────────────────────────────────
  static double cardRadius(BuildContext context) =>
      value(context, mobile: 12.0, tablet: 14.0, desktop: 16.0);

  static double cardPadding(BuildContext context) =>
      value(context, mobile: 14.0, tablet: 18.0, desktop: 20.0);

  static EdgeInsets cardEdgeInsets(BuildContext context) {
    final p = cardPadding(context);
    return EdgeInsets.all(p);
  }

  /// Wrap this around your dialog content on mobile to show as bottom sheet.
  static Future<T?> showAdaptiveDialog<T>({
    required BuildContext context,
    required WidgetBuilder builder,
    bool isDismissible = true,
  }) {
    if (isMobile(context)) {
      return showModalBottomSheet<T>(
        context: context,
        isScrollControlled: true,
        isDismissible: isDismissible,
        useSafeArea: true,
        shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
        ),
        builder: builder,
      );
    }
    return showDialog<T>(
      context: context,
      barrierDismissible: isDismissible,
      builder: (ctx) => Dialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 520),
          child: builder(ctx),
        ),
      ),
    );
  }

  // ── Spacing ────────────────────────────────────────────────────────────────
  static double spacingXs(BuildContext context) =>
      value(context, mobile: 8.0, tablet: 10.0, desktop: 12.0);

  static double spacingSm(BuildContext context) =>
      value(context, mobile: 12.0, tablet: 16.0, desktop: 20.0);

  static double spacingMd(BuildContext context) =>
      value(context, mobile: 16.0, tablet: 20.0, desktop: 24.0);

  static double spacingLg(BuildContext context) =>
      value(context, mobile: 24.0, tablet: 28.0, desktop: 32.0);

  // Width-based variants
  static double spacingXsW(double w) =>
      valueW(w, mobile: 8.0, tablet: 10.0, desktop: 12.0);
  static double spacingSmW(double w) =>
      valueW(w, mobile: 12.0, tablet: 16.0, desktop: 20.0);
  static double spacingMdW(double w) =>
      valueW(w, mobile: 16.0, tablet: 20.0, desktop: 24.0);
  static double spacingLgW(double w) =>
      valueW(w, mobile: 24.0, tablet: 28.0, desktop: 32.0);
}

/// Mixin that provides [screenWidth] and [screenHeight] shortcuts.
mixin ResponsiveMixin<T extends StatefulWidget> on State<T> {
  double get screenWidth => MediaQuery.sizeOf(context).width;
  double get screenHeight => MediaQuery.sizeOf(context).height;
  bool get isMobile => Responsive.isMobile(context);
  bool get isTablet => Responsive.isTablet(context);
  bool get isDesktop => Responsive.isDesktop(context);
}
