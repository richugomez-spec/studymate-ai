import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/widgets/notifications/app_notification.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_required_modal.dart';
import '../widgets/topic_builder.dart';

class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String? _activeSubjectId;
  String _activeSubjectName = 'My Subjects';
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final id = await ref.read(firestoreServiceProvider).getActiveSubjectId();
      if (!mounted || id == null || id.isEmpty) return;
      final subjects = ref
              .read(userSubjectsStreamProvider(
                ref.read(currentUserProvider)?.id ?? '',
              ))
              .asData
              ?.value ??
          const <Map<String, dynamic>>[];
      final matches = subjects.where((subject) => subject['id'] == id);
      if (matches.isNotEmpty) await _selectSubject(matches.first);
    });
  }

  Future<void> _selectSubject(Map<String, dynamic> subject) async {
    final id = subject['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final name = subject['name']?.toString() ?? 'Subject';
    setState(() {
      _activeSubjectId = id;
      _activeSubjectName = name;
    });
    ref.read(activeKnowledgeSubjectIdProvider.notifier).state = id;
    ref.read(activeKnowledgeSubjectNameProvider.notifier).state = name;
    ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state = id;
    ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
    await ref.read(firestoreServiceProvider).setActiveSubjectId(id);
  }

  Future<void> _createSubject() async {
    if (ref.read(currentUserProvider) == null) {
      AuthRequiredModal.show(
        context,
        title: 'Sign in to create a subject',
        message: 'Sign in to save your subjects, topics, and notes.',
      );
      return;
    }
    final controller = TextEditingController();
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Create subject'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Subject name'),
          onSubmitted: (value) => Navigator.pop(context, value.trim()),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, controller.text.trim()),
            child: const Text('Create'),
          ),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty) return;
    try {
      final id = await ref.read(firestoreServiceProvider).createSubject(name);
      if (!mounted) return;
      await _selectSubject({'id': id, 'name': name});
    } catch (error) {
      _showError('Could not create subject: $error');
    }
  }

  Future<void> _renameSubject(Map<String, dynamic> subject) async {
    final id = subject['id']?.toString() ?? '';
    final controller =
        TextEditingController(text: subject['name']?.toString() ?? '');
    final name = await showDialog<String>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Rename subject'),
        content: TextField(controller: controller, autofocus: true),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (name == null || name.isEmpty || id.isEmpty) return;
    try {
      await ref.read(firestoreServiceProvider).renameSubject(id, name);
      KnowledgeEngine.invalidateSubjectContext(id,
          ownerId: ref.read(firestoreServiceProvider).currentUserId);
      if (_activeSubjectId == id && mounted) {
        setState(() => _activeSubjectName = name);
        ref.read(activeKnowledgeSubjectNameProvider.notifier).state = name;
      }
    } catch (error) {
      _showError('Could not rename subject: $error');
    }
  }

  Future<void> _deleteSubject(Map<String, dynamic> subject) async {
    final id = subject['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Delete subject?'),
        content: const Text(
          'This deletes the subject, its topics, subtopics, notes, chats, and generated study materials.',
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Delete')),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await ref.read(knowledgeEngineProvider).deleteSubject(id);
      if (_activeSubjectId == id && mounted) _clearActiveSubject();
    } catch (error) {
      _showError('Could not delete subject: $error');
    }
  }

  Future<void> _addNote({
    String topicId = '',
    String topic = '',
    String subtopicId = '',
    String subtopic = '',
  }) async {
    if (ref.read(currentUserProvider) == null) {
      AuthRequiredModal.show(
        context,
        title: 'Sign in to save notes',
        message: 'Sign in to keep your notes synced with your subject.',
      );
      return;
    }
    final subjectId = _activeSubjectId;
    if (subjectId == null) return;
    final titleController = TextEditingController();
    final contentController = TextEditingController();
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(subtopic.isNotEmpty
            ? 'Add note to $subtopic'
            : topic.isNotEmpty
                ? 'Add note to $topic'
                : 'Add subject note'),
        content: SizedBox(
          width: 480,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleController,
                autofocus: true,
                decoration: const InputDecoration(labelText: 'Note title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                minLines: 4,
                maxLines: 10,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: const Text('Save note')),
        ],
      ),
    );
    final title = titleController.text.trim();
    final content = contentController.text.trim();
    titleController.dispose();
    contentController.dispose();
    if (shouldSave != true || content.isEmpty) return;

    setState(() => _saving = true);
    try {
      await ref.read(firestoreServiceProvider).saveKnowledgeNote(
            title: title.isEmpty ? 'Note' : title,
            content: content,
            subject: _activeSubjectName,
            subjectId: subjectId,
            topic: topic,
            subtopic: subtopic,
            topicId: topicId,
            subtopicId: subtopicId,
          );
      KnowledgeEngine.invalidateSubjectContext(subjectId,
          ownerId: ref.read(firestoreServiceProvider).currentUserId);
      // An empty selection tells every study tool to use all notes in the
      // active subject, including notes added before this one.
      ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
    } catch (error) {
      _showError('Could not save note: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _generateAiNotes({
    required String topicId,
    required String topic,
    required String subtopicId,
    required String subtopic,
  }) async {
    if (ref.read(currentUserProvider) == null) {
      AuthRequiredModal.show(
        context,
        title: 'Sign in to save notes',
        message: 'Sign in to generate and save notes to your subject.',
      );
      return;
    }
    final subjectId = _activeSubjectId;
    if (subjectId == null || _saving) return;
    final subjectName = _activeSubjectName;
    setState(() => _saving = true);
    try {
      final content = await ref.read(knowledgeEngineProvider).generateAiNotes(
            subjectId: subjectId,
            topicId: topicId,
            subtopicId: subtopicId,
          );
      final title =
          subtopic.isNotEmpty ? 'AI Notes - $subtopic' : 'AI Notes - $topic';
      await ref.read(firestoreServiceProvider).saveKnowledgeNote(
            title: title,
            content: content,
            subject: subjectName,
            subjectId: subjectId,
            topic: topic,
            topicId: topicId,
            subtopic: subtopic,
            subtopicId: subtopicId,
          );
      if (mounted) {
        AppNotification.showSuccess(
          context: context,
          message: 'AI notes saved and ready to edit.',
        );
      }
    } catch (error) {
      _showError('Could not generate AI notes: $error');
    } finally {
      if (mounted) setState(() => _saving = false);
    }
  }

  Future<void> _editNote(Map<String, dynamic> note) async {
    final id = note['id']?.toString() ?? '';
    if (id.isEmpty) return;
    final titleController =
        TextEditingController(text: note['title']?.toString() ?? 'Note');
    final contentController =
        TextEditingController(text: note['content']?.toString() ?? '');
    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Edit note'),
        content: SizedBox(
          width: 520,
          child: SingleChildScrollView(
            child: Column(mainAxisSize: MainAxisSize.min, children: [
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Note title'),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: contentController,
                minLines: 6,
                maxLines: 14,
                decoration: const InputDecoration(labelText: 'Note'),
              ),
            ]),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save changes'),
          ),
        ],
      ),
    );
    final title = titleController.text;
    final content = contentController.text;
    titleController.dispose();
    contentController.dispose();
    if (shouldSave != true || content.trim().isEmpty) return;
    try {
      await ref.read(firestoreServiceProvider).updateKnowledgeNote(
            noteId: id,
            title: title,
            content: content,
          );
      if (mounted) {
        AppNotification.showSuccess(
          context: context,
          message: 'Note saved successfully.',
        );
      }
    } catch (error) {
      _showError('Could not update note: $error');
    }
  }

  Future<void> _clearActiveSubject() async {
    final prevId = _activeSubjectId;
    final prevName = _activeSubjectName;
    setState(() {
      _activeSubjectId = null;
      _activeSubjectName = 'My Subjects';
    });
    ref.read(activeKnowledgeSubjectIdProvider.notifier).state = null;
    ref.read(activeKnowledgeSubjectNameProvider.notifier).state = null;
    ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state = null;
    ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
    ref.read(activeDocumentProvider.notifier).clearDocument();
    await ref.read(firestoreServiceProvider).setActiveSubjectId(null);

    if (mounted && prevId != null) {
      AppNotification.showUndo(
        context: context,
        message: 'Active subject deselected',
        onUndo: () async {
          if (!mounted) return;
          setState(() {
            _activeSubjectId = prevId;
            _activeSubjectName = prevName;
          });
          ref.read(activeKnowledgeSubjectIdProvider.notifier).state = prevId;
          ref.read(activeKnowledgeSubjectNameProvider.notifier).state = prevName;
          await ref.read(firestoreServiceProvider).setActiveSubjectId(prevId);
          if (mounted) {
            AppNotification.showSuccess(
              context: context,
              message: 'Subject restored: $prevName',
            );
          }
        },
      );
    }
  }

  void _showError(String message) {
    if (!mounted) return;
    AppNotification.showError(
      context: context,
      message: message,
    );
  }

  void _openTool(String route) {
    final subjectId = _activeSubjectId;
    if (subjectId == null) {
      _showError('Open a subject to use its study tools.');
      return;
    }
    context.push(route.replaceFirst(':topicId', 'current'));
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? '';
    final subjects = userId.isEmpty
        ? const <Map<String, dynamic>>[]
        : ref.watch(userSubjectsStreamProvider(userId)).asData?.value ??
            const <Map<String, dynamic>>[];
    final workspaceItems = userId.isEmpty
        ? const <Map<String, dynamic>>[]
        : ref.watch(userKnowledgeStreamProvider(userId)).asData?.value ??
            const <Map<String, dynamic>>[];
    final notes = workspaceItems
        .where((item) =>
            item['kind'] == 'note' &&
            item['subjectId']?.toString() == _activeSubjectId)
        .toList(growable: false);
    final isDesktop = MediaQuery.sizeOf(context).width >= 1100;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        leading: _activeSubjectId == null
            ? null
            : IconButton(
                tooltip: 'All subjects',
                onPressed: _clearActiveSubject,
                icon: const Icon(Icons.arrow_back),
              ),
        title: Text(_activeSubjectId == null ? 'Subjects' : _activeSubjectName),
        actions: [
          if (_activeSubjectId != null)
            TextButton.icon(
              onPressed: () => _addNote(),
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('Add Note'),
            ),
          IconButton(
            tooltip: 'Create subject',
            onPressed: _createSubject,
            icon: const Icon(Icons.create_new_folder_outlined),
          ),
        ],
      ),
      body: userId.isEmpty
          ? const Center(child: Text('Sign in to manage your subjects.'))
          : _activeSubjectId == null
              ? _buildSubjectList(subjects)
              : Row(
                  children: [
                    Expanded(
                      child: Column(
                        children: [
                          Expanded(
                            child: TopicBuilder(
                              key: ValueKey(_activeSubjectId),
                              subjectId: _activeSubjectId!,
                              subjectName: _activeSubjectName,
                              onClose: _clearActiveSubject,
                              onAddNote: _addNote,
                              onGenerateAiNotes: _generateAiNotes,
                            ),
                          ),
                          _NotesShelf(
                            notes: notes,
                            isSaving: _saving,
                            onAddNote: () => _addNote(),
                            onEditNote: _editNote,
                          ),
                        ],
                      ),
                    ),
                    if (isDesktop) ...[
                      const VerticalDivider(width: 1),
                      SizedBox(
                          width: 300,
                          child: _StudyToolsPanel(onOpen: _openTool)),
                    ],
                  ],
                ),
      bottomNavigationBar: _activeSubjectId != null && !isDesktop
          ? SafeArea(
              child: SizedBox(
                height: 68,
                child: _StudyToolsPanel(onOpen: _openTool, compact: true),
              ),
            )
          : null,
    );
  }

  Widget _buildSubjectList(List<Map<String, dynamic>> subjects) {
    if (subjects.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Icon(Icons.menu_book_outlined,
              size: 48, color: AppColors.electricVioletLight),
          const SizedBox(height: 12),
          const Text('Create a subject to organize topics and notes.'),
          const SizedBox(height: 12),
          FilledButton.icon(
            onPressed: _createSubject,
            icon: const Icon(Icons.add),
            label: const Text('Create Subject'),
          ),
        ]),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
        maxCrossAxisExtent: 360,
        mainAxisExtent: 92,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        return Card(
          color: Theme.of(context).colorScheme.surfaceContainer,
          child: ListTile(
            onTap: () => _selectSubject(subject),
            leading: const Icon(Icons.folder_outlined,
                color: AppColors.electricVioletLight),
            title: Text(subject['name']?.toString() ?? 'Subject'),
            subtitle: const Text('Topics, subtopics, and notes'),
            trailing: PopupMenuButton<String>(
              onSelected: (action) {
                if (action == 'rename') _renameSubject(subject);
                if (action == 'delete') _deleteSubject(subject);
              },
              itemBuilder: (context) => const [
                PopupMenuItem(value: 'rename', child: Text('Rename')),
                PopupMenuItem(value: 'delete', child: Text('Delete')),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _NotesShelf extends StatelessWidget {
  const _NotesShelf({
    required this.notes,
    required this.isSaving,
    required this.onAddNote,
    required this.onEditNote,
  });

  final List<Map<String, dynamic>> notes;
  final bool isSaving;
  final VoidCallback onAddNote;
  final ValueChanged<Map<String, dynamic>> onEditNote;

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 170,
      padding: const EdgeInsets.fromLTRB(16, 10, 16, 12),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainer,
        border: Border(top: BorderSide(color: AppColors.darkBorderSubtle)),
      ),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
        Row(children: [
          const Expanded(
            child: Text('NOTES',
                style: TextStyle(fontWeight: FontWeight.w700, fontSize: 11)),
          ),
          if (isSaving)
            const SizedBox.square(
                dimension: 16,
                child: CircularProgressIndicator(strokeWidth: 2)),
          TextButton.icon(
            onPressed: onAddNote,
            icon: const Icon(Icons.add, size: 18),
            label: const Text('Add Note'),
          ),
        ]),
        Expanded(
          child: notes.isEmpty
              ? const Center(
                  child: Text('No notes yet. Add a note to this subject.'))
              : ListView(
                  scrollDirection: Axis.horizontal,
                  children: notes
                      .map((note) => SizedBox(
                            width: 260,
                            child: Card(
                              color: AppColors.darkBackground,
                              child: ListTile(
                                leading: const Icon(
                                    Icons.sticky_note_2_outlined,
                                    color: AppColors.teal),
                                title: Text(note['title']?.toString() ?? 'Note',
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis),
                                subtitle: Text(
                                  [note['topic'], note['subtopic']]
                                      .where((value) =>
                                          value != null &&
                                          value.toString().isNotEmpty)
                                      .join(' · '),
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                ),
                                onTap: () => onEditNote(note),
                              ),
                            ),
                          ))
                      .toList(growable: false),
                ),
        ),
      ]),
    );
  }
}

