import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/graph_node.dart';

/// A single interactive node widget rendered on the graph canvas.
class GraphNodeWidget extends StatefulWidget {
  final GraphNode node;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback? onToggleExpand;

  const GraphNodeWidget({
    super.key,
    required this.node,
    required this.onTap,
    required this.onDoubleTap,
    this.onToggleExpand,
  });

  @override
  State<GraphNodeWidget> createState() => _GraphNodeWidgetState();
}

class _GraphNodeWidgetState extends State<GraphNodeWidget>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _pulseAnim;
  bool _hovered = false;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1400),
    );
    _pulseAnim = Tween<double>(begin: 1.0, end: 1.12).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );
    if (widget.node.isSelected) {
      _pulseController.repeat(reverse: true);
    }
  }

  @override
  void didUpdateWidget(GraphNodeWidget old) {
    super.didUpdateWidget(old);
    if (widget.node.isSelected && !_pulseController.isAnimating) {
      _pulseController.repeat(reverse: true);
    } else if (!widget.node.isSelected && _pulseController.isAnimating) {
      _pulseController.stop();
      _pulseController.reset();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final node = widget.node;

    return AnimatedBuilder(
      animation: _pulseAnim,
      builder: (context, child) {
        final scale = node.isSelected ? _pulseAnim.value : (_hovered ? 1.06 : 1.0);
        return Transform.scale(
          scale: scale,
          child: child,
        );
      },
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          onDoubleTap: widget.onDoubleTap,
          child: _buildNodeBody(isDark, node),
        ),
      ),
    ).animate().fadeIn(duration: 280.ms).scale(
          begin: const Offset(0.6, 0.6),
          end: const Offset(1.0, 1.0),
          duration: 320.ms,
          curve: Curves.easeOutBack,
        );
  }

  Widget _buildNodeBody(bool isDark, GraphNode node) {
    switch (node.type) {
      case GraphNodeType.subject:
        return _SubjectNodeWidget(
          node: node,
          isDark: isDark,
          hovered: _hovered,
        );
      case GraphNodeType.topic:
        return _TopicNodeWidget(
          node: node,
          isDark: isDark,
          hovered: _hovered,
          onToggleExpand: widget.onToggleExpand,
        );
      case GraphNodeType.subtopic:
        return _SubtopicNodeWidget(
          node: node,
          isDark: isDark,
          hovered: _hovered,
        );
      case GraphNodeType.aiExpanded:
        return _AiNodeWidget(
          node: node,
          isDark: isDark,
          hovered: _hovered,
        );
    }
  }
}

// ── Subject Node ──────────────────────────────────────────────────────────────
class _SubjectNodeWidget extends StatelessWidget {
  final GraphNode node;
  final bool isDark;
  final bool hovered;

  const _SubjectNodeWidget({
    required this.node,
    required this.isDark,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    final r = node.radius;
    return Container(
      width: r * 2,
      height: r * 2,
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF367FE3), Color(0xFF56C7F2)],
        ),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandAccent.withOpacity(hovered ? 0.55 : 0.35),
            blurRadius: hovered ? 30 : 20,
            spreadRadius: hovered ? 4 : 2,
          ),
          if (node.isSelected)
            BoxShadow(
              color: AppColors.brandAccent.withOpacity(0.60),
              blurRadius: 40,
              spreadRadius: 6,
            ),
        ],
        border: node.isSelected
            ? Border.all(color: Colors.white.withOpacity(0.75), width: 2.5)
            : null,
      ),
      child: ClipOval(
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 4, sigmaY: 4),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                node.label,
                textAlign: TextAlign.center,
                maxLines: 3,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 13.5,
                  fontWeight: FontWeight.w700,
                  letterSpacing: -0.3,
                  fontFamily: 'Inter',
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Topic Node ────────────────────────────────────────────────────────────────
class _TopicNodeWidget extends StatelessWidget {
  final GraphNode node;
  final bool isDark;
  final bool hovered;
  final VoidCallback? onToggleExpand;

