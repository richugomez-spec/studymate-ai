import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';

class SubjectScreen extends ConsumerWidget {
  final String subjectId;
  const SubjectScreen({super.key, required this.subjectId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final subjectTitle = activeDoc != null
        ? activeDoc.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')
        : 'Subject Folio ($subjectId)';

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: Text(
          subjectTitle,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.darkBorderSubtle),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'COURSE OVERVIEW',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextTertiary,
                          letterSpacing: 0.8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        subjectTitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 22,
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        activeDoc?.summary.overview ?? 'Study material and cognitive concept units.',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          color: Colors.white.withOpacity(0.6),
                          height: 1.4,
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                Text(
                  'CONCEPT MODULES',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                if (activeDoc != null && activeDoc.concepts.isNotEmpty) ...[
                  ...activeDoc.concepts.map((concept) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: AppColors.darkSurfaceVariant,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: AppColors.darkBorderSubtle),
                          ),
                          child: Row(
                            children: [
                              Container(
                                width: 8,
                                height: 8,
                                decoration: const BoxDecoration(
                                  color: AppColors.teal,
                                  shape: BoxShape.circle,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      concept.title,
                                      style: const TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 14,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 2),
                                    Text(
                                      concept.description,
                                      style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12,
                                        color: Colors.white.withOpacity(0.55),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.darkTextTertiary),
                                onPressed: () {
                                  context.push(AppRoutes.quiz.replaceFirst(':topicId', activeDoc.id));
                                },
                              ),
                            ],
                          ),
                        ),
                      )),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkBorderSubtle),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.menu_book_outlined, size: 30, color: AppColors.darkTextTertiary),
                          const SizedBox(height: 10),
                          const Text('No Concept Modules Loaded', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Text('Upload course notes to extract modular concept maps.', style: TextStyle(color: Colors.white.withOpacity(0.5), fontSize: 12)),
                          const SizedBox(height: 12),
                          ElevatedButton(
                            onPressed: () => context.push(AppRoutes.uploadCenter),
                            style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricViolet),
                            child: const Text('Upload Notes', style: TextStyle(color: Colors.white)),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
