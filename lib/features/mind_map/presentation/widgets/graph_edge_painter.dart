import 'package:flutter/material.dart';
import '../models/graph_node.dart';

/// Smooth animated Bézier curve edge painter for the knowledge tree.
/// Renders NotebookLM-style cubic curves, dashed edges for AI nodes,
/// branch glowing, and animated edge drawing.
class GraphEdgePainter extends CustomPainter {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final double animationProgress; // 0.0 -> 1.0 for edge drawing animation
  final bool isDark;

  static const Color _edgeColor = Color(0xFF5EA9FF);
  static const Color _edgeGlowColor = Color(0xFF3B82F6);
  static const Color _aiEdgeColor = Color(0xFF14B8A6);

  GraphEdgePainter({
    required this.nodes,
    required this.edges,
    this.animationProgress = 1.0,
    this.isDark = true,
  });

  @override
  void paint(Canvas canvas, Size size) {
    if (nodes.isEmpty || edges.isEmpty) return;

    final nodeMap = {for (final n in nodes) n.id: n};

    for (final edge in edges) {
      final from = nodeMap[edge.fromId];
      final to = nodeMap[edge.toId];

      if (from == null || to == null) continue;
      if (!from.isVisible || !to.isVisible) continue;

      // Vertical tree connection:
      // Exit from bottom center of parent, enter at top center of child
      final start = Offset(from.position.dx, from.position.dy + from.height / 2.0);
      final end = Offset(to.position.dx, to.position.dy - to.height / 2.0);

      // Construct cubic Bézier curve
      final deltaY = (end.dy - start.dy).abs();
      final cp1 = Offset(start.dx, start.dy + deltaY * 0.50);
      final cp2 = Offset(end.dx, end.dy - deltaY * 0.50);

      final fullPath = Path()
        ..moveTo(start.dx, start.dy)
        ..cubicTo(cp1.dx, cp1.dy, cp2.dx, cp2.dy, end.dx, end.dy);

      // Handle animated edge drawing (0.0 to 1.0)
      final Path path;
      if (animationProgress < 1.0) {
        path = _extractSubPath(fullPath, animationProgress);
      } else {
        path = fullPath;
      }

      final isAiEdge = edge.isDashed || to.type == GraphNodeType.aiExpanded;
      final isSelectedBranch = from.isSelected || to.isSelected;
      final isHighlighted = from.isHighlighted && to.isHighlighted;

      final baseColor = isAiEdge ? _aiEdgeColor : _edgeColor;

      // Glow pass for selected or highlighted branches
      if (isSelectedBranch || isHighlighted) {
        final glowPaint = Paint()
          ..color = (isAiEdge ? _aiEdgeColor : _edgeGlowColor).withOpacity(0.55)
          ..style = PaintingStyle.stroke
          ..strokeWidth = 5.0
          ..maskFilter = const MaskFilter.blur(BlurStyle.normal, 6);

        if (isAiEdge) {
          _drawDashedPath(canvas, path, glowPaint, dashLength: 6, dashSpace: 4);
        } else {
          canvas.drawPath(path, glowPaint);
        }
      }

      // Base edge paint
      final edgeOpacity = isSelectedBranch
          ? 0.95
          : isHighlighted
              ? 0.85
              : isDark
                  ? 0.50
                  : 0.40;

      final strokeWidth = isSelectedBranch ? 2.5 : 1.8;

      final mainPaint = Paint()
        ..color = baseColor.withOpacity(edgeOpacity)
        ..style = PaintingStyle.stroke
        ..strokeWidth = strokeWidth
        ..strokeCap = StrokeCap.round;

      if (isAiEdge) {
        _drawDashedPath(canvas, path, mainPaint, dashLength: 6, dashSpace: 4);
      } else {
        canvas.drawPath(path, mainPaint);
      }

      // Small subtle connector dot at child entry point
      if (animationProgress > 0.85) {
        final dotPaint = Paint()
          ..color = baseColor.withOpacity(isSelectedBranch ? 1.0 : 0.70)
          ..style = PaintingStyle.fill;
        canvas.drawCircle(end, isSelectedBranch ? 3.5 : 2.5, dotPaint);
      }
    }
  }

  Path _extractSubPath(Path source, double progress) {
    final dest = Path();
    for (final metric in source.computeMetrics()) {
      final extractLength = metric.length * progress.clamp(0.0, 1.0);
      dest.addPath(metric.extractPath(0.0, extractLength), Offset.zero);
    }
    return dest;
  }

  void _drawDashedPath(
    Canvas canvas,
    Path path,
    Paint paint, {
    required double dashLength,
    required double dashSpace,
  }) {
    for (final metric in path.computeMetrics()) {
      double distance = 0.0;
      while (distance < metric.length) {
        final end = (distance + dashLength).clamp(0.0, metric.length);
        final segment = metric.extractPath(distance, end);
        canvas.drawPath(segment, paint);
        distance += dashLength + dashSpace;
      }
    }
  }

  @override
  bool shouldRepaint(covariant GraphEdgePainter oldDelegate) {
    return oldDelegate.animationProgress != animationProgress ||
        oldDelegate.nodes != nodes ||
        oldDelegate.edges != edges ||
        oldDelegate.isDark != isDark;
  }
}
