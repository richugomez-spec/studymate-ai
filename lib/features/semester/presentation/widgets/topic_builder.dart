import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/notifications/app_notification.dart';
import '../../../../services/firestore_service.dart';

class TopicBuilder extends ConsumerStatefulWidget {
  const TopicBuilder({
    super.key,
    required this.subjectId,
    required this.subjectName,
    required this.notes,
    required this.onClose,
    required this.onAddNote,
    required this.onGenerateAiNotes,
    required this.onEditNotes,
    required this.onDeleteNotes,
  });

  final String subjectId;
  final String subjectName;
  final List<Map<String, dynamic>> notes;
  final VoidCallback onClose;
  final Future<void> Function({
    String topicId,
    String topic,
    String subtopicId,
    String subtopic,
  }) onAddNote;
  final Future<void> Function({
    required String topicId,
    required String topic,
    required String subtopicId,
    required String subtopic,
  }) onGenerateAiNotes;
  final Future<void> Function(List<Map<String, dynamic>> notes) onEditNotes;
  final Future<void> Function({
    required String topicId,
    required String topicName,
    required String subtopicId,
    required String subtopicName,
  }) onDeleteNotes;

  @override
  ConsumerState<TopicBuilder> createState() => _TopicBuilderState();
}

class _TopicBuilderState extends ConsumerState<TopicBuilder> {
  final Map<String, bool> _expandedTopics = {};
  bool _isLoading = false;
  List<Map<String, dynamic>> _topics = [];
  String? _lastLibraryVersion;
  Timer? _libraryChangeDebounce;

  List<Map<String, dynamic>> _notesAt(
    String topicId,
    String topicName, [
    String subtopicId = '',
    String subtopicName = '',
  ]) =>
      widget.notes.where((note) {
        final noteTopicId = note['topicId']?.toString() ?? '';
        final noteSubtopicId = note['subtopicId']?.toString() ?? '';
        final topicMatches = noteTopicId == topicId ||
            (noteTopicId.isEmpty && note['topic']?.toString() == topicName);
        final subtopicMatches = subtopicId.isEmpty
            ? noteSubtopicId.isEmpty &&
                (note['subtopic']?.toString() ?? '').isEmpty
            : noteSubtopicId == subtopicId ||
                (noteSubtopicId.isEmpty &&
                    note['subtopic']?.toString() == subtopicName);
        return topicMatches && subtopicMatches;
      }).toList();

  @override
  void initState() {
    super.initState();
    _loadTopics();
  }

  Future<void> _loadTopics() async {
    setState(() => _isLoading = true);
    try {
      final topics = await ref
          .read(firestoreServiceProvider)
          .getSubjectTopicsWithSubtopics(widget.subjectId);
      if (mounted) {
        setState(() {
          _topics = topics;
          _isLoading = false;
        });
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppNotification.showError(
          context: context,
          message: 'Failed to load topics: $error',
        );
      }
    }
  }

  @override
  void dispose() {
    _libraryChangeDebounce?.cancel();
    super.dispose();
  }

