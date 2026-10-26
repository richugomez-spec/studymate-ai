import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Micro-interaction utilities for StudyMate AI.
/// Provides tactile spring button presses, hover lifts, elevation changes, and refined ripples.

/// 1. Tactile Pressable Wrapper
/// Wraps any widget and adds an iOS/Linear-style tactile spring scale animation on press.
class AppPressable extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final double pressScale;
  final Duration duration;
  final Curve curve;
  final bool enableHaptics;
  final HitTestBehavior behavior;

  const AppPressable({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.pressScale = 0.965,
    this.duration = const Duration(milliseconds: 140),
    this.curve = Curves.easeOutCubic,
    this.enableHaptics = true,
    this.behavior = HitTestBehavior.opaque,
  });

  @override
  State<AppPressable> createState() => _AppPressableState();
}

class _AppPressableState extends State<AppPressable>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
      reverseDuration: widget.duration,
    );

    _scaleAnimation = Tween<double>(
      begin: 1.0,
      end: widget.pressScale,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: widget.curve,
    ));
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    if (widget.onTap != null || widget.onLongPress != null) {
      _controller.forward();
      if (widget.enableHaptics) {
        HapticFeedback.selectionClick();
      }
    }
  }

  void _onTapUp(TapUpDetails details) {
    _controller.reverse();
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: widget.behavior,
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      onTap: widget.onTap,
      onLongPress: widget.onLongPress,
      child: AnimatedBuilder(
        animation: _scaleAnimation,
        builder: (context, child) {
          return Transform.scale(
            scale: _scaleAnimation.value,
            child: child,
          );
        },
        child: widget.child,
      ),
    );
  }
}

/// 2. Interactive Hover Card
/// Responsive card for desktop and mobile with smooth hover lift (-3px),
/// animated elevation, border glow, press scale, and refined ink ripples.
class AppHoverCard extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final VoidCallback? onLongPress;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;
  final Color? hoverBorderColor;
  final Color? borderColor;
  final double borderWidth;
  final double liftDistance;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry margin;
  final Duration duration;
  final bool enablePressScale;
  final Color? glowColor;

  const AppHoverCard({
    required this.child,
    super.key,
    this.onTap,
    this.onLongPress,
    this.borderRadius,
    this.backgroundColor,
    this.hoverBorderColor,
    this.borderColor,
    this.borderWidth = 1.0,
    this.liftDistance = 3.0,
    this.padding = EdgeInsets.zero,
    this.margin = EdgeInsets.zero,
    this.duration = const Duration(milliseconds: 180),
    this.enablePressScale = true,
    this.glowColor,
  });

  @override
  State<AppHoverCard> createState() => _AppHoverCardState();
}

