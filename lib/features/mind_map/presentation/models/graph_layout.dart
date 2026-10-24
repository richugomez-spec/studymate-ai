import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'graph_node.dart';

/// State-of-the-art Buchheim-Walker Tidier Tree Layout Engine.
/// Computes non-overlapping, aesthetic hierarchical tree coordinates
/// in O(N) linear time according to the Buchheim-Walker algorithm.
class GraphLayoutEngine {
  // Spacing parameters
  static const double _levelSeparation = 135.0; // vertical spacing between levels
  static const double _siblingSeparation = 24.0; // horizontal gap between sibling nodes
  static const double _subtreeSeparation = 48.0; // horizontal gap between distinct subtrees

  /// Computes hierarchical positions for all visible nodes.
  /// Returns a new list of nodes with updated node positions.
  static List<GraphNode> layout(
    List<GraphNode> nodes,
    List<GraphEdge> edges,
  ) {
    if (nodes.isEmpty) return nodes;

    // Find root node (Subject)
    final root = nodes.firstWhere(
      (n) => n.type == GraphNodeType.subject,
      orElse: () => nodes.first,
    );

    // Build parent-to-children map based on edges and visibility
    final nodeById = {for (final n in nodes) n.id: n};
    final childrenMap = <String, List<String>>{};
    for (final edge in edges) {
      final childNode = nodeById[edge.toId];
      if (childNode != null && childNode.isVisible) {
        childrenMap.putIfAbsent(edge.fromId, () => []).add(edge.toId);
      }
    }

    // Build layout tree representation
    final rootLayoutNode = _buildLayoutTree(
      nodeId: root.id,
      nodeById: nodeById,
      childrenMap: childrenMap,
      depth: 0,
      number: 1,
    );

    // Run Buchheim-Walker 2-pass algorithm
    _firstWalk(rootLayoutNode);
    final positions = <String, Offset>{};
    _secondWalk(rootLayoutNode, 0.0, 0.0, positions);

    // Center root at Offset(0, 0)
    final rootPos = positions[root.id] ?? Offset.zero;
    final offsetX = -rootPos.dx;
    final offsetY = -rootPos.dy;

    return nodes.map((n) {
      if (positions.containsKey(n.id)) {
        final pos = positions[n.id]!;
        return n.copyWith(position: Offset(pos.dx + offsetX, pos.dy + offsetY));
      }
      return n;
    }).toList();
  }

  static _LayoutNode _buildLayoutTree({
    required String nodeId,
    required Map<String, GraphNode> nodeById,
    required Map<String, List<String>> childrenMap,
    required int depth,
    required int number,
    _LayoutNode? parent,
  }) {
    final node = nodeById[nodeId]!;
    final layoutNode = _LayoutNode(
      id: nodeId,
      node: node,
      depth: depth,
      number: number,
      parent: parent,
    );

    // If node is expanded, add visible children
    if (node.isExpanded) {
      final childIds = childrenMap[nodeId] ?? const [];
      for (var i = 0; i < childIds.length; i++) {
        final childNode = _buildLayoutTree(
          nodeId: childIds[i],
          nodeById: nodeById,
          childrenMap: childrenMap,
          depth: depth + 1,
          number: i + 1,
          parent: layoutNode,
        );
        layoutNode.children.add(childNode);
      }
    }

    return layoutNode;
  }

  // ── First Walk (Post-order) ──────────────────────────────────────────────────

  static void _firstWalk(_LayoutNode node) {
    if (node.children.isEmpty) {
      if (node.hasLeftSibling) {
        node.prelim = node.leftSibling!.prelim + _getSpacing(node.leftSibling!, node);
      } else {
        node.prelim = 0.0;
      }
    } else {
      _LayoutNode? defaultAncestor = node.children.first;
      for (final child in node.children) {
        _firstWalk(child);
        defaultAncestor = _apportion(child, defaultAncestor);
      }
      _executeShifts(node);

      final midpoint = (node.children.first.prelim + node.children.last.prelim) / 2.0;
      if (node.hasLeftSibling) {
        node.prelim = node.leftSibling!.prelim + _getSpacing(node.leftSibling!, node);
        node.mod = node.prelim - midpoint;
      } else {
        node.prelim = midpoint;
      }
    }
  }

  // ── Apportion Contours ────────────────────────────────────────────────────────