  const _TopicNodeWidget({
    required this.node,
    required this.isDark,
    required this.hovered,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? (hovered ? const Color(0xFF1A3A6E) : const Color(0xFF132A4E))
        : (hovered ? const Color(0xFFDDEAFF) : const Color(0xFFEDF4FF));

    final border = node.isSelected
        ? AppColors.brandAccent
        : (isDark
            ? AppColors.brandAccent.withOpacity(0.45)
            : AppColors.brandAccent.withOpacity(0.30));

    return Container(
      constraints: const BoxConstraints(minWidth: 90, maxWidth: 130),
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: border, width: node.isSelected ? 1.8 : 1.2),
        boxShadow: [
          BoxShadow(
            color: AppColors.brandAccent.withOpacity(hovered ? 0.25 : 0.10),
            blurRadius: hovered ? 18 : 8,
            offset: const Offset(0, 3),
          ),
          if (node.isSelected)
            BoxShadow(
              color: AppColors.brandAccent.withOpacity(0.30),
              blurRadius: 24,
              spreadRadius: 2,
            ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Text(
            node.label,
            textAlign: TextAlign.center,
            maxLines: 3,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
              fontSize: 11.5,
              fontWeight: FontWeight.w600,
              letterSpacing: -0.2,
              fontFamily: 'Inter',
            ),
          ),
          const SizedBox(height: 4),
          GestureDetector(
            onTap: onToggleExpand,
            child: AnimatedRotation(
              turns: node.isExpanded ? 0.0 : -0.25,
              duration: const Duration(milliseconds: 220),
              curve: Curves.easeOutCubic,
              child: Icon(
                Icons.keyboard_arrow_down_rounded,
                size: 14,
                color: isDark
                    ? AppColors.darkTextTertiary
                    : AppColors.lightTextTertiary,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ── Subtopic Node ─────────────────────────────────────────────────────────────
class _SubtopicNodeWidget extends StatelessWidget {
  final GraphNode node;
  final bool isDark;
  final bool hovered;

  const _SubtopicNodeWidget({
    required this.node,
    required this.isDark,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    final bg = isDark
        ? (hovered ? AppColors.darkSurfaceContainerHigh : AppColors.darkCard)
        : (hovered ? AppColors.lightSurfaceVariant : AppColors.lightSurface);

    final border = node.isSelected
        ? AppColors.brandAccent
        : (isDark ? AppColors.darkBorder : AppColors.lightBorder);

    return Container(
      constraints: const BoxConstraints(minWidth: 70, maxWidth: 110),
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 7),
      decoration: BoxDecoration(
        color: bg,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: border, width: node.isSelected ? 1.6 : 1.0),
        boxShadow: [
          if (hovered || node.isSelected)
            BoxShadow(
              color: AppColors.brandAccent.withOpacity(0.18),
              blurRadius: 14,
              offset: const Offset(0, 3),
            ),
        ],
      ),
      child: Text(
        node.label,
        textAlign: TextAlign.center,
        maxLines: 3,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
          color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
          fontSize: 10,
          fontWeight: FontWeight.w500,
          fontFamily: 'Inter',
        ),
      ),
    );
  }
}

// ── AI Expanded Node ──────────────────────────────────────────────────────────
class _AiNodeWidget extends StatelessWidget {
  final GraphNode node;
  final bool isDark;
  final bool hovered;

  const _AiNodeWidget({
    required this.node,
    required this.isDark,
    required this.hovered,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      constraints: const BoxConstraints(minWidth: 65, maxWidth: 105),
      padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 6),
      decoration: BoxDecoration(
        color: isDark
            ? AppColors.teal.withOpacity(0.10)
            : AppColors.teal.withOpacity(0.08),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: AppColors.teal.withOpacity(hovered ? 0.70 : 0.45),
          width: 1.0,
        ),
        boxShadow: [
          if (hovered)
            BoxShadow(
              color: AppColors.teal.withOpacity(0.20),
              blurRadius: 12,
            ),
        ],
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.auto_awesome_rounded,
            size: 9,
            color: AppColors.teal.withOpacity(0.80),
          ),
          const SizedBox(width: 4),
          Flexible(
            child: Text(
              node.label,
              textAlign: TextAlign.center,
              maxLines: 3,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: isDark
                    ? AppColors.teal.withOpacity(0.90)
                    : const Color(0xFF1E7A6E),
                fontSize: 9.5,
                fontWeight: FontWeight.w500,
                fontFamily: 'Inter',
              ),
            ),
          ),
        ],
      ),
    );
  }
}
