import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

/// Tasteful, modern page transitions for StudyMate AI.
/// Provides Material 3 Fade Through, subtle Slide Parallax, and Scale/Shared Axis transitions.
abstract final class AppPageTransitions {
  static const Duration defaultDuration = Duration(milliseconds: 280);
  static const Duration slideDuration = Duration(milliseconds: 300);
  static const Duration scaleDuration = Duration(milliseconds: 260);

  /// 1. Fade Through Transition
  /// Recommended for top-level navigation (ShellRoute tabs: Home, Library, AI Chat, Tools, Settings).
  /// Incoming page scales subtly from 0.95 to 1.0 and fades in after outgoing page fades out.
  static Page<T> fadeThrough<T>({
    required Widget child,
    LocalKey? key,
    Duration duration = defaultDuration,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        return _FadeThroughTransition(
          animation: animation,
          secondaryAnimation: secondaryAnimation,
          child: child,
        );
      },
    );
  }

  /// 2. Slide Transition
  /// Recommended for forward drill-downs (Subject details, Unit screens, Analyzer).
  /// Uses subtle parallax: child slides from Offset(0.12, 0) + fades in,
  /// while previous screen shifts back by Offset(-0.04, 0).
  static Page<T> slide<T>({
    required Widget child,
    LocalKey? key,
    AxisDirection direction = AxisDirection.left,
    Duration duration = slideDuration,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curveAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final Offset beginOffset;
        switch (direction) {
          case AxisDirection.left:
            beginOffset = const Offset(0.12, 0.0);
            break;
          case AxisDirection.right:
            beginOffset = const Offset(-0.12, 0.0);
            break;
          case AxisDirection.up:
            beginOffset = const Offset(0.0, 0.08);
            break;
          case AxisDirection.down:
            beginOffset = const Offset(0.0, -0.08);
            break;
        }

        final slideIn = Tween<Offset>(
          begin: beginOffset,
          end: Offset.zero,
        ).animate(curveAnimation);

        final fadeIn = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
        ));

        // Subtle parallax shift for outgoing page
        final secondaryCurve = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final parallaxOut = Tween<Offset>(
          begin: Offset.zero,
          end: Offset(-beginOffset.dx * 0.35, -beginOffset.dy * 0.35),
        ).animate(secondaryCurve);

        final fadeOut = Tween<double>(
          begin: 1.0,
          end: 0.85,
        ).animate(secondaryCurve);

        return SlideTransition(
          position: parallaxOut,
          child: FadeTransition(
            opacity: fadeOut,
            child: SlideTransition(
              position: slideIn,
              child: FadeTransition(
                opacity: fadeIn,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }

  /// 3. Scale Transition
  /// Recommended for modals, study tools, achievements, or focal task dialogs.
  /// Smoothly scales up from 0.92 to 1.0 with a soft fade in.
  static Page<T> scale<T>({
    required Widget child,
    LocalKey? key,
    Duration duration = scaleDuration,
    String? name,
    Object? arguments,
    String? restorationId,
  }) {
    return CustomTransitionPage<T>(
      key: key,
      child: child,
      name: name,
      arguments: arguments,
      restorationId: restorationId,
      transitionDuration: duration,
      reverseTransitionDuration: duration,
      transitionsBuilder: (context, animation, secondaryAnimation, child) {
        final curveAnimation = CurvedAnimation(
          parent: animation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );

        final scaleIn = Tween<double>(
          begin: 0.92,
          end: 1.0,
        ).animate(curveAnimation);

        final fadeIn = Tween<double>(
          begin: 0.0,
          end: 1.0,
        ).animate(CurvedAnimation(
          parent: animation,
          curve: const Interval(0.0, 0.75, curve: Curves.easeOut),
        ));

        // When a subsequent page opens, scale subtly upward
        final secondaryCurve = CurvedAnimation(
          parent: secondaryAnimation,
          curve: Curves.easeOutCubic,
          reverseCurve: Curves.easeInCubic,
        );
        final scaleOut = Tween<double>(
          begin: 1.0,
          end: 1.04,
        ).animate(secondaryCurve);

        final fadeOut = Tween<double>(
          begin: 1.0,
          end: 0.0,
        ).animate(secondaryCurve);

        return ScaleTransition(
          scale: scaleOut,
          child: FadeTransition(
            opacity: fadeOut,
            child: ScaleTransition(
              scale: scaleIn,
              child: FadeTransition(
                opacity: fadeIn,
                child: child,
              ),
            ),
          ),
        );
      },
    );
  }
}

/// Internal implementation of Material 3 Fade Through pattern.
class _FadeThroughTransition extends StatelessWidget {
  final Animation<double> animation;
  final Animation<double> secondaryAnimation;
  final Widget child;

  const _FadeThroughTransition({
    required this.animation,
    required this.secondaryAnimation,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    // Incoming page: fades in from 35% to 100% of duration; scales 0.95 -> 1.0
    final fadeIn = CurvedAnimation(
      parent: animation,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOut),
    );
    final scaleIn = Tween<double>(begin: 0.95, end: 1.0).animate(CurvedAnimation(
      parent: animation,
      curve: const Interval(0.35, 1.0, curve: Curves.easeOutCubic),
    ));

    // Outgoing page: fades out from 0% to 35% of duration; scales 1.0 -> 0.95
    final fadeOut = CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.35, curve: Curves.easeIn),
    );
    final scaleOut = Tween<double>(begin: 1.0, end: 0.95).animate(CurvedAnimation(
      parent: secondaryAnimation,
      curve: const Interval(0.0, 0.35, curve: Curves.easeInCubic),
    ));

    return FadeTransition(
      opacity: Tween<double>(begin: 1.0, end: 0.0).animate(fadeOut),
      child: ScaleTransition(
        scale: scaleOut,
        child: FadeTransition(
          opacity: fadeIn,
          child: ScaleTransition(
            scale: scaleIn,
            child: child,
          ),
        ),
      ),
    );
  }
}
