import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/ai/rag/chunker.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class LibraryScreen extends ConsumerWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? ref.watch(firestoreServiceProvider).currentUserId ?? '';
    final firestoreDocsAsync = userId.isNotEmpty
        ? ref.watch(userDocumentsStreamProvider(userId))
        : null;
    final firestoreDocs = firestoreDocsAsync?.asData?.value ?? [];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            backgroundColor: AppColors.darkBackground,
            elevation: 0,
            titleSpacing: 20,
            title: const Text(
              'Library',
              style: TextStyle(
                fontFamily: 'Inter',
                fontWeight: FontWeight.w600,
                fontSize: 18,
                color: Colors.white,
              ),
            ),
            actions: [
              Padding(
                padding: const EdgeInsets.only(right: 16),
                child: InkWell(
                  onTap: () => context.push(AppRoutes.uploadCenter),
                  borderRadius: BorderRadius.circular(6),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(6),
                      border: Border.all(color: AppColors.darkBorderSubtle),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.add_rounded, size: 14, color: Colors.white),
                        SizedBox(width: 5),
                        Text(
                          'Import',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 4, 20, 20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Active Semester Card
                _ActiveSemesterCard(persistedDocsCount: firestoreDocs.length)
                    .animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
                const SizedBox(height: 12),

                // Section: Subjects
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text(
                      'SUBJECTS & MATERIALS',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.8,
                        color: AppColors.darkTextTertiary,
                      ),
                    ),
                    InkWell(
                      onTap: () => context.push(AppRoutes.uploadCenter),
                      child: const Text(
                        '+ add material',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: AppColors.electricViolet,
                        ),
                      ),
                    ),
                  ],
                ).animate(delay: 100.ms).fadeIn(),

                const SizedBox(height: 10),

                if (firestoreDocs.isNotEmpty) ...[
                  ...firestoreDocs.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final doc = entry.value;
                    return Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: _SubjectCard(
                        name: doc.title.isNotEmpty
                            ? doc.title
                            : doc.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
                        code: doc.fileType.toUpperCase(),
                        colorIndex: idx % AppColors.subjectColors.length,
                        topicCount: doc.conceptCount,
                        progress: (doc.quizCount > 0 ? 0.6 : 0.25),
                        onTap: () {
                          // Make this the active document across the entire app
                          ref.read(activeDocumentProvider.notifier).setDocument(
                            UploadedDocument(
                              id: doc.id,
                              fileName: doc.fileName,
                              fileType: doc.fileType,
                              byteSize: 1024 * 50,
                              fullText: doc.title,
                              chunks: [
                                DocumentChunk(
                                  content: '${doc.title}\n${doc.subject}',
                                  chunkIndex: 0,
                                  tokenCount: 50,
                                  documentId: doc.id,
                                ),
                              ],
                              concepts: [
                                ExtractedConcept(
                                  id: 'concept_${doc.id}_1',
                                  title: doc.title.isNotEmpty ? doc.title : doc.fileName,
                                  description: 'Core concepts and topics extracted from ${doc.fileName}.',
                                  initialMastery: 0.6,
                                  importanceScore: 5,
                                  keyPoints: ['Overview of ${doc.title}', 'Key foundational principles', 'Practical exam applications'],
                                ),
                              ],
                              flashcards: [
                                ExtractedFlashcard(
                                  id: 'fc_${doc.id}_1',
                                  front: 'What is the core subject of ${doc.title}?',
                                  back: doc.subject,
                                  conceptTitle: doc.title,
                                ),
                              ],
                              quizzes: [
                                ExtractedQuizQuestion(
                                  id: 'qz_${doc.id}_1',
                                  question: 'Which area does ${doc.title} belong to?',
                                  options: [doc.subject, 'General Studies', 'Unrelated Topic', 'Introductory Overview'],
                                  correctIndex: 0,
                                  explanation: 'Based on your saved document metadata in StudyMate AI.',
                                  conceptTitle: doc.title,
                                ),
                              ],
                              summary: ExtractedSummary(
                                title: doc.title,
                                overview: 'Comprehensive study folio for ${doc.fileName} (${doc.fileType}). Includes ${doc.conceptCount} core micro-concepts and assessment questions.',
                                keyTakeaways: ['Indexed in active knowledge base', 'Full AI context available in AI Coach', 'Ready for quiz generation'],
                                coreTheorems: ['Primary topic: ${doc.subject}'],
                                examTraps: ['Review key definitions before the exam'],
                              ),
                              uploadedAt: doc.uploadedAt,
                              downloadUrl: doc.fileUrl,
                            ),
                          );
                          context.push(AppRoutes.summary.replaceFirst(':topicId', doc.id));
                        },
                      ).animate(delay: (150 + idx * 50).ms).fadeIn().slideY(begin: 0.1, end: 0),
                    );
                  }),
                ] else if (activeDoc != null) ...[
                  Padding(
                    padding: const EdgeInsets.only(bottom: 12),
                    child: _SubjectCard(
                      name: activeDoc.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), ''),
                      code: activeDoc.fileType.toUpperCase(),
                      colorIndex: 0,
                      topicCount: activeDoc.concepts.length,
                      progress: 0.25,
                      onTap: () {
                        context.push(AppRoutes.summary.replaceFirst(':topicId', activeDoc.id));
                      },
                    ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkBorderSubtle),
                    ),
                    child: Column(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(14),
                          decoration: BoxDecoration(
                            color: AppColors.electricViolet.withOpacity(0.12),
                            shape: BoxShape.circle,
                          ),
                          child: const Icon(Icons.library_books_rounded, color: AppColors.electricViolet, size: 30),
                        ),
                        const SizedBox(height: 14),
                        const Text(
                          'No Subjects Enrolled Yet',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          'Upload lecture slides, notes, or chapters to automatically create and organize your course library in Firestore.',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: Colors.white.withOpacity(0.6),
                          ),
                        ),
                        const SizedBox(height: 16),
                        ElevatedButton.icon(
                          onPressed: () => context.push(AppRoutes.uploadCenter),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricViolet,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                          ),
                          icon: const Icon(Icons.upload_file_rounded, size: 18),
                          label: const Text('Upload Study Material', style: TextStyle(fontWeight: FontWeight.w700)),
                        ),
                      ],
                    ),
                  ),
                ],
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ActiveSemesterCard extends ConsumerWidget {
  final int persistedDocsCount;

  const _ActiveSemesterCard({this.persistedDocsCount = 0});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activeDoc = ref.watch(activeDocumentProvider);
    final hasMaterials = persistedDocsCount > 0 || activeDoc != null;

    final semesterTitle = user?.course != null
        ? user!.course!
        : (user?.yearOfStudy != null ? 'Year ${user!.yearOfStudy}' : 'Academic Course Folio');

    return Container(
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'ACADEMIC STATUS',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 9.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextTertiary,
                      letterSpacing: 0.7,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    semesterTitle,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    hasMaterials
                        ? '${persistedDocsCount > 0 ? persistedDocsCount : 1} Study Materials Indexed'
                        : 'No Study Materials Loaded',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                ],
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(
                    hasMaterials ? 'Active' : '0%',
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 24,
                      fontWeight: FontWeight.w700,
                      color: AppColors.electricViolet,
                    ),
                  ),
                  Text(
                    'overall progress',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.4),
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: LinearProgressIndicator(
              value: hasMaterials ? 0.35 : 0.0,
              minHeight: 6,
              backgroundColor: Colors.white.withOpacity(0.1),
              valueColor: const AlwaysStoppedAnimation<Color>(AppColors.electricViolet),
            ),
          ),
        ],
      ),
    );
  }
}