class _StudyToolsPanel extends StatelessWidget {
  const _StudyToolsPanel({required this.onOpen, this.compact = false});

  final ValueChanged<String> onOpen;
  final bool compact;

  @override
  Widget build(BuildContext context) {
    final tools = <(String, IconData, String)>[
      (AppRoutes.aiChat, Icons.auto_awesome, 'AI Chat'),
      (AppRoutes.flashcards, Icons.flip_to_front, 'Flashcards'),
      (AppRoutes.quiz, Icons.quiz_outlined, 'Quiz'),
      (AppRoutes.mindMap, Icons.hub_outlined, 'Mind Map'),
      (AppRoutes.summary, Icons.summarize_outlined, 'Summary'),
      (AppRoutes.questionPaperAnalyzer, Icons.analytics_outlined, 'PYQ'),
      (AppRoutes.examGenerator, Icons.assignment_outlined, 'Exam Generator'),
    ];
    return compact
        ? ListView(
            scrollDirection: Axis.horizontal,
            children: tools
                .map((tool) => Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 4),
                      child: ActionChip(
                        avatar: Icon(tool.$2, size: 18),
                        label: Text(tool.$3),
                        onPressed: () => onOpen(tool.$1),
                      ),
                    ))
                .toList(growable: false),
          )
        : ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Text('STUDY TOOLS',
                  style: Theme.of(context).textTheme.labelSmall),
              const SizedBox(height: 8),
              for (final tool in tools)
                ListTile(
                  leading: Icon(tool.$2, color: AppColors.electricVioletLight),
                  title: Text(tool.$3),
                  onTap: () => onOpen(tool.$1),
                ),
            ],
          );
  }
}
