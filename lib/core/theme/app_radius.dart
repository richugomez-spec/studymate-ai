import 'package:flutter/material.dart';

/// Border radius design tokens
abstract final class AppRadius {
  static const double xs = 3.0; // hairline / micro
  static const double sm = 8.0; // tags / badges / chips
  static const double md = 12.0; // buttons / cards / inputs
  static const double lg = 16.0; // modal containers / panels
  static const double xl = 20.0; // hero modules
  static const double xxl = 24.0;
  static const double full = 999.0; // pills / avatar

  // Pre-built BorderRadius objects
  static final xsAll = BorderRadius.circular(xs);
  static final smAll = BorderRadius.circular(sm);
  static final mdAll = BorderRadius.circular(md);
  static final lgAll = BorderRadius.circular(lg);
  static final xlAll = BorderRadius.circular(xl);
  static final xxlAll = BorderRadius.circular(xxl);
  static final fullAll = BorderRadius.circular(full);

  // Bottom sheets (top corners only)
  static const bottomSheet = BorderRadius.only(
    topLeft: Radius.circular(lg),
    topRight: Radius.circular(lg),
  );
}
