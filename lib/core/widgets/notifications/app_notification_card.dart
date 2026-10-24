import 'dart:ui';
import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';
import '../../theme/app_radius.dart';
import 'app_notification_type.dart';

/// Modern floating glassmorphic notification card.
class AppNotificationCard extends StatefulWidget {
  final String? title;
  final String message;
  final AppNotificationType type;
  final IconData? icon;
  final Widget? customIcon;
  final String? actionLabel;
  final VoidCallback? onAction;
  final VoidCallback onDismiss;
  final Duration duration;
  final bool showProgressBar;
  final bool dismissible;

  const AppNotificationCard({
    required this.message,
    required this.type,
    required this.onDismiss,
    super.key,
    this.title,
    this.icon,
    this.customIcon,
    this.actionLabel,
    this.onAction,
    this.duration = const Duration(seconds: 4),
    this.showProgressBar = true,
    this.dismissible = true,
  });

  @override
  State<AppNotificationCard> createState() => _AppNotificationCardState();
}

class _AppNotificationCardState extends State<AppNotificationCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _progressController;
  bool _isPaused = false;
  double _dragOffsetY = 0.0;
  double _dragOffsetX = 0.0;

  @override
  void initState() {
    super.initState();
    final hasAutoDismiss = widget.duration > Duration.zero &&
        widget.type != AppNotificationType.loading;

    _progressController = AnimationController(
      vsync: this,
      duration: widget.duration,
    );

    if (hasAutoDismiss) {
      _progressController.reverse(from: 1.0).then((_) {
        if (mounted && !_isPaused) {
          widget.onDismiss();
        }
      });
    }
  }

  @override
  void dispose() {
    _progressController.dispose();
    super.dispose();
  }

  void _pauseTimer() {
    if (_progressController.isAnimating) {
      _progressController.stop();
      setState(() => _isPaused = true);
    }
  }

  void _resumeTimer() {
    if (_isPaused &&
        widget.duration > Duration.zero &&
        widget.type != AppNotificationType.loading) {
      setState(() => _isPaused = false);
      _progressController.reverse(from: _progressController.value).then((_) {
        if (mounted && !_isPaused) {
          widget.onDismiss();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final color = widget.type.color(context);

    final titleText = widget.title ??
        (widget.type == AppNotificationType.undo
            ? null
            : widget.type.defaultTitle);

    final hasAction = (widget.actionLabel != null && widget.onAction != null) ||
        widget.type == AppNotificationType.undo;
    final effectiveActionLabel = widget.actionLabel ??
        (widget.type == AppNotificationType.undo ? 'Undo' : null);

    return MouseRegion(
      onEnter: (_) => _pauseTimer(),
      onExit: (_) => _resumeTimer(),
      child: GestureDetector(
        onVerticalDragUpdate: widget.dismissible
            ? (details) {
                if (details.delta.dy < 0) {
                  setState(() => _dragOffsetY += details.delta.dy);
                }
              }
            : null,
        onVerticalDragEnd: widget.dismissible
            ? (details) {
                if (_dragOffsetY < -20 || (details.primaryVelocity ?? 0) < -200) {
                  widget.onDismiss();
                } else {
                  setState(() => _dragOffsetY = 0.0);
                }
              }
            : null,
        onHorizontalDragUpdate: widget.dismissible
            ? (details) {
                setState(() => _dragOffsetX += details.delta.dx);
              }
            : null,
        onHorizontalDragEnd: widget.dismissible
            ? (details) {
                if (_dragOffsetX.abs() > 60 ||
                    (details.primaryVelocity ?? 0).abs() > 300) {
                  widget.onDismiss();
                } else {
                  setState(() => _dragOffsetX = 0.0);
                }
              }
            : null,
        child: Transform.translate(
          offset: Offset(_dragOffsetX, _dragOffsetY),
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            decoration: BoxDecoration(
              borderRadius: AppRadius.lgAll,
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(isDark ? 0.38 : 0.09),
                  blurRadius: 22,
                  offset: const Offset(0, 8),
                ),
                BoxShadow(
                  color: color.withOpacity(isDark ? 0.16 : 0.08),
                  blurRadius: 18,
                  spreadRadius: -2,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: AppRadius.lgAll,
              child: BackdropFilter(
                filter: ImageFilter.blur(sigmaX: 18, sigmaY: 18),
                child: Container(
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurface.withOpacity(0.85)
                        : Colors.white.withOpacity(0.92),
                    borderRadius: AppRadius.lgAll,
                    border: Border.all(
                      color: color.withOpacity(isDark ? 0.32 : 0.22),
                      width: 1.2,
                    ),
                    gradient: LinearGradient(
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                      colors: [
                        color.withOpacity(isDark ? 0.12 : 0.06),
                        isDark
                            ? AppColors.darkSurface.withOpacity(0.80)
                            : Colors.white.withOpacity(0.90),
                      ],
                      stops: const [0.0, 0.4],
                    ),
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: const EdgeInsets.fromLTRB(14, 12, 10, 12),
                        child: Row(
                          children: [
                            // ── Icon Badge ─────────────────────────────────
                            _buildIconBadge(color, isDark),
                            const SizedBox(width: 12),

                            // ── Title & Message ────────────────────────────
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  if (titleText != null &&
                                      titleText.isNotEmpty) ...[
                                    Text(
                                      titleText,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 13.5,
                                        fontWeight: FontWeight.w700,
                                        letterSpacing: -0.2,
                                        color: isDark
                                            ? AppColors.darkTextPrimary
                                            : AppColors.lightTextPrimary,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                  ],
                                  Text(
                                    widget.message,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12.5,
                                      fontWeight: FontWeight.w400,
                                      height: 1.35,
                                      color: isDark
                                          ? AppColors.darkTextSecondary
                                          : AppColors.lightTextSecondary,
                                    ),
                                  ),
                                ],
                              ),
                            ),

                            // ── Action Button ──────────────────────────────
                            if (hasAction &&
                                effectiveActionLabel != null) ...[
                              const SizedBox(width: 8),
                              _buildActionButton(
                                context,
                                color: color,
                                isDark: isDark,
                                label: effectiveActionLabel,
                              ),
                            ],

                            // ── Close Icon ─────────────────────────────────
                            if (widget.dismissible &&
                                widget.type != AppNotificationType.loading) ...[
                              const SizedBox(width: 4),
                              Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  borderRadius: BorderRadius.circular(16),
                                  onTap: widget.onDismiss,
                                  hoverColor: color.withOpacity(0.12),
                                  child: Padding(
                                    padding: const EdgeInsets.all(6),
                                    child: Icon(
                                      Icons.close_rounded,
                                      size: 16,
                                      color: isDark
                                          ? AppColors.darkTextTertiary
                                          : AppColors.lightTextTertiary,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ],
                        ),
                      ),

                      // ── Animated Progress Bar ────────────────────────────
                      if (widget.showProgressBar &&
                          widget.duration > Duration.zero &&
                          widget.type != AppNotificationType.loading)
                        AnimatedBuilder(
                          animation: _progressController,
                          builder: (context, _) {
                            return ClipRRect(
                              borderRadius: const BorderRadius.vertical(
                                bottom: Radius.circular(15),
                              ),
                              child: LinearProgressIndicator(
                                value: _progressController.value,
                                minHeight: 2.5,
                                backgroundColor: Colors.transparent,
                                valueColor: AlwaysStoppedAnimation<Color>(
                                  color.withOpacity(0.65),
                                ),
                              ),
                            );
                          },
                        ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildIconBadge(Color color, bool isDark) {
    if (widget.customIcon != null) {
      return widget.customIcon!;
    }

    if (widget.type == AppNotificationType.loading) {
      return Container(
        width: 38,
        height: 38,
        decoration: BoxDecoration(
          color: color.withOpacity(isDark ? 0.16 : 0.12),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: color.withOpacity(isDark ? 0.35 : 0.25),
          ),
        ),
        alignment: Alignment.center,
        child: SizedBox(
          width: 18,
          height: 18,
          child: CircularProgressIndicator(
            strokeWidth: 2.2,
            valueColor: AlwaysStoppedAnimation<Color>(color),
          ),
        ),
      );
    }

    final iconData = widget.icon ?? widget.type.defaultIcon;

    return Container(
      width: 38,
      height: 38,
      decoration: BoxDecoration(
        color: color.withOpacity(isDark ? 0.15 : 0.12),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(
          color: color.withOpacity(isDark ? 0.32 : 0.22),
        ),
      ),
      alignment: Alignment.center,
      child: Icon(
        iconData,
        size: 20,
        color: color,
      ),
    );
  }

  Widget _buildActionButton(
    BuildContext context, {
    required Color color,
    required bool isDark,
    required String label,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          widget.onAction?.call();
          widget.onDismiss();
        },
        borderRadius: BorderRadius.circular(8),
        hoverColor: color.withOpacity(0.2),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.18 : 0.12),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.38 : 0.28),
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (widget.type == AppNotificationType.undo) ...[
                Icon(
                  Icons.replay_rounded,
                  size: 14,
                  color: isDark ? Colors.white : color,
                ),
                const SizedBox(width: 4),
              ],
              Text(
                label,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: isDark ? Colors.white : color,
                  letterSpacing: 0.1,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
