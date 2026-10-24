import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../../../../core/theme/app_colors.dart';
import '../models/graph_layout.dart';
import '../models/graph_node.dart';
import 'graph_edge_painter.dart';
import 'graph_node_widget.dart';

/// The interactive canvas that renders and manages the knowledge graph.
/// Supports pan, zoom (mouse wheel + pinch), fit-to-screen, and node dragging.
class GraphCanvas extends StatefulWidget {
  final List<GraphNode> nodes;
  final List<GraphEdge> edges;
  final void Function(GraphNode) onNodeTap;
  final void Function(GraphNode) onNodeDoubleTap;
  final void Function(String topicId) onToggleExpand;
  final TransformationController? transformController;

  const GraphCanvas({
    required this.nodes,
    required this.edges,
    required this.onNodeTap,
    required this.onNodeDoubleTap,
    required this.onToggleExpand,
    super.key,
    this.transformController,
  });

  @override
  State<GraphCanvas> createState() => GraphCanvasState();
}

class GraphCanvasState extends State<GraphCanvas>
    with TickerProviderStateMixin {
  late TransformationController _transformController;
  late AnimationController _animController;
  Animation<Matrix4>? _matrixAnimation;

  static const double _minScale = 0.25;
  static const double _maxScale = 3.0;
  static const double _padding = 120.0;

  @override
  void initState() {
    super.initState();
    _transformController =
        widget.transformController ?? TransformationController();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
  }

  @override
  void dispose() {
    if (widget.transformController == null) {
      _transformController.dispose();
    }
    _animController.dispose();
    super.dispose();
  }

  /// Animate camera to center + fit all nodes in view.
  void fitToScreen(Size viewSize) {
    if (widget.nodes.isEmpty) return;
    final bounds = GraphLayoutEngine.computeBounds(widget.nodes);
    if (bounds.isEmpty) return;

    final scaleX = (viewSize.width - _padding * 2) / bounds.width;
    final scaleY = (viewSize.height - _padding * 2) / bounds.height;
    final scale = math.min(scaleX, scaleY).clamp(_minScale, _maxScale);

    final scaledW = bounds.width * scale;
    final scaledH = bounds.height * scale;
    final tx = (viewSize.width - scaledW) / 2 - bounds.left * scale;
    final ty = (viewSize.height - scaledH) / 2 - bounds.top * scale;

    final target = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);

    _animateToMatrix(target);
  }

  /// Center and zoom to a specific node.
  void centerOn(GraphNode node, Size viewSize) {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final targetScale = math.max(currentScale, 1.2).clamp(_minScale, _maxScale);
    final tx =
        viewSize.width / 2 - node.position.dx * targetScale;
    final ty =
        viewSize.height / 2 - node.position.dy * targetScale;

    final target = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(targetScale);

    _animateToMatrix(target);
  }

  void resetView() {
    _animateToMatrix(Matrix4.identity());
  }

  void _animateToMatrix(Matrix4 target) {
    final current = _transformController.value.clone();
    _matrixAnimation = Matrix4Tween(begin: current, end: target).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeInOutCubic),
    );
    _animController.forward(from: 0).then((_) {
      _transformController.value = target;
    });
    _animController.addListener(() {
      if (_matrixAnimation != null) {
        _transformController.value = _matrixAnimation!.value;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return LayoutBuilder(
      builder: (context, constraints) {
        final viewSize = Size(constraints.maxWidth, constraints.maxHeight);
        return Listener(
          onPointerSignal: (event) {
            if (event is PointerScrollEvent) {
              _handleMouseScroll(event, viewSize);
            }
          },
          child: InteractiveViewer(
            transformationController: _transformController,
            minScale: _minScale,
            maxScale: _maxScale,
            constrained: false,
            boundaryMargin: const EdgeInsets.all(double.infinity),
            child: SizedBox(
              width: 3000,
              height: 3000,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Background grid dots ──────────────────────────────────
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPainter(isDark: isDark),
                    ),
                  ),

                  // ── Canvas origin (offset to center) ──────────────────────
                  Transform.translate(
                    offset: const Offset(1500, 1500),
                    child: Stack(
                      clipBehavior: Clip.none,
                      children: [
                        // Edges layer
                        CustomPaint(
                          painter: GraphEdgePainter(
                            nodes: widget.nodes,
                            edges: widget.edges,
                            isDark: isDark,
                          ),
                          child: const SizedBox(
                            width: 0,
                            height: 0,
                          ),
                        ),
                        // Nodes layer
                        ...widget.nodes
                            .where((n) => n.isVisible)
                            .map((node) => _PositionedNode(
                                  node: node,
                                  onTap: () => widget.onNodeTap(node),
                                  onDoubleTap: () =>
                                      widget.onNodeDoubleTap(node),
                                  onToggleExpand: node.type ==
                                          GraphNodeType.topic
                                      ? () => widget.onToggleExpand(node.id)
                                      : null,
                                )),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  void _handleMouseScroll(PointerScrollEvent event, Size viewSize) {
    final scale = _transformController.value.getMaxScaleOnAxis();
    final delta = event.scrollDelta.dy > 0 ? 0.9 : 1.1;
    final newScale = (scale * delta).clamp(_minScale, _maxScale);
    final focalPoint = event.localPosition;

    // Scale around focal point
    final translation = _transformController.value.getTranslation();
    final focalInScene = Offset(
      (focalPoint.dx - translation.x) / scale,
      (focalPoint.dy - translation.y) / scale,
    );

    final newTx = focalPoint.dx - focalInScene.dx * newScale;
    final newTy = focalPoint.dy - focalInScene.dy * newScale;

    _transformController.value = Matrix4.identity()
      ..translate(newTx, newTy)
      ..scale(newScale);
  }
}

/// Widget that positions a node absolutely on the canvas.
class _PositionedNode extends StatelessWidget {
  final GraphNode node;
  final VoidCallback onTap;
  final VoidCallback onDoubleTap;
  final VoidCallback? onToggleExpand;

  const _PositionedNode({
    required this.node,
    required this.onTap,
    required this.onDoubleTap,
    this.onToggleExpand,
  });

  @override
  Widget build(BuildContext context) {
    // We center the widget on node.position
    return Positioned(
      left: node.position.dx - _estimatedHalfWidth(node),
      top: node.position.dy - _estimatedHalfHeight(node),
      child: GraphNodeWidget(
        key: ValueKey(node.id),
        node: node,
        onTap: onTap,
        onDoubleTap: onDoubleTap,
        onToggleExpand: onToggleExpand,
      ),
    );
  }

  double _estimatedHalfWidth(GraphNode n) {
    switch (n.type) {
      case GraphNodeType.subject:
        return n.radius;
      case GraphNodeType.topic:
        return 65;
      case GraphNodeType.subtopic:
        return 55;
      case GraphNodeType.aiExpanded:
        return 52;
    }
  }

  double _estimatedHalfHeight(GraphNode n) {
    switch (n.type) {
      case GraphNodeType.subject:
        return n.radius;
      case GraphNodeType.topic:
        return 30;
      case GraphNodeType.subtopic:
        return 22;
      case GraphNodeType.aiExpanded:
        return 20;
    }
  }
}

/// Subtle background dot grid
class _GridPainter extends CustomPainter {
  final bool isDark;
  const _GridPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = isDark
          ? AppColors.darkBorderSubtle.withOpacity(0.35)
          : AppColors.lightBorder.withOpacity(0.55)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.fill;

    const spacing = 36.0;
    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), 1.0, paint);
      }
    }
  }

  @override
  bool shouldRepaint(_GridPainter old) => old.isDark != isDark;
}
