import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/ai/engines/ai_engine_providers.dart';
import '../../../../core/ai/engines/ai_learning_engine.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

/// Living Mission Control Dashboard
///
/// The central operating system interface of StudyMate AI.
/// Continuously guides the student with:
/// - Real-time Daily Learning Mission
/// - Cognitive Radar vitals (Exam Readiness, Stability, Focus Minutes)
/// - High-Yield Gap Radar (Weakest & Strongest Concepts)
/// - Proactive AI Coach Intervention Feed
/// - Quick Cognitive Drills
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? 'guest_user';
    final missionAsync = ref.watch(dailyLearningMissionProvider(userId));
    final examReadinessAsync = ref.watch(examReadinessScoreProvider(userId));
    final activeDoc = ref.watch(activeDocumentProvider);

    return Scaffold(
      backgroundColor: AppColors.darkBackground,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: AppColors.darkBackground,
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Text(
                  'S',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    fontWeight: FontWeight.w700,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  'PORTAL',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 11,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                Text(
                  '/',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
                const SizedBox(width: 8),
                const Text(
                  'Home Workspace',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextPrimary,
                  ),
                ),
              ],
            ),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(vertical: 12),
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(6),
                  border: Border.all(color: AppColors.darkBorderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      width: 6,
                      height: 6,
                      decoration: const BoxDecoration(
                        color: AppColors.emerald,
                        shape: BoxShape.circle,
                      ),
                    ),
                    const SizedBox(width: 6),
                    const Text(
                      '28:02',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                        color: AppColors.emerald,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => context.push(AppRoutes.uploadCenter),
                tooltip: 'Search folio or add material (⌘K)',
                icon: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurface,
                    borderRadius: BorderRadius.circular(6),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search_rounded, size: 14, color: AppColors.darkTextSecondary),
                      const SizedBox(width: 6),
                      Text(
                        'Search folio',
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: AppColors.darkTextTertiary,
                        ),
                      ),
                      const SizedBox(width: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 4, vertical: 1),
                        decoration: BoxDecoration(
                          color: AppColors.darkSurfaceContainer,
                          borderRadius: BorderRadius.circular(3),
                        ),
                        child: Text(
                          '⌘K',
                          style: TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 9,
                            color: AppColors.darkTextTertiary,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              const SizedBox(width: 8),
              IconButton(
                onPressed: () => context.push(AppRoutes.profile),
                tooltip: 'Profile',
                icon: CircleAvatar(
                  radius: 14,
                  backgroundColor: AppColors.darkSurfaceContainerHigh,
                  child: const Text(
                    'SM',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.darkTextPrimary,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // ── 1. Greeting & Academic Status ────────────────────────────
                _GreetingAndStatusHeader().animate().fadeIn(duration: 400.ms).slideY(begin: 0.05, end: 0),

                const SizedBox(height: 24),

                // ── 2. Today's Learning Mission (Hero Card) ──────────────────
                missionAsync.when(
                  data: (mission) => mission != null
                      ? _TodayLearningMissionCard(mission: mission)
                          .animate(delay: 100.ms).fadeIn().slideY(begin: 0.05, end: 0)
                      : const _EmptyLearningMissionCard()
                          .animate(delay: 100.ms).fadeIn().slideY(begin: 0.05, end: 0),
                  loading: () => Container(
                    height: 110,
                    decoration: BoxDecoration(
                      color: AppColors.darkSurfaceVariant,
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.darkBorderSubtle),
                    ),
                  ),
                  error: (_, __) => const _EmptyLearningMissionCard(),
                ),

                const SizedBox(height: 24),

                // ── 3. Next Actions & Deadlines / Vitals ──────────────────────
                _SuggestedActionsAndDeadlinesRow(activeDoc: activeDoc)
                    .animate(delay: 180.ms).fadeIn().slideY(begin: 0.05, end: 0),

                const SizedBox(height: 24),

                // ── 4. Cognitive Radar & Vitals ──────────────────────────────
                examReadinessAsync.when(
                  data: (readiness) => _CognitiveRadarVitalsRow(readinessScore: readiness)
                      .animate(delay: 240.ms).fadeIn().slideY(begin: 0.05, end: 0),
                  loading: () => const _CognitiveRadarVitalsRow(readinessScore: 0.0),
                  error: (_, __) => const _CognitiveRadarVitalsRow(readinessScore: 0.0),
                ),

                const SizedBox(height: 24),

                // ── 5. High-Yield Gap Radar ──────────────────────────────────
                _HighYieldGapRadarCard().animate(delay: 300.ms).fadeIn().slideY(begin: 0.05, end: 0),

                const SizedBox(height: 24),

                // ── 6. Quick Cognitive Learning Tools ────────────────────────
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'COGNITIVE LEARNING TOOLS',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextTertiary,
                        letterSpacing: 0.8,
                      ),
                    ),
                  ],
                ).animate(delay: 360.ms).fadeIn(),
                const SizedBox(height: 10),
                _QuickCognitiveActionsGrid().animate(delay: 380.ms).fadeIn(),

                const SizedBox(height: 40),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 1. Greeting & Academic Status Header ─────────────────────────────────────

