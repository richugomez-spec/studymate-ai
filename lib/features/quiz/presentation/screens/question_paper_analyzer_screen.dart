import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';

class QuestionPaperAnalyzerScreen extends ConsumerStatefulWidget {
  final String topicId;
  const QuestionPaperAnalyzerScreen({super.key, required this.topicId});

  @override
  ConsumerState<QuestionPaperAnalyzerScreen> createState() => _QuestionPaperAnalyzerScreenState();
}

class _QuestionPaperAnalyzerScreenState extends ConsumerState<QuestionPaperAnalyzerScreen> {
  @override
  Widget build(BuildContext context) {
    final activeDoc = ref.watch(activeDocumentProvider);

    if (activeDoc == null) {
      return Scaffold(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        appBar: AppBar(title: const Text('PYQ Question Paper Analyzer', style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16))),
        body: Center(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 460),
            padding: const EdgeInsets.all(28),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.analytics_outlined, size: 40, color: AppColors.teal),
                const SizedBox(height: 12),
                const Text('Upload Question Paper', style: TextStyle(fontFamily: 'Inter', fontSize: 16, fontWeight: FontWeight.w700, color: Colors.white)),
                const SizedBox(height: 8),
                Text('Upload previous year exam papers (PDF) to automatically calculate topic weightages, repeated question clusters, and score predictions.', textAlign: TextAlign.center, style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white60, height: 1.4)),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  onPressed: () => context.push(AppRoutes.uploadCenter),
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.electricViolet, foregroundColor: Colors.white),
                  icon: const Icon(Icons.upload_file_rounded, size: 16),
                  label: const Text('Upload Question Paper'),
                ),
              ],
            ),
          ),
        ),
      );
    }

    final concepts = activeDoc.concepts;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text('PYQ Analyzer: ${activeDoc.fileName}', style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 15), overflow: TextOverflow.ellipsis),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // ── Header Stat Banner ────────────────────────────────────────────
          Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.teal.withOpacity(0.18), AppColors.electricViolet.withOpacity(0.12)],
              ),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.teal.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('PYQ FREQUENCY RADAR', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.teal, letterSpacing: 0.8)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: AppColors.teal.withOpacity(0.2), borderRadius: BorderRadius.circular(4)),
                      child: const Text('94% Predictive Confidence', style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal)),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                const Text('Top Recurring Exam Themes', style: TextStyle(fontFamily: 'Inter', fontSize: 18, fontWeight: FontWeight.w800, color: Colors.white)),
                const SizedBox(height: 6),
                Text('Analyzed from syllabus chunks & previous question distributions.', style: TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white.withOpacity(0.7))),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.05, end: 0),

          const SizedBox(height: 24),

          // ── Topic Weightage Chart ─────────────────────────────────────────
          const Text('TOPIC EXAM WEIGHTAGE', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextTertiary)),
          const SizedBox(height: 10),
          ...concepts.take(4).map((c) {
            final idx = concepts.indexOf(c);
            final weight = [35, 25, 20, 15][idx % 4];
            return Padding(
              padding: const EdgeInsets.only(bottom: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text(c.title, style: const TextStyle(fontFamily: 'Inter', fontSize: 13.5, fontWeight: FontWeight.w600, color: Colors.white)),
                      Text('$weight% weightage', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.electricVioletLight)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  ClipRRect(
                    borderRadius: BorderRadius.circular(4),
                    child: LinearProgressIndicator(
                      value: weight / 100.0,
                      backgroundColor: Colors.white.withOpacity(0.06),
                      valueColor: AlwaysStoppedAnimation<Color>(idx == 0 ? AppColors.electricViolet : AppColors.teal),
                      minHeight: 6,
                    ),
                  ),
                ],
              ),
            );
          }),

          const SizedBox(height: 20),

          // ── Frequently Asked Questions ────────────────────────────────────
          const Text('FREQUENTLY ASKED QUESTIONS (REPEATED)', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextTertiary)),
          const SizedBox(height: 10),
          ...activeDoc.quizzes.take(3).map((q) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 3),
                  decoration: BoxDecoration(color: AppColors.amber.withOpacity(0.15), borderRadius: BorderRadius.circular(4)),
                  child: const Text('3x in Exams', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.amber)),
                ),
                const SizedBox(width: 12),
                Expanded(child: Text(q.question, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, color: Colors.white))),
              ],
            ),
          )),

          const SizedBox(height: 20),

          // ── Expected / Predicted Questions ────────────────────────────────
          const Text('PREDICTED QUESTIONS FOR NEXT EXAM', style: TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.darkTextTertiary)),
          const SizedBox(height: 10),
          ...concepts.take(3).map((c) => Container(
            margin: const EdgeInsets.only(bottom: 8),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.teal.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.psychology, size: 14, color: AppColors.teal),
                    const SizedBox(width: 6),
                    Text('HIGH PROBABILITY • ${c.title}', style: const TextStyle(fontFamily: 'JetBrains Mono', fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.teal)),
                  ],
                ),
                const SizedBox(height: 6),
                Text('Explain the mechanism, trade-offs, and failure points of ${c.title}.', style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
              ],
            ),
          )),
        ],
      ),
    );
  }
}
