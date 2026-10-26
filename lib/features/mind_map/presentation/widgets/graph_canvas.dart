import 'dart:math' as math;
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';

import '../models/graph_layout.dart';
import '../models/graph_node.dart';
import 'graph_edge_painter.dart';
import 'graph_node_widget.dart';

/// The interactive knowledge tree canvas.
/// Supports smooth pan, mouse wheel zoom, pinch zoom, animated edge drawing,
/// double-tap node centering, and camera transitions.
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
  late AnimationController _cameraController;
  late AnimationController _edgeDrawController;
  Animation<Matrix4>? _matrixAnimation;

  static const double _minScale = 0.20;
  static const double _maxScale = 2.8;
  static const double _canvasSize = 6000.0;
  static const double _canvasCenter = _canvasSize / 2.0;

  @override
  void initState() {
    super.initState();
    _transformController =
        widget.transformController ?? TransformationController();

    _cameraController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 550),
    );

    // Animated edge drawing controller
    _edgeDrawController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    )..forward();
  }

  @override
  void didUpdateWidget(GraphCanvas oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Trigger animated edge drawing if nodes count or edges change
    if (oldWidget.nodes.length != widget.nodes.length ||
        oldWidget.edges.length != widget.edges.length) {
      _edgeDrawController.forward(from: 0.0);
    }
  }

  @override
  void dispose() {
    if (widget.transformController == null) {
      _transformController.dispose();
    }
    _cameraController.dispose();
    _edgeDrawController.dispose();
    super.dispose();
  }

  /// Animate camera to frame all visible nodes comfortably on screen.
  void fitToScreen(Size viewSize) {
    if (widget.nodes.isEmpty) return;
    final bounds = GraphLayoutEngine.computeBounds(widget.nodes);
    if (bounds.isEmpty) return;

    const padding = 100.0;
    final availableW = math.max(100.0, viewSize.width - padding * 2);
    final availableH = math.max(100.0, viewSize.height - padding * 2);

    final scaleX = availableW / bounds.width;
    final scaleY = availableH / bounds.height;
    final scale = math.min(scaleX, scaleY).clamp(_minScale, 1.25);

    final boundsCenter = bounds.center;
    final canvasTargetX = _canvasCenter + boundsCenter.dx;
    final canvasTargetY = _canvasCenter + boundsCenter.dy;

    final tx = viewSize.width / 2.0 - canvasTargetX * scale;
    final ty = viewSize.height / 2.0 - canvasTargetY * scale;

    final target = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(scale);

    _animateToMatrix(target);
  }

  /// Animate camera to center on a specific node.
  void centerOn(GraphNode node, Size viewSize) {
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final targetScale =
        math.max(currentScale, 1.15).clamp(_minScale, _maxScale);

    final canvasTargetX = _canvasCenter + node.position.dx;
    final canvasTargetY = _canvasCenter + node.position.dy;

    final tx = viewSize.width / 2.0 - canvasTargetX * targetScale;
    final ty = viewSize.height / 2.0 - canvasTargetY * targetScale;

    final target = Matrix4.identity()
      ..translate(tx, ty)
      ..scale(targetScale);

    _animateToMatrix(target);
  }

  void resetView(Size viewSize) {
    fitToScreen(viewSize);
  }

  void zoomIn(Size viewSize) {
    final current = _transformController.value.getMaxScaleOnAxis();
    final targetScale = (current * 1.25).clamp(_minScale, _maxScale);
    _zoomToScale(targetScale, viewSize);
  }

  void zoomOut(Size viewSize) {
    final current = _transformController.value.getMaxScaleOnAxis();
    final targetScale = (current * 0.80).clamp(_minScale, _maxScale);
    _zoomToScale(targetScale, viewSize);
  }

  void _zoomToScale(double targetScale, Size viewSize) {
    final currentMatrix = _transformController.value;
    final currentScale = currentMatrix.getMaxScaleOnAxis();
    if (currentScale <= 0) return;

    final cx = viewSize.width / 2.0;
    final cy = viewSize.height / 2.0;

    final currentTx = currentMatrix.storage[12];
    final currentTy = currentMatrix.storage[13];

    final canvasX = (cx - currentTx) / currentScale;
    final canvasY = (cy - currentTy) / currentScale;

    final newTx = cx - canvasX * targetScale;
    final newTy = cy - canvasY * targetScale;

    final target = Matrix4.identity()
      ..translate(newTx, newTy)
      ..scale(targetScale);

    _animateToMatrix(target);
  }

  void _animateToMatrix(Matrix4 target) {
    final current = _transformController.value.clone();
    _matrixAnimation = Matrix4Tween(begin: current, end: target).animate(
      CurvedAnimation(parent: _cameraController, curve: Curves.easeOutCubic),
    );
    _cameraController.forward(from: 0).then((_) {
      _transformController.value = target;
    });
    _cameraController.addListener(() {
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
              width: _canvasSize,
              height: _canvasSize,
              child: Stack(
                clipBehavior: Clip.none,
                children: [
                  // ── Dotted grid background pattern ──────────────────────────
                  Positioned.fill(
                    child: CustomPaint(
                      painter: _GridPatternPainter(isDark: isDark),
                    ),
                  ),

                  // Graph origin is the center of the canvas. Keeping every
                  // node inside this Stack's bounds is required for hit tests.
                  Stack(
                    clipBehavior: Clip.none,
                    children: [
                      // Layer 1: Bézier Curves Edge Painter with animated draw
                      Positioned.fill(
                        child: AnimatedBuilder(
                          animation: _edgeDrawController,
                          builder: (context, _) {
                            return CustomPaint(
                              painter: GraphEdgePainter(
                                nodes: widget.nodes,
                                edges: widget.edges,
                                animationProgress: _edgeDrawController.value,
                                isDark: isDark,
                                originOffset: const Offset(
                                  _canvasCenter,
                                  _canvasCenter,
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      // Layer 2: Node widgets share the same positive canvas space.
                      for (final node in widget.nodes)
                        if (node.isVisible)
                          AnimatedPositioned(
                            duration: const Duration(milliseconds: 300),
                            curve: Curves.easeOutCubic,
                            left: _canvasCenter +
                                node.position.dx -
                                node.width / 2.0,
                            top: _canvasCenter +
                                node.position.dy -
                                node.height / 2.0,
                            child: GraphNodeWidget(
                              node: node,
                              onTap: () {
                                debugPrint(
                                    'CANVAS RECEIVED NODE ${node.label}');
                                widget.onNodeTap(node);
                              },
                              onDoubleTap: () => widget.onNodeDoubleTap(node),
                              onToggleExpand: node.type == GraphNodeType.topic
                                  ? () => widget.onToggleExpand(node.id)
                                  : null,
                            ),
                          ),
                    ],
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
    final currentScale = _transformController.value.getMaxScaleOnAxis();
    final zoomFactor = event.scrollDelta.dy > 0 ? 0.90 : 1.10;
    final newScale = (currentScale * zoomFactor).clamp(_minScale, _maxScale);

    final focalX = event.localPosition.dx;
    final focalY = event.localPosition.dy;

    final currentTx = _transformController.value.storage[12];
    final currentTy = _transformController.value.storage[13];

    final canvasX = (focalX - currentTx) / currentScale;
    final canvasY = (focalY - currentTy) / currentScale;

    final newTx = focalX - canvasX * newScale;
    final newTy = focalY - canvasY * newScale;

    setState(() {
      _transformController.value = Matrix4.identity()
        ..translate(newTx, newTy)
        ..scale(newScale);
    });
  }
}

/// Dotted grid background painter for the knowledge tree canvas.
class _GridPatternPainter extends CustomPainter {
  final bool isDark;
  const _GridPatternPainter({required this.isDark});

  @override
  void paint(Canvas canvas, Size size) {
    final dotPaint = Paint()
      ..color = isDark
          ? const Color(0xFF1E3A5F).withOpacity(0.35)
          : const Color(0xFF94A3B8).withOpacity(0.20)
      ..style = PaintingStyle.fill;

    const spacing = 32.0;
    const radius = 1.2;

    for (double x = 0; x < size.width; x += spacing) {
      for (double y = 0; y < size.height; y += spacing) {
        canvas.drawCircle(Offset(x, y), radius, dotPaint);
      }
    }
  }

  @override
  bool shouldRepaint(covariant _GridPatternPainter oldDelegate) =>
      oldDelegate.isDark != isDark;
}