class _GreetingAndStatusHeader extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activeDoc = ref.watch(activeDocumentProvider);

    final firestoreUserAsync = user != null
        ? ref.watch(userProfileStreamProvider(user.id))
        : null;
    final firestoreUser = firestoreUserAsync?.asData?.value;

    final displayName = firestoreUser?.name.isNotEmpty == true
        ? firestoreUser!.name
        : (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!
            : (user?.email != null && user!.email.isNotEmpty)
                ? user.email.split('@').first
                : 'Student';

    final greetingTitle = 'Ready to continue, $displayName';
    final courseSubtitle = user?.course != null && user!.course!.isNotEmpty
        ? user.course!
        : (activeDoc != null ? 'Active Folio: ${activeDoc.fileName}' : 'Academic Course Workspace');

    return Padding(
      padding: const EdgeInsets.only(top: 12, bottom: 6),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'RESUME WORKSPACE  •  TERM 1  •  AUTUMN 2026',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 10,
                        fontWeight: FontWeight.w600,
                        color: AppColors.darkTextTertiary,
                        letterSpacing: 1.0,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      greetingTitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 26,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.6,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 5),
                    Text(
                      courseSubtitle,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 13,
                        fontWeight: FontWeight.w400,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                  ],
                ),
              ),
              Row(
                children: [
                  InkWell(
                    onTap: () {
                      if (activeDoc != null) {
                        context.push(AppRoutes.flashcards.replaceFirst(':topicId', activeDoc.id));
                      } else {
                        context.push(AppRoutes.uploadCenter);
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.darkBorderSubtle),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          const Icon(Icons.psychology_outlined, size: 14, color: AppColors.darkTextSecondary),
                          const SizedBox(width: 7),
                          Text(
                            activeDoc != null
                                ? 'Spaced Recall (${activeDoc.concepts.length} due)'
                                : 'Spaced Recall (0 due)',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  InkWell(
                    onTap: () async {
                      final uid = user?.id ?? ref.read(firestoreServiceProvider).currentUserId;
                      if (uid != null && uid.isNotEmpty) {
                        await ref.read(firestoreServiceProvider).recordStudySessionTime(uid, 25);
                      }
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Focus Block recorded! +25 study minutes added to Firestore.'),
                            duration: Duration(seconds: 3),
                          ),
                        );
                      }
                    },
                    borderRadius: BorderRadius.circular(6),
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 7),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceVariant,
                        borderRadius: BorderRadius.circular(6),
                        border: Border.all(color: AppColors.darkBorderSubtle),
                      ),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.play_arrow_rounded, size: 14, color: AppColors.darkTextSecondary),
                          SizedBox(width: 5),
                          Text(
                            '25m Focus Block',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StatusPill extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _StatusPill({required this.icon, required this.label, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: color.withOpacity(0.25)),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 5),
          Text(
            label,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

// ── 2. Today's Learning Mission Hero Card ────────────────────────────────────

class _TodayLearningMissionCard extends StatelessWidget {
  final DailyLearningMission mission;

  const _TodayLearningMissionCard({required this.mission});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    'IN PROGRESS',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.emerald,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 10),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'CORPUS 04 / ${mission.subjectName.toUpperCase()}',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextTertiary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 10),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'LEMMA #1042',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      color: AppColors.darkTextTertiary,
                    ),
                  ),
                ],
              ),
              const Icon(Icons.chevron_left_rounded, size: 18, color: AppColors.darkTextTertiary),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      mission.title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        letterSpacing: -0.3,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      mission.description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _StitchMetric(label: 'RETENTION', value: '${mission.expectedMasteryGainPercent + 75}% Optimal'),
                        const SizedBox(width: 24),
                        _StitchMetric(label: 'STAGE', value: 'L-4 (${mission.estimatedMinutes} mins)'),
                        const SizedBox(width: 24),
                        const _StitchMetric(label: 'SOURCE', value: 'Vlasov (1959) §4.2'),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      final targetId = mission.targetConcepts.isNotEmpty
                          ? mission.targetConcepts.first.topicId
                          : 'general';
                      context.push(AppRoutes.quiz.replaceFirst(':topicId', targetId));
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkSurfaceContainerHigh,
                      foregroundColor: AppColors.darkTextPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: AppColors.darkBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          mission.callToAction.isNotEmpty ? mission.callToAction : 'Resume Derivation',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => context.push(AppRoutes.library),
                    icon: const Icon(Icons.menu_book_outlined, size: 14, color: AppColors.darkTextSecondary),
                    label: const Text(
                      'Open Folio PDF',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _EmptyLearningMissionCard extends ConsumerWidget {
  const _EmptyLearningMissionCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDoc = ref.watch(activeDocumentProvider);

    final title = activeDoc != null
        ? 'Continue mastering ${activeDoc.fileName.replaceAll(RegExp(r'\.[a-zA-Z0-9]+$'), '')}'
        : 'Welcome to StudyMate AI — Ready for your next study session';

    final description = activeDoc != null
        ? '${activeDoc.concepts.length} concepts extracted. Complete an active recall drill to reinforce your memory retention.'
        : 'Upload lecture slides, syllabus, or notes (PDF, DOCX, TXT) to generate personalized adaptive quizzes, flashcards, and concept maps.';

    final tagText = activeDoc != null ? 'ACTIVE FOLIO / ${activeDoc.fileType}' : 'ACADEMIC OS / STANDBY';
    final lemmaText = activeDoc != null ? '${activeDoc.concepts.length} CONCEPTS' : 'NO MATERIAL';

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 22, vertical: 20),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppColors.darkBorderSubtle, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Text(
                    activeDoc != null ? 'IN PROGRESS' : 'GET STARTED',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: activeDoc != null ? AppColors.emerald : AppColors.electricViolet,
                      letterSpacing: 0.8,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 10),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    tagText,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: AppColors.darkTextTertiary,
                      letterSpacing: 0.6,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '•',
                    style: TextStyle(color: AppColors.darkTextTertiary, fontSize: 10),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    lemmaText,
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      color: AppColors.darkTextTertiary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        height: 1.35,
                        letterSpacing: -0.3,
                        color: AppColors.darkTextPrimary,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      description,
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12.5,
                        height: 1.45,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    const SizedBox(height: 18),
                    Row(
                      children: [
                        _StitchMetric(
                          label: 'DOCUMENTS',
                          value: activeDoc != null ? '1 Active' : '0 Indexed',
                        ),
                        const SizedBox(width: 24),
                        _StitchMetric(
                          label: 'CONCEPTS',
                          value: '${activeDoc?.concepts.length ?? 0} Extracted',
                        ),
                        const SizedBox(width: 24),
                        _StitchMetric(
                          label: 'STATUS',
                          value: activeDoc != null ? 'Ready for drill' : 'Awaiting upload',
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 24),
              Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () {
                      if (activeDoc != null) {
                        context.push(AppRoutes.quiz.replaceFirst(':topicId', activeDoc.id));
                      } else {
                        context.push(AppRoutes.uploadCenter);
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkSurfaceContainerHigh,
                      foregroundColor: AppColors.darkTextPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: AppColors.darkBorder),
                      ),
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          activeDoc != null ? 'Start Quiz Drill' : 'Upload Notes',
                          style: const TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                        const SizedBox(width: 6),
                        const Icon(Icons.arrow_forward_rounded, size: 14),
                      ],
                    ),
                  ),
                  const SizedBox(height: 10),
                  TextButton.icon(
                    onPressed: () => context.push(activeDoc != null ? AppRoutes.library : AppRoutes.uploadCenter),
                    icon: Icon(
                      activeDoc != null ? Icons.menu_book_outlined : Icons.upload_file_rounded,
                      size: 14,
                      color: AppColors.darkTextSecondary,
                    ),
                    label: Text(
                      activeDoc != null ? 'View in Library' : 'Upload Folio',
                      style: const TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 12,
                        color: AppColors.darkTextSecondary,
                      ),
                    ),
                    style: TextButton.styleFrom(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _StitchMetric extends StatelessWidget {
  final String label;
  final String value;

  const _StitchMetric({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 9,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextTertiary,
            letterSpacing: 0.8,
          ),
        ),
        const SizedBox(height: 3),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: AppColors.darkTextPrimary,
          ),
        ),
      ],
    );
  }
}

