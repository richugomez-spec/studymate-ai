import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/services/firebase_upload_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class UploadCenterScreen extends ConsumerStatefulWidget {
  const UploadCenterScreen({super.key});

  @override
  ConsumerState<UploadCenterScreen> createState() => _UploadCenterScreenState();
}

class _UploadCenterScreenState extends ConsumerState<UploadCenterScreen> {
  bool _isProcessing = false;
  String _statusMessage = '';
  double _uploadProgress = 0.0; // 0.0 – 1.0

  static const _fileTypes = [
    _FileType(icon: '📄', label: 'PDF', color: Color(0xFFFF6B6B), description: 'Textbooks, papers'),
    _FileType(icon: '📊', label: 'PPTX', color: Color(0xFFFF9F43), description: 'Lecture slides'),
    _FileType(icon: '📝', label: 'DOCX', color: Color(0xFF5F85DB), description: 'Word documents'),
    _FileType(icon: '🖼️', label: 'Image', color: Color(0xFF26de81), description: 'PNG, JPG, WEBP'),
  ];

  Future<void> _pickFile() async {
    setState(() {
      _isProcessing = true;
      _uploadProgress = 0.0;
      _statusMessage = 'Selecting file...';
    });

    try {
      final processingService = ref.read(documentProcessingServiceProvider);
      final uploadService = ref.read(firebaseUploadServiceProvider);

      // 1. Pick file
      final file = await processingService.pickFile();
      if (file == null) {
        setState(() => _isProcessing = false);
        return;
      }

      // 2. Validate (type + size) — throws ArgumentError on failure
      try {
        uploadService.validateFile(file);
      } on ArgumentError catch (e) {
        setState(() => _isProcessing = false);
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(SnackBar(
            content: Text(e.message.toString()),
            backgroundColor: AppColors.error,
            duration: const Duration(seconds: 4),
          ));
        }
        return;
      }

      // 3. Process document immediately (sub-second local extraction)
      setState(() {
        _uploadProgress = 0.5;
        _statusMessage = 'Analysing ${file.name}...';
      });

      final docId = 'doc_${DateTime.now().millisecondsSinceEpoch}';
      final processedDoc = await processingService.processFromBytes(
        bytes: file.bytes!,
        fileName: file.name,
        byteSize: file.size,
        firestoreDocId: docId,
        downloadUrl: '',
      );

      // 4. Set as active document immediately so student is never stuck
      ref.read(activeDocumentProvider.notifier).setDocument(processedDoc);
      setState(() {
        _uploadProgress = 1.0;
        _isProcessing = false;
      });

      if (mounted) _showSuccessSheet(processedDoc);

      // 5. Fire-and-forget: Upload to Firebase Storage & Firestore in background
      unawaited(() async {
        try {
          final uploadResult = await uploadService.uploadFile(file);
          final firestoreService = ref.read(firestoreServiceProvider);
          final currentUser = ref.read(currentUserProvider);
          final ownerId = currentUser?.id ?? uploadService.currentUserId;

          if (ownerId != null && ownerId.isNotEmpty) {
            await firestoreService.createDocument(
              ownerId: ownerId,
              title: processedDoc.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
              subject: 'General',
              fileName: file.name,
              fileUrl: uploadResult.downloadUrl,
              conceptCount: processedDoc.concepts.length,
              quizCount: processedDoc.quizzes.length,
              flashcardCount: processedDoc.flashcards.length,
            );
          }

          if (uploadResult.downloadUrl.isNotEmpty) {
            await uploadService.markAsProcessed(
              uploadResult.firestoreDocId,
              conceptCount: processedDoc.concepts.length,
              flashcardCount: processedDoc.flashcards.length,
              quizCount: processedDoc.quizzes.length,
              summary: processedDoc.summary.overview,
              extractedText: processedDoc.fullText,
              pageCount: processedDoc.chunks.length,
            );
          }
        } catch (e) {
          debugPrint('Background cloud sync notice: $e');
        }
      }());

    } catch (e) {
      setState(() => _isProcessing = false);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(
          content: Text('Upload failed: $e'),
          backgroundColor: AppColors.error,
          duration: const Duration(seconds: 5),
        ));
      }
    }
  }



  void _showSuccessSheet(UploadedDocument doc) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: AppColors.darkSurface,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(24)),
      ),
      builder: (ctx) => Padding(
        padding: const EdgeInsets.fromLTRB(24, 20, 24, 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 48,
                height: 4,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
            ),
            const SizedBox(height: 20),
            Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: AppColors.teal.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: const Icon(Icons.check_circle_rounded, color: AppColors.teal, size: 28),
                ),
                const SizedBox(width: 14),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        doc.fileName,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${doc.concepts.length} Concepts • ${doc.quizzes.length} Quizzes • ${doc.flashcards.length} Cards',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          color: Colors.white.withOpacity(0.6),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Text(
              'What would you like to explore first?',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w600,
                color: Colors.white70,
              ),
            ),
            const SizedBox(height: 14),
            _ActionOption(
              icon: Icons.chat_bubble_outline_rounded,
              color: AppColors.electricViolet,
              title: 'AI Socratic Chat',
              subtitle: 'Ask questions & discuss concepts with AI',
              onTap: () {
                Navigator.of(ctx).pop();
                context.go(AppRoutes.aiChat);
              },
            ),
            const SizedBox(height: 10),
            _ActionOption(
              icon: Icons.quiz_outlined,
              color: AppColors.teal,
              title: 'Targeted Knowledge Quiz',
              subtitle: '${doc.quizzes.length} questions extracted from this material',
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/topic/quiz/${doc.id}');
              },
            ),
            const SizedBox(height: 10),
            _ActionOption(
              icon: Icons.style_outlined,
              color: AppColors.skyBlue,
              title: 'Active Recall Flashcards',
              subtitle: '${doc.flashcards.length} spaced repetition cards ready',
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/topic/flashcards/${doc.id}');
              },
            ),
            const SizedBox(height: 10),
            _ActionOption(
              icon: Icons.auto_stories_outlined,
              color: AppColors.coral,
              title: 'Executive Summary',
              subtitle: 'Key takeaways and exam traps synthesis',
              onTap: () {
                Navigator.of(ctx).pop();
                context.push('/topic/summary/${doc.id}');
              },
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text(
          'Upload Center',
          style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_rounded),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [


          // ── Drop Zone ──────────────────────────────────────────────────────
          GestureDetector(
            onTap: _isProcessing ? null : _pickFile,
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              height: 170,
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(20),
                border: Border.all(
                  color: AppColors.electricViolet.withOpacity(0.6),
                  width: 1.5,
                  style: BorderStyle.solid,
                ),
              ),
              child: _isProcessing
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Show linear progress during upload, circular during processing
                        if (_uploadProgress > 0.0 && _uploadProgress < 1.0)
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 24),
                            child: ClipRRect(
                              borderRadius: BorderRadius.circular(6),
                              child: LinearProgressIndicator(
                                value: _uploadProgress,
                                backgroundColor: Colors.white.withOpacity(0.1),
                                valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricViolet),
                                minHeight: 6,
                              ),
                            ),
                          )
                        else
                          const CircularProgressIndicator(color: AppColors.electricViolet),
                        const SizedBox(height: 16),
                        Text(
                          _statusMessage,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w500,
                            color: Colors.white70,
                          ),
                        ),
                      ],
                    )
                  : Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          width: 56,
                          height: 56,
                          decoration: BoxDecoration(
                            gradient: AppColors.primaryGradient,
                            borderRadius: BorderRadius.circular(16),
                          ),
                          child: const Icon(Icons.cloud_upload_rounded, size: 28, color: Colors.white),
                        ),
                        const SizedBox(height: 12),
                        const Text(
                          'Tap to upload your PDF or PPTX',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 15,
                            fontWeight: FontWeight.w600,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          'PDF, PPTX, DOCX, TXT notes supported',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.4),
                          ),
                        ),
                      ],
                    ),
            ),
          ),

          const SizedBox(height: 24),

          // ── Active Document Card (if loaded) ──────────────────────────────
          if (activeDoc != null) ...[
            const Text(
              'Active Document',
              style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: AppColors.teal.withOpacity(0.4)),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(8),
                        decoration: BoxDecoration(
                          color: AppColors.teal.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          activeDoc.fileType,
                          style: const TextStyle(fontWeight: FontWeight.w800, fontSize: 11, color: AppColors.teal),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          activeDoc.fileName,
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontWeight: FontWeight.w700,
                            fontSize: 14,
                            color: Colors.white,
                          ),
                          overflow: TextOverflow.ellipsis,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.arrow_forward_rounded, color: AppColors.teal, size: 20),
                        onPressed: () => _showSuccessSheet(activeDoc),
                      ),
                    ],
                  ),
                  const SizedBox(height: 10),
                  Text(
                    activeDoc.summary.overview,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(fontFamily: 'Inter', fontSize: 12, color: Colors.white.withOpacity(0.6)),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _DocBadge(label: '${activeDoc.concepts.length} Concepts'),
                      const SizedBox(width: 8),
                      _DocBadge(label: '${activeDoc.quizzes.length} Quizzes'),
                      const SizedBox(width: 8),
                      _DocBadge(label: '${activeDoc.flashcards.length} Cards'),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
          ],

          // ── Supported File Types ───────────────────────────────────────────
          const Text(
            'Supported Formats',
            style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white),
          ),
          const SizedBox(height: 12),
          GridView.count(
            crossAxisCount: 2,
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 2.2,
            children: _fileTypes.map((type) => Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: AppColors.darkSurface,
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: AppColors.darkBorder),
              ),
              child: Row(
                children: [
                  Text(type.icon, style: const TextStyle(fontSize: 24)),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(type.label, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w600, color: Colors.white)),
                        Text(type.description, style: TextStyle(fontFamily: 'Inter', fontSize: 10, color: Colors.white.withOpacity(0.4)), overflow: TextOverflow.ellipsis),
                      ],
                    ),
                  ),
                ],
              ),
            )).toList(),
          ),
        ],
      ),
    );
  }
}

class _DocBadge extends StatelessWidget {
  final String label;
  const _DocBadge({required this.label});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.06),
        borderRadius: BorderRadius.circular(6),
      ),
      child: Text(
        label,
        style: const TextStyle(fontFamily: 'Inter', fontSize: 10, fontWeight: FontWeight.w600, color: Colors.white70),
      ),
    );
  }
}

class _ActionOption extends StatelessWidget {
  final IconData icon;
  final Color color;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  const _ActionOption({
    required this.icon,
    required this.color,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: color.withOpacity(0.08),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: color.withOpacity(0.2)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: color, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w700, color: Colors.white)),
                  Text(subtitle, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.6))),
                ],
              ),
            ),
            Icon(Icons.chevron_right_rounded, color: color, size: 18),
          ],
        ),
      ),
    );
  }
}

class _FileType {
  final String icon;
  final String label;
  final Color color;
  final String description;
  const _FileType({required this.icon, required this.label, required this.color, required this.description});
}
