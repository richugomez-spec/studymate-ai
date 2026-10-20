import 'dart:async';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/services/firebase_upload_service.dart';
import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../services/firestore_models.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_required_modal.dart';

String _mimeTypeFor(String? extension) => switch (extension?.toLowerCase()) {
      'pdf' => 'application/pdf',
      'png' => 'image/png',
      'jpg' || 'jpeg' => 'image/jpeg',
      'webp' => 'image/webp',
      _ => 'application/octet-stream',
    };

String _statusLabel(FirestoreDocumentModel doc) {
  if (doc.uploadStatus == 'uploading' || doc.status == 'uploading') {
    return 'Uploading';
  }
  if (doc.status == 'indexed') return 'AI Ready';
  if (doc.status == 'upload_error' || doc.status == 'index_error') {
    return 'Needs retry';
  }
  return 'Processing';
}

Color _statusColor(FirestoreDocumentModel doc) {
  return doc.status == 'indexed'
      ? AppColors.teal
      : (doc.status == 'upload_error' || doc.status == 'index_error')
          ? AppColors.amber
          : AppColors.electricVioletLight;
}

/// Library Workspace — NotebookLM-inspired 3-column workspace
/// Left sidebar (in MainShell) | Center document folio | Right AI Tools Studio
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _searchQuery = '';
  String? _activeSubjectId;
  String _activeSubjectName = 'General';
  final Set<String> _selectedDocIds = {};
  String _viewMode = 'grid'; // grid | list

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final id = await ref.read(firestoreServiceProvider).getActiveSubjectId();
      if (!mounted || id == null || id.isEmpty) return;
      setState(() {
        _activeSubjectId = id;
      });
      final active = ref.read(activeDocumentProvider);
      if (active != null && active.subjectId != id) {
        ref.read(activeDocumentProvider.notifier).clearDocument();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userId =
        user?.id ?? ref.watch(firestoreServiceProvider).currentUserId ?? '';
    final activeDoc = ref.watch(activeDocumentProvider);
    final firestoreDocsAsync = userId.isNotEmpty
        ? ref.watch(userDocumentsStreamProvider(userId))
        : null;
    final firestoreDocs = firestoreDocsAsync?.asData?.value ?? [];
    FirestoreDocumentModel? activeRecord;
    for (final doc in firestoreDocs) {
      if (doc.id == activeDoc?.id) {
        activeRecord = doc;
        break;
      }
    }
    final selectedRecord = activeRecord;
    if (activeDoc != null &&
        selectedRecord != null &&
        selectedRecord.status == 'indexed' &&
        selectedRecord.conceptCount != activeDoc.concepts.length) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final current = ref.read(activeDocumentProvider);
        if (current?.id != selectedRecord.id || current == null) return;
        if (current.concepts.length != selectedRecord.conceptCount) {
          ref
              .read(activeDocumentProvider.notifier)
              .setDocument(_buildFallback(selectedRecord));
        }
      });
    }
    final workspaceItems = userId.isNotEmpty
        ? ref.watch(userKnowledgeStreamProvider(userId)).asData?.value ??
            const <Map<String, dynamic>>[]
        : const <Map<String, dynamic>>[];
    final subjects = userId.isNotEmpty
        ? ref.watch(userSubjectsStreamProvider(userId)).asData?.value ??
            const <Map<String, dynamic>>[]
        : const <Map<String, dynamic>>[];
    if (_activeSubjectId != null && _activeSubjectName == 'General') {
      final restored = subjects.where((s) => s['id'] == _activeSubjectId);
      if (restored.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            setState(() => _activeSubjectName =
                restored.first['name']?.toString() ?? 'General');
        });
      }
    }

    // Automatically restore last opened document from Firestore if none is active
    final restoreDocs = _activeSubjectId == null
        ? firestoreDocs
        : firestoreDocs
            .where((doc) => doc.subjectId == _activeSubjectId)
            .toList();
    if (activeDoc == null && restoreDocs.isNotEmpty) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (!mounted) return;
        final current = ref.read(activeDocumentProvider);
        if (current == null && restoreDocs.isNotEmpty) {
          final sorted = List<FirestoreDocumentModel>.from(restoreDocs);
          sorted.sort((a, b) => b.lastOpened.compareTo(a.lastOpened));
          _onDocTap(sorted.first);
        }
      });
    }

    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    final filteredDocs = firestoreDocs.where((doc) {
      if (_activeSubjectId != null && doc.subjectId != _activeSubjectId)
        return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return doc.title.toLowerCase().contains(q) ||
          doc.fileName.toLowerCase().contains(q) ||
          doc.subject.toLowerCase().contains(q);
    }).toList();

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: Row(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          // Center Workspace
          Expanded(
            flex: isDesktop ? 3 : 1,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _LibraryHeader(
                  totalDocs: firestoreDocs.length,
                  searchQuery: _searchQuery,
                  viewMode: _viewMode,
                  onSearchChanged: (val) =>
                      setState(() => _searchQuery = val.trim()),
                  onViewModeChanged: (mode) => setState(() => _viewMode = mode),
                  onUpload: () => _openUploadModal(context),
                  onAddNote: _addNote,
                  onAddFolder: _addFolder,
                  subjects: subjects,
                  activeSubjectId: _activeSubjectId,
                  onSubjectSelected: (subject) => setState(() {
                    _activeSubjectId = subject?['id'] as String?;
                    _activeSubjectName =
                        subject?['name']?.toString() ?? 'General';
                    _selectedDocIds.clear();
                    ref
                        .read(selectedKnowledgeSourceIdsProvider.notifier)
                        .state = const [];
                    if (activeDoc != null &&
                        _activeSubjectId != null &&
                        activeDoc.subjectId != _activeSubjectId) {
                      ref.read(activeDocumentProvider.notifier).clearDocument();
                    }
                    unawaited(ref
                        .read(firestoreServiceProvider)
                        .setActiveSubjectId(_activeSubjectId));
                  }),
                  onSubjectCreate: _createSubject,
                  onSubjectRename: (subject) => _renameSubject(subject),
                  onSubjectDelete: (subject) => _deleteSubject(subject),
                ),
                const Divider(
                    height: 1, thickness: 1, color: AppColors.darkBorderSubtle),
                Expanded(
                  child: filteredDocs.isEmpty && activeDoc == null
                      ? _LibraryEmptyState(
                          onUpload: () => _openUploadModal(context))
                      : _LibraryDocumentFolio(
                          docs: filteredDocs,
                          activeDoc: activeDoc,
                          selectedDocIds: _selectedDocIds,
                          viewMode: _viewMode,
                          onDocTap: _onDocTap,
                          onDocSelect: _onDocSelect,
                          onQuickAction: _onQuickAction,
                          onDocDelete: (doc) => _onDocDelete(doc, userId),
                          onDocRename: _onDocRename,
                          onDocReindex: _onDocReindex,
                        ),
                ),
                _WorkspaceShelf(
                    items: _activeSubjectId == null
                        ? workspaceItems
                        : workspaceItems
                            .where(
                                (item) => item['subjectId'] == _activeSubjectId)
                            .toList()),
              ],
            ),
          ),

          // Right Study Tools Studio
          if (isDesktop) ...[
            const VerticalDivider(
                width: 1, thickness: 1, color: AppColors.darkBorderSubtle),
            SizedBox(
              width: 300,
              child: _StudyToolsStudio(
                activeDoc: activeDoc,
                onToolTap: (route) => _openTool(context, activeDoc, route),
                onAiChat: () {
                  final ids = _selectedDocIds.isNotEmpty
                      ? _selectedDocIds.toList(growable: false)
                      : activeDoc == null
                          ? const <String>[]
                          : <String>[activeDoc.id];
                  ref.read(selectedKnowledgeSourceIdsProvider.notifier).state =
                      ids;
                  context.go(AppRoutes.aiChat);
                },
              ),
            ),
          ],
        ],
      ),
    );
  }

  void _onDocTap(FirestoreDocumentModel doc) {
    UploadedDocument active;
    if (doc.documentData != null && doc.documentData!.isNotEmpty) {
      try {
        active = UploadedDocument.fromJson(doc.documentData!);
      } catch (_) {
        active = _buildFallback(doc);
      }
    } else {
      active = _buildFallback(doc);
    }
    ref.read(activeDocumentProvider.notifier).setDocument(active);
    // Update lastOpened in Firestore (fire-and-forget)
    ref.read(firestoreServiceProvider).updateLastOpened(doc.id);
  }

  void _onDocSelect(String docId) {
    setState(() {
      if (_selectedDocIds.contains(docId)) {
        _selectedDocIds.remove(docId);
      } else {
        _selectedDocIds.add(docId);
      }
    });
    ref.read(selectedKnowledgeSourceIdsProvider.notifier).state =
        List<String>.unmodifiable(_selectedDocIds);
  }

  void _onQuickAction(FirestoreDocumentModel doc, String route) {
    final active = _buildFallback(doc);
    ref.read(activeDocumentProvider.notifier).setDocument(active);
    if (route == AppRoutes.aiChat) {
      context.go(route);
    } else {
      context.push(route.replaceFirst(':topicId', doc.id));
    }
  }

  Future<void> _onDocDelete(FirestoreDocumentModel doc, String userId) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF111217),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        title: const Text('Delete Document',
            style: TextStyle(
                fontFamily: 'Inter',
                color: AppColors.darkTextPrimary,
                fontSize: 16,
                fontWeight: FontWeight.w700)),
        content: Text(
            'Remove "${doc.title.isNotEmpty ? doc.title : doc.fileName}" permanently? This cannot be undone.',
            style: const TextStyle(
                fontFamily: 'Inter',
                color: AppColors.darkTextSecondary,
                fontSize: 13)),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx, false),
              child: const Text('Cancel',
                  style: TextStyle(color: AppColors.darkTextSecondary))),
          TextButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete',
                style: TextStyle(
                    color: AppColors.error, fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    if (confirm != true) return;
    try {
      await ref
          .read(firebaseUploadServiceProvider)
          .deleteStoredDocument(doc.storagePath);
    } catch (error) {
      debugPrint('Stored file cleanup did not complete: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('The file could not be removed. Please retry.'),
        ));
      }
      return;
    }
    await ref.read(firestoreServiceProvider).deleteDocument(
          documentId: doc.id,
          ownerId: userId.isNotEmpty ? userId : doc.ownerId,
        );
    // Clear active doc if it was the deleted one
    final activeDoc = ref.read(activeDocumentProvider);
    if (activeDoc?.id == doc.id) {
      ref.read(activeDocumentProvider.notifier).clearDocument();
    }
  }

  Future<void> _onDocRename(FirestoreDocumentModel doc) async {
    final controller = TextEditingController(text: doc.title);
    final title = await showDialog<String>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Rename file'),
        content: TextField(
          controller: controller,
          autofocus: true,
          decoration: const InputDecoration(labelText: 'Name'),
        ),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          FilledButton(
              onPressed: () => Navigator.pop(ctx, controller.text.trim()),
              child: const Text('Save')),
        ],
      ),
    );
    controller.dispose();
    if (title == null || title.isEmpty) return;
    await ref.read(firestoreServiceProvider).renameDocument(doc.id, title);
  }

  Future<void> _onDocReindex(FirestoreDocumentModel doc) async {
    try {
      final firestore = ref.read(firestoreServiceProvider);
      final upload = ref.read(firebaseUploadServiceProvider);
      final processing = ref.read(documentProcessingServiceProvider);
      await firestore.setDocumentStatus(doc.id, 'processing');
      final bytes = doc.storagePath.isEmpty
          ? null
          : await upload.downloadDocument(doc.storagePath);
      final text = bytes == null
          ? (doc.extractedText ?? '')
          : await processing.extractText(PlatformFile(
              name: doc.fileName, size: bytes.length, bytes: bytes));
      if (text.trim().isEmpty && bytes == null) {
        throw StateError('No source content is available.');
      }
      await ref.read(knowledgeEngineProvider).index(
            sourceId: doc.id,
            title: doc.title,
            content: text,
            subject: doc.subject,
            sourceBytes: bytes,
            mimeType: _mimeTypeFor(doc.fileType),
          );
    } catch (error) {
      debugPrint('Document re-indexing did not complete.');
      await ref
          .read(firestoreServiceProvider)
          .setDocumentIndexError(doc.id, 'unavailable');
    }
  }

  void _openTool(
      BuildContext context, UploadedDocument? activeDoc, String routeTemplate) {
    if (activeDoc == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please select or upload a document first.'),
          backgroundColor: AppColors.electricViolet,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final ids = _selectedDocIds.length > 1
        ? _selectedDocIds.toList(growable: false)
        : <String>[activeDoc.id];
    ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = ids;
    context.push(routeTemplate.replaceFirst(':topicId', ids.join(',')));
  }

  void _openUploadModal(BuildContext context) {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      AuthRequiredModal.show(
        context,
        title: 'Sign in to upload documents',
        message:
            'Create a free account or sign in to index your notes and generate AI study materials.',
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => _UploadModal(
        defaultSubject: _activeSubjectName,
        onFilesUploaded: (docs) {
          if (docs.isNotEmpty) {
            ref.read(activeDocumentProvider.notifier).setDocument(docs.first);
          }
        },
      ),
    );
  }

  Future<void> _createSubject() async {
    final controller = TextEditingController();
    final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Create subject'),
              content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Subject name')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                    child: const Text('Create'))
              ],
            ));
    controller.dispose();
    if (name == null || name.isEmpty) return;
    final id = await ref.read(firestoreServiceProvider).createSubject(name);
    if (mounted)
      setState(() {
        _activeSubjectId = id;
        _activeSubjectName = name;
      });
    await ref.read(firestoreServiceProvider).setActiveSubjectId(id);
  }

  Future<void> _renameSubject(Map<String, dynamic> subject) async {
    final controller =
        TextEditingController(text: subject['name']?.toString() ?? '');
    final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Rename subject'),
              content: TextField(
                  controller: controller,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Subject name')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, controller.text.trim()),
                    child: const Text('Save'))
              ],
            ));
    controller.dispose();
    if (name == null || name.isEmpty) return;
    await ref
        .read(firestoreServiceProvider)
        .renameSubject(subject['id'] as String, name);
    if (_activeSubjectId == subject['id'] && mounted)
      setState(() => _activeSubjectName = name);
  }

  Future<void> _deleteSubject(Map<String, dynamic> subject) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Delete subject?'),
              content:
                  const Text('Documents and notes will remain in General.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'))
              ],
            ));
    if (confirm != true) return;
    final id = subject['id'] as String;
    await ref.read(firestoreServiceProvider).deleteSubject(id);
    if (_activeSubjectId == id && mounted)
      setState(() {
        _activeSubjectId = null;
        _activeSubjectName = 'General';
      });
    if (_activeSubjectId == null)
      await ref.read(firestoreServiceProvider).setActiveSubjectId(null);
  }

  Future<void> _addNote() async {
    if (ref.read(currentUserProvider) == null) {
      AuthRequiredModal.show(
        context,
        title: 'Sign in to save notes',
        message: 'Sign in to keep your knowledge workspace synced.',
      );
      return;
    }
    final title = TextEditingController();
    final content = TextEditingController();
    final subject = TextEditingController(text: _activeSubjectName);
    final topic = TextEditingController();
    await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Add knowledge note'),
              content: SingleChildScrollView(
                  child: Column(mainAxisSize: MainAxisSize.min, children: [
                TextField(
                    controller: title,
                    decoration: const InputDecoration(labelText: 'Title')),
                TextField(
                    controller: subject,
                    decoration: const InputDecoration(labelText: 'Subject')),
                TextField(
                    controller: topic,
                    decoration: const InputDecoration(labelText: 'Topic')),
                TextField(
                    controller: content,
                    minLines: 4,
                    maxLines: 8,
                    decoration: const InputDecoration(labelText: 'Note')),
              ])),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () async {
                      if (content.text.trim().isEmpty) return;
                      final noteTitle = title.text.trim().isEmpty
                          ? 'Note'
                          : title.text.trim();
                      final noteContent = content.text.trim();
                      final noteSubject = subject.text.trim();
                      final noteTopic = topic.text.trim();
                      final subjectId = noteSubject.toLowerCase() ==
                                  _activeSubjectName.toLowerCase() &&
                              _activeSubjectId != null
                          ? _activeSubjectId!
                          : await ref
                              .read(firestoreServiceProvider)
                              .getOrCreateSubject(noteSubject);
                      final noteId = await ref
                          .read(firestoreServiceProvider)
                          .saveKnowledgeNote(
                              title: noteTitle,
                              content: noteContent,
                              subject: noteSubject,
                              subjectId: subjectId,
                              topic: noteTopic);
                      final engine = ref.read(knowledgeEngineProvider);
                      unawaited(() async {
                        try {
                          await engine.index(
                              sourceId: noteId,
                              sourceKind: 'note',
                              title: noteTitle,
                              content: noteContent,
                              subject: noteSubject,
                              subjectId: subjectId,
                              topic: noteTopic);
                        } catch (error) {
                          debugPrint('Note indexing failed: $error');
                        }
                      }());
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Save note'))
              ],
            ));
    title.dispose();
    content.dispose();
    subject.dispose();
    topic.dispose();
  }

  Future<void> _addFolder() async {
    if (ref.read(currentUserProvider) == null) {
      AuthRequiredModal.show(
        context,
        title: 'Sign in to create folders',
        message: 'Sign in to keep your knowledge workspace synced.',
      );
      return;
    }
    final name = TextEditingController();
    await showDialog<void>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Create workspace folder'),
              content: TextField(
                  controller: name,
                  autofocus: true,
                  decoration: const InputDecoration(labelText: 'Folder name')),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () async {
                      if (name.text.trim().isEmpty) return;
                      await ref
                          .read(firestoreServiceProvider)
                          .createWorkspaceFolder(
                              name: name.text.trim(),
                              subject: _activeSubjectName,
                              subjectId: _activeSubjectId ?? '');
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Create'))
              ],
            ));
    name.dispose();
  }

  UploadedDocument _buildFallback(FirestoreDocumentModel doc) {
    final indexedConcepts =
        (doc.structuredKnowledge?['concepts'] as List? ?? const [])
            .whereType<Map>()
            .toList();
    return UploadedDocument(
      id: doc.id,
      fileName: doc.fileName,
      fileType: doc.fileType,
      byteSize: 1024 * 50,
      fullText: doc.extractedText ?? doc.title,
      concepts: [
        for (var i = 0; i < indexedConcepts.length; i++)
          ExtractedConcept(
            id: (indexedConcepts[i]['id'] ?? '$i').toString(),
            title: (indexedConcepts[i]['name'] ??
                    indexedConcepts[i]['title'] ??
                    'Concept ${i + 1}')
                .toString(),
            description: (indexedConcepts[i]['description'] ??
                    indexedConcepts[i]['definition'] ??
                    '')
                .toString(),
            keyPoints: (indexedConcepts[i]['keyPoints'] as List? ?? const [])
                .map((value) => value.toString())
                .toList(),
          ),
      ],
      flashcards: const [],
      quizzes: const [],
      summary: ExtractedSummary(
        title: doc.title,
        overview: '',
        keyTakeaways: const [],
        coreTheorems: const [],
        examTraps: const [],
      ),
      uploadedAt: doc.uploadedAt,
      subjectId: doc.subjectId,
      subject: doc.subject,
      downloadUrl: doc.fileUrl,
    );
  }
}

