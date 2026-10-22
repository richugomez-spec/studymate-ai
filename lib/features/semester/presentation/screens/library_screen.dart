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

String _statusLabel(FirestoreDocumentModel doc) {
  if (doc.status == 'indexed' || doc.uploadStatus == 'completed') {
    return 'AI Ready';
  }
  if (doc.status == 'extracting') return 'Extracting';
  if (doc.status == 'indexing') return 'Indexing';
  if (doc.uploadStatus == 'cancelled' || doc.status == 'cancelled') {
    return 'Cancelled · Retry';
  }
  if (doc.status == 'queued' || doc.uploadStatus == 'queued') return 'Queued';
  if (doc.uploadStatus == 'uploading' || doc.status == 'uploading') {
    return 'Uploading';
  }
  if (doc.status == 'upload_error' ||
      doc.status == 'index_error' ||
      doc.uploadStatus == 'failed') {
    return 'Needs Retry';
  }
  return 'Processing';
}

Color _statusColor(FirestoreDocumentModel doc) {
  return doc.status == 'indexed'
      ? AppColors.teal
      : (doc.status == 'upload_error' ||
              doc.status == 'index_error' ||
              doc.status == 'cancelled' ||
              doc.uploadStatus == 'failed' ||
              doc.uploadStatus == 'cancelled')
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
  String? _activeFolderId;
  String? _activeFolderName;
  String? _activeFolderParentId;
  final Set<String> _selectedDocIds = {};
  final Set<String> _deletingDocIds = {};
  String _viewMode = 'grid'; // grid | list
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      await _recoverStaleUploads();
      final id = await ref.read(firestoreServiceProvider).getActiveSubjectId();
      if (!mounted || id == null || id.isEmpty) return;
      ref.read(activeKnowledgeSubjectIdProvider.notifier).state = id;
    });
  }

  Future<void> _recoverStaleUploads() async {
    try {
      await ref.read(firestoreServiceProvider).recoverStaleUploads();
    } catch (error) {
      debugPrint('Stale upload recovery did not complete: $error');
    }
  }

  @override
  void dispose() {
    super.dispose();
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
    final chatSessions = userId.isNotEmpty
        ? ref.watch(userChatSessionsStreamProvider(userId)).asData?.value ??
            const <FirestoreChatSessionModel>[]
        : const <FirestoreChatSessionModel>[];
    final selectedWorkspaceSubjectId =
        ref.watch(activeKnowledgeSubjectIdProvider);
    if (selectedWorkspaceSubjectId != null &&
        ref.read(activeKnowledgeSubjectNameProvider) == null) {
      final selected =
          subjects.where((s) => s['id'] == selectedWorkspaceSubjectId);
      if (selected.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted) {
            ref.read(activeKnowledgeSubjectNameProvider.notifier).state =
                selected.first['name']?.toString() ?? 'Subject';
          }
        });
      }
    }
    if (_activeSubjectId != null && _activeSubjectName == 'General') {
      final restored = subjects.where((s) => s['id'] == _activeSubjectId);
      if (restored.isNotEmpty) {
        WidgetsBinding.instance.addPostFrameCallback((_) {
          if (mounted)
            setState(() => _activeSubjectName =
                restored.first['name']?.toString() ?? 'General');
          ref.read(activeKnowledgeSubjectNameProvider.notifier).state =
              restored.first['name']?.toString() ?? 'General';
        });
      }
    }

    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    debugPrint('📋 [UI] Build: Total docs from Firestore stream: ${firestoreDocs.length}');
    debugPrint('📋 [UI] Build: Active subject: $_activeSubjectId, Active folder: $_activeFolderId');
    debugPrint('📋 [UI] Build: Deleting doc IDs: $_deletingDocIds');

    final filteredDocs = firestoreDocs.where((doc) {
      if (_deletingDocIds.contains(doc.id)) {
        debugPrint('📋 [UI] Filtering out deleting doc: ${doc.id}');
        return false;
      }
      if (_activeFolderId != null &&
          doc.folderId != _activeFolderId &&
          doc.subjectId != _activeFolderId) return false;
      if (_activeFolderId == null &&
          _activeSubjectId != null &&
          doc.subjectId != _activeSubjectId) return false;
      if (_searchQuery.isEmpty) return true;
      final q = _searchQuery.toLowerCase();
      return doc.title.toLowerCase().contains(q) ||
          doc.fileName.toLowerCase().contains(q) ||
          doc.subject.toLowerCase().contains(q);
    }).toList();

    debugPrint('📋 [UI] Build: Filtered docs for display: ${filteredDocs.length}');

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
                  totalDocs: _activeSubjectId == null ? 0 : filteredDocs.length,
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
                  activeSubjectName: _activeSubjectName,
                  activeFolderName: _activeFolderName,
                  onNavigateRoot: _navigateLibraryRoot,
                  onNavigateSubject: _navigateSubjectRoot,
                  onSubjectCreate: _createSubject,
                  onSubjectRename: (subject) => _renameSubject(subject),
                  onSubjectDelete: (subject) => _deleteSubject(subject),
                ),
                const Divider(
                    height: 1, thickness: 1, color: AppColors.darkBorderSubtle),
                Expanded(
                  child: _activeSubjectId == null
                      ? _SubjectExplorer(
                          subjects: subjects,
                          documents: firestoreDocs,
                          workspaceItems: workspaceItems,
                          chatSessions: chatSessions,
                          onOpen: _openSubject,
                          onRename: _renameSubject,
                          onDelete: _deleteSubject,
                          onCreate: _createSubject,
                        )
                      : filteredDocs.isEmpty
                          ? _LibraryEmptyState(
                              onUpload: () => _openUploadModal(context),
                              onAddFolder: _addFolder,
                              onAddNote: _addNote,
                            )
                          : _LibraryDocumentFolio(
                              docs: filteredDocs,
                              activeDoc: activeDoc,
                              selectedDocIds: _selectedDocIds,
                              viewMode: _viewMode,
                              onDocTap: _onDocTap,
                              onDocSelect: _onDocSelect,
                              onDocDelete: (doc) => _onDocDelete(doc, userId),
                              onDocRename: _onDocRename,
                              onDocReindex: _onDocReindex,
                              onDocView: _viewDocument,
                              onDocMove: _moveDocument,
                            ),
                ),
                if (_activeSubjectId != null)
                  _WorkspaceShelf(
                      items: workspaceItems.where((item) {
                        if (_activeFolderId != null) {
                          if (item['kind'] == 'folder') {
                            return item['parentId'] == _activeFolderId;
                          }
                          return item['folderId'] == _activeFolderId;
                        }
                        return item['subjectId'] == _activeSubjectId &&
                            (item['parentId'] == null ||
                                item['parentId'] == '' ||
                                item['parentId'] == _activeSubjectId);
                      }).toList(),
                      onOpenFolder: _openFolder,
                      onRenameFolder: _renameFolder,
                      onDeleteFolder: _deleteFolder,
                      onMoveToFolder: _moveSelectedToFolder,
                      showUp: _activeFolderId != null,
                      onNavigateUp: () => _navigateFolderUp(workspaceItems)),
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
                subjectName:
                    _activeSubjectId == null ? null : _activeSubjectName,
                onToolTap: (route) => _openTool(context, route),
                onAiChat: () {
                  final ids = _selectedDocIds.toList(growable: false);
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

  Set<String> _folderIdsForSubject(
      String subjectId, List<Map<String, dynamic>> items) {
    final ids = <String>{
      for (final item in items)
        if (item['kind'] == 'folder' &&
            (item['subjectId'] == subjectId || item['parentId'] == subjectId))
          item['id'].toString(),
    };
    var changed = true;
    while (changed) {
      changed = false;
      for (final item in items) {
        if (item['kind'] == 'folder' &&
            ids.contains(item['parentId']) &&
            ids.add(item['id'].toString())) changed = true;
      }
    }
    return ids;
  }

  List<FirestoreDocumentModel> _documentsForSubject(
      String subjectId,
      List<FirestoreDocumentModel> documents,
      List<Map<String, dynamic>> items) {
    final folders = _folderIdsForSubject(subjectId, items);
    final filtered = documents
        .where((doc) =>
            doc.subjectId == subjectId ||
            folders.contains(doc.subjectId) ||
            folders.contains(doc.folderId))
        .toList();
    debugPrint('📊 [UI] _documentsForSubject($subjectId): ${filtered.length} docs (from ${documents.length} total)');
    return filtered;
  }

  Future<void> _openSubject(Map<String, dynamic> subject) async {
    final id = subject['id'] as String;
    final name = subject['name']?.toString() ?? 'Subject';
    debugPrint('🔍 [UI] Opening subject: $name ($id)');

    final userId = ref.read(currentUserProvider)?.id ??
        ref.read(firestoreServiceProvider).currentUserId ??
        '';
    debugPrint('🔍 [UI] User ID: $userId');

    final documents = userId.isEmpty
        ? const <FirestoreDocumentModel>[]
        : ref.read(userDocumentsStreamProvider(userId)).asData?.value ??
            const <FirestoreDocumentModel>[];
    debugPrint('🔍 [UI] Total documents from stream: ${documents.length}');

    final items = userId.isEmpty
        ? const <Map<String, dynamic>>[]
        : ref.read(userKnowledgeStreamProvider(userId)).asData?.value ??
            const <Map<String, dynamic>>[];

    final subjectDocs = _documentsForSubject(id, documents, items);
    debugPrint('🔍 [UI] Documents for this subject: ${subjectDocs.length}');
    for (final doc in subjectDocs) {
      debugPrint('🔍 [UI]   - ${doc.fileName} (id: ${doc.id})');
    }

    final ids = subjectDocs.map((doc) => doc.id).toSet();
    setState(() {
      _activeSubjectId = id;
      _activeSubjectName = name;
      _activeFolderId = null;
      _activeFolderName = null;
      _activeFolderParentId = null;
      _selectedDocIds.clear();
    });
    ref.read(activeKnowledgeSubjectIdProvider.notifier).state = id;
    ref.read(activeKnowledgeSubjectNameProvider.notifier).state = name;
    ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state = id;
    ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
    if (!ids.contains(ref.read(activeDocumentProvider)?.id)) {
      ref.read(activeDocumentProvider.notifier).clearDocument();
    }
    await ref.read(firestoreServiceProvider).setActiveSubjectId(id);
  }

  void _navigateSubjectRoot() {
    if (_activeSubjectId == null) return;
    setState(() {
      _activeFolderId = null;
      _activeFolderName = null;
      _activeFolderParentId = null;
      _selectedDocIds.clear();
    });
    ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state =
        _activeSubjectId;
    ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
  }

  Future<void> _navigateLibraryRoot() async {
    setState(() {
      _activeSubjectId = null;
      _activeSubjectName = 'General';
      _activeFolderId = null;
      _activeFolderName = null;
      _activeFolderParentId = null;
      _selectedDocIds.clear();
    });
    ref.read(activeKnowledgeSubjectIdProvider.notifier).state = null;
    ref.read(activeKnowledgeSubjectNameProvider.notifier).state = null;
    ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state = null;
    ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
    ref.read(activeDocumentProvider.notifier).clearDocument();
    await ref.read(firestoreServiceProvider).setActiveSubjectId(null);
  }

  Future<void> _onDocTap(FirestoreDocumentModel doc) async {
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
    await ref
        .read(firestoreServiceProvider)
        .updateLastOpened(doc.subjectId, doc.id);
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

  Future<void> _onDocDelete(FirestoreDocumentModel doc, String _) async {
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
    if (confirm != true) {
      debugPrint('🖱️ [UI] Delete cancelled by user');
      return;
    }
    debugPrint('🖱️ [UI] Delete confirmed for document: ${doc.id} (${doc.fileName})');
    debugPrint('🖱️ [UI] Subject: ${doc.subjectId}');
    setState(() => _deletingDocIds.add(doc.id));
    try {
      debugPrint('🖱️ [UI] Calling KnowledgeEngine.deleteDocument...');
      await ref.read(knowledgeEngineProvider).deleteDocument(
            subjectId: doc.subjectId,
            documentId: doc.id,
          );
      debugPrint('🖱️ [UI] ✅ Delete operation completed successfully');
      _selectedDocIds.remove(doc.id);
      ref.read(selectedKnowledgeSourceIdsProvider.notifier).state =
          List.unmodifiable(_selectedDocIds);
      debugPrint('🖱️ [UI] Removed from selection state');
    } catch (error, stackTrace) {
      debugPrint('🖱️ [UI] ❌ Delete operation failed: $error');
      debugPrint('🖱️ [UI] Stack trace: $stackTrace');
      if (mounted) {
        setState(() => _deletingDocIds.remove(doc.id));
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('The file could not be deleted. Please retry.'),
        ));
      }
      return;
    }
    // Clear active doc if it was the deleted one
    final activeDoc = ref.read(activeDocumentProvider);
    if (activeDoc?.id == doc.id) {
      debugPrint('🖱️ [UI] Clearing active document provider');
      ref.read(activeDocumentProvider.notifier).clearDocument();
    }
    debugPrint('🖱️ [UI] ✅✅✅ UI DELETE HANDLER COMPLETE');
    if (mounted) {
      setState(() => _deletingDocIds.remove(doc.id));
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
    await ref
        .read(firestoreServiceProvider)
        .renameDocument(doc.subjectId, doc.id, title);
    KnowledgeEngine.invalidateSubjectContext(doc.subjectId,
        ownerId: ref.read(firestoreServiceProvider).currentUserId);
  }

  Future<void> _viewDocument(FirestoreDocumentModel doc) async {
    final preview = () async {
      final cached = doc.extractedText?.trim() ?? '';
      if (cached.isNotEmpty) return cached;
      if (doc.storagePath.isEmpty) return '';
      try {
        final bytes = await ref
            .read(firebaseUploadServiceProvider)
            .downloadDocument(doc.storagePath);
        return await ref.read(documentProcessingServiceProvider).extractText(
              PlatformFile(
                  name: doc.fileName, size: bytes.length, bytes: bytes),
            );
      } catch (error) {
        debugPrint('Document preview could not be loaded: $error');
        rethrow;
      }
    }();
    await showDialog<void>(
      context: context,
      builder: (context) => Dialog(
        child: SizedBox(
          width: 760,
          height: 620,
          child: Column(children: [
            ListTile(
              title: Text(doc.title.isNotEmpty ? doc.title : doc.fileName),
              subtitle: Text(doc.fileType.toUpperCase()),
              trailing: IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ),
            const Divider(height: 1),
            Expanded(
              child: FutureBuilder<String>(
                future: preview,
                builder: (context, snapshot) {
                  if (snapshot.connectionState != ConnectionState.done) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  final content = snapshot.data?.trim() ?? '';
                  if (content.isEmpty) {
                    return const Center(
                        child: Text('No readable preview is available yet.'));
                  }
                  return SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: SelectableText(content),
                  );
                },
              ),
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _moveDocument(FirestoreDocumentModel doc) async {
    final userId = ref.read(currentUserProvider)?.id ??
        ref.read(firestoreServiceProvider).currentUserId ??
        '';
    final items = userId.isEmpty
        ? const <Map<String, dynamic>>[]
        : ref.read(userKnowledgeStreamProvider(userId)).asData?.value ??
            const <Map<String, dynamic>>[];
    final folderIds = _activeSubjectId == null
        ? <String>{}
        : _folderIdsForSubject(_activeSubjectId!, items);
    final folders = items
        .where((item) =>
            item['kind'] == 'folder' && folderIds.contains(item['id']))
        .toList();
    if (folders.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Create a folder before moving this file.'),
      ));
      return;
    }
    final folder = await showDialog<Map<String, dynamic>>(
      context: context,
      builder: (context) => SimpleDialog(
        title: const Text('Move to folder'),
        children: folders
            .where((item) => item['id'] != doc.folderId)
            .map((item) => SimpleDialogOption(
                  onPressed: () => Navigator.pop(context, item),
                  child: Text(item['title']?.toString() ?? 'Folder'),
                ))
            .toList(),
      ),
    );
    if (folder == null) return;
    await ref.read(firestoreServiceProvider).moveDocumentToFolder(
          doc.id,
          folder['id'] as String,
          folderName: folder['title']?.toString() ?? 'Folder',
        );
    KnowledgeEngine.invalidateSubjectContext(doc.subjectId,
        ownerId: ref.read(firestoreServiceProvider).currentUserId);
  }

  Future<void> _onDocReindex(FirestoreDocumentModel doc) async {
    KnowledgeEngine.invalidateSubjectContext(doc.subjectId,
        ownerId: ref.read(firestoreServiceProvider).currentUserId);
    try {
      PlatformFile? replacementFile;
      if (doc.status == 'upload_error' || doc.status == 'cancelled') {
        final picked = await FilePicker.platform.pickFiles(
          type: FileType.custom,
          allowedExtensions: [doc.fileType.toLowerCase().replaceAll('.', '')],
          withData: true,
        );
        if (picked == null || picked.files.isEmpty) return;
        replacementFile = picked.files.first;
      }
      await ref.read(knowledgeEngineProvider).retryDocumentIndex(
            sourceId: doc.id,
            title: doc.title,
            subject: doc.subject,
            subjectId: doc.subjectId,
            storagePath: doc.storagePath,
            status: doc.status,
            fileType: doc.fileType,
            extractedText: doc.extractedText ?? '',
            replacementFile: replacementFile,
          );
    } catch (error) {
      debugPrint('Document re-indexing did not complete: $error');
    }
  }

  void _openTool(BuildContext context, String routeTemplate) {
    if (_activeSubjectId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Open a subject to use its study tools.'),
          backgroundColor: AppColors.electricViolet,
          duration: Duration(seconds: 2),
        ),
      );
      return;
    }
    final ids = _selectedDocIds.toList(growable: false);
    ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = ids;
    context.push(routeTemplate.replaceFirst(
        ':topicId', ids.isEmpty ? 'current' : ids.join(',')));
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
        subjectId: _activeSubjectId,
        folderId: _activeFolderId,
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
    ref.read(activeKnowledgeSubjectIdProvider.notifier).state = id;
    ref.read(activeKnowledgeSubjectNameProvider.notifier).state = name;
    ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state = id;
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
    KnowledgeEngine.invalidateSubjectContext(subject['id'] as String,
        ownerId: ref.read(firestoreServiceProvider).currentUserId);
    if (_activeSubjectId == subject['id'] && mounted)
      setState(() => _activeSubjectName = name);
    if (_activeSubjectId == subject['id']) {
      ref.read(activeKnowledgeSubjectNameProvider.notifier).state = name;
    }
  }

  Future<void> _deleteSubject(Map<String, dynamic> subject) async {
    final confirm = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Delete subject?'),
              content: const Text(
                  'This permanently deletes the subject, its folders, documents, notes, chats, and generated study materials.'),
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
    final deletingActiveSubject = _activeSubjectId == id;
    try {
      await ref.read(knowledgeEngineProvider).deleteSubject(id);
      if (deletingActiveSubject && mounted) {
        setState(() {
          _activeSubjectId = null;
          _activeSubjectName = 'General';
          _activeFolderId = null;
          _activeFolderName = null;
          _activeFolderParentId = null;
          _selectedDocIds.clear();
        });
        ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state = null;
        ref.read(activeKnowledgeSubjectIdProvider.notifier).state = null;
        ref.read(activeKnowledgeSubjectNameProvider.notifier).state = null;
        ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
        ref.read(activeDocumentProvider.notifier).clearDocument();
      }
    } catch (error) {
      debugPrint('Subject cleanup did not complete: $error');
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content:
              Text('The subject could not be fully deleted. Please retry.'),
        ));
      }
    }
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
                              folderId: _activeFolderId ?? '',
                              topic: noteTopic);
                      KnowledgeEngine.invalidateSubjectContext(subjectId,
                          ownerId:
                              ref.read(firestoreServiceProvider).currentUserId);
                      final engine = ref.read(knowledgeEngineProvider);
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
                        return;
                      }
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
                              parentId: _activeFolderId ?? '',
                              subject: _activeSubjectName,
                              subjectId: _activeSubjectId ?? '');
                      if (ctx.mounted) Navigator.pop(ctx);
                    },
                    child: const Text('Create'))
              ],
            ));
    name.dispose();
  }

  void _openFolder(Map<String, dynamic> folder) {
    final userId = ref.read(currentUserProvider)?.id ??
        ref.read(firestoreServiceProvider).currentUserId ??
        '';
    final docs = userId.isEmpty
        ? const <FirestoreDocumentModel>[]
        : ref.read(userDocumentsStreamProvider(userId)).asData?.value ??
            const <FirestoreDocumentModel>[];
    final folderDocs = docs
        .where((doc) =>
            doc.folderId == folder['id'] || doc.subjectId == folder['id'])
        .toList();
    setState(() {
      _activeFolderId = folder['id'] as String;
      _activeFolderName = folder['title']?.toString() ?? 'Folder';
      final parentId = folder['parentId']?.toString() ?? '';
      _activeFolderParentId = parentId.isEmpty ? null : parentId;
      ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state =
          _activeFolderId;
      _selectedDocIds.clear();
      ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
      final active = ref.read(activeDocumentProvider);
      if (active != null && active.subjectId != _activeFolderId) {
        ref.read(activeDocumentProvider.notifier).clearDocument();
      }
    });
    if (folderDocs.isNotEmpty) _onDocTap(folderDocs.first);
  }

  Future<void> _renameFolder(Map<String, dynamic> folder) async {
    final controller =
        TextEditingController(text: folder['title']?.toString() ?? '');
    final name = await showDialog<String>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Rename folder'),
              content: TextField(controller: controller, autofocus: true),
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
        .renameWorkspaceFolder(folder['id'] as String, name);
    KnowledgeEngine.invalidateSubjectContext(_activeSubjectId,
        ownerId: ref.read(firestoreServiceProvider).currentUserId);
    if (_activeFolderId == folder['id'] && mounted)
      setState(() => _activeFolderName = name);
  }

  Future<void> _deleteFolder(Map<String, dynamic> folder) async {
    final confirmed = await showDialog<bool>(
        context: context,
        builder: (ctx) => AlertDialog(
              title: const Text('Delete folder?'),
              content:
                  const Text('Documents will remain in the parent workspace.'),
              actions: [
                TextButton(
                    onPressed: () => Navigator.pop(ctx, false),
                    child: const Text('Cancel')),
                FilledButton(
                    onPressed: () => Navigator.pop(ctx, true),
                    child: const Text('Delete'))
              ],
            ));
    if (confirmed != true) return;
    await ref
        .read(firestoreServiceProvider)
        .deleteWorkspaceFolder(folder['id'] as String);
    KnowledgeEngine.invalidateSubjectContext(_activeSubjectId,
        ownerId: ref.read(firestoreServiceProvider).currentUserId);
    if (_activeFolderId == folder['id'] && mounted) {
      setState(() {
        _activeFolderId = null;
        _activeFolderName = null;
        _activeFolderParentId = null;
        _selectedDocIds.clear();
        ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state =
            _activeSubjectId;
        ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
      });
    }
  }

  Future<void> _moveSelectedToFolder(Map<String, dynamic> folder) async {
    if (_selectedDocIds.isEmpty) return;
    final movedIds = _selectedDocIds.toList(growable: false);
    final firestore = ref.read(firestoreServiceProvider);
    await Future.wait(movedIds.map((id) => firestore.moveDocumentToFolder(
          id,
          folder['id'] as String,
          folderName: folder['title']?.toString() ?? 'Folder',
        )));
    KnowledgeEngine.invalidateSubjectContext(_activeSubjectId,
        ownerId: firestore.currentUserId);
    if (mounted)
      setState(() {
        _selectedDocIds
          ..clear()
          ..addAll(movedIds);
        _activeFolderId = folder['id'] as String;
        _activeFolderName = folder['title']?.toString() ?? 'Folder';
        final parentId = folder['parentId']?.toString() ?? '';
        _activeFolderParentId = parentId.isEmpty ? null : parentId;
        ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state =
            _activeFolderId;
        ref.read(selectedKnowledgeSourceIdsProvider.notifier).state =
            List.unmodifiable(_selectedDocIds);
        if (movedIds.contains(ref.read(activeDocumentProvider)?.id)) {
          ref.read(activeDocumentProvider.notifier).clearDocument();
        }
      });
  }

  void _navigateFolderUp(List<Map<String, dynamic>> items) {
    final parentId = _activeFolderParentId;
    if (parentId != null) {
      final parents = items.where((item) => item['id'] == parentId);
      if (parents.isNotEmpty) {
        _openFolder(parents.first);
        return;
      }
    }
    setState(() {
      _activeFolderId = null;
      _activeFolderName = null;
      _activeFolderParentId = null;
      ref.read(activeKnowledgeWorkspaceIdProvider.notifier).state =
          _activeSubjectId;
      _selectedDocIds.clear();
      ref.read(selectedKnowledgeSourceIdsProvider.notifier).state = const [];
    });
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

class _SubjectExplorer extends StatelessWidget {
  const _SubjectExplorer({
    required this.subjects,
    required this.documents,
    required this.workspaceItems,
    required this.chatSessions,
    required this.onOpen,
    required this.onRename,
    required this.onDelete,
    required this.onCreate,
  });
  final List<Map<String, dynamic>> subjects;
  final List<FirestoreDocumentModel> documents;
  final List<Map<String, dynamic>> workspaceItems;
  final List<FirestoreChatSessionModel> chatSessions;
  final ValueChanged<Map<String, dynamic>> onOpen;
  final ValueChanged<Map<String, dynamic>> onRename;
  final ValueChanged<Map<String, dynamic>> onDelete;
  final VoidCallback onCreate;

  Set<String> _folderIds(String subjectId) {
    final ids = <String>{
      for (final item in workspaceItems)
        if (item['kind'] == 'folder' &&
            (item['subjectId'] == subjectId || item['parentId'] == subjectId))
          item['id'].toString(),
    };
    var changed = true;
    while (changed) {
      changed = false;
      for (final item in workspaceItems) {
        if (item['kind'] == 'folder' &&
            ids.contains(item['parentId']) &&
            ids.add(item['id'].toString())) changed = true;
      }
    }
    return ids;
  }

  @override
  Widget build(BuildContext context) {
    if (subjects.isEmpty) {
      return Center(
        child: Column(mainAxisSize: MainAxisSize.min, children: [
          const Text('Create a subject to organize your study workspace.'),
          const SizedBox(height: 12),
          FilledButton.icon(
              onPressed: onCreate,
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('Create Subject')),
        ]),
      );
    }
    return GridView.builder(
      padding: const EdgeInsets.all(20),
      gridDelegate: const SliverGridDelegateWithMaxCrossAxisExtent(
          maxCrossAxisExtent: 340,
          mainAxisExtent: 126,
          crossAxisSpacing: 12,
          mainAxisSpacing: 12),
      itemCount: subjects.length,
      itemBuilder: (context, index) {
        final subject = subjects[index];
        final id = subject['id'].toString();
        final name = subject['name']?.toString() ?? 'Subject';
        final folders = _folderIds(id);
        final files = documents
            .where((doc) =>
                doc.subjectId == id ||
                folders.contains(doc.subjectId) ||
                folders.contains(doc.folderId))
            .length;
        final chats =
            chatSessions.where((session) => session.subjectId == id).length;

        debugPrint('🎴 [UI] Subject card "$name" ($id): showing $files files (from ${documents.length} total docs in stream)');

        return Card(
          clipBehavior: Clip.antiAlias,
          child: InkWell(
            onTap: () => onOpen(subject),
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
              child: Row(children: [
                const Icon(Icons.folder_rounded,
                    size: 34, color: AppColors.electricVioletLight),
                const SizedBox(width: 12),
                Expanded(
                    child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(subject['name']?.toString() ?? 'Subject',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.w700)),
                    const SizedBox(height: 5),
                    Text(
                        '$files files · ${folders.length} folders · $chats chats',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: Theme.of(context).textTheme.bodySmall),
                  ],
                )),
                PopupMenuButton<String>(
                  onSelected: (action) {
                    if (action == 'rename') onRename(subject);
                    if (action == 'delete') onDelete(subject);
                  },
                  itemBuilder: (_) => const [
                    PopupMenuItem(value: 'rename', child: Text('Rename')),
                    PopupMenuItem(value: 'delete', child: Text('Delete')),
                  ],
                ),
              ]),
            ),
          ),
        );
      },
    );
  }
}