  Future<void> _addTopic() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Topic'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Topic Name',
            hintText: 'e.g., Cloud Computing Basics',
          ),
          onSubmitted: (value) => Navigator.pop(ctx, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      final topicId = await ref.read(firestoreServiceProvider).createTopic(
            subjectId: widget.subjectId,
            name: name,
          );
      await _loadTopics();
      setState(() => _expandedTopics[topicId] = true);
      if (mounted) {
        AppNotification.showSuccess(
          context: context,
          message: 'Topic "$name" created successfully.',
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppNotification.showError(
          context: context,
          message: 'Failed to create topic: $error',
        );
      }
    }
  }

  Future<void> _addSubtopic(String topicId) async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('New Subtopic'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(
            labelText: 'Subtopic Name',
            hintText: 'e.g., Introduction',
          ),
          onSubmitted: (value) => Navigator.pop(ctx, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, controller.text.trim()),
            child: const Text('Add'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(firestoreServiceProvider).createSubtopic(
            subjectId: widget.subjectId,
            topicId: topicId,
            name: name,
          );
      await _loadTopics();
      if (mounted) {
        AppNotification.showSuccess(
          context: context,
          message: 'Subtopic "$name" created successfully.',
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppNotification.showError(
          context: context,
          message: 'Failed to create subtopic: $error',
        );
      }
    }
  }

  Future<void> _deleteTopic(String topicId, String topicName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Topic'),
        content: Text(
          'Delete "$topicName" and all its subtopics?',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(firestoreServiceProvider).deleteTopic(
            subjectId: widget.subjectId,
            topicId: topicId,
          );
      await _loadTopics();
      if (mounted) {
        AppNotification.showSuccess(
          context: context,
          message: 'Topic "$topicName" deleted.',
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppNotification.showError(
          context: context,
          message: 'Failed to delete topic: $error',
        );
      }
    }
  }

  Future<void> _deleteSubtopic(
      String topicId, String subtopicId, String subtopicName) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Delete Subtopic'),
        content: Text('Delete "$subtopicName"?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            style: FilledButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm != true) return;

    setState(() => _isLoading = true);
    try {
      await ref.read(firestoreServiceProvider).deleteSubtopic(
            subjectId: widget.subjectId,
            topicId: topicId,
            subtopicId: subtopicId,
          );
      await _loadTopics();
      if (mounted) {
        AppNotification.showSuccess(
          context: context,
          message: 'Subtopic "$subtopicName" deleted.',
        );
      }
    } catch (error) {
      if (mounted) {
        setState(() => _isLoading = false);
        AppNotification.showError(
          context: context,
          message: 'Failed to delete subtopic: $error',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    ref.listen<AsyncValue<String>>(
      subjectTopicsVersionProvider(widget.subjectId),
      (_, next) {
        final version = next.valueOrNull;
        if (version == null || version.isEmpty) return;
        if (_lastLibraryVersion == null) {
          _lastLibraryVersion = version;
          return;
        }
        if (_lastLibraryVersion == version) return;
        _lastLibraryVersion = version;
        _libraryChangeDebounce?.cancel();
        _libraryChangeDebounce = Timer(const Duration(milliseconds: 350), () {
          if (mounted) _loadTopics();
        });
      },
    );
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(12),
        border:
            Border.all(color: AppColors.electricVioletLight.withOpacity(0.3)),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.all(16),
            child: Row(
              children: [
                Icon(Icons.topic_outlined,
                    color: AppColors.electricVioletLight, size: 24),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Manage Topics',
                        style: Theme.of(context).textTheme.titleLarge?.copyWith(
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                      ),
                      Text(
                        widget.subjectName,
                        style: Theme.of(context).textTheme.bodySmall?.copyWith(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                            ),
                      ),
                    ],
                  ),
                ),
                AppPressable(
                  onTap: _isLoading ? null : _addTopic,
                  child: FilledButton.icon(
                    onPressed: _isLoading ? null : _addTopic,
                    icon: const Icon(Icons.add),
                    label: const Text('Add Topic'),
                  ),
                ),
                IconButton(
                  tooltip: 'Back to subjects',
                  icon: const Icon(Icons.close),
                  onPressed: widget.onClose,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ],
            ),
          ),
          const Divider(height: 1, color: AppColors.darkBorderSubtle),

          // Content
          if (_isLoading)
            const Padding(
              padding: EdgeInsets.all(16),
              child: Column(
                children: [
                  AppSkeletonTopicCard(),
                  SizedBox(height: 12),
                  AppSkeletonTopicCard(),
                ],
              ),
            )
          else
            Flexible(
              child: ListView(
                shrinkWrap: true,
                padding: const EdgeInsets.all(16),
                children: [
                  if (_topics.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.all(32),
                        child: Column(
                          children: [
                            Icon(Icons.topic_outlined,
                                size: 48,
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant),
                            const SizedBox(height: 16),
                            Text(
                              'No topics yet',
                              style: TextStyle(
                                color: Theme.of(context)
                                    .colorScheme
                                    .onSurfaceVariant,
                                fontSize: 16,
                              ),
                            ),
                          ],
                        ),
                      ),
                    )
                  else
                    ..._topics.map((topic) => _buildTopicCard(topic)),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildTopicCard(Map<String, dynamic> topic) {
    final topicId = topic['id'] as String;
    final topicName = topic['name'] as String;
    final subtopics =
        (topic['subtopics'] as List<dynamic>?)?.cast<Map<String, dynamic>>() ??
            [];
    final isExpanded = _expandedTopics[topicId] ?? false;
    final topicNotes = _notesAt(topicId, topicName);

    return AppHoverCard(
      margin: const EdgeInsets.only(bottom: 12),
      backgroundColor: AppColors.darkBackground,
      borderRadius: BorderRadius.circular(12),
      borderColor: AppColors.electricVioletLight.withOpacity(0.25),
      hoverBorderColor: AppColors.electricVioletLight.withOpacity(0.55),
      glowColor: AppColors.electricViolet,
      child: Column(
        children: [
          InkWell(
            onTap: () {
              setState(() {
                _expandedTopics[topicId] = !isExpanded;
              });
            },
            borderRadius: BorderRadius.circular(12),
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: Row(
                children: [
                  AnimatedRotation(
                    turns: isExpanded ? 0.25 : 0.0,
                    duration: const Duration(milliseconds: 240),
                    curve: Curves.easeOutCubic,
                    child: const Icon(
                      Icons.keyboard_arrow_right,
                      color: AppColors.electricVioletLight,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      topicName,
                      style: const TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  if (!isExpanded && subtopics.isNotEmpty)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.electricVioletLight.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${subtopics.length} ${subtopics.length == 1 ? 'subtopic' : 'subtopics'}',
                        style: TextStyle(
                          fontSize: 12,
                          color: AppColors.electricVioletLight,
                        ),
                      ),
                    ),
                  const SizedBox(width: 8),
                  PopupMenuButton<String>(
                    icon: Icon(Icons.more_vert,
                        color: Theme.of(context).colorScheme.onSurfaceVariant),
                    onSelected: (action) {
                      if (action == 'delete') {
                        _deleteTopic(topicId, topicName);
                      } else if (action == 'edit-notes') {
                        widget.onEditNotes(topicNotes);
                      } else if (action == 'delete-notes') {
                        widget.onDeleteNotes(
                          topicId: topicId,
                          topicName: topicName,
                          subtopicId: '',
                          subtopicName: '',
                        );
                      }
                    },
                    itemBuilder: (_) => [
                      if (topicNotes.isNotEmpty)
                        const PopupMenuItem(
                          value: 'edit-notes',
                          child: Row(children: [
                            Icon(Icons.edit_note_outlined, size: 20),
                            SizedBox(width: 8),
                            Text('Edit Notes'),
                          ]),
                        ),
                      if (topicNotes.isNotEmpty)
                        const PopupMenuItem(
                          value: 'delete-notes',
                          child: Row(children: [
                            Icon(Icons.delete_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Delete Notes'),
                          ]),
                        ),
                      const PopupMenuItem(
                        value: 'delete',
                        child: Row(
                          children: [
                            Icon(Icons.delete_outline, size: 20),
                            SizedBox(width: 8),
                            Text('Delete Topic'),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
          AppSmoothExpansion(
            isExpanded: isExpanded,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const Divider(height: 1, color: AppColors.darkBorderSubtle),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      if (subtopics.isEmpty)
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Text(
                            'No subtopics yet',
                            style: TextStyle(
                              color: Theme.of(context)
                                  .colorScheme
                                  .onSurfaceVariant,
                              fontSize: 14,
                            ),
                          ),
                        )
                      else
                        ...subtopics.map((subtopic) =>
                            _buildSubtopicItem(topicId, topicName, subtopic)),
                      const SizedBox(height: 8),
                      AppPressable(
                        onTap: () => _addSubtopic(topicId),
                        child: OutlinedButton.icon(
                          onPressed: () => _addSubtopic(topicId),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Subtopic'),
                          style: OutlinedButton.styleFrom(
                            foregroundColor: AppColors.teal,
                            side: BorderSide(
                                color: AppColors.teal.withOpacity(0.5)),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 8),
                          ),
                        ),
                      ),
                      const SizedBox(height: 8),
                      AppPressable(
                        onTap: () => widget.onAddNote(
                          topicId: topicId,
                          topic: topicName,
                        ),
                        child: TextButton.icon(
                          onPressed: () => widget.onAddNote(
                            topicId: topicId,
                            topic: topicName,
                          ),
                          icon: const Icon(Icons.note_add_outlined, size: 18),
                          label: const Text('Add Topic Note'),
                        ),
                      ),
                      AppPressable(
                        onTap: () => widget.onGenerateAiNotes(
                          topicId: topicId,
                          topic: topicName,
                          subtopicId: '',
                          subtopic: '',
                        ),
                        child: OutlinedButton.icon(
                          onPressed: () => widget.onGenerateAiNotes(
                            topicId: topicId,
                            topic: topicName,
                            subtopicId: '',
                            subtopic: '',
                          ),
                          icon: const Icon(Icons.auto_awesome, size: 18),
                          label: Text(topicNotes.any((note) =>
                                  note['origin'] == 'ai_generated' ||
                                  (note['title']
                                          ?.toString()
                                          .startsWith('AI Notes -') ??
                                      false))
                              ? '\u2728 Regenerate AI Notes'
                              : '\u2728 Generate AI Notes'),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtopicItem(
      String topicId, String topicName, Map<String, dynamic> subtopic) {
    final subtopicId = subtopic['id'] as String;
    final subtopicName = subtopic['name'] as String;
    final subtopicNotes =
        _notesAt(topicId, topicName, subtopicId, subtopicName);

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: AppColors.teal.withOpacity(0.2),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          ListTile(
            dense: true,
            leading: Icon(Icons.subdirectory_arrow_right,
                color: AppColors.teal, size: 20),
            title: Text(
              subtopicName,
              style: const TextStyle(
                fontSize: 14,
                color: Colors.white,
              ),
            ),
            trailing: Row(mainAxisSize: MainAxisSize.min, children: [
              IconButton(
                tooltip: 'Add note to subtopic',
                icon: const Icon(Icons.note_add_outlined,
                    color: AppColors.teal, size: 18),
                onPressed: () => widget.onAddNote(
                  topicId: topicId,
                  topic: topicName,
                  subtopicId: subtopicId,
                  subtopic: subtopicName,
                ),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
              if (subtopicNotes.isNotEmpty)
                PopupMenuButton<String>(
                  tooltip: 'Manage notes',
                  onSelected: (action) {
                    if (action == 'edit') {
                      widget.onEditNotes(subtopicNotes);
                    } else if (action == 'delete-notes') {
                      widget.onDeleteNotes(
                        topicId: topicId,
                        topicName: topicName,
                        subtopicId: subtopicId,
                        subtopicName: subtopicName,
                      );
                    }
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(
                      value: 'edit',
                      child: Row(children: [
                        Icon(Icons.edit_note_outlined, size: 20),
                        SizedBox(width: 8),
                        Text('Edit Notes'),
                      ]),
                    ),
                    PopupMenuItem(
                      value: 'delete-notes',
                      child: Row(children: [
                        Icon(Icons.delete_outline, size: 20),
                        SizedBox(width: 8),
                        Text('Delete Notes'),
                      ]),
                    ),
                  ],
                  icon: const Icon(Icons.more_vert, size: 18),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(minWidth: 32),
                ),
              IconButton(
                icon: Icon(Icons.close,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    size: 18),
                onPressed: () =>
                    _deleteSubtopic(topicId, subtopicId, subtopicName),
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(minWidth: 32),
              ),
            ]),
          ),
          TextButton.icon(
            onPressed: () => widget.onGenerateAiNotes(
              topicId: topicId,
              topic: topicName,
              subtopicId: subtopicId,
              subtopic: subtopicName,
            ),
            icon: const Icon(Icons.auto_awesome, size: 16),
            label: Text(subtopicNotes.any((note) =>
                    note['origin'] == 'ai_generated' ||
                    (note['title']?.toString().startsWith('AI Notes -') ??
                        false))
                ? '\u2728 Regenerate AI Notes'
                : '\u2728 Generate AI Notes'),
          ),
        ],
      ),
    );
  }
}