// ── Library Header ────────────────────────────────────────────────────────────

class _WorkspaceShelf extends StatelessWidget {
  const _WorkspaceShelf({required this.items});
  final List<Map<String, dynamic>> items;
  @override
  Widget build(BuildContext context) {
    final folders = items.where((item) => item['kind'] == 'folder').toList();
    final notes = items.where((item) => item['kind'] == 'note').toList();
    if (folders.isEmpty && notes.isEmpty) return const SizedBox(height: 8);
    return SizedBox(
        height: 126,
        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Text('FOLDERS & NOTES',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 11))),
          Expanded(
              child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 12),
                  children: [
                for (final folder in folders)
                  _WorkspaceItemCard(
                      icon: Icons.folder_outlined,
                      title: folder['title']?.toString() ?? 'Folder',
                      subtitle:
                          folder['subject']?.toString() ?? 'Workspace folder'),
                for (final note in notes)
                  _WorkspaceItemCard(
                      icon: Icons.sticky_note_2_outlined,
                      title: note['title']?.toString() ?? 'Note',
                      subtitle: note['topic']?.toString() ??
                          note['subject']?.toString() ??
                          'Knowledge note'),
              ])),
        ]));
  }
}

class _WorkspaceItemCard extends StatelessWidget {
  const _WorkspaceItemCard(
      {required this.icon, required this.title, required this.subtitle});
  final IconData icon;
  final String title;
  final String subtitle;
  @override
  Widget build(BuildContext context) => SizedBox(
      width: 190,
      child: Card(
          child: ListTile(
        leading: Icon(icon),
        title: Text(title, maxLines: 1, overflow: TextOverflow.ellipsis),
        subtitle: Text(subtitle, maxLines: 1, overflow: TextOverflow.ellipsis),
      )));
}

