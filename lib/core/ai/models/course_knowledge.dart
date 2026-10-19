/// Editable course tree that becomes the source of truth for study tools.
class CourseOutline {
  final String id;
  final String title;
  final String description;
  final List<CourseUnitNode> units;
  final List<String> documentIds;

  const CourseOutline({
    required this.id,
    required this.title,
    this.description = '',
    this.units = const [],
    this.documentIds = const [],
  });

  CourseOutline copyWith({
    String? id,
    String? title,
    String? description,
    List<CourseUnitNode>? units,
    List<String>? documentIds,
  }) {
    return CourseOutline(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      units: units ?? this.units,
      documentIds: documentIds ?? this.documentIds,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'units': units.map((u) => u.toJson()).toList(),
        'documentIds': documentIds,
      };

  factory CourseOutline.fromJson(Map<String, dynamic> json) => CourseOutline(
        id: json['id'] ?? '',
        title: json['title'] ?? 'Untitled Course',
        description: json['description'] ?? '',
        units: (json['units'] as List? ?? [])
            .map((u) => CourseUnitNode.fromJson(Map<String, dynamic>.from(u)))
            .toList(),
        documentIds: List<String>.from(json['documentIds'] ?? []),
      );

  String toPromptBlock() {
    final buffer = StringBuffer();
    buffer.writeln('COURSE STRUCTURE (source of truth): $title');
    if (description.isNotEmpty) buffer.writeln(description);
    for (var i = 0; i < units.length; i++) {
      final unit = units[i];
      buffer.writeln('Unit ${i + 1}. ${unit.title}');
      for (var j = 0; j < unit.topics.length; j++) {
        buffer.writeln('    ${j + 1}. ${unit.topics[j].title}');
      }
    }
    return buffer.toString().trim();
  }
}

class CourseUnitNode {
  final String id;
  final String title;
  final String description;
  final List<CourseTopicNode> topics;

  const CourseUnitNode({
    required this.id,
    required this.title,
    this.description = '',
    this.topics = const [],
  });

  CourseUnitNode copyWith({
    String? id,
    String? title,
    String? description,
    List<CourseTopicNode>? topics,
  }) {
    return CourseUnitNode(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      topics: topics ?? this.topics,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'topics': topics.map((t) => t.toJson()).toList(),
      };

  factory CourseUnitNode.fromJson(Map<String, dynamic> json) => CourseUnitNode(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        topics: (json['topics'] as List? ?? [])
            .map((t) => CourseTopicNode.fromJson(Map<String, dynamic>.from(t)))
            .toList(),
      );
}

class CourseTopicNode {
  final String id;
  final String title;
  final String description;
  final List<String> keywords;

  const CourseTopicNode({
    required this.id,
    required this.title,
    this.description = '',
    this.keywords = const [],
  });

  CourseTopicNode copyWith({
    String? id,
    String? title,
    String? description,
    List<String>? keywords,
  }) {
    return CourseTopicNode(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      keywords: keywords ?? this.keywords,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'title': title,
        'description': description,
        'keywords': keywords,
      };

  factory CourseTopicNode.fromJson(Map<String, dynamic> json) => CourseTopicNode(
        id: json['id'] ?? '',
        title: json['title'] ?? '',
        description: json['description'] ?? '',
        keywords: List<String>.from(json['keywords'] ?? []),
      );
}

enum KnowledgeSourceKind {
  notes,
  modelKnowledge,
  web,
  conversation,
  course,
}

class KnowledgeSourceDecision {
  final List<KnowledgeSourceKind> sources;
  final bool needsWeb;
  final String reason;

  const KnowledgeSourceDecision({
    required this.sources,
    required this.needsWeb,
    required this.reason,
  });
}
