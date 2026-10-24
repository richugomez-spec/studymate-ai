import 'dart:math' as math;

import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/graph_node.dart';

/// Custom painter that renders all graph edges as smooth cubic bezier curves.
class GraphEdgePainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final bool isDark;

  const GraphEdgePainter({
    required this.nodes,
    required this.edges,
    required this.isDark,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final nodeMap = {for (final n in nodes) n.id: n};

    for (final edge in edges) {
      final from = nodeMap[edge.fromId];
      final to = nodeMap[edge.toId];
      if (from == null || to == null) continue;
      if (!from.isVisible || !to.isVisible) continue;

      // Determine if the parent is collapsed
      final parent = nodeMap[to.parentId];
      if (parent != null && !parent.isExpanded) continue;

      _drawEdge(canvas, from, to);
    }
  }

  void _drawEdge(Canvas canvas, GraphNode from, GraphNode to) {
    final Color edgeColor;
    final double strokeWidth;

    switch (to.type) {
      case GraphNodeType.subject:
        return;
      case GraphNodeType.topic:
        edgeColor = isDark
            ? AppColors.brandAccent.withOpacity(0.55)
            : AppColors.brandAccent.withOpacity(0.40);
        strokeWidth = 2.0;
        break;
      case GraphNodeType.subtopic:
        edgeColor = isDark
            ? AppColors.darkBorder.withOpacity(0.80)
            : AppColors.lightBorder.withOpacity(0.95);
        strokeWidth = 1.4;
        break;
      case GraphNodeType.aiExpanded:
        edgeColor = isDark
            ? AppColors.teal.withOpacity(0.50)
            : AppColors.teal.withOpacity(0.40);
        strokeWidth = 1.2;
        break;
    }

    final paint = Paint()
      ..color = to.isHighlighted
          ? AppColors.brandAccent.withOpacity(0.85)
          : (to.isSelected ? AppColors.brandAccent : edgeColor)
      ..strokeWidth =
          to.isSelected || to.isHighlighted ? strokeWidth + 0.8 : strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    // Draw smooth cubic bezier
    final p0 = from.position;
    final p3 = to.position;
    final dx = (p3.dx - p0.dx) * 0.45;
    final dy = (p3.dy - p0.dy) * 0.08; // slight vertical curve
    final p1 = Offset(p0.dx + dx, p0.dy + dy);
    final p2 = Offset(p3.dx - dx, p3.dy - dy);

    final path = Path()
      ..moveTo(p0.dx, p0.dy)
      ..cubicTo(p1.dx, p1.dy, p2.dx, p2.dy, p3.dx, p3.dy);

    // Draw dashed line for AI-expanded edges
    if (to.isAiGenerated) {
      _drawDashedPath(canvas, path, paint);
    } else {
      canvas.drawPath(path, paint);
    }

    // Draw animated dot at midpoint for selected edges
    if (to.isSelected || from.isSelected) {
      final midPaint = Paint()
        ..color = AppColors.brandAccent
        ..style = PaintingStyle.fill;
      final mid = _cubicPoint(p0, p1, p2, p3, 0.5);
      canvas.drawCircle(mid, 3.5, midPaint);
    }
  }

  Offset _cubicPoint(Offset p0, Offset p1, Offset p2, Offset p3, double t) {
    final mt = 1.0 - t;
    return Offset(
      mt * mt * mt * p0.dx +
          3 * mt * mt * t * p1.dx +
          3 * mt * t * t * p2.dx +
          t * t * t * p3.dx,
      mt * mt * mt * p0.dy +
          3 * mt * mt * t * p1.dy +
          3 * mt * t * t * p2.dy +
          t * t * t * p3.dy,
    );
  }

  void _drawDashedPath(Canvas canvas, Path path, Paint paint) {
    const dashLength = 6.0;
    const gapLength = 4.0;
    final metrics = path.computeMetrics();
    for (final metric in metrics) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = math.min(distance + dashLength, metric.length);
        canvas.drawPath(metric.extractPath(distance, end), paint);
        distance += dashLength + gapLength;
      }
    }
  }

  @override
  bool shouldRepaint(GraphEdgePainter oldDelegate) =>
      oldDelegate.nodes != nodes || oldDelegate.edges != edges || oldDelegate.isDark != isDark;
}