class _LibraryHeader extends StatelessWidget {
  final int totalDocs;
  final String searchQuery;
  final String viewMode;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onViewModeChanged;
  final VoidCallback onUpload;
  final VoidCallback onAddNote;
  final VoidCallback onAddFolder;
  final List<Map<String, dynamic>> subjects;
  final String? activeSubjectId;
  final ValueChanged<Map<String, dynamic>?> onSubjectSelected;
  final VoidCallback onSubjectCreate;
  final ValueChanged<Map<String, dynamic>> onSubjectRename;
  final ValueChanged<Map<String, dynamic>> onSubjectDelete;

  const _LibraryHeader({
    required this.totalDocs,
    required this.searchQuery,
    required this.viewMode,
    required this.onSearchChanged,
    required this.onViewModeChanged,
    required this.onUpload,
    required this.onAddNote,
    required this.onAddFolder,
    required this.subjects,
    required this.activeSubjectId,
    required this.onSubjectSelected,
    required this.onSubjectCreate,
    required this.onSubjectRename,
    required this.onSubjectDelete,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      color: AppColors.darkSurface,
      child: Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text(
                    'My Workspace',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 8),
                  if (totalDocs > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 7, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.electricViolet.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '$totalDocs files',
                        style: const TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: AppColors.electricVioletLight,
                        ),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 2),
              Text(
                'Your uploaded study materials, AI-indexed and ready.',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  color: AppColors.darkTextSecondary.withOpacity(0.7),
                ),
              ),
              const SizedBox(height: 6),
              Row(mainAxisSize: MainAxisSize.min, children: [
                DropdownButton<String?>(
                  value: activeSubjectId,
                  hint: const Text('All subjects'),
                  underline: const SizedBox.shrink(),
                  items: [
                    const DropdownMenuItem<String?>(
                        value: null, child: Text('All subjects')),
                    ...subjects.map((subject) => DropdownMenuItem<String?>(
                          value: subject['id'] as String,
                          child: Text(subject['name']?.toString() ?? 'Subject'),
                        )),
                  ],
                  onChanged: (id) => onSubjectSelected(id == null
                      ? null
                      : subjects.where((s) => s['id'] == id).first),
                ),
                IconButton(
                    tooltip: 'Create subject',
                    onPressed: onSubjectCreate,
                    icon: const Icon(Icons.add_circle_outline, size: 18)),
                if (activeSubjectId != null)
                  PopupMenuButton<String>(
                    tooltip: 'Subject options',
                    onSelected: (action) {
                      final subject = subjects
                          .where((s) => s['id'] == activeSubjectId)
                          .first;
                      if (action == 'rename') onSubjectRename(subject);
                      if (action == 'delete') onSubjectDelete(subject);
                    },
                    itemBuilder: (_) => const [
                      PopupMenuItem(
                          value: 'rename', child: Text('Rename subject')),
                      PopupMenuItem(
                          value: 'delete', child: Text('Delete subject')),
                    ],
                  ),
              ]),
            ],
          ),
          const Spacer(),
          // Search
          Container(
            width: 200,
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            padding: const EdgeInsets.symmetric(horizontal: 10),
            child: Row(
              children: [
                Icon(Icons.search_rounded,
                    size: 15, color: Colors.white.withOpacity(0.35)),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.darkTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
                      hintStyle: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.28)),
                      border: InputBorder.none,
                      isDense: true,
                      contentPadding: EdgeInsets.zero,
                    ),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 8),
          // View toggle
          Container(
            height: 34,
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Row(
              children: [
                _ViewBtn(
                    icon: Icons.grid_view_rounded,
                    active: viewMode == 'grid',
                    onTap: () => onViewModeChanged('grid')),
                _ViewBtn(
                    icon: Icons.view_list_rounded,
                    active: viewMode == 'list',
                    onTap: () => onViewModeChanged('list')),
              ],
            ),
          ),
          const SizedBox(width: 10),
          OutlinedButton.icon(
              onPressed: onAddNote,
              icon: const Icon(Icons.note_add_outlined, size: 15),
              label: const Text('Add Note')),
          const SizedBox(width: 8),
          OutlinedButton.icon(
              onPressed: onAddFolder,
              icon: const Icon(Icons.create_new_folder_outlined, size: 15),
              label: const Text('Folder')),
          const SizedBox(width: 8),
          // Upload
          ElevatedButton.icon(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricViolet,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add_rounded, size: 15),
            label: const Text(
              'Add Sources',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12.5,
                  fontWeight: FontWeight.w600),
            ),
          ),
        ],
      ),
    );
  }
}