class _SubjectCard extends StatelessWidget {
  final String name;
  final String code;
  final int colorIndex;
  final int topicCount;
  final double progress;
  final VoidCallback? onTap;

  const _SubjectCard({
    required this.name,
    required this.code,
    required this.colorIndex,
    required this.topicCount,
    required this.progress,
    this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    final color = AppColors.subjectColors[colorIndex];

    return GestureDetector(
      onTap: onTap ?? () {},
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: color.withOpacity(0.2)),
              ),
              child: Center(
                child: Text(
                  name.substring(0, 1),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 20,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ),
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Row(
                    children: [
                      Text(
                        code,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        width: 3,
                        height: 3,
                        decoration: BoxDecoration(
                          color: Colors.white.withOpacity(0.3),
                          shape: BoxShape.circle,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Text(
                        '$topicCount topics',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 8),
                  Row(
                    children: [
                      Expanded(
                        child: ClipRRect(
                          borderRadius: BorderRadius.circular(4),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 4,
                            backgroundColor: Colors.white.withOpacity(0.08),
                            valueColor: AlwaysStoppedAnimation<Color>(color),
                          ),
                        ),
                      ),
                      const SizedBox(width: 10),
                      Text(
                        '${(progress * 100).round()}%',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          fontWeight: FontWeight.w600,
                          color: color,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Icon(Icons.chevron_right_rounded, size: 22, color: Colors.white.withOpacity(0.3)),
          ],
        ),
      ),
    );
  }
}