class _MissionMetaTag extends StatelessWidget {
  final IconData icon;
  final String text;
  final Color color;

  const _MissionMetaTag({required this.icon, required this.text, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.12),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 12, color: color),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class _SuggestedActionsAndDeadlinesRow extends StatelessWidget {
  final UploadedDocument? activeDoc;

  const _SuggestedActionsAndDeadlinesRow({this.activeDoc});

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

        final leftAction = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'SUGGESTED NEXT ACTIONS',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                Text(
                  activeDoc != null ? 'Prioritized by active material' : 'Awaiting material',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            InkWell(
              onTap: () {
                if (activeDoc != null) {
                  context.push(AppRoutes.flashcards.replaceFirst(':topicId', activeDoc!.id));
                } else {
                  context.push(AppRoutes.uploadCenter);
                }
              },
              borderRadius: BorderRadius.circular(8),
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                decoration: BoxDecoration(
                  color: AppColors.darkSurfaceVariant,
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: AppColors.darkBorderSubtle),
                ),
                child: Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(7),
                      decoration: BoxDecoration(
                        color: AppColors.darkSurfaceContainer,
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: const Icon(Icons.psychology_outlined, size: 16, color: AppColors.darkTextPrimary),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            activeDoc != null
                                ? 'Spaced Repetition: ${activeDoc!.concepts.length} Concept Cards'
                                : 'Spaced Repetition: Start First Active Drill',
                            style: const TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 13,
                              fontWeight: FontWeight.w600,
                              color: AppColors.darkTextPrimary,
                            ),
                          ),
                          const SizedBox(height: 3),
                          Text(
                            activeDoc != null
                                ? 'Active recall window open • ${activeDoc!.fileName}'
                                : 'Upload material to generate flashcard review queue',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 11.5,
                              color: AppColors.darkTextSecondary,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.chevron_right_rounded, size: 18, color: AppColors.darkTextTertiary),
                  ],
                ),
              ),
            ),
          ],
        );

        final rightDeadlines = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  'UPCOMING DEADLINES',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                InkWell(
                  onTap: () => context.push(AppRoutes.studyPlanner),
                  child: Text(
                    'Study Planner →',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 10,
                      color: AppColors.electricViolet,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
              decoration: BoxDecoration(
                color: AppColors.darkSurfaceVariant,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: AppColors.darkBorderSubtle),
              ),
              child: activeDoc != null
                  ? Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'ACTIVE STUDY TARGET',
                                    style: TextStyle(
                                      fontFamily: 'JetBrains Mono',
                                      fontSize: 10,
                                      color: AppColors.darkTextTertiary,
                                    ),
                                  ),
                                  const SizedBox(height: 3),
                                  Text(
                                    activeDoc!.fileName,
                                    style: const TextStyle(
                                      fontFamily: 'Inter',
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: AppColors.darkTextPrimary,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 8),
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  '${activeDoc!.concepts.length} concepts',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 10,
                                    fontWeight: FontWeight.w600,
                                    color: AppColors.emerald,
                                  ),
                                ),
                                Text(
                                  'Ready',
                                  style: TextStyle(
                                    fontFamily: 'JetBrains Mono',
                                    fontSize: 9.5,
                                    color: AppColors.darkTextTertiary,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(color: AppColors.darkBorderSubtle, height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Quiz status: ${activeDoc!.quizzes.length} generated',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: AppColors.darkTextTertiary,
                              ),
                            ),
                            Text(
                              '${activeDoc!.flashcards.length} cards',
                              style: TextStyle(
                                fontFamily: 'JetBrains Mono',
                                fontSize: 10,
                                color: AppColors.darkTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ],
                    )
                  : InkWell(
                      onTap: () => context.push(AppRoutes.uploadCenter),
                      child: Row(
                        children: [
                          const Icon(Icons.calendar_today_outlined, size: 16, color: AppColors.darkTextTertiary),
                          const SizedBox(width: 10),
                          Expanded(
                            child: Text(
                              'No study targets set. Upload material to begin.',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                          ),
                          const Icon(Icons.arrow_forward_rounded, size: 14, color: AppColors.darkTextTertiary),
                        ],
                      ),
                    ),
            ),
          ],
        );

        if (isMobile) {
          return Column(
            children: [
              leftAction,
              const SizedBox(height: 16),
              rightDeadlines,
            ],
          );
        }

        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(flex: 11, child: leftAction),
            const SizedBox(width: 20),
            Expanded(flex: 9, child: rightDeadlines),
          ],
        );
      },
    );
  }
}

