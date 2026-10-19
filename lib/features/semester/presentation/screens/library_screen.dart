import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/services/firebase_upload_service.dart';
import '../../../../services/firestore_models.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_required_modal.dart';

/// Library Workspace — NotebookLM-inspired 3-column workspace
/// Left sidebar (in MainShell) | Center document folio | Right AI Tools Studio
class LibraryScreen extends ConsumerStatefulWidget {
  const LibraryScreen({super.key});

  @override
  ConsumerState<LibraryScreen> createState() => _LibraryScreenState();
}

class _LibraryScreenState extends ConsumerState<LibraryScreen> {
  String _searchQuery = '';
  final Set<String> _selectedDocIds = {};
  String _viewMode = 'grid'; // grid | list

  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? ref.watch(firestoreServiceProvider).currentUserId ?? '';
    final firestoreDocsAsync = userId.isNotEmpty
        ? ref.watch(userDocumentsStreamProvider(userId))
        : null;
    final firestoreDocs = firestoreDocsAsync?.asData?.value ?? [];

    final isDesktop = MediaQuery.of(context).size.width >= 1100;

    final filteredDocs = firestoreDocs.where((doc) {
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
                  onSearchChanged: (val) => setState(() => _searchQuery = val.trim()),
                  onViewModeChanged: (mode) => setState(() => _viewMode = mode),
                  onUpload: () => _openUploadModal(context),
                ),
                const Divider(height: 1, thickness: 1, color: AppColors.darkBorderSubtle),
                Expanded(
                  child: filteredDocs.isEmpty && activeDoc == null
                      ? _LibraryEmptyState(onUpload: () => _openUploadModal(context))
                      : _LibraryDocumentFolio(
                          docs: filteredDocs,
                          activeDoc: activeDoc,
                          selectedDocIds: _selectedDocIds,
                          viewMode: _viewMode,
                          onDocTap: _onDocTap,
                          onDocSelect: _onDocSelect,
                          onQuickAction: _onQuickAction,
                        ),
                ),
              ],
            ),
          ),

          // Right Study Tools Studio
          if (isDesktop) ...[
            const VerticalDivider(width: 1, thickness: 1, color: AppColors.darkBorderSubtle),
            SizedBox(
              width: 300,
              child: _StudyToolsStudio(
                activeDoc: activeDoc,
                onToolTap: (route) => _openTool(context, activeDoc, route),
                onAiChat: () => context.go(AppRoutes.aiChat),
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
  }

  void _onDocSelect(String docId) {
    setState(() {
      if (_selectedDocIds.contains(docId)) {
        _selectedDocIds.remove(docId);
      } else {
        _selectedDocIds.add(docId);
      }
    });
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

  void _openTool(BuildContext context, UploadedDocument? activeDoc, String routeTemplate) {
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
    context.push(routeTemplate.replaceFirst(':topicId', activeDoc.id));
  }

  void _openUploadModal(BuildContext context) {
    final user = ref.read(currentUserProvider);
    if (user == null) {
      AuthRequiredModal.show(
        context,
        title: 'Sign in to upload documents',
        message: 'Create a free account or sign in to index your notes and generate AI study materials.',
      );
      return;
    }

    showDialog(
      context: context,
      barrierColor: Colors.black.withOpacity(0.75),
      builder: (ctx) => _UploadModal(
        onFilesUploaded: (docs) {
          if (docs.isNotEmpty) {
            ref.read(activeDocumentProvider.notifier).setDocument(docs.first);
          }
        },
      ),
    );
  }

  UploadedDocument _buildFallback(FirestoreDocumentModel doc) {
    return UploadedDocument(
      id: doc.id,
      fileName: doc.fileName,
      fileType: doc.fileType,
      byteSize: 1024 * 50,
      fullText: doc.extractedText ?? doc.title,
      chunks: const [],
      concepts: [
        ExtractedConcept(
          id: 'c_1',
          title: doc.title.isNotEmpty ? doc.title : doc.fileName,
          description: doc.summary ?? 'Core principles extracted from ${doc.fileName}.',
          initialMastery: 0.6,
          importanceScore: 5,
        ),
      ],
      flashcards: [
        ExtractedFlashcard(
          id: 'fc_1',
          front: 'What is the core subject of ${doc.title}?',
          back: doc.subject,
          conceptTitle: doc.title,
        ),
      ],
      quizzes: [
        ExtractedQuizQuestion(
          id: 'qz_1',
          question: 'What is the main subject covered in ${doc.title}?',
          options: [doc.subject, 'General Knowledge', 'Introductory', 'Other'],
          correctIndex: 0,
          explanation: 'Extracted from metadata.',
          conceptTitle: doc.title,
        ),
      ],
      summary: ExtractedSummary(
        title: doc.title,
        overview: doc.summary ?? 'Summary for ${doc.fileName}.',
        keyTakeaways: const ['Indexed in active knowledge base', 'Full AI context available in AI Coach'],
        coreTheorems: const [],
        examTraps: const [],
      ),
      uploadedAt: doc.uploadedAt,
      downloadUrl: doc.fileUrl,
    );
  }
}

// ── Library Header ────────────────────────────────────────────────────────────

class _LibraryHeader extends StatelessWidget {
  final int totalDocs;
  final String searchQuery;
  final String viewMode;
  final ValueChanged<String> onSearchChanged;
  final ValueChanged<String> onViewModeChanged;
  final VoidCallback onUpload;

  const _LibraryHeader({
    required this.totalDocs,
    required this.searchQuery,
    required this.viewMode,
    required this.onSearchChanged,
    required this.onViewModeChanged,
    required this.onUpload,
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
                      padding: const EdgeInsets.symmetric(horizontal: 7, vertical: 2),
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
                Icon(Icons.search_rounded, size: 15, color: Colors.white.withOpacity(0.35)),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    onChanged: onSearchChanged,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12, color: AppColors.darkTextPrimary),
                    decoration: InputDecoration(
                      hintText: 'Search documents...',
                      hintStyle: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.28)),
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
                _ViewBtn(icon: Icons.grid_view_rounded, active: viewMode == 'grid', onTap: () => onViewModeChanged('grid')),
                _ViewBtn(icon: Icons.view_list_rounded, active: viewMode == 'list', onTap: () => onViewModeChanged('list')),
              ],
            ),
          ),
          const SizedBox(width: 10),
          // Upload
          ElevatedButton.icon(
            onPressed: onUpload,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.electricViolet,
              foregroundColor: Colors.white,
              elevation: 0,
              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 9),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            icon: const Icon(Icons.add_rounded, size: 15),
            label: const Text(
              'Add Sources',
              style: TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.w600),
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
  const _ViewBtn({required this.icon, required this.active, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          color: active ? AppColors.darkSurfaceContainerHigh : Colors.transparent,
          borderRadius: BorderRadius.circular(7),
        ),
        child: Icon(icon, size: 16, color: active ? AppColors.electricVioletLight : Colors.white.withOpacity(0.35)),
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
              border: Border.all(color: AppColors.electricViolet.withOpacity(0.2), width: 1.5),
            ),
            child: const Icon(Icons.cloud_upload_outlined, size: 38, color: AppColors.electricViolet),
          ).animate().fadeIn(duration: 500.ms).scaleXY(begin: 0.8, end: 1.0, duration: 500.ms, curve: Curves.easeOut),
          const SizedBox(height: 22),
          const Text(
            'No Study Materials Yet',
            style: TextStyle(fontFamily: 'Inter', fontSize: 19, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary, letterSpacing: -0.3),
          ).animate(delay: 100.ms).fadeIn(duration: 400.ms).slideY(begin: 0.2, end: 0),
          const SizedBox(height: 10),
          Text(
            'Upload lecture notes, textbooks, or assignments.\nStudyMate AI extracts concepts, summaries, flashcards & quizzes.',
            textAlign: TextAlign.center,
            style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, color: AppColors.darkTextSecondary.withOpacity(0.75), height: 1.55),
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
                  padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 12),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                  elevation: 0,
                ),
                icon: const Icon(Icons.file_upload_outlined, size: 17),
                label: const Text('Upload Documents', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600)),
              ),
            ],
          ).animate(delay: 200.ms).fadeIn(duration: 400.ms).slideY(begin: 0.15, end: 0),
          const SizedBox(height: 28),
          Wrap(
            spacing: 8,
            runSpacing: 6,
            alignment: WrapAlignment.center,
            children: ['PDF', 'PPTX', 'DOCX', 'TXT', 'Markdown'].map((f) => Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(6),
                border: Border.all(color: AppColors.darkBorderSubtle),
              ),
              child: Text(f, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10.5, color: AppColors.darkTextSecondary)),
            )).toList(),
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

  const _LibraryDocumentFolio({
    required this.docs,
    required this.activeDoc,
    required this.selectedDocIds,
    required this.viewMode,
    required this.onDocTap,
    required this.onDocSelect,
    required this.onQuickAction,
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
                  title: activeDoc!.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
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
              style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9.5, fontWeight: FontWeight.w700, color: AppColors.darkTextTertiary, letterSpacing: 1.0),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 1),
              decoration: BoxDecoration(color: AppColors.darkSurfaceContainer, borderRadius: BorderRadius.circular(4)),
              child: Text('${displayDocs.length}', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9.5, color: AppColors.darkTextTertiary)),
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
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal),
                ),
              ),
            ],
          ],
        ),
        const SizedBox(height: 14),
        if (viewMode == 'grid')
          LayoutBuilder(
            builder: (context, constraints) {
              final cols = constraints.maxWidth > 850 ? 3 : (constraints.maxWidth > 560 ? 2 : 1);
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

  const _DocumentCard({
    required this.doc,
    required this.isActive,
    required this.isSelected,
    required this.index,
    required this.onTap,
    required this.onSelect,
    required this.onQuickAction,
  });

  @override
  State<_DocumentCard> createState() => _DocumentCardState();
}

class _DocumentCardState extends State<_DocumentCard> {
  bool _hovered = false;

  static Color _fileColor(String ext) {
    switch (ext.toLowerCase().replaceAll('.', '')) {
      case 'pdf': return const Color(0xFFFF6B6B);
      case 'pptx':
      case 'ppt': return const Color(0xFFFF9F43);
      case 'docx':
      case 'doc': return const Color(0xFF5F85DB);
      default: return AppColors.teal;
    }
  }

  static String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
                      color: (widget.isActive ? AppColors.electricViolet : Colors.black).withOpacity(0.12),
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
                        style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, fontWeight: FontWeight.w800, color: fileColor),
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
                          style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          _formatDate(doc.uploadedAt),
                          style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9.5, color: AppColors.darkTextTertiary),
                        ),
                      ],
                    ),
                  ),
                  GestureDetector(
                    onTap: widget.onSelect,
                    child: Icon(
                      widget.isSelected ? Icons.check_box_rounded : Icons.check_box_outline_blank_rounded,
                      size: 15,
                      color: widget.isSelected ? AppColors.teal : Colors.white.withOpacity(0.2),
                    ),
                  ),
                ],
              ),
              const Spacer(),
              Row(
                children: [
                  _MetaPill(label: '${doc.conceptCount} concepts', color: AppColors.electricViolet),
                  const SizedBox(width: 5),
                  _MetaPill(label: '${doc.quizCount} quizzes', color: AppColors.skyBlue),
                ],
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.teal.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check_circle_rounded, size: 9, color: AppColors.teal),
                        SizedBox(width: 3),
                        Text('AI Ready', style: TextStyle(fontFamily: 'Inter', fontSize: 9.5, fontWeight: FontWeight.w600, color: AppColors.teal)),
                      ],
                    ),
                  ),
                  const Spacer(),
                  if (_hovered)
                    Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        _HoverAction(icon: Icons.flip_to_front_outlined, tooltip: 'Flashcards', color: AppColors.teal,
                            onTap: () => widget.onQuickAction(AppRoutes.flashcards)),
                        _HoverAction(icon: Icons.quiz_outlined, tooltip: 'Quiz', color: AppColors.amber,
                            onTap: () => widget.onQuickAction(AppRoutes.quiz)),
                        _HoverAction(icon: Icons.summarize_outlined, tooltip: 'Summary', color: AppColors.skyBlue,
                            onTap: () => widget.onQuickAction(AppRoutes.summary)),
                      ],
                    )
                  else if (widget.isActive)
                    const Icon(Icons.radio_button_checked_rounded, size: 13, color: AppColors.electricViolet),
                ],
              ),
            ],
          ),
        ).animate(delay: Duration(milliseconds: widget.index * 40)).fadeIn(duration: 300.ms).slideY(begin: 0.08, end: 0),
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

  const _DocumentListRow({
    required this.doc,
    required this.isActive,
    required this.isSelected,
    required this.index,
    required this.onTap,
    required this.onSelect,
    required this.onQuickAction,
  });

  @override
  State<_DocumentListRow> createState() => _DocumentListRowState();
}