class _ViewBtn extends StatelessWidget {
  final IconData icon;
  final bool active;
  final VoidCallback onTap;
  const _ViewBtn(
      {required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color:
              active ? AppColors.darkSurfaceContainerHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon,
            size: 16,
            color: active
                ? AppColors.electricVioletLight
                : Colors.white.withOpacity(0.35)),
      ),
    );
  }
}

// ── Empty State ───────────────────────────────────────────────────────────────

class _LibraryEmptyState extends StatelessWidget {
  final VoidCallback onUpload;
  const _LibraryEmptyState({required this.onUpload});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            padding: const EdgeInsets.all(22),
            decoration: BoxDecoration(
              color: AppColors.electricViolet.withOpacity(0.08),
              shape: BoxShape.circle,
              border: Border.all(
                  color: AppColors.electricViolet.withOpacity(0.2), width: 1.5),
            ),
            child: const Icon(Icons.cloud_upload_outlined,
                size: 38, color: AppColors.electricViolet),
          ).animate().fadeIn(duration: 500.ms).scaleXY(
              begin: 0.8, end: 1.0, duration: 500.ms, curve: Curves.easeOut),
          const SizedBox(height: 22),
          const Text(
            'No Study Materials Yet',
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 19,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextPrimary,
                letterSpacing: -0.3),
          )
              .animate(delay: 100.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.2, end: 0),
          const SizedBox(height: 10),
          Text(
            'Upload lecture notes, textbooks, or assignments.\nStudyMate AI extracts concepts, summaries, flashcards & quizzes.',
            textAlign: TextAlign.center,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13.5,
                color: AppColors.darkTextSecondary.withOpacity(0.75),
                height: 1.55),
          ).animate(delay: 150.ms).fadeIn(duration: 400.ms),
          const SizedBox(height: 28),
          Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ElevatedButton.icon(
                onPressed: onUpload,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricViolet,
                  foregroundColor: Colors.white,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.file_upload_outlined, size: 17),
                label: const Text('Upload Documents',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w600)),
              ),
            ],
          )
              .animate(delay: 200.ms)
              .fadeIn(duration: 400.ms)
              .slideY(begin: 0.15, end: 0),
          const SizedBox(height: 28),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: ['PDF', 'PPTX', 'DOCX', 'TXT', 'Markdown']
                .map((f) => Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.darkBorderSubtle),
                      ),
                      child: Text(f,
                          style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 10.5,
                              color: AppColors.darkTextSecondary)),
                    ))
                .toList(),
          ).animate(delay: 300.ms).fadeIn(duration: 400.ms),
        ],
      ),
    );
  }
}