// ── 4. Cognitive Radar & Vitals Row ──────────────────────────────────────────

class _CognitiveRadarVitalsRow extends ConsumerWidget {
  final double readinessScore;

  const _CognitiveRadarVitalsRow({required this.readinessScore});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userId = user?.id ?? ref.watch(firestoreServiceProvider).currentUserId ?? '';
    final progressAsync = userId.isNotEmpty
        ? ref.watch(userStudyProgressStreamProvider(userId))
        : null;
    final progress = progressAsync?.asData?.value;

    final focusMinutes = progress?.totalMinutes ?? 0;
    final quizzesDone = progress?.quizzesCompleted ?? 0;
    final conceptsKnown = progress?.conceptsLearned ?? 0;

    final computedReadiness = readinessScore > 0
        ? readinessScore.toInt()
        : (quizzesDone > 0 ? (quizzesDone * 20).clamp(15, 100) : 0);

    final computedStability = conceptsKnown > 0
        ? (conceptsKnown * 15).clamp(20, 95)
        : (computedReadiness > 0 ? (computedReadiness * 0.9).toInt() : 0);

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 600;

        final items = [
          _VitalCard(
            title: 'Exam Readiness',
            value: computedReadiness > 0 ? '$computedReadiness%' : '0%',
            trend: computedReadiness > 0 ? 'Live Metric' : 'No quiz data yet',
            color: const Color(0xFF43D197),
            icon: Icons.military_tech_rounded,
            progress: computedReadiness / 100.0,
          ),
          _VitalCard(
            title: 'Memory Stability',
            value: computedStability > 0 ? '$computedStability%' : '0%',
            trend: computedStability > 0 ? 'Active Decay Model' : 'No review data',
            color: const Color(0xFF61C9FF),
            icon: Icons.shield_rounded,
            progress: computedStability / 100.0,
          ),
          _VitalCard(
            title: 'Focus Total',
            value: '${focusMinutes}m',
            trend: 'Firestore tracked',
            color: AppColors.electricViolet,
            icon: Icons.timelapse_rounded,
            progress: (focusMinutes / 60.0).clamp(0.0, 1.0),
          ),
        ];

