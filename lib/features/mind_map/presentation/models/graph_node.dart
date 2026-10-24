import 'package:flutter/material.dart';

/// Node type in the knowledge graph hierarchy
enum GraphNodeType { subject, topic, subtopic, aiExpanded }

/// Represents a single node in the interactive knowledge graph.
class GraphNode {
  final String id;
  final String label;
  final GraphNodeType type;
  final String? parentId;
  final String? topicId;       // for subtopics: the parent topic id
  final String? subjectId;     // for topics/subtopics: subject id
  final String? description;
  final bool isAiGenerated;    // true = temporary AI-expanded node

  // Layout state (set by layout algorithm)
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
    this.isAiGenerated = false,
    this.position = Offset.zero,
    this.isExpanded = true,
    this.isSelected = false,
    this.isHighlighted = false,
    this.isVisible = true,
  });

  /// Node radius used for hit-testing and layout spacing
  double get radius {
    switch (type) {
      case GraphNodeType.subject:
        return 52.0;
      case GraphNodeType.topic:
        return 36.0;
      case GraphNodeType.subtopic:
        return 24.0;
      case GraphNodeType.aiExpanded:
        return 22.0;
    }
  }

  GraphNode copyWith({
    Offset? position,
    bool? isExpanded,
    bool? isSelected,
    bool? isHighlighted,
    bool? isVisible,
  }) {
    return GraphNode(
      id: id,
      label: label,
      type: type,
      parentId: parentId,
      topicId: topicId,
      subjectId: subjectId,
      description: description,
      isAiGenerated: isAiGenerated,
      position: position ?? this.position,
      isExpanded: isExpanded ?? this.isExpanded,
      isSelected: isSelected ?? this.isSelected,
      isHighlighted: isHighlighted ?? this.isHighlighted,
      isVisible: isVisible ?? this.isVisible,
    );
  }
}

/// Represents an edge (connection) between two nodes.
class GraphEdge {
  final String fromId;
  final String toId;

  const GraphEdge({required this.fromId, required this.toId});
}