// ── Document Folio ────────────────────────────────────────────────────────────

class _LibraryDocumentFolio extends StatelessWidget {
  final List<FirestoreDocumentModel> docs;
  final UploadedDocument? activeDoc;
  final Set<String> selectedDocIds;
  final String viewMode;
  final ValueChanged<FirestoreDocumentModel> onDocTap;
  final ValueChanged<String> onDocSelect;
  final void Function(FirestoreDocumentModel, String) onQuickAction;
  final ValueChanged<FirestoreDocumentModel> onDocDelete;
  final ValueChanged<FirestoreDocumentModel> onDocRename;
  final ValueChanged<FirestoreDocumentModel> onDocReindex;

  const _LibraryDocumentFolio({
    required this.docs,
    required this.activeDoc,
    required this.selectedDocIds,
    required this.viewMode,
    required this.onDocTap,
    required this.onDocSelect,
    required this.onQuickAction,
    required this.onDocDelete,
    required this.onDocRename,
    required this.onDocReindex,
  });

  @override
  Widget build(BuildContext context) {
    final displayDocs = docs.isNotEmpty
        ? docs
        : (activeDoc != null
            ? [
                FirestoreDocumentModel(
                  id: activeDoc!.id,
                  ownerId: '',
                  title: activeDoc!.fileName
                      .replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
                  subject: 'General',
                  fileName: activeDoc!.fileName,
                  fileUrl: activeDoc!.downloadUrl ?? '',
                  uploadedAt: activeDoc!.uploadedAt,
                  lastOpened: DateTime.now(),
                  conceptCount: activeDoc!.concepts.length,
                  quizCount: activeDoc!.quizzes.length,
                  flashcardCount: activeDoc!.flashcards.length,
                  summary: activeDoc!.summary.overview,
                  extractedText: activeDoc!.fullText,
                  documentData: activeDoc!.toJson(),
                ),
              ]
            : <FirestoreDocumentModel>[]);

    return ListView(
      padding: const EdgeInsets.all(24),
      children: [
        Row(
          children: [
            const Text(
              'INDEXED DOCUMENTS',
              style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 9.5,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextTertiary,
                  letterSpacing: 1.0),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(
                  color: AppColors.darkSurfaceContainer,
                  borderRadius: BorderRadius.circular(4)),
              child: Text('${displayDocs.length}',
                  style: const TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 9.5,
                      color: AppColors.darkTextTertiary)),
            ),
            if (selectedDocIds.isNotEmpty) ...[
              const Spacer(),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                decoration: BoxDecoration(
                  color: AppColors.teal.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.teal.withOpacity(0.3)),
                ),
                child: Text(
                  '${selectedDocIds.length} selected — Cross-doc AI',
                  style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.teal),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        if (viewMode == 'grid')
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 850
                  ? 3
                  : (constraints.maxWidth > 560 ? 2 : 1);
              return GridView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: cols,
                  crossAxisSpacing: 14,
                  mainAxisSpacing: 14,
                  childAspectRatio: 1.5,
                ),
                itemCount: displayDocs.length,
                itemBuilder: (ctx, i) {
                  final d = displayDocs[i];
                  return _DocumentCard(
                    doc: d,
                    isActive: activeDoc?.id == d.id,
                    isSelected: selectedDocIds.contains(d.id),
                    index: i,
                    onTap: () => onDocTap(d),
                    onSelect: () => onDocSelect(d.id),
                    onQuickAction: (route) => onQuickAction(d, route),
                    onDelete: () => onDocDelete(d),
                    onRename: () => onDocRename(d),
                    onReindex: () => onDocReindex(d),
                  );
                },
              );
            },
          )
        else
          Column(
            children: displayDocs.asMap().entries.map((e) {
              final d = e.value;
              return Padding(
                padding: const EdgeInsets.only(bottom: 8),
                child: _DocumentListRow(
                  doc: d,
                  isActive: activeDoc?.id == d.id,
                  isSelected: selectedDocIds.contains(d.id),
                  index: e.key,
                  onTap: () => onDocTap(d),
                  onSelect: () => onDocSelect(d.id),
                  onQuickAction: (route) => onQuickAction(d, route),
                  onDelete: () => onDocDelete(d),
                  onRename: () => onDocRename(d),
                  onReindex: () => onDocReindex(d),
                ),
              );
            }).toList(),
          ),
      ],
    );
  }
}

// ── Document Card (Grid) ──────────────────────────────────────────────────────

class _DocumentCard extends StatefulWidget {
  final FirestoreDocumentModel doc;
  final bool isActive;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final ValueChanged<String> onQuickAction;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final VoidCallback onReindex;

  const _DocumentCard({
    required this.doc,
    required this.isActive,
    required this.isSelected,
    required this.index,
    required this.onTap,
    required this.onSelect,
    required this.onQuickAction,
    required this.onDelete,
    required this.onRename,
    required this.onReindex,
  });

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  bool _hovered = false;

  static Color _fileColor(String ext) {
    switch (ext.toLowerCase().replaceAll('.', '')) {
      case 'pdf':
        return const Color(0xFFFF6B6B);
      case 'pptx':
      case 'ppt':
        return const Color(0xFFFF9F43);
      case 'docx':
      case 'doc':
        return const Color(0xFF5F85DB);
      default:
        return AppColors.teal;
    }
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final fileColor = _fileColor(doc.fileType);
    final ftLabel = doc.fileType.replaceAll('.', '').toUpperCase();
    final ftShort = ftLabel.length > 4 ? ftLabel.substring(0, 4) : ftLabel;

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 180),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.darkSurfaceContainer
                : _hovered
                    ? AppColors.darkSurfaceVariant
                    : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.electricViolet.withOpacity(0.5)
                  : widget.isSelected
                      ? AppColors.teal.withOpacity(0.5)
                      : _hovered
                          ? AppColors.darkBorder
                          : AppColors.darkBorderSubtle,
              width: widget.isActive || widget.isSelected ? 1.5 : 1,
            ),
            boxShadow: (widget.isActive || _hovered)
                ? [
                    BoxShadow(
                      color: (widget.isActive
                              ? AppColors.electricViolet
                              : Colors.black)
                          .withOpacity(0.12),
                      blurRadius: 16,
                      offset: const Offset(0, 4),
                    ),
                  ]
                : null,
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: fileColor.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Center(
                      child: Text(
                        ftShort,
                        style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 9,
                            fontWeight: FontWeight.w800,
                            color: fileColor),
                      ),
                    ),
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          doc.title.isNotEmpty ? doc.title : doc.fileName,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkTextPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(doc.uploadedAt),
                          style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 9.5,
                              color: AppColors.darkTextTertiary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onSelect,
                    child: Icon(
                      widget.isSelected
                          ? Icons.check_box_rounded
                          : Icons.check_box_outline_blank_rounded,
                      size: 15,
                      color: widget.isSelected
                          ? AppColors.teal
                          : Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _MetaPill(
                      label: '${doc.conceptCount} concepts',
                      color: AppColors.electricViolet),
                  const SizedBox(width: 5),
                  _MetaPill(
                      label: '${doc.quizCount} quizzes',
                      color: AppColors.skyBlue),
                  const SizedBox(width: 5),
                  _MetaPill(label: _statusLabel(doc), color: _statusColor(doc)),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded,
                            size: 9, color: AppColors.teal),
                        SizedBox(width: 3),
                        Text(_statusLabel(doc),
                            style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 9.5,
                                fontWeight: FontWeight.w600,
                                color: _statusColor(doc))),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (_hovered)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _HoverAction(
                            icon: Icons.flip_to_front_outlined,
                            tooltip: 'Flashcards',
                            color: AppColors.teal,
                            onTap: () =>
                                widget.onQuickAction(AppRoutes.flashcards)),
                        _HoverAction(
                            icon: Icons.quiz_outlined,
                            tooltip: 'Quiz',
                            color: AppColors.amber,
                            onTap: () => widget.onQuickAction(AppRoutes.quiz)),
                        _HoverAction(
                            icon: Icons.summarize_outlined,
                            tooltip: 'Summary',
                            color: AppColors.skyBlue,
                            onTap: () =>
                                widget.onQuickAction(AppRoutes.summary)),
                        _HoverAction(
                            icon: Icons.edit_outlined,
                            tooltip: 'Rename',
                            color: AppColors.skyBlue,
                            onTap: widget.onRename),
                        _HoverAction(
                            icon: Icons.refresh_rounded,
                            tooltip: 'Re-index',
                            color: AppColors.amber,
                            onTap: widget.onReindex),
                        _HoverAction(
                            icon: Icons.delete_outline_rounded,
                            tooltip: 'Delete',
                            color: AppColors.error,
                            onTap: widget.onDelete),
                      ],
                    )
                  else if (widget.isActive)
                    const Icon(Icons.radio_button_checked_rounded,
                        size: 13, color: AppColors.electricViolet),
                ],
              ),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: widget.index * 40))
            .fadeIn(duration: 300.ms)
            .slideY(begin: 0.08, end: 0),
      ),
    );
  }
}

