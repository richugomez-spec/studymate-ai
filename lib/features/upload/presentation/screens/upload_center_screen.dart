import 'dart:async';

import 'package:file_picker/file_picker.dart';
import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/ai/services/knowledge_engine.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/services/firebase_upload_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_required_modal.dart';

/// Workspace source dialog. Metadata is written first; Storage and Gemini
/// indexing continue after this dialog closes.
class UploadCenterScreen extends ConsumerStatefulWidget {
  final String? targetTool;
  const UploadCenterScreen({super.key, this.targetTool});

  @override
  ConsumerState<UploadCenterScreen> createState() => _UploadCenterScreenState();
}

class _UploadCenterScreenState extends ConsumerState<UploadCenterScreen> {
  final _subject = TextEditingController();
  final _topic = TextEditingController();
  final _subtopic = TextEditingController();
  final _notes = TextEditingController();
  final _tags = TextEditingController();
  final List<PlatformFile> _files = [];
  bool _saving = false;
  bool _dragging = false;
  double _progress = 0;
  String? _error;

  @override
  void dispose() {
    _subject.dispose();
    _topic.dispose();
    _subtopic.dispose();
    _notes.dispose();
    _tags.dispose();
    super.dispose();
  }

  Future<void> _pickFiles() async {
    final picked =
        await ref.read(documentProcessingServiceProvider).pickMultipleFiles();
    if (mounted && picked.isNotEmpty) {
      setState(() {
        _files.addAll(picked.where(
            (f) => !_files.any((x) => x.name == f.name && x.size == f.size)));
        _error = null;
      });
    }
  }

  Future<void> _saveSources() async {
    if (ref.read(currentUserProvider) == null) {
      final signedIn = await AuthRequiredModal.show(context,
          title: 'Sign in to upload sources',
          message: 'Your workspace sources are saved to your account.');
      if (!signedIn || !mounted) return;
    }
    if (_files.isEmpty || _saving) return;
    setState(() {
      _saving = true;
      _error = null;
      _progress = 0.05;
    });
    try {
      final upload = ref.read(firebaseUploadServiceProvider);
      final processing = ref.read(documentProcessingServiceProvider);
      final engine = ref.read(knowledgeEngineProvider);
      final firestore = ref.read(firestoreServiceProvider);
      final subject =
          _subject.text.trim().isEmpty ? 'General' : _subject.text.trim();
      final topic = _topic.text.trim();
      final subtopic = _subtopic.text.trim();
      final notes = _notes.text.trim();
      final tags = _tags.text
          .split(',')
          .map((s) => s.trim())
          .where((s) => s.isNotEmpty)
          .toList();
      final results = await Future.wait(_files.map((file) => upload.uploadFile(
            file,
            subject: subject,
            topic: topic,
            subtopic: subtopic,
            notes: notes,
            tags: tags,
            onProgress: (value) {
              if (mounted) setState(() => _progress = value);
            },
          )));
      if (!mounted) return;
      for (var i = 0; i < _files.length; i++) {
        final file = _files[i];
        final sourceId = results[i].firestoreDocId;
        unawaited(() async {
          try {
            final text = await processing.extractText(file);
            await engine.index(
                sourceId: sourceId,
                title: file.name,
                content: text,
                subject: subject,
                topic: topic,
                subtopic: subtopic,
                sourceBytes: file.bytes,
                mimeType: _mimeType(file.extension));
          } catch (error) {
            debugPrint('Knowledge indexing did not complete.');
            await firestore.setDocumentIndexError(sourceId, 'unavailable');
          }
        }());
      }
      _openTarget(results.first.firestoreDocId);
    } catch (e) {
      debugPrint('Source upload did not complete.');
      if (mounted)
        setState(() {
          _saving = false;
          _error = 'Could not add sources right now. Please try again.';
        });
    }
  }