class _WorkspaceShelf extends StatelessWidget {
  const _WorkspaceShelf({
    required this.items,
    required this.onOpenFolder,
    required this.onRenameFolder,
    required this.onDeleteFolder,
    required this.onMoveToFolder,
    required this.showUp,
    required this.onNavigateUp,
  });
  final List<Map<String, dynamic>> items;
  final ValueChanged<Map<String, dynamic>> onOpenFolder;
  final ValueChanged<Map<String, dynamic>> onRenameFolder;
  final ValueChanged<Map<String, dynamic>> onDeleteFolder;
  final ValueChanged<Map<String, dynamic>> onMoveToFolder;
  final bool showUp;
  final VoidCallback onNavigateUp;
  @override
  Widget build(BuildContext context) {
    final folders = items.where((item) => item['kind'] == 'folder').toList();
    final notes = items.where((item) => item['kind'] == 'note').toList();
    if (folders.isEmpty && notes.isEmpty && !showUp)
      return const SizedBox(height: 8);
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
                if (showUp)
                  SizedBox(
                      width: 100,
                      child: Card(
                          child: ListTile(
                        onTap: onNavigateUp,
                        leading: const Icon(Icons.arrow_upward),
                        title: const Text('Up'),
                      ))),
                for (final folder in folders)
                  SizedBox(
                    width: 220,
                    child: Card(
                      child: ListTile(
                        onTap: () => onOpenFolder(folder),
                        leading: const Icon(Icons.folder_outlined),
                        title: Text(folder['title']?.toString() ?? 'Folder',
                            maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: const Text('Open folder'),
                        trailing: PopupMenuButton<String>(
                          onSelected: (action) {
                            if (action == 'move') onMoveToFolder(folder);
                            if (action == 'rename') onRenameFolder(folder);
                            if (action == 'delete') onDeleteFolder(folder);
                          },
                          itemBuilder: (_) => const [
                            PopupMenuItem(
                                value: 'move',
                                child: Text('Move selected here')),
                            PopupMenuItem(
                                value: 'rename', child: Text('Rename')),
                            PopupMenuItem(
                                value: 'delete', child: Text('Delete')),
                          ],
                        ),
                      ),
                    ),
                  ),
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
  final String activeSubjectName;
  final String? activeFolderName;
  final VoidCallback onNavigateRoot;
  final VoidCallback onNavigateSubject;
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
    required this.activeSubjectName,
    required this.activeFolderName,
    required this.onNavigateRoot,
    required this.onNavigateSubject,
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
                TextButton(
                    onPressed: onNavigateRoot, child: const Text('Library')),
                if (activeSubjectId != null) ...[
                  const Icon(Icons.chevron_right, size: 16),
                  TextButton(
                      onPressed: onNavigateSubject,
                      child: Text(activeSubjectName)),
                ],
                if (activeFolderName != null) ...[
                  const Icon(Icons.chevron_right, size: 16),
                  Text(activeFolderName!),
                ],
                if (activeSubjectId == null)
                  IconButton(
                      tooltip: 'Create subject',
                      onPressed: onSubjectCreate,
                      icon: const Icon(Icons.add_circle_outline, size: 18)),
                if (activeSubjectId != null) ...[
                  TextButton.icon(
                    onPressed: () => onSubjectRename(
                        subjects.firstWhere((s) => s['id'] == activeSubjectId)),
                    icon: const Icon(Icons.drive_file_rename_outline, size: 15),
                    label: const Text('Rename Subject'),
                  ),
                  TextButton.icon(
                    onPressed: () => onSubjectDelete(
                        subjects.firstWhere((s) => s['id'] == activeSubjectId)),
                    icon: const Icon(Icons.delete_outline, size: 15),
                    label: const Text('Delete Subject'),
                    style:
                        TextButton.styleFrom(foregroundColor: AppColors.error),
                  ),
                ],
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
          if (activeSubjectId != null) ...[
            OutlinedButton.icon(
                onPressed: onAddNote,
                icon: const Icon(Icons.note_add_outlined, size: 15),
                label: const Text('New Note')),
            const SizedBox(width: 8),
            OutlinedButton.icon(
                onPressed: onAddFolder,
                icon: const Icon(Icons.create_new_folder_outlined, size: 15),
                label: const Text('New Folder')),
            const SizedBox(width: 8),
            ElevatedButton.icon(
              onPressed: onUpload,
              style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricViolet,
                foregroundColor: Colors.white,
                elevation: 0,
                padding:
                    const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8)),
              ),
              icon: const Icon(Icons.add_rounded, size: 15),
              label: const Text('Upload Files'),
            ),
          ],
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
  final VoidCallback onAddFolder;
  final VoidCallback onAddNote;
  const _LibraryEmptyState(
      {required this.onUpload,
      required this.onAddFolder,
      required this.onAddNote});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Column(mainAxisSize: MainAxisSize.min, children: [
        const Text('This subject has no files.'),
        const SizedBox(height: 14),
        Wrap(spacing: 8, children: [
          FilledButton.icon(
              onPressed: onUpload,
              icon: const Icon(Icons.upload_file),
              label: const Text('Upload')),
          OutlinedButton.icon(
              onPressed: onAddFolder,
              icon: const Icon(Icons.create_new_folder_outlined),
              label: const Text('New Folder')),
          OutlinedButton.icon(
              onPressed: onAddNote,
              icon: const Icon(Icons.note_add_outlined),
              label: const Text('New Note')),
        ]),
      ]),
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
  final ValueChanged<FirestoreDocumentModel> onDocDelete;
  final ValueChanged<FirestoreDocumentModel> onDocRename;
  final ValueChanged<FirestoreDocumentModel> onDocReindex;
  final ValueChanged<FirestoreDocumentModel> onDocView;
  final ValueChanged<FirestoreDocumentModel> onDocMove;

  const _LibraryDocumentFolio({
    required this.docs,
    required this.activeDoc,
    required this.selectedDocIds,
    required this.viewMode,
    required this.onDocTap,
    required this.onDocSelect,
    required this.onDocDelete,
    required this.onDocRename,
    required this.onDocReindex,
    required this.onDocView,
    required this.onDocMove,
  });

  @override
  Widget build(BuildContext context) {
    final displayDocs = docs;

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
                    onDelete: () => onDocDelete(d),
                    onRename: () => onDocRename(d),
                    onReindex: () => onDocReindex(d),
                    onView: () => onDocView(d),
                    onMove: () => onDocMove(d),
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
                  onDelete: () => onDocDelete(d),
                  onRename: () => onDocRename(d),
                  onReindex: () => onDocReindex(d),
                  onView: () => onDocView(d),
                  onMove: () => onDocMove(d),
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
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final VoidCallback onReindex;
  final VoidCallback onView;
  final VoidCallback onMove;

  const _DocumentCard({
    required this.doc,
    required this.isActive,
    required this.isSelected,
    required this.index,
    required this.onTap,
    required this.onSelect,
    required this.onDelete,
    required this.onRename,
    required this.onReindex,
    required this.onView,
    required this.onMove,
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
                            icon: Icons.visibility_outlined,
                            tooltip: 'View',
                            color: AppColors.skyBlue,
                            onTap: widget.onView),
                        _HoverAction(
                            icon: Icons.drive_file_move_outline,
                            tooltip: 'Move',
                            color: AppColors.teal,
                            onTap: widget.onMove),
                        _HoverAction(
                            icon: Icons.edit_outlined,
                            tooltip: 'Rename',
                            color: AppColors.skyBlue,
                            onTap: widget.onRename),
                        _HoverAction(
                            icon: Icons.refresh_rounded,
                            tooltip: doc.status == 'index_error' ||
                                    doc.status == 'upload_error' ||
                                    doc.status == 'cancelled' ||
                                    doc.uploadStatus == 'failed' ||
                                    doc.uploadStatus == 'cancelled'
                                ? 'Retry'
                                : 'Re-index',
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
  final VoidCallback onDelete;
  final VoidCallback onRename;
  final VoidCallback onReindex;
  final VoidCallback onView;
  final VoidCallback onMove;

  const _DocumentListRow({
    required this.doc,
    required this.isActive,
    required this.isSelected,
    required this.index,
    required this.onTap,
    required this.onSelect,
    required this.onDelete,
    required this.onRename,
    required this.onReindex,
    required this.onView,
    required this.onMove,
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
                    icon: Icons.visibility_outlined,
                    tooltip: 'View',
                    color: AppColors.skyBlue,
                    onTap: widget.onView),
                _HoverAction(
                    icon: Icons.drive_file_move_outline,
                    tooltip: 'Move',
                    color: AppColors.teal,
                    onTap: widget.onMove),
                _HoverAction(
                    icon: Icons.edit_outlined,
                    tooltip: 'Rename',
                    color: AppColors.skyBlue,
                    onTap: widget.onRename),
                _HoverAction(
                    icon: Icons.refresh_rounded,
                    tooltip: doc.status == 'index_error' ||
                            doc.status == 'upload_error' ||
                            doc.status == 'cancelled' ||
                            doc.uploadStatus == 'failed' ||
                            doc.uploadStatus == 'cancelled'
                        ? 'Retry'
                        : 'Re-index',
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
  final String? subjectName;
  final ValueChanged<String> onToolTap;
  final VoidCallback onAiChat;

  const _StudyToolsStudio({
    required this.subjectName,
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
              if (subjectName != null)
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
            subjectName ?? 'Choose a subject to use study tools.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.white.withOpacity(0.4)),
          ),
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
            child: subjectName == null
                ? const Center(child: Text('Open a subject to begin.'))
                : ListView(
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
                          onTap: () =>
                              onToolTap(AppRoutes.questionPaperAnalyzer)),
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
  final String defaultSubject;
  final String? subjectId;
  final String? folderId;
  const _UploadModal(
      {required this.defaultSubject, this.subjectId, this.folderId});

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
    final knowledgeEngine = ref.read(knowledgeEngineProvider);
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

      final subjectId = widget.subjectId;
      if (subjectId == null || subjectId.isEmpty) {
        throw StateError('Open a subject before uploading files.');
      }

      setState(() {
        _currentStep = 'Saving sources to your workspace…';
        _progress = 0.25;
      });
      final results = await Future.wait<UploadResult?>(
        files.asMap().entries.map((entry) async {
          final file = entry.value;
          try {
            return await knowledgeEngine.uploadAndIndex(
              file,
              onUploadProgress: (progress) {
                if (!mounted) return;
                setState(() {
                  _currentStep = 'Uploading ${file.name}';
                  _progress =
                      0.25 + 0.45 * ((entry.key + progress) / files.length);
                });
              },
              subject: subject,
              subjectId: subjectId,
              folderId: widget.folderId ?? '',
              topic: topic,
              subtopic: subtopic,
              notes: notes,
              tags: tags,
            );
          } catch (error) {
            debugPrint('Upload failed for ${file.name}: $error');
            return null;
          }
        }),
      );

      setState(() {
        _currentStep = 'Upload and indexing complete.';
        _progress = 1;
      });

      if (mounted) {
        Navigator.of(context).pop();
        if (results.any((result) => result == null)) {
          ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
            content:
                Text('Some files failed to upload. Use Retry in the Library.'),
          ));
        }
      }
    } catch (error) {
      debugPrint('Upload workflow did not complete: $error');
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
                readOnly: widget.subjectId != null,
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