// ── Document List Row ─────────────────────────────────────────────────────────

class _DocumentListRow extends StatefulWidget {
  final FirestoreDocumentModel doc;
  final bool isActive;
  final bool isSelected;
  final int index;
  final VoidCallback onTap;
  final VoidCallback onSelect;
  final ValueChanged<String> onQuickAction;
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final VoidCallback onReindex;

  const _DocumentListRow({
    required this.doc,
    required this.isActive,
    required this.isSelected,
    required this.index,
    required this.onTap,
    required this.onSelect,
    required this.onQuickAction,
    required this.onDelete,
    required this.onRename,
    required this.onReindex,
  });

  @override
  State<_DocumentListRow> createState() => _DocumentListRowState();
}

class _DocumentListRowState extends State<_DocumentListRow> {
  bool _hovered = false;

  static Color _fileColor(String ext) {
    switch (ext.toLowerCase().replaceAll('.', '')) {
      case 'pdf':
        return const Color(0xFFFF6B6B);
      case 'pptx':
      case 'ppt':
        return const Color(0xFFFF9F43);
      case 'docx':
      case 'doc':
        return const Color(0xFF5F85DB);
      default:
        return AppColors.teal;
    }
  }

  static String _formatDate(DateTime dt) {
    const months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    return '${dt.day} ${months[dt.month - 1]} ${dt.year}';
  }

  @override
  Widget build(BuildContext context) {
    final doc = widget.doc;
    final fileColor = _fileColor(doc.fileType);

    return MouseRegion(
      onEnter: (_) => setState(() => _hovered = true),
      onExit: (_) => setState(() => _hovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 160),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: widget.isActive
                ? AppColors.darkSurfaceContainer
                : _hovered
                    ? AppColors.darkSurfaceVariant
                    : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isActive
                  ? AppColors.electricViolet.withOpacity(0.4)
                  : AppColors.darkBorderSubtle,
              width: widget.isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(
                    color: fileColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(7)),
                child: Center(
                    child: Icon(Icons.description_rounded,
                        size: 16, color: fileColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title.isNotEmpty ? doc.title : doc.fileName,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(_formatDate(doc.uploadedAt),
                        style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 9.5,
                            color: AppColors.darkTextTertiary)),
                  ],
                ),
              ),
              _MetaPill(
                  label: '${doc.conceptCount} concepts',
                  color: AppColors.electricViolet),
              const SizedBox(width: 6),
              _MetaPill(
                  label: '${doc.flashcardCount} cards', color: AppColors.teal),
              const SizedBox(width: 6),
              _MetaPill(label: _statusLabel(doc), color: _statusColor(doc)),
              const SizedBox(width: 12),
              if (_hovered) ...[
                _HoverAction(
                    icon: Icons.flip_to_front_outlined,
                    tooltip: 'Flashcards',
                    color: AppColors.teal,
                    onTap: () => widget.onQuickAction(AppRoutes.flashcards)),
                _HoverAction(
                    icon: Icons.quiz_outlined,
                    tooltip: 'Quiz',
                    color: AppColors.amber,
                    onTap: () => widget.onQuickAction(AppRoutes.quiz)),
                _HoverAction(
                    icon: Icons.summarize_outlined,
                    tooltip: 'Summary',
                    color: AppColors.skyBlue,
                    onTap: () => widget.onQuickAction(AppRoutes.summary)),
                _HoverAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Rename',
                    color: AppColors.skyBlue,
                    onTap: widget.onRename),
                _HoverAction(
                    icon: Icons.refresh_rounded,
                    tooltip: 'Re-index',
                    color: AppColors.amber,
                    onTap: widget.onReindex),
                _HoverAction(
                    icon: Icons.delete_outline_rounded,
                    tooltip: 'Delete',
                    color: AppColors.error,
                    onTap: widget.onDelete),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.chevron_right_rounded,
                  size: 16, color: AppColors.darkTextTertiary),
            ],
          ),
        )
            .animate(delay: Duration(milliseconds: widget.index * 30))
            .fadeIn(duration: 250.ms),
      ),
    );
  }
}

// ── Right Panel: Study Tools Studio ──────────────────────────────────────────

class _StudyToolsStudio extends StatelessWidget {
  final UploadedDocument? activeDoc;
  final ValueChanged<String> onToolTap;
  final VoidCallback onAiChat;