        if (isMobile) {
          return Column(
            children: items
                .map((w) => Padding(padding: const EdgeInsets.only(bottom: 10), child: w))
                .toList(),
          );
        }

        return Row(
          children: [
            Expanded(child: items[0]),
            const SizedBox(width: 12),
            Expanded(child: items[1]),
            const SizedBox(width: 12),
            Expanded(child: items[2]),
          ],
        );
      },
    );
  }
}

class _VitalCard extends StatelessWidget {
  final String title;
  final String value;
  final String trend;
  final Color color;
  final IconData icon;
  final double progress;

  const _VitalCard({
    required this.title,
    required this.value,
    required this.trend,
    required this.color,
    required this.icon,
    required this.progress,
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
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 15, color: color),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: AppColors.darkTextPrimary,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 3),
          Text(
            trend,
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              color: AppColors.darkTextTertiary,
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.06),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(2),
            minHeight: 3,
          ),
        ],
      ),
    );
  }
}

// ── 4. High-Yield Gap Radar Card ─────────────────────────────────────────────

class _HighYieldGapRadarCard extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final concepts = activeDoc?.concepts ?? [];

    return Container(
      padding: const EdgeInsets.all(20),
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
              Text(
                'HIGH-YIELD GAP RADAR',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  letterSpacing: 0.8,
                  color: AppColors.darkTextTertiary,
                ),
              ),
              if (concepts.isNotEmpty)
                Text(
                  'View all concepts',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    color: AppColors.darkTextTertiary,
                  ),
                ),
            ],
          ),
          const SizedBox(height: 14),
          if (concepts.isEmpty) ...[
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.03),
                borderRadius: BorderRadius.circular(14),
                border: Border.all(color: Colors.white.withOpacity(0.06)),
              ),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.electricViolet.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: const Icon(Icons.analytics_outlined, color: AppColors.electricViolet, size: 22),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text(
                          'Radar Inactive — No Data Yet',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w700,
                            color: Colors.white,
                          ),
                        ),
                        const SizedBox(height: 3),
                        Text(
                          'Upload lecture notes or take an active recall drill to detect vulnerable concepts.',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ] else ...[
            _GapRow(
              label: 'Weakest Concept',
              concept: concepts.first.title,
              masteryPct: '${(concepts.first.initialMastery * 100).toInt()}% Mastery',
              status: 'Critical Gap',
              color: const Color(0xFFFF6B6B),
              onAction: () {
                context.push(AppRoutes.quiz.replaceFirst(':topicId', activeDoc!.id));
              },
            ),
            if (concepts.length > 1) ...[
              const Divider(color: AppColors.darkBorder, height: 20),
              _GapRow(
                label: 'Imminent Forgetting',
                concept: concepts[1].title,
                masteryPct: '${(concepts[1].initialMastery * 100).toInt()}% Mastery',
                status: 'Review Priority',
                color: const Color(0xFFFF9F43),
                onAction: () {
                  context.push(AppRoutes.flashcards.replaceFirst(':topicId', activeDoc!.id));
                },
              ),
            ],
            if (concepts.length > 2) ...[
              const Divider(color: AppColors.darkBorder, height: 20),
              _GapRow(
                label: 'Strongest Mastery',
                concept: concepts.last.title,
                masteryPct: '${(concepts.last.initialMastery * 100).toInt()}% Mastery',
                status: 'Solidified',
                color: const Color(0xFF43D197),
                onAction: null,
              ),
            ],
          ],
        ],
      ),
    );
  }
}

