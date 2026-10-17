import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class PlannerScreen extends ConsumerWidget {
  const PlannerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? ref.watch(firestoreServiceProvider).currentUserId ?? '';
    final firestoreDocsAsync = userId.isNotEmpty
        ? ref.watch(userDocumentsStreamProvider(userId))
        : null;
    final docs = firestoreDocsAsync?.asData?.value ?? [];

    final now = DateTime.now();
    final days = List.generate(7, (i) => now.add(Duration(days: i)));

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_rounded, color: Colors.white),
          onPressed: () => context.pop(),
        ),
        title: const Text(
          'Study Planner & Spaced Recall',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.add_rounded, color: AppColors.electricViolet),
            tooltip: 'Add Study Material',
            onPressed: () => context.push(AppRoutes.uploadCenter),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 800),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── 7-Day Micro Calendar ──────────────────────────────────────
                Text(
                  'THIS WEEK SCHEDULE',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                SizedBox(
                  height: 72,
                  child: ListView.separated(
                    scrollDirection: Axis.horizontal,
                    itemCount: days.length,
                    separatorBuilder: (_, __) => const SizedBox(width: 8),
                    itemBuilder: (context, i) {
                      final day = days[i];
                      final isToday = i == 0;
                      const dayNames = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
                      final dayLabel = dayNames[day.weekday - 1];

                      return Container(
                        width: 60,
                        padding: const EdgeInsets.symmetric(vertical: 10),
                        decoration: BoxDecoration(
                          color: isToday ? AppColors.electricViolet.withOpacity(0.15) : AppColors.darkSurfaceVariant,
                          borderRadius: BorderRadius.circular(8),
                          border: Border.all(
                            color: isToday ? AppColors.electricViolet : AppColors.darkBorderSubtle,
                            width: isToday ? 1.5 : 1,
                          ),
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              dayLabel,
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                fontWeight: isToday ? FontWeight.w700 : FontWeight.w500,
                                color: isToday ? AppColors.electricViolet : AppColors.darkTextTertiary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              '${day.day}',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                                color: isToday ? Colors.white : AppColors.darkTextSecondary,
                              ),
                            ),
                          ],
                        ),
                      );
                    },
                  ),
                ).animate().fadeIn(duration: 300.ms),

                const SizedBox(height: 24),

                // ── Spaced Review Queue ──────────────────────────────────────
                Text(
                  'ADAPTIVE SPACED RECALL TARGETS',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),

                if (docs.isNotEmpty) ...[
                  ...docs.map((doc) => Padding(
                        padding: const EdgeInsets.only(bottom: 10),
                        child: _PlannerTargetCard(
                          title: doc.title.isNotEmpty ? doc.title : doc.fileName,
                          subtitle: '${doc.conceptCount} concepts • ${doc.quizCount} quizzes',
                          badge: 'Due Today',
                          badgeColor: AppColors.emerald,
                          onAction: () {
                            context.push(AppRoutes.quiz.replaceFirst(':topicId', doc.id));
                          },
                        ),
                      )),
                ] else if (activeDoc != null) ...[
                  _PlannerTargetCard(
                    title: activeDoc.fileName,
                    subtitle: '${activeDoc.concepts.length} concepts indexed • ${activeDoc.quizzes.length} quizzes ready',
                    badge: 'Active Target',
                    badgeColor: AppColors.emerald,
                    onAction: () {
                      context.push(AppRoutes.quiz.replaceFirst(':topicId', activeDoc.id));
                    },
                  ),
                ] else ...[
                  Container(
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkBorderSubtle),
                    ),
                    child: Center(
                      child: Column(
                        children: [
                          const Icon(Icons.event_note_rounded, size: 36, color: AppColors.electricViolet),
                          const SizedBox(height: 12),
                          const Text(
                            'No Study Targets Scheduled Yet',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 15,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'Upload study notes or slides to automatically populate your spaced repetition plan.',
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
                              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
                            ),
                            icon: const Icon(Icons.upload_file_rounded, size: 16),
                            label: const Text('Upload Material'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],

                const SizedBox(height: 24),

                // ── Daily Focus Target ───────────────────────────────────────
                Text(
                  'DAILY COGNITIVE FOCUS TARGET',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(18),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.darkBorderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppColors.electricViolet.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(Icons.timer_rounded, size: 22, color: AppColors.electricViolet),
                      ),
                      const SizedBox(width: 14),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Standard 60-Minute Focus Target',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                            ),
                            const SizedBox(height: 2),
                            Text(
                              'Complete 2x 25m Pomodoro sessions from your home dashboard to hit your streak goal.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 11.5,
                                color: Colors.white.withOpacity(0.6),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(width: 12),
                      OutlinedButton(
                        onPressed: () => context.go(AppRoutes.home),
                        style: OutlinedButton.styleFrom(
                          side: const BorderSide(color: AppColors.darkBorder),
                          foregroundColor: Colors.white,
                        ),
                        child: const Text('Go to Timer'),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 32),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _PlannerTargetCard extends StatelessWidget {
  final String title;
  final String subtitle;
  final String badge;
  final Color badgeColor;
  final VoidCallback onAction;

  const _PlannerTargetCard({
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.badgeColor,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorderSubtle),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            decoration: BoxDecoration(
              color: badgeColor.withOpacity(0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              badge,
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w700,
                color: badgeColor,
              ),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 2),
                Text(
                  subtitle,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 11,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton(
            onPressed: onAction,
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.darkSurfaceContainerHigh,
              foregroundColor: Colors.white,
              elevation: 0,
              side: const BorderSide(color: AppColors.darkBorder),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text('Practice', style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                SizedBox(width: 4),
                Icon(Icons.arrow_forward_rounded, size: 13),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