  const _StudyToolsStudio({
    required this.activeDoc,
    required this.onToolTap,
    required this.onAiChat,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppColors.darkSurface,
      padding: const EdgeInsets.all(18),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(6),
                decoration: BoxDecoration(
                  color: AppColors.electricViolet.withOpacity(0.12),
                  borderRadius: BorderRadius.circular(6),
                ),
                child: const Icon(Icons.psychology_outlined,
                    size: 15, color: AppColors.electricVioletLight),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Study Tools',
                  style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13.5,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary),
                ),
              ),
              if (activeDoc != null)
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4)),
                  child: const Text('Active',
                      style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: AppColors.teal)),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            activeDoc != null
                ? activeDoc!.fileName
                : 'Select a document to enable tools.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.white.withOpacity(0.4)),
          ),
          if (activeDoc != null) ...[
            const SizedBox(height: 14),
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                gradient: LinearGradient(colors: [
                  AppColors.electricViolet.withOpacity(0.12),
                  AppColors.skyBlue.withOpacity(0.06),
                ]),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                    color: AppColors.electricViolet.withOpacity(0.22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeDoc!.fileName,
                    style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatBubble(
                          label: '${activeDoc!.concepts.length}',
                          sublabel: 'concepts'),
                      const SizedBox(width: 6),
                      _StatBubble(
                          label: '${activeDoc!.flashcards.length}',
                          sublabel: 'cards'),
                      const SizedBox(width: 6),
                      _StatBubble(
                          label: '${activeDoc!.quizzes.length}',
                          sublabel: 'quizzes'),
                    ],
                  ),
                ],
              ),
            ),
          ],
          const SizedBox(height: 16),
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 9,
                fontWeight: FontWeight.w700,
                color: AppColors.darkTextTertiary,
                letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _ToolTile(
                    icon: Icons.auto_awesome_rounded,
                    title: 'AI Chat Tutor',
                    desc: 'Ask anything with citations',
                    color: AppColors.electricViolet,
                    onTap: onAiChat),
                _ToolTile(
                    icon: Icons.summarize_rounded,
                    title: 'Smart Summary',
                    desc: 'Key takeaways & overview',
                    color: AppColors.skyBlue,
                    onTap: () => onToolTap(AppRoutes.summary)),
                _ToolTile(
                    icon: Icons.hub_rounded,
                    title: 'Mind Map',
                    desc: 'Visual concept graph',
                    color: AppColors.amber,
                    onTap: () => onToolTap(AppRoutes.mindMap)),
                _ToolTile(
                    icon: Icons.flip_to_front_rounded,
                    title: 'Flashcards',
                    desc: 'Spaced repetition drills',
                    color: AppColors.teal,
                    onTap: () => onToolTap(AppRoutes.flashcards)),
                _ToolTile(
                    icon: Icons.quiz_rounded,
                    title: 'Quiz Generator',
                    desc: 'Active recall questions',
                    color: AppColors.electricVioletLight,
                    onTap: () => onToolTap(AppRoutes.quiz)),
                _ToolTile(
                    icon: Icons.analytics_rounded,
                    title: 'PYQ Analyzer',
                    desc: 'Exam weight analysis',
                    color: AppColors.teal,
                    onTap: () => onToolTap(AppRoutes.questionPaperAnalyzer)),
                _ToolTile(
                    icon: Icons.assignment_rounded,
                    title: 'Exam Generator',
                    desc: 'Full mock papers',
                    color: AppColors.electricViolet,
                    onTap: () => onToolTap(AppRoutes.examGenerator)),
                _ToolTile(
                    icon: Icons.functions_rounded,
                    title: 'Formula Sheet',
                    desc: 'Extracted equations',
                    color: AppColors.skyBlue,
                    onTap: () => onToolTap(AppRoutes.summary)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── Upload Modal ──────────────────────────────────────────────────────────────

class _UploadModal extends ConsumerStatefulWidget {
  final ValueChanged<List<UploadedDocument>> onFilesUploaded;
  final String defaultSubject;
  const _UploadModal(
      {required this.onFilesUploaded, required this.defaultSubject});

  @override
  ConsumerState<_UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends ConsumerState<_UploadModal> {
  bool _isProcessing = false;
  String _currentStep = '';
  double _progress = 0.0;
  final _subjectController = TextEditingController();
  final _topicController = TextEditingController();
  final _subtopicController = TextEditingController();
  final _notesController = TextEditingController();
  final _tagsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _subjectController.text = widget.defaultSubject;
  }

  @override
  void dispose() {
    _subjectController.dispose();
    _topicController.dispose();
    _subtopicController.dispose();
    _notesController.dispose();
    _tagsController.dispose();
    super.dispose();
  }

  Future<void> _pickAndUpload(
      {List<String>? extensions, List<PlatformFile>? selectedFiles}) async {
    final processingService = ref.read(documentProcessingServiceProvider);
    final uploadService = ref.read(firebaseUploadServiceProvider);
    final knowledgeEngine = ref.read(knowledgeEngineProvider);
    final firestore = ref.read(firestoreServiceProvider);
    final subject = _subjectController.text.trim().isEmpty
        ? 'General'
        : _subjectController.text.trim();
    final topic = _topicController.text.trim();
    final subtopic = _subtopicController.text.trim();
    final notes = _notesController.text.trim();
    final tags = _tagsController.text
        .split(',')
        .map((tag) => tag.trim())
        .where((tag) => tag.isNotEmpty)
        .toList();

    setState(() {
      _isProcessing = true;
      _currentStep = 'Selecting files...';
      _progress = 0.05;
    });

    try {
      final files = selectedFiles ??
          await processingService.pickMultipleFiles(
              allowedExtensions: extensions);
      if (files.isEmpty) {
        setState(() => _isProcessing = false);
        return;
      }

      final subjectId = await firestore.getOrCreateSubject(subject);

      setState(() {
        _currentStep = 'Saving sources to your workspace…';
        _progress = 0.25;
      });
      final results =
          await Future.wait(files.map((file) => uploadService.uploadFile(
                file,
                subject: subject,
                subjectId: subjectId,
                topic: topic,
                subtopic: subtopic,
                notes: notes,
                tags: tags,
              )));
      final completedDocs = <UploadedDocument>[];
      for (var i = 0; i < files.length; i++) {
        final file = files[i];
        final result = results[i];
        completedDocs.add(UploadedDocument(
          id: result.firestoreDocId,
          fileName: file.name,
          fileType: (file.extension ?? 'file').toUpperCase(),
          byteSize: file.size,
          fullText: '',
          concepts: const [],
          flashcards: const [],
          quizzes: const [],
          summary: ExtractedSummary(
              title: file.name,
              overview: '',
              keyTakeaways: const [],
              coreTheorems: const [],
              examTraps: const []),
          uploadedAt: DateTime.now(),
          downloadUrl: result.downloadUrl,
          subjectId: subjectId,
          subject: subject,
        ));
        unawaited(() async {
          try {
            final text = await processingService.extractText(file);
            await knowledgeEngine.index(
              sourceId: result.firestoreDocId,
              title: file.name,
              content: text,
              subject: subject,
              subjectId: subjectId,
              topic: topic,
              subtopic: subtopic,
              sourceBytes: file.bytes,
              mimeType: _mimeTypeFor(file.extension),
            );
          } catch (_) {
            debugPrint('Background indexing did not complete.');
            await firestore.setDocumentIndexError(
                result.firestoreDocId, 'unavailable');
          }
        }());
      }

      setState(() {
        _currentStep = 'Sources saved. Indexing continues in the background.';
        _progress = 0.35;
      });

      if (mounted) {
        widget.onFilesUploaded(completedDocs);
        Navigator.of(context).pop();
      }
    } catch (_) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Upload could not be completed. Please try again.'),
              backgroundColor: AppColors.error),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.symmetric(horizontal: 24, vertical: 24),
      child: Container(
        constraints: const BoxConstraints(maxWidth: 540),
        padding: const EdgeInsets.all(28),
        decoration: BoxDecoration(
          color: const Color(0xFF111217),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
          boxShadow: [
            BoxShadow(
                color: Colors.black.withOpacity(0.55),
                blurRadius: 40,
                offset: const Offset(0, 8))
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Header
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                      color: AppColors.electricViolet.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.file_upload_outlined,
                      size: 18, color: AppColors.electricViolet),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Sources to Workspace',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 16,
                              fontWeight: FontWeight.w700,
                              color: AppColors.darkTextPrimary)),
                      Text(
                          'AI will extract concepts, flashcards & quizzes instantly.',
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              color: AppColors.darkTextSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded,
                      size: 18, color: AppColors.darkTextSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 22),

            TextField(
                controller: _subjectController,
                decoration: const InputDecoration(labelText: 'Subject')),
            TextField(
                controller: _topicController,
                decoration: const InputDecoration(labelText: 'Topic')),
            TextField(
                controller: _subtopicController,
                decoration: const InputDecoration(labelText: 'Subtopic')),
            TextField(
                controller: _notesController,
                maxLines: 2,
                decoration: const InputDecoration(labelText: 'Optional notes')),
            TextField(
                controller: _tagsController,
                decoration:
                    const InputDecoration(labelText: 'Tags (comma separated)')),
            const SizedBox(height: 14),

            // Source type pills
            Row(
              children: [
                _SourcePill(
                    icon: Icons.picture_as_pdf_rounded,
                    label: 'PDF',
                    color: const Color(0xFFFF6B6B),
                    onTap: _isProcessing
                        ? null
                        : () => _pickAndUpload(extensions: ['pdf'])),
                const SizedBox(width: 6),
                _SourcePill(
                    icon: Icons.slideshow_rounded,
                    label: 'PPT',
                    color: const Color(0xFFFF9F43),
                    onTap: _isProcessing
                        ? null
                        : () => _pickAndUpload(extensions: ['pptx', 'ppt'])),
                const SizedBox(width: 6),
                _SourcePill(
                    icon: Icons.description_rounded,
                    label: 'DOCX',
                    color: const Color(0xFF5F85DB),
                    onTap: _isProcessing
                        ? null
                        : () => _pickAndUpload(extensions: ['docx', 'doc'])),
                const SizedBox(width: 6),
                _SourcePill(
                    icon: Icons.text_snippet_rounded,
                    label: 'TXT',
                    color: AppColors.teal,
                    onTap: _isProcessing
                        ? null
                        : () => _pickAndUpload(extensions: ['txt', 'md'])),
              ],
            ),
            const SizedBox(height: 14),

            // Drop zone
            DropTarget(
              onDragDone: (detail) async {
                if (_isProcessing) return;
                final files = await Future.wait(detail.files.map((file) async {
                  final bytes = await file.readAsBytes();
                  return PlatformFile(
                      name: file.name, size: bytes.length, bytes: bytes);
                }));
                if (mounted) await _pickAndUpload(selectedFiles: files);
              },
              child: GestureDetector(
                onTap: _isProcessing ? null : _pickAndUpload,
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  height: 148,
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceVariant.withOpacity(0.6),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: _isProcessing
                          ? AppColors.electricViolet.withOpacity(0.4)
                          : AppColors.darkBorder,
                      width: 1.5,
                    ),
                  ),
                  child: Center(
                    child: _isProcessing
                        ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(
                                width: 36,
                                height: 36,
                                child: CircularProgressIndicator(
                                  value: _progress,
                                  strokeWidth: 3,
                                  color: AppColors.electricViolet,
                                  backgroundColor: AppColors.electricViolet
                                      .withOpacity(0.12),
                                ),
                              ),
                              const SizedBox(height: 12),
                              Text(
                                _currentStep,
                                style: const TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12.5,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.electricVioletLight),
                              ),
                              const SizedBox(height: 3),
                              Text(
                                '${(_progress * 100).toInt()}%',
                                style: const TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 12,
                                    fontWeight: FontWeight.w700,
                                    color: AppColors.darkTextSecondary),
                              ),
                            ],
                          )
                        : Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color:
                                      AppColors.electricViolet.withOpacity(0.1),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(Icons.upload_file_rounded,
                                    size: 26, color: AppColors.electricViolet),
                              ),
                              const SizedBox(height: 10),
                              const Text('Click to browse or drag files here',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 13,
                                      fontWeight: FontWeight.w600,
                                      color: AppColors.darkTextPrimary)),
                              const SizedBox(height: 3),
                              Text('PDF, PPTX, DOCX, TXT, Markdown',
                                  style: TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 11,
                                      color: Colors.white.withOpacity(0.32))),
                            ],
                          ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// ── Shared Micro Widgets ──────────────────────────────────────────────────────