class _DocumentListRowState extends State<_DocumentListRow> {
  bool _hovered = false;

  static Color _fileColor(String ext) {
    switch (ext.toLowerCase().replaceAll('.', '')) {
      case 'pdf': return const Color(0xFFFF6B6B);
      case 'pptx':
      case 'ppt': return const Color(0xFFFF9F43);
      case 'docx':
      case 'doc': return const Color(0xFF5F85DB);
      default: return AppColors.teal;
    }
  }

  static String _formatDate(DateTime dt) {
    const months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
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
                : _hovered ? AppColors.darkSurfaceVariant : AppColors.darkSurface,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: widget.isActive ? AppColors.electricViolet.withOpacity(0.4) : AppColors.darkBorderSubtle,
              width: widget.isActive ? 1.5 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 32,
                height: 32,
                decoration: BoxDecoration(color: fileColor.withOpacity(0.15), borderRadius: BorderRadius.circular(7)),
                child: Center(child: Icon(Icons.description_rounded, size: 16, color: fileColor)),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      doc.title.isNotEmpty ? doc.title : doc.fileName,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                    Text(_formatDate(doc.uploadedAt), style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9.5, color: AppColors.darkTextTertiary)),
                  ],
                ),
              ),
              _MetaPill(label: '${doc.conceptCount} concepts', color: AppColors.electricViolet),
              const SizedBox(width: 6),
              _MetaPill(label: '${doc.flashcardCount} cards', color: AppColors.teal),
              const SizedBox(width: 12),
              if (_hovered) ...[
                _HoverAction(icon: Icons.flip_to_front_outlined, tooltip: 'Flashcards', color: AppColors.teal,
                    onTap: () => widget.onQuickAction(AppRoutes.flashcards)),
                _HoverAction(icon: Icons.quiz_outlined, tooltip: 'Quiz', color: AppColors.amber,
                    onTap: () => widget.onQuickAction(AppRoutes.quiz)),
                _HoverAction(icon: Icons.summarize_outlined, tooltip: 'Summary', color: AppColors.skyBlue,
                    onTap: () => widget.onQuickAction(AppRoutes.summary)),
                const SizedBox(width: 4),
              ],
              const Icon(Icons.chevron_right_rounded, size: 16, color: AppColors.darkTextTertiary),
            ],
          ),
        ).animate(delay: Duration(milliseconds: widget.index * 30)).fadeIn(duration: 250.ms),
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
                child: const Icon(Icons.psychology_outlined, size: 15, color: AppColors.electricVioletLight),
              ),
              const SizedBox(width: 8),
              const Expanded(
                child: Text(
                  'Study Tools',
                  style: TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary),
                ),
              ),
              if (activeDoc != null)
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                  decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.12), borderRadius: BorderRadius.circular(4)),
                  child: const Text('Active', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.teal)),
                ),
            ],
          ),
          const SizedBox(height: 5),
          Text(
            activeDoc != null ? activeDoc!.fileName : 'Select a document to enable tools.',
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.4)),
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
                border: Border.all(color: AppColors.electricViolet.withOpacity(0.22)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    activeDoc!.fileName,
                    style: const TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      _StatBubble(label: '${activeDoc!.concepts.length}', sublabel: 'concepts'),
                      const SizedBox(width: 6),
                      _StatBubble(label: '${activeDoc!.flashcards.length}', sublabel: 'cards'),
                      const SizedBox(width: 6),
                      _StatBubble(label: '${activeDoc!.quizzes.length}', sublabel: 'quizzes'),
                    ],
                  ),
                ],
              ),
            ),
          ],

          const SizedBox(height: 16),
          const Text(
            'QUICK ACTIONS',
            style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.darkTextTertiary, letterSpacing: 1.0),
          ),
          const SizedBox(height: 8),

          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _ToolTile(icon: Icons.auto_awesome_rounded, title: 'AI Chat Tutor', desc: 'Ask anything with citations', color: AppColors.electricViolet, onTap: onAiChat),
                _ToolTile(icon: Icons.summarize_rounded, title: 'Smart Summary', desc: 'Key takeaways & overview', color: AppColors.skyBlue, onTap: () => onToolTap(AppRoutes.summary)),
                _ToolTile(icon: Icons.hub_rounded, title: 'Mind Map', desc: 'Visual concept graph', color: AppColors.amber, onTap: () => onToolTap(AppRoutes.mindMap)),
                _ToolTile(icon: Icons.flip_to_front_rounded, title: 'Flashcards', desc: 'Spaced repetition drills', color: AppColors.teal, onTap: () => onToolTap(AppRoutes.flashcards)),
                _ToolTile(icon: Icons.quiz_rounded, title: 'Quiz Generator', desc: 'Active recall questions', color: AppColors.electricVioletLight, onTap: () => onToolTap(AppRoutes.quiz)),
                _ToolTile(icon: Icons.analytics_rounded, title: 'PYQ Analyzer', desc: 'Exam weight analysis', color: AppColors.teal, onTap: () => onToolTap(AppRoutes.questionPaperAnalyzer)),
                _ToolTile(icon: Icons.assignment_rounded, title: 'Exam Generator', desc: 'Full mock papers', color: AppColors.electricViolet, onTap: () => onToolTap(AppRoutes.examGenerator)),
                _ToolTile(icon: Icons.functions_rounded, title: 'Formula Sheet', desc: 'Extracted equations', color: AppColors.skyBlue, onTap: () => onToolTap(AppRoutes.summary)),
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
  const _UploadModal({required this.onFilesUploaded});

  @override
  ConsumerState<_UploadModal> createState() => _UploadModalState();
}

