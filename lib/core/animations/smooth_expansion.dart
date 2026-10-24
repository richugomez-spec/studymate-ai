import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';

/// Smooth accordion expansion and collapse component for StudyMate AI.
/// Provides smooth animated height changes with easeOutCubic curve,
/// opacity transitions, and synchronized chevron rotation.

/// 1. Smooth Expansion Wrapper
/// Animates height and opacity of any child content when [isExpanded] changes.
class AppSmoothExpansion extends StatelessWidget {
  final Widget child;
  final bool isExpanded;
  final Duration duration;
  final Curve curve;
  final Alignment alignment;

  const AppSmoothExpansion({
    required this.child,
    required this.isExpanded,
    super.key,
    this.duration = const Duration(milliseconds: 260),
    this.curve = Curves.easeOutCubic,
    this.alignment = Alignment.topCenter,
  });

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: duration,
      curve: curve,
      alignment: alignment,
      clipBehavior: Clip.antiAlias,
      child: isExpanded
          ? AnimatedOpacity(
              opacity: isExpanded ? 1.0 : 0.0,
              duration: duration,
              curve: Curves.easeIn,
              child: child,
            )
          : const SizedBox.shrink(),
    );
  }
}

/// 2. Interactive Accordion Expansion Card
/// A complete card with title, subtitle, optional leading icon, rotating trailing chevron,
/// and smooth content expansion.
class AppExpansionCard extends StatefulWidget {
  final Widget title;
  final Widget? subtitle;
  final Widget? leading;
  final Widget child;
  final bool initiallyExpanded;
  final ValueChanged<bool>? onExpansionChanged;
  final EdgeInsetsGeometry padding;
  final EdgeInsetsGeometry headerPadding;
  final BorderRadius? borderRadius;
  final Color? backgroundColor;

  const AppExpansionCard({
    required this.title,
    required this.child,
    super.key,
    this.subtitle,
    this.leading,
    this.initiallyExpanded = false,
    this.onExpansionChanged,
    this.padding = const EdgeInsets.all(16),
    this.headerPadding = const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
    this.borderRadius,
    this.backgroundColor,
  });

  @override
  State<AppExpansionCard> createState() => _AppExpansionCardState();
}

class _AppExpansionCardState extends State<AppExpansionCard> {
  late bool _isExpanded;

  @override
  void initState() {
    super.initState();
    _isExpanded = widget.initiallyExpanded;
  }

  void _toggle() {
    setState(() => _isExpanded = !_isExpanded);
    widget.onExpansionChanged?.call(_isExpanded);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final radius = widget.borderRadius ?? AppRadius.lgAll;
    final bg = widget.backgroundColor ??
        (isDark ? AppColors.darkCard : AppColors.lightSurface);
    final border = isDark ? AppColors.darkBorder : AppColors.lightBorder;

    return Container(
      decoration: BoxDecoration(
        color: bg,
        borderRadius: radius,
        border: Border.all(color: border),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Header
          Material(
            color: Colors.transparent,
            borderRadius: radius,
            child: InkWell(
              onTap: _toggle,
              borderRadius: radius,
              splashColor: AppColors.brandAccent.withOpacity(0.08),
              highlightColor: AppColors.brandAccent.withOpacity(0.03),
              child: Padding(
                padding: widget.headerPadding,
                child: Row(
                  children: [
                    if (widget.leading != null) ...[
                      widget.leading!,
                      const SizedBox(width: 12),
                    ],
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          widget.title,
                          if (widget.subtitle != null) ...[
                            const SizedBox(height: 2),
                            widget.subtitle!,
                          ],
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    // Rotating chevron
                    AnimatedRotation(
                      turns: _isExpanded ? 0.5 : 0.0,
                      duration: const Duration(milliseconds: 240),
                      curve: Curves.easeOutCubic,
                      child: Icon(
                        Icons.keyboard_arrow_down_rounded,
                        color: isDark
                            ? AppColors.darkTextSecondary
                            : AppColors.lightTextSecondary,
                        size: 22,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          // Expanded Content with divider
          AppSmoothExpansion(
            isExpanded: _isExpanded,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Divider(
                  height: 1,
                  color: isDark
                      ? AppColors.darkBorderSubtle
                      : AppColors.lightBorder,
                ),
                Padding(
                  padding: widget.padding,
                  child: widget.child,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