  static _LayoutNode _apportion(_LayoutNode node, _LayoutNode? defaultAncestor) {
    if (!node.hasLeftSibling) return defaultAncestor ?? node;

    _LayoutNode? vInnerRight = node;
    _LayoutNode? vOuterRight = node;
    _LayoutNode? vInnerLeft = node.leftSibling;
    _LayoutNode? vOuterLeft = vInnerRight.leftmostSibling;

    double sInnerRight = vInnerRight.mod;
    double sOuterRight = vOuterRight.mod;
    double sInnerLeft = vInnerLeft!.mod;
    double sOuterLeft = vOuterLeft!.mod;

    while (vInnerLeft?.nextRight != null && vInnerRight?.nextLeft != null) {
      final currentInnerLeft = vInnerLeft!.nextRight!;
      final currentInnerRight = vInnerRight!.nextLeft!;
      vInnerLeft = currentInnerLeft;
      vInnerRight = currentInnerRight;
      vOuterLeft = vOuterLeft!.nextLeft;
      vOuterRight = vOuterRight!.nextRight;

      vOuterRight?.ancestor = node;

      final shift = (currentInnerLeft.prelim + sInnerLeft) -
          (currentInnerRight.prelim + sInnerRight) +
          _getSpacing(currentInnerLeft, currentInnerRight);

      if (shift > 0) {
        final ancestor = _ancestor(currentInnerLeft, node, defaultAncestor);
        _moveSubtree(ancestor, node, shift);
        sInnerRight += shift;
        sOuterRight += shift;
      }

      sInnerLeft += currentInnerLeft.mod;
      sInnerRight += currentInnerRight.mod;
      sOuterLeft += vOuterLeft!.mod;
      sOuterRight += vOuterRight!.mod;
    }

    if (vInnerLeft?.nextRight != null && vOuterRight?.nextRight == null) {
      vOuterRight?.thread = vInnerLeft!.nextRight;
      vOuterRight?.mod += sInnerLeft - sOuterRight;
    }

    if (vInnerRight?.nextLeft != null && vOuterLeft?.nextLeft == null) {
      vOuterLeft?.thread = vInnerRight!.nextLeft;
      vOuterLeft?.mod += sInnerRight - sOuterLeft;
      defaultAncestor = node;
    }

    return defaultAncestor ?? node;
  }

  static void _moveSubtree(_LayoutNode leftNode, _LayoutNode rightNode, double shift) {
    final subtrees = rightNode.number - leftNode.number;
    if (subtrees <= 0) return;
    rightNode.change -= shift / subtrees;
    rightNode.shift += shift;
    leftNode.change += shift / subtrees;
    rightNode.prelim += shift;
    rightNode.mod += shift;
  }

  static void _executeShifts(_LayoutNode node) {
    double shift = 0.0;
    double change = 0.0;
    for (var i = node.children.length - 1; i >= 0; i--) {
      final child = node.children[i];
      child.prelim += shift;
      child.mod += shift;
      change += child.change;
      shift += child.shift + change;
    }
  }

  static _LayoutNode _ancestor(_LayoutNode vInnerLeft, _LayoutNode node, _LayoutNode? defaultAncestor) {
    if (node.parent?.children.contains(vInnerLeft.ancestor) ?? false) {
      return vInnerLeft.ancestor!;
    }
    return defaultAncestor ?? node;
  }

  // ── Second Walk (Pre-order) ──────────────────────────────────────────────────

  static void _secondWalk(
    _LayoutNode node,
    double modSum,
    double y,
    Map<String, Offset> positions,
  ) {
    final x = node.prelim + modSum;
    positions[node.id] = Offset(x, y);

    for (final child in node.children) {
      _secondWalk(
        child,
        modSum + node.mod,
        y + _levelSeparation,
        positions,
      );
    }
  }

  static double _getSpacing(_LayoutNode left, _LayoutNode right) {
    final halfLeft = left.node.width / 2.0;
    final halfRight = right.node.width / 2.0;
    final isSibling = left.parent == right.parent;
    final gap = isSibling ? _siblingSeparation : _subtreeSeparation;
    return halfLeft + halfRight + gap;
  }

  /// Calculates a tight bounding box around all positioned visible nodes.
  static Rect computeBounds(List<GraphNode> nodes) {
    if (nodes.isEmpty) return Rect.zero;
    double minX = double.infinity;
    double minY = double.infinity;
    double maxX = double.negativeInfinity;
    double maxY = double.negativeInfinity;

    for (final n in nodes) {
      if (!n.isVisible) continue;
      final halfW = n.width / 2.0 + 16.0;
      final halfH = n.height / 2.0 + 16.0;
      minX = math.min(minX, n.position.dx - halfW);
      minY = math.min(minY, n.position.dy - halfH);
      maxX = math.max(maxX, n.position.dx + halfW);
      maxY = math.max(maxY, n.position.dy + halfH);
    }

    if (minX == double.infinity) return Rect.zero;
    return Rect.fromLTRB(minX, minY, maxX, maxY);
  }
}

/// Internal layout tree node used by Buchheim-Walker.
class _LayoutNode {
  final String id;
  final GraphNode node;
  final int depth;
  final int number; // 1-indexed sibling position
  final _LayoutNode? parent;
  final List<_LayoutNode> children = [];

  double prelim = 0.0;
  double mod = 0.0;
  double shift = 0.0;
  double change = 0.0;
  _LayoutNode? thread;
  _LayoutNode? ancestor;

  _LayoutNode({
    required this.id,
    required this.node,
    required this.depth,
    required this.number,
    this.parent,
  }) {
    ancestor = this;
  }

  bool get hasLeftSibling => parent != null && number > 1;

  _LayoutNode? get leftSibling {
    if (!hasLeftSibling) return null;
    return parent!.children[number - 2];
  }

  _LayoutNode? get leftmostSibling {
    if (parent == null || parent!.children.isEmpty) return null;
    return parent!.children.first;
  }

  _LayoutNode? get nextLeft {
    if (children.isNotEmpty) return children.first;
    return thread;
  }

  _LayoutNode? get nextRight {
    if (children.isNotEmpty) return children.last;
    return thread;
  }
}