class _GapRow extends StatelessWidget {
  final String label;
  final String concept;
  final String masteryPct;
  final String status;
  final Color color;
  final VoidCallback? onAction;

  const _GapRow({
    required this.label,
    required this.concept,
    required this.masteryPct,
    required this.status,
    required this.color,
    required this.onAction,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Container(
          width: 8,
          height: 8,
          decoration: BoxDecoration(color: color, shape: BoxShape.circle),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Text(
                    label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: Colors.white.withOpacity(0.5),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    '• $status',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: color,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 3),
              Text(
                concept,
                style: const TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ],
          ),
        ),
        Text(
          masteryPct,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            fontWeight: FontWeight.w700,
            color: color,
          ),
        ),
        if (onAction != null) ...[
          const SizedBox(width: 8),
          IconButton(
            onPressed: onAction,
            icon: const Icon(Icons.arrow_forward_ios_rounded, size: 13, color: Colors.white54),
          ),
        ],
      ],
    );
  }
}

// ── 5. Proactive AI Coach Feed ───────────────────────────────────────────────

class _ProactiveAICoachFeed extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final hasConcepts = activeDoc != null && activeDoc.concepts.isNotEmpty;

    final tipText = hasConcepts
        ? '💡 "Keep your momentum going on ${activeDoc.concepts.first.title}! Take a quick active recall drill to reinforce retention."'
        : '💡 "Welcome to StudyMate AI! Start by uploading your course materials, slides, or syllabus to automatically extract concepts and quizzes."';

    final tipSub = hasConcepts
        ? 'Study DNA: Your retention doubles when reviewing within 24h.'
        : 'Adaptive OS: Socratic tutoring tailored to your learning pace.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF191333), Color(0xFF1E1742)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.electricViolet.withOpacity(0.3)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(7),
                decoration: BoxDecoration(
                  color: AppColors.electricViolet.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Icon(Icons.support_agent_rounded, size: 18, color: AppColors.electricViolet),
              ),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'AI Learning Coach',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'Proactive Cognitive Push',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      color: AppColors.electricViolet,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 14),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: Colors.black.withOpacity(0.25),
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: Colors.white.withOpacity(0.06)),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        tipText,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12,
                          height: 1.4,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        tipSub,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.5),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 12),
                ElevatedButton(
                  onPressed: () {
                    if (hasConcepts) {
                      context.push(AppRoutes.quiz.replaceFirst(':topicId', activeDoc.id));
                    } else {
                      context.push(AppRoutes.uploadCenter);
                    }
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricViolet,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                  ),
                  child: Text(
                    hasConcepts ? 'Start Drill' : 'Upload',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// ── 6. Quick Cognitive Learning Tools Grid ───────────────────────────────────

class _QuickCognitiveActionsGrid extends ConsumerWidget {
  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDoc = ref.watch(activeDocumentProvider);

    void navigateOrPrompt(String routeTemplate) {
      if (activeDoc != null) {
        context.push(routeTemplate.replaceFirst(':topicId', activeDoc.id));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Please upload study material first to generate cognitive tools!'),
            backgroundColor: AppColors.electricViolet,
            duration: Duration(seconds: 2),
          ),
        );
        context.push(AppRoutes.uploadCenter);
      }
    }

    final actions = [
      _ActionItem(
        icon: Icons.quiz_rounded,
        title: 'Active Quiz',
        subtitle: 'Micro-Drills',
        color: const Color(0xFF7B61FF),
        onTap: () => navigateOrPrompt(AppRoutes.quiz),
      ),
      _ActionItem(
        icon: Icons.flip_to_front_rounded,
        title: '3D Flashcards',
        subtitle: 'SM-2 Repetition',
        color: const Color(0xFF4ECDC4),
        onTap: () => navigateOrPrompt(AppRoutes.flashcards),
      ),
      _ActionItem(
        icon: Icons.hub_rounded,
        title: 'Mind Map',
        subtitle: 'Semantic DAG',
        color: const Color(0xFFFF9F43),
        onTap: () => navigateOrPrompt(AppRoutes.mindMap),
      ),
      _ActionItem(
        icon: Icons.auto_stories_rounded,
        title: 'Smart Summary',
        subtitle: 'Key Formulas',
        color: const Color(0xFF5F85DB),
        onTap: () => navigateOrPrompt(AppRoutes.summary),
      ),
    ];

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: actions.length,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        childAspectRatio: 2.6,
        crossAxisSpacing: 8,
        mainAxisSpacing: 8,
      ),
      itemBuilder: (_, index) {
        final a = actions[index];
        return InkWell(
          onTap: a.onTap,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
            decoration: BoxDecoration(
              color: AppColors.darkSurfaceVariant,
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: AppColors.darkBorderSubtle),
            ),
            child: Row(
              children: [
                Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(0.10),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: Icon(a.icon, color: a.color, size: 16),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        a.title,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.2,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.subtitle,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: AppColors.darkTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class _ActionItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _ActionItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });
}

