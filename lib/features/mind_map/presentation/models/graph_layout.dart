import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'graph_node.dart';

/// Radial tree layout engine for the knowledge graph.
/// Places nodes in concentric rings around the root without overlap.
class GraphLayoutEngine {
  // Spacing constants
  static const double _topicRingRadius = 240.0;
  static const double _subtopicRingOffset = 160.0;
  static const double _aiExpandedOffset = 120.0;

  /// Compute positions for all visible nodes using a radial layout.
  /// Returns a new list of nodes with updated node positions.
  static List<GraphNode> layout(
    List<GraphNode> nodes,
    List<GraphEdge> edges,
  ) {
    if (nodes.isEmpty) return nodes;

    // Find root (subject node)
    final root = nodes.firstWhere(
      (n) => n.type == GraphNodeType.subject,
      orElse: () => nodes.first,
    );

    // Build adjacency
    final childMap = <String, List<String>>{};
    for (final edge in edges) {
      childMap.putIfAbsent(edge.fromId, () => []).add(edge.toId);
    }

    final updated = <String, Offset>{};
    updated[root.id] = Offset.zero;

    // Topic nodes around subject
    final topics = nodes
        .where((n) =>
            n.type == GraphNodeType.topic &&
            n.parentId == root.id &&
            n.isVisible)
        .toList();

    if (topics.isNotEmpty) {
      final topicAngleStep = (2 * math.pi) / topics.length;
      for (var i = 0; i < topics.length; i++) {
        final angle = i * topicAngleStep - math.pi / 2;
        final x = math.cos(angle) * _topicRingRadius;
        final y = math.sin(angle) * _topicRingRadius;
        updated[topics[i].id] = Offset(x, y);

        // Subtopics around each topic
        if (topics[i].isExpanded) {
          final subtopics = nodes
              .where((n) =>
                  (n.type == GraphNodeType.subtopic ||
                      n.type == GraphNodeType.aiExpanded) &&
                  n.parentId == topics[i].id &&
                  n.isVisible)
              .toList();

          if (subtopics.isNotEmpty) {
            final topicPos = Offset(x, y);
            _layoutChildren(
              parent: topicPos,
              parentAngle: angle,
              children: subtopics,
              ringRadius: _subtopicRingOffset,
              updated: updated,
              nodes: nodes,
              childMap: childMap,
              ringOffset: _aiExpandedOffset,
            );
          }
        }
      }
    }

    // Apply positions
    return nodes.map((n) {
      if (updated.containsKey(n.id)) {
        return n.copyWith(position: updated[n.id]);
      }
      return n;
    }).toList();
  }

  static void _layoutChildren({
    required Offset parent,
    required double parentAngle,
    required List<GraphNode> children,
    required double ringRadius,
    required Map<String, Offset> updated,
    required List<GraphNode> nodes,
    required Map<String, List<String>> childMap,
    required double ringOffset,
  }) {
    if (children.isEmpty) return;

    // Fan the children away from the parent direction
    final spreadAngle = math.min(math.pi * 0.9, children.length * 0.45);
    final startAngle = parentAngle - spreadAngle / 2;
    final step = children.length > 1 ? spreadAngle / (children.length - 1) : 0.0;

    for (var i = 0; i < children.length; i++) {
      final angle = startAngle + i * step;
      final x = parent.dx + math.cos(angle) * ringRadius;
      final y = parent.dy + math.sin(angle) * ringRadius;
      updated[children[i].id] = Offset(x, y);

      // AI-expanded grandchildren
      if (children[i].isExpanded) {
        final grandchildren = nodes
            .where((n) =>
                n.type == GraphNodeType.aiExpanded &&
                n.parentId == children[i].id &&
                n.isVisible)
            .toList();
        if (grandchildren.isNotEmpty) {
          _layoutChildren(
            parent: Offset(x, y),
            parentAngle: angle,
            children: grandchildren,
            ringRadius: ringOffset,
            updated: updated,
            nodes: nodes,
            childMap: childMap,
            ringOffset: 80.0,
          );
        }
      }
    }
  }

  /// Returns a tight bounding box for all visible positioned nodes.
  static Rect computeBounds(List<GraphNode> nodes) {
    if (nodes.isEmpty) return Rect.zero;
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;
    for (final n in nodes) {
      if (!n.isVisible) continue;
      final r = n.radius + 8;
      minX = math.min(minX, n.position.dx - r);
      minY = math.min(minY, n.position.dy - r);
      maxX = math.max(maxX, n.position.dx + r);
      maxY = math.max(maxY, n.position.dy + r);
    }
    if (minX == double.infinity) return Rect.zero;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}