class _AppHoverCardState extends State<AppHoverCard> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = widget.borderRadius ?? AppRadius.lgAll;

    final baseBorderColor = widget.borderColor ??
        (isDark ? AppColors.darkBorder : AppColors.lightBorder);
    final activeHoverBorderColor = widget.hoverBorderColor ??
        (isDark ? AppColors.brandAccent.withOpacity(0.55) : AppColors.brandAccent.withOpacity(0.40));

    final baseBg = widget.backgroundColor ??
        (isDark ? AppColors.darkCard : AppColors.lightSurface);

    final glow = widget.glowColor ?? AppColors.brandAccent;

    // Smooth transform: lift upwards on hover, sink slightly on press
    final double offsetY = _isPressed
        ? 1.0
        : (_isHovered ? -widget.liftDistance : 0.0);
    final double scale = _isPressed && widget.enablePressScale ? 0.985 : 1.0;

    return Container(
      margin: widget.margin,
      child: MouseRegion(
        cursor: widget.onTap != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.basic,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: GestureDetector(
          onTapDown: (_) {
            if (widget.onTap != null) setState(() => _isPressed = true);
          },
          onTapUp: (_) {
            if (_isPressed) setState(() => _isPressed = false);
          },
          onTapCancel: () {
            if (_isPressed) setState(() => _isPressed = false);
          },
          child: AnimatedContainer(
            duration: widget.duration,
            curve: Curves.easeOutCubic,
            transform: Matrix4.identity()
              ..translate(0.0, offsetY)
              ..scale(scale),
            decoration: BoxDecoration(
              color: baseBg,
              borderRadius: radius,
              border: Border.all(
                color: _isHovered ? activeHoverBorderColor : baseBorderColor,
                width: widget.borderWidth,
              ),
              boxShadow: [
                // Base ambient shadow
                BoxShadow(
                  color: Colors.black.withOpacity(
                    isDark ? (_isHovered ? 0.45 : 0.25) : (_isHovered ? 0.12 : 0.04),
                  ),
                  blurRadius: _isHovered ? 20 : 8,
                  offset: Offset(0, _isHovered ? 10 : 3),
                ),
                // Accent glow on hover
                if (_isHovered)
                  BoxShadow(
                    color: glow.withOpacity(isDark ? 0.18 : 0.10),
                    blurRadius: 16,
                    spreadRadius: -2,
                    offset: const Offset(0, 4),
                  ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              borderRadius: radius,
              clipBehavior: Clip.antiAlias,
              child: InkWell(
                onTap: widget.onTap,
                onLongPress: widget.onLongPress,
                splashFactory: InkSparkle.splashFactory,
                splashColor: glow.withOpacity(0.12),
                highlightColor: glow.withOpacity(0.04),
                child: Padding(
                  padding: widget.padding,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

/// 3. Interactive Modern Button
/// Micro-interaction button with press scale, hover glow, and refined ripple.
class AppInteractiveButton extends StatefulWidget {
  final Widget child;
  final VoidCallback? onPressed;
  final Color? backgroundColor;
  final Color? foregroundColor;
  final Color? borderColor;
  final BorderRadius? borderRadius;
  final EdgeInsetsGeometry padding;
  final double elevation;
  final bool isFullWidth;
  final Widget? icon;

  const AppInteractiveButton({
    required this.child,
    super.key,
    this.onPressed,
    this.backgroundColor,
    this.foregroundColor,
    this.borderColor,
    this.borderRadius,
    this.padding = const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
    this.elevation = 0,
    this.isFullWidth = false,
    this.icon,
  });

  @override
  State<AppInteractiveButton> createState() => _AppInteractiveButtonState();
}

class _AppInteractiveButtonState extends State<AppInteractiveButton> {
  bool _isHovered = false;
  bool _isPressed = false;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final radius = widget.borderRadius ?? AppRadius.mdAll;

    final bg = widget.backgroundColor ??
        (isDark ? AppColors.brandAccent : AppColors.brandAccent);
    final fg = widget.foregroundColor ?? Colors.white;

    final double scale = _isPressed ? 0.96 : (_isHovered ? 1.015 : 1.0);

    return AppPressable(
      onTap: widget.onPressed,
      child: MouseRegion(
        cursor: widget.onPressed != null
            ? SystemMouseCursors.click
            : SystemMouseCursors.forbidden,
        onEnter: (_) => setState(() => _isHovered = true),
        onExit: (_) => setState(() => _isHovered = false),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 140),
          curve: Curves.easeOutCubic,
          transform: Matrix4.identity()..scale(scale),
          decoration: BoxDecoration(
            color: bg,
            borderRadius: radius,
            border: widget.borderColor != null
                ? Border.all(color: widget.borderColor!)
                : null,
            boxShadow: [
              if (widget.elevation > 0 || _isHovered)
                BoxShadow(
                  color: bg.withOpacity(_isHovered ? 0.35 : 0.20),
                  blurRadius: _isHovered ? 14 : 6,
                  offset: Offset(0, _isHovered ? 5 : 2),
                ),
            ],
          ),
          child: Material(
            color: Colors.transparent,
            borderRadius: radius,
            clipBehavior: Clip.antiAlias,
            child: InkWell(
              onTap: widget.onPressed,
              splashFactory: InkSparkle.splashFactory,
              splashColor: fg.withOpacity(0.18),
              highlightColor: fg.withOpacity(0.06),
              child: Container(
                width: widget.isFullWidth ? double.infinity : null,
                padding: widget.padding,
                alignment: Alignment.center,
                child: Row(
                  mainAxisSize: widget.isFullWidth
                      ? MainAxisSize.max
                      : MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    if (widget.icon != null) ...[
                      widget.icon!,
                      const SizedBox(width: 8),
                    ],
                    DefaultTextStyle(
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 14,
                        fontWeight: FontWeight.w600,
                        color: fg,
                        letterSpacing: -0.1,
                      ),
                      child: widget.child,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