class _SectionHeader extends StatelessWidget {
  final String title;

  const _SectionHeader({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 16,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

class _ActiveMaterialBanner extends StatelessWidget {
  final UploadedDocument doc;
  const _ActiveMaterialBanner({required this.doc});

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoutes.uploadCenter),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              AppColors.teal.withOpacity(0.18),
              AppColors.electricViolet.withOpacity(0.10),
            ],
          ),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.teal.withOpacity(0.4)),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: AppColors.teal.withOpacity(0.2),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.description_rounded, color: AppColors.teal, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Active Study Material',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w700,
                      color: AppColors.teal,
                      letterSpacing: 0.5,
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    doc.fileName,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                    overflow: TextOverflow.ellipsis,
                  ),
                  Text(
                    '${doc.concepts.length} concepts • ${doc.quizzes.length} quizzes • ${doc.flashcards.length} cards',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded, color: AppColors.teal, size: 20),
          ],
        ),
      ),
    );
  }
}

class _UploadPromptBanner extends StatelessWidget {
  const _UploadPromptBanner();

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: () => context.push(AppRoutes.uploadCenter),
      borderRadius: BorderRadius.circular(16),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkSurface,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(
            color: AppColors.electricViolet.withOpacity(0.4),
            style: BorderStyle.solid,
          ),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 18),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Upload Your Study Material',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    'PDF, PPTX, DOCX, TXT → AI extracts concepts, quizzes & flashcards',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      color: Colors.white.withOpacity(0.55),
                    ),
                  ),
                ],
              ),
            ),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Text(
                'Upload',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