  void _openTarget(String id) {
    final file = _files.first;
    ref.read(activeDocumentProvider.notifier).setDocument(UploadedDocument(
          id: id,
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
        ));
    final target = widget.targetTool?.toLowerCase().trim();
    if (target == null || target.isEmpty) {
      context.pop();
      return;
    }
    final route = switch (target) {
      'mindmap' || 'mind_map' => AppRoutes.mindMap,
      'quiz' => AppRoutes.quiz,
      'flashcards' || 'flashcard' => AppRoutes.flashcards,
      'summary' || 'smart_summary' => AppRoutes.summary,
      'formula' ||
      'formula_sheet' =>
        '${AppRoutes.summary.replaceFirst(':topicId', id)}?mode=formula',
      'pyq' || 'pyq_analyzer' => AppRoutes.questionPaperAnalyzer,
      'mock_exam' || 'exam' => AppRoutes.examGenerator,
      'chat' || 'ai_chat' => AppRoutes.aiChat,
      _ => AppRoutes.library,
    };
    if (route
        .startsWith('${AppRoutes.summary.replaceFirst(':topicId', id)}?')) {
      context.go(route);
    } else if (route == AppRoutes.aiChat || route == AppRoutes.library) {
      context.go(route);
    } else {
      context.go(route.replaceFirst(':topicId', id));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black54,
      body: Center(
        child: Dialog(
          backgroundColor: AppColors.darkSurface,
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 620, maxHeight: 760),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(children: [
                    const Expanded(
                        child: Text('Add sources to workspace',
                            style: TextStyle(
                                fontSize: 18, fontWeight: FontWeight.w700))),
                    IconButton(
                        onPressed: () => context.pop(),
                        icon: const Icon(Icons.close)),
                  ]),
                  Wrap(spacing: 8, runSpacing: 4, children: [
                    _field(_subject, 'Subject'),
                    _field(_topic, 'Topic'),
                    _field(_subtopic, 'Subtopic'),
                    _field(_tags, 'Tags (comma separated)'),
                  ]),
                  TextField(
                      controller: _notes,
                      maxLines: 2,
                      decoration:
                          const InputDecoration(labelText: 'Custom notes')),
                  const SizedBox(height: 14),
                  DropTarget(
                    onDragEntered: (_) => setState(() => _dragging = true),
                    onDragExited: (_) => setState(() => _dragging = false),
                    onDragDone: (detail) async {
                      final dropped = await Future.wait(
                          detail.files.map((file) async => PlatformFile(
                                name: file.name,
                                size: await file.length(),
                                bytes: await file.readAsBytes(),
                              )));
                      if (mounted)
                        setState(() {
                          _files.addAll(dropped);
                          _dragging = false;
                        });
                    },
                    child: InkWell(
                      onTap: _saving ? null : _pickFiles,
                      child: Container(
                        height: 100,
                        alignment: Alignment.center,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: _dragging
                                  ? AppColors.teal
                                  : AppColors.electricViolet),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.cloud_upload_outlined),
                              SizedBox(height: 8),
                              Text('Choose multiple files or drop them here'),
                            ]),
                      ),
                    ),
                  ),
                  if (_files.isNotEmpty) ...[
                    const SizedBox(height: 10),
                    SizedBox(
                        height: 170,
                        child: ListView(shrinkWrap: true, children: [
                          for (var i = 0; i < _files.length; i++)
                            ListTile(
                              dense: true,
                              leading:
                                  const Icon(Icons.insert_drive_file_outlined),
                              title: Text(_files[i].name),
                              trailing: IconButton(
                                onPressed: _saving
                                    ? null
                                    : () => setState(() => _files.removeAt(i)),
                                icon: const Icon(Icons.close),
                              ),
                            ),
                        ])),
                  ],
                  if (_saving) ...[
                    const SizedBox(height: 10),
                    LinearProgressIndicator(
                        value: _progress == 0 ? null : _progress),
                  ],
                  if (_error != null)
                    Text(_error!,
                        style: const TextStyle(color: Colors.redAccent)),
                  const SizedBox(height: 14),
                  FilledButton.icon(
                    onPressed: _saving || _files.isEmpty ? null : _saveSources,
                    icon: const Icon(Icons.add),
                    label: Text(
                        _saving ? 'Saving sources…' : 'Upload and continue'),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _field(TextEditingController controller, String label) => SizedBox(
      width: 260,
      child: TextField(
          controller: controller,
          decoration: InputDecoration(labelText: label)));

  String _mimeType(String? extension) => switch (extension?.toLowerCase()) {
        'pdf' => 'application/pdf',
        'png' => 'image/png',
        'jpg' || 'jpeg' => 'image/jpeg',
        'webp' => 'image/webp',
        _ => 'application/octet-stream',
      };
}