class _MetaPill extends StatelessWidget {
  final String label;
  final Color color;
  const _MetaPill({required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
          color: color.withOpacity(0.10),
          borderRadius: BorderRadius.circular(4)),
      child: Text(label,
          style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 9.5,
              fontWeight: FontWeight.w600,
              color: color.withOpacity(0.9))),
    );
  }
}

class _HoverAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _HoverAction(
      {required this.icon,
      required this.tooltip,
      required this.color,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          width: 24,
          height: 24,
          margin: const EdgeInsets.only(left: 4),
          decoration: BoxDecoration(
              color: color.withOpacity(0.12),
              borderRadius: BorderRadius.circular(5)),
          child: Icon(icon, size: 13, color: color),
        ),
      ),
    );
  }
}

class _StatBubble extends StatelessWidget {
  final String label;
  final String sublabel;
  const _StatBubble({required this.label, required this.sublabel});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: AppColors.darkSurfaceContainerHigh,
          borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: [
          Text(label,
              style: const TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary)),
          Text(sublabel,
              style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 9,
                  color: AppColors.darkTextTertiary)),
        ],
      ),
    );
  }
}

class _ToolTile extends StatefulWidget {
  final IconData icon;
  final String title;
  final String desc;
  final Color color;
  final VoidCallback onTap;
  const _ToolTile(
      {required this.icon,
      required this.title,
      required this.desc,
      required this.color,
      required this.onTap});

  @override
  State<_ToolTile> createState() => _ToolTileState();
}

class _ToolTileState extends State<_ToolTile> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 6),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            decoration: BoxDecoration(
              color: _hovered
                  ? AppColors.darkSurfaceContainerHigh
                  : AppColors.darkSurfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                  color: _hovered
                      ? AppColors.darkBorder
                      : AppColors.darkBorderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(
                      color: widget.color.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(5)),
                  child: Icon(widget.icon, size: 14, color: widget.color),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title,
                          style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkTextPrimary)),
                      Text(widget.desc,
                          style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 10,
                              color: Colors.white.withOpacity(0.4))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded,
                    size: 14,
                    color: Colors.white.withOpacity(_hovered ? 0.5 : 0.2)),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _SourcePill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;
  final VoidCallback? onTap;
  const _SourcePill(
      {required this.icon,
      required this.label,
      required this.color,
      this.onTap});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 10),
          decoration: BoxDecoration(
            color: color.withOpacity(0.08),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: color.withOpacity(0.2)),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(height: 4),
              Text(label,
                  style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
