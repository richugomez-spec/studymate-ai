import 'package:flutter/material.dart';

/// Border radius design tokens
abstract final class AppRadius {
  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 12.0;
  static const double lg = 16.0;
  static const double xl = 20.0;
  static const double xxl = 24.0;
  static const double full = 100.0;

  // Pre-built BorderRadius objects
  static final xsAll = BorderRadius.circular(xs);
  static final smAll = BorderRadius.circular(sm);
  static final mdAll = BorderRadius.circular(md);
  static final lgAll = BorderRadius.circular(lg);
  static final xlAll = BorderRadius.circular(xl);
  static final xxlAll = BorderRadius.circular(xxl);
  static final fullAll = BorderRadius.circular(full);

  // Bottom sheets (top corners only)
  static final bottomSheet = const BorderRadius.only(
    topLeft: Radius.circular(xxl),
    topRight: Radius.circular(xxl),
  );
}
