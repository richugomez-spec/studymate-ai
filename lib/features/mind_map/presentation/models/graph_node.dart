import 'package:flutter/material.dart';

/// Node type in the knowledge tree hierarchy
enum GraphNodeType { subject, topic, subtopic, aiExpanded }

/// Represents a single node in the interactive knowledge tree.
class GraphNode {
  final String id;
  final String label;
  final GraphNodeType type;
  final String? parentId;
  final String? topicId; // for subtopics: parent topic id
  final String? subjectId; // subject id
  final String? description;
  final List<Map<String, dynamic>> notes; // real student notes from Firestore
  final int childCount; // number of direct children
  final bool isAiGenerated; // true = temporary AI-expanded node

  // Layout & UI state
  Offset position;
  bool isExpanded;
  bool isSelected;
  bool isHighlighted;
  bool isVisible;

  GraphNode({
    required this.id,
    required this.label,
    required this.type,
    this.parentId,
    this.topicId,
    this.subjectId,
    this.description,
    this.notes = const [],
    this.childCount = 0,
    this.isAiGenerated = false,
    this.position = Offset.zero,
    this.isExpanded = true,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isVisible = true,
  });

  /// Node width based on type
  double get width {
    switch (type) {
      case GraphNodeType.subject:
        return 120.0;
      case GraphNodeType.topic:
        return 180.0;
      case GraphNodeType.subtopic:
        return 160.0;
      case GraphNodeType.aiExpanded:
        return 145.0;
    }
  }

  /// Node height based on type
  double get height {
    switch (type) {
      case GraphNodeType.subject:
        return 120.0;
      case GraphNodeType.topic:
        return 56.0;
      case GraphNodeType.subtopic:
        return 48.0;
      case GraphNodeType.aiExpanded:
        return 44.0;
    }
  }

  /// Node radius used for collision boundaries and hit testing
  double get radius {
    switch (type) {
      case GraphNodeType.subject:
        return 60.0;
      case GraphNodeType.topic:
        return 40.0;
      case GraphNodeType.subtopic:
        return 28.0;
      case GraphNodeType.aiExpanded:
        return 24.0;
    }
  }

  GraphNode copyWith({
    Offset? position,
    bool? isExpanded,
    bool? isSelected,
    bool? isHighlighted,
    bool? isVisible,
    int? childCount,
    List<Map<String, dynamic>>? notes,
  }) {
    return GraphNode(
      id: id,
      label: label,
      type: type,
      parentId: parentId,
      topicId: topicId,
      subjectId: subjectId,
      description: description,
      notes: notes ?? this.notes,
      childCount: childCount ?? this.childCount,
      isAiGenerated: isAiGenerated,
      position: position ?? this.position,
      isExpanded: isExpanded ?? this.isExpanded,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// Represents an edge (connection) between two nodes in the tree.
class GraphEdge {
  final String fromId;
  final String toId;
  final bool isDashed;

  const GraphEdge({
    required this.fromId,
    required this.toId,
    this.isDashed = false,
  });
}