class _UploadModalState extends ConsumerState<_UploadModal> {
  bool _isProcessing = false;
  String _currentStep = '';
  double _progress = 0.0;

  Future<void> _pickAndUpload({List<String>? extensions}) async {
    final processingService = ref.read(documentProcessingServiceProvider);
    final uploadService = ref.read(firebaseUploadServiceProvider);
    final firestoreService = ref.read(firestoreServiceProvider);
    final user = ref.read(currentUserProvider);
    final ownerId = user?.id ?? uploadService.currentUserId ?? '';

    setState(() {
      _isProcessing = true;
      _currentStep = 'Selecting files...';
      _progress = 0.05;
    });

    try {
      final files = await processingService.pickMultipleFiles(allowedExtensions: extensions);
      if (files.isEmpty) {
        setState(() => _isProcessing = false);
        return;
      }

      final completedDocs = <UploadedDocument>[];

      for (int i = 0; i < files.length; i++) {
        final f = files[i];
        final base = (i + 1) / files.length;

        setState(() {
          _currentStep = 'Processing ${f.name}...';
          _progress = (base * 0.3).clamp(0.0, 1.0);
        });

        final docId = 'doc_${DateTime.now().millisecondsSinceEpoch}_$i';
        final processedDoc = await processingService.processFromBytes(
          bytes: f.bytes!,
          fileName: f.name,
          byteSize: f.size,
          firestoreDocId: docId,
          downloadUrl: '',
          userId: ownerId,
        );

        setState(() {
          _currentStep = 'Extracting concepts from ${f.name}...';
          _progress = (base * 0.7).clamp(0.0, 1.0);
        });

        completedDocs.add(processedDoc);

        unawaited(() async {
          try {
            final uploadResult = await uploadService.uploadFile(f);
            if (ownerId.isNotEmpty) {
              await firestoreService.createDocument(
                ownerId: ownerId,
                title: f.name.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
                fileName: f.name,
                fileUrl: uploadResult.downloadUrl,
                conceptCount: processedDoc.concepts.length,
                quizCount: processedDoc.quizzes.length,
                flashcardCount: processedDoc.flashcards.length,
                summary: processedDoc.summary.overview,
                extractedText: processedDoc.fullText,
                documentData: processedDoc.toJson(),
              );
            }
          } catch (e) {
            debugPrint('Cloud sync error: $e');
          }
        }());
      }

      setState(() {
        _currentStep = 'All documents indexed & ready!';
        _progress = 1.0;
      });

      await Future.delayed(const Duration(milliseconds: 700));
      if (mounted) {
        widget.onFilesUploaded(completedDocs);
        Navigator.of(context).pop();
      }
    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Upload failed: $e'), backgroundColor: AppColors.error),
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
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.55), blurRadius: 40, offset: const Offset(0, 8))],
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
                  decoration: BoxDecoration(color: AppColors.electricViolet.withOpacity(0.12), borderRadius: BorderRadius.circular(8)),
                  child: const Icon(Icons.file_upload_outlined, size: 18, color: AppColors.electricViolet),
                ),
                const SizedBox(width: 12),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text('Add Sources to Workspace', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
                      Text('AI will extract concepts, flashcards & quizzes instantly.', style: TextStyle(fontFamily: 'Inter', fontSize: 11.5, color: AppColors.darkTextSecondary)),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close_rounded, size: 18, color: AppColors.darkTextSecondary),
                  onPressed: () => Navigator.of(context).pop(),
                  padding: EdgeInsets.zero,
                  constraints: const BoxConstraints(),
                ),
              ],
            ),
            const SizedBox(height: 22),

            // Source type pills
            Row(
              children: [
                _SourcePill(icon: Icons.picture_as_pdf_rounded, label: 'PDF', color: const Color(0xFFFF6B6B), onTap: _isProcessing ? null : () => _pickAndUpload(extensions: ['pdf'])),
                const SizedBox(width: 6),
                _SourcePill(icon: Icons.slideshow_rounded, label: 'PPT', color: const Color(0xFFFF9F43), onTap: _isProcessing ? null : () => _pickAndUpload(extensions: ['pptx', 'ppt'])),
                const SizedBox(width: 6),
                _SourcePill(icon: Icons.description_rounded, label: 'DOCX', color: const Color(0xFF5F85DB), onTap: _isProcessing ? null : () => _pickAndUpload(extensions: ['docx', 'doc'])),
                const SizedBox(width: 6),
                _SourcePill(icon: Icons.text_snippet_rounded, label: 'TXT', color: AppColors.teal, onTap: _isProcessing ? null : () => _pickAndUpload(extensions: ['txt', 'md'])),
              ],
            ),
            const SizedBox(height: 14),

            // Drop zone
            GestureDetector(
              onTap: _isProcessing ? null : _pickAndUpload,
              child: AnimatedContainer(
                duration: const Duration(milliseconds: 200),
                height: 148,
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceVariant.withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: _isProcessing ? AppColors.electricViolet.withOpacity(0.4) : AppColors.darkBorder,
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
                                backgroundColor: AppColors.electricViolet.withOpacity(0.12),
                              ),
                            ),
                            const SizedBox(height: 12),
                            Text(
                              _currentStep,
                              style: const TextStyle(fontFamily: 'Inter', fontSize: 12.5, fontWeight: FontWeight.w600, color: AppColors.electricVioletLight),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              '${(_progress * 100).toInt()}%',
                              style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.darkTextSecondary),
                            ),
                          ],
                        )
                      : Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.electricViolet.withOpacity(0.1),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.upload_file_rounded, size: 26, color: AppColors.electricViolet),
                            ),
                            const SizedBox(height: 10),
                            const Text('Click to browse or drag files here', style: TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary)),
                            const SizedBox(height: 3),
                            Text('PDF, PPTX, DOCX, TXT, Markdown', style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.32))),
                          ],
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
      decoration: BoxDecoration(color: color.withOpacity(0.10), borderRadius: BorderRadius.circular(4)),
      child: Text(label, style: TextStyle(fontFamily: 'Inter', fontSize: 9.5, fontWeight: FontWeight.w600, color: color.withOpacity(0.9))),
    );
  }
}

class _HoverAction extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final Color color;
  final VoidCallback onTap;
  const _HoverAction({required this.icon, required this.tooltip, required this.color, required this.onTap});

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
          decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
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
      decoration: BoxDecoration(color: AppColors.darkSurfaceContainerHigh, borderRadius: BorderRadius.circular(6)),
      child: Column(
        children: [
          Text(label, style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.darkTextPrimary)),
          Text(sublabel, style: const TextStyle(fontFamily: 'Inter', fontSize: 9, color: AppColors.darkTextTertiary)),
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
  const _ToolTile({required this.icon, required this.title, required this.desc, required this.color, required this.onTap});

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
              color: _hovered ? AppColors.darkSurfaceContainerHigh : AppColors.darkSurfaceContainer,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: _hovered ? AppColors.darkBorder : AppColors.darkBorderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: BoxDecoration(color: widget.color.withOpacity(0.12), borderRadius: BorderRadius.circular(5)),
                  child: Icon(widget.icon, size: 14, color: widget.color),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(widget.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 12, fontWeight: FontWeight.w600, color: AppColors.darkTextPrimary)),
                      Text(widget.desc, style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white.withOpacity(0.4))),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, size: 14, color: Colors.white.withOpacity(_hovered ? 0.5 : 0.2)),
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
  const _SourcePill({required this.icon, required this.label, required this.color, this.onTap});

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
              Text(label, style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: color)),
            ],
          ),
        ),
      ),
    );
  }
}
