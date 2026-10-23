import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_required_modal.dart';

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
            title: const Text(
              'StudyMate AI',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 16,
                fontWeight: FontWeight.w700,
                color: Colors.white,
              ),
            ),
            actions: [
              if (user == null) ...[
                Padding(
                  padding:
                      const EdgeInsets.symmetric(vertical: 10, horizontal: 8),
                  child: ElevatedButton(
                    onPressed: () => AuthRequiredModal.show(
                      context,
                      title: 'Sign in to StudyMate AI',
                      message:
                          'Sign in to access your course notes, AI tutor, and custom study materials.',
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.electricViolet,
                      foregroundColor: Colors.white,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(horizontal: 14),
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(8)),
                    ),
                    child: const Text(
                      'Sign In',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontWeight: FontWeight.w600,
                        fontSize: 12.5,
                      ),
                    ),
                  ),
                ),
              ],
              IconButton(
                onPressed: () => context.push(AppRoutes.library),
                tooltip: 'Open Subjects',
                icon: const Icon(Icons.menu_book_outlined,
                    size: 20, color: AppColors.electricVioletLight),
              ),
              if (user != null)
                IconButton(
                  onPressed: () => context.push(AppRoutes.profile),
                  tooltip: 'Profile',
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor: AppColors.darkSurfaceContainerHigh,
                    child: Text(
                      user.displayName?.isNotEmpty == true
                          ? user.displayName![0].toUpperCase()
                          : 'U',
                      style: const TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: AppColors.electricViolet,
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
                _GreetingAndStatusHeader()
                    .animate()
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.05, end: 0),

                const SizedBox(height: 24),

                // ── 2. Today's Learning Mission (Hero Card) ──────────────────
                const _EmptyLearningMissionCard()
                    .animate(delay: 100.ms)
                    .fadeIn()
                    .slideY(begin: 0.05, end: 0),

                const SizedBox(height: 24),

                // ── 3. Quick Resume & Recent Active Material ───────────────────────
                const _SuggestedActionsAndDeadlinesRow()
                    .animate(delay: 180.ms)
                    .fadeIn()
                    .slideY(begin: 0.05, end: 0),

                const SizedBox(height: 24),

                // ── 4. Today's Progress & Study Streak ──────────────────────
                const _CognitiveRadarVitalsRow(readinessScore: 0.0)
                    .animate(delay: 240.ms)
                    .fadeIn()
                    .slideY(begin: 0.05, end: 0),

                const SizedBox(height: 36),
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

    final firestoreUserAsync =
        user != null ? ref.watch(userProfileStreamProvider(user.id)) : null;
    final firestoreUser = firestoreUserAsync?.asData?.value;

    final isGuest = user == null;
    final course = user?.course;
    final displayName = firestoreUser?.name.isNotEmpty == true
        ? firestoreUser!.name
        : (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!
            : (user?.email != null && user!.email.isNotEmpty)
                ? user.email.split('@').first
                : 'Guest Student';

    final greetingTitle =
        isGuest ? 'Welcome to StudyMate AI' : 'Ready to continue, $displayName';
    final courseSubtitle = isGuest
        ? 'Browse preview workspace • Sign in anytime to unlock full AI coaching'
        : (course?.isNotEmpty == true ? course! : 'Academic Course Workspace');

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
                      'ACTIVE WORKSPACE  •  STUDY SESSION',
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

  const _StatusPill(
      {required this.icon, required this.label, required this.color});

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

class _EmptyLearningMissionCard extends StatelessWidget {
  const _EmptyLearningMissionCard();

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
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          const Text(
            'YOUR LEARNING WORKSPACE',
            style: TextStyle(
              fontFamily: 'JetBrains Mono',
              fontSize: 10,
              fontWeight: FontWeight.w700,
              color: AppColors.electricViolet,
              letterSpacing: 0.8,
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Build your knowledge one topic at a time',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w700,
              height: 1.35,
              letterSpacing: -0.3,
              color: AppColors.darkTextPrimary,
            ),
          ),
          const SizedBox(height: 8),
          const Text(
            'Organize subjects into topics and subtopics, add your own notes, and use your study tools to review.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.45,
              color: AppColors.darkTextSecondary,
            ),
          ),
          const SizedBox(height: 18),
          Wrap(
            alignment: WrapAlignment.spaceBetween,
            crossAxisAlignment: WrapCrossAlignment.center,
            spacing: 16,
            runSpacing: 14,
            children: [
              const Wrap(
                spacing: 20,
                runSpacing: 8,
                children: [
                  _StitchMetric(
                      label: 'ORGANIZE', value: 'Subjects and topics'),
                  _StitchMetric(
                      label: 'REVIEW', value: 'Flashcards and quizzes'),
                ],
              ),
              Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ElevatedButton.icon(
                    onPressed: () => context.push(AppRoutes.library),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.darkSurfaceContainerHigh,
                      foregroundColor: AppColors.darkTextPrimary,
                      elevation: 0,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(6),
                        side: const BorderSide(color: AppColors.darkBorder),
                      ),
                      padding: const EdgeInsets.symmetric(
                          horizontal: 14, vertical: 10),
                    ),
                    icon: const Icon(Icons.menu_book_outlined, size: 16),
                    label: const Text('Open Subjects'),
                  ),
                  const SizedBox(width: 10),
                  TextButton.icon(
                    onPressed: () => context.go(AppRoutes.aiChat),
                    icon: const Icon(Icons.auto_awesome, size: 14),
                    label: const Text('AI Chat'),
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

  const _MissionMetaTag(
      {required this.icon, required this.text, required this.color});

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
  const _SuggestedActionsAndDeadlinesRow();

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;
        final actions = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'SUGGESTED NEXT ACTIONS',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 10,
                fontWeight: FontWeight.w600,
                color: AppColors.darkTextTertiary,
                letterSpacing: 0.8,
              ),
            ),
            const SizedBox(height: 10),
            _DashboardActionCard(
              icon: Icons.topic_outlined,
              title: 'Organize a subject',
              subtitle: 'Add topics, subtopics, and manual notes',
              onTap: () => context.push(AppRoutes.library),
            ),
          ],
        );
        final planner = Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            InkWell(
              onTap: () => context.push(AppRoutes.studyPlanner),
              child: const Text(
                'STUDY PLANNER  →',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 10,
                  fontWeight: FontWeight.w600,
                  color: AppColors.electricViolet,
                  letterSpacing: 0.8,
                ),
              ),
            ),
            const SizedBox(height: 10),
            _DashboardActionCard(
              icon: Icons.calendar_today_outlined,
              title: 'Plan your study time',
              subtitle: 'Track study progress and upcoming deadlines',
              onTap: () => context.push(AppRoutes.studyPlanner),
            ),
          ],
        );
        if (isMobile) {
          return Column(
              children: [actions, const SizedBox(height: 16), planner]);
        }
        return Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Expanded(child: actions),
            const SizedBox(width: 20),
            Expanded(child: planner),
          ],
        );
      },
    );
  }
}

class _DashboardActionCard extends StatelessWidget {
  const _DashboardActionCard({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final IconData icon;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) => InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(8),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          decoration: BoxDecoration(
            color: AppColors.darkSurfaceVariant,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(color: AppColors.darkBorderSubtle),
          ),
          child: Row(children: [
            Icon(icon, size: 18, color: AppColors.electricVioletLight),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w600,
                          color: AppColors.darkTextPrimary)),
                  const SizedBox(height: 3),
                  Text(subtitle,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11.5,
                          color: AppColors.darkTextSecondary)),
                ],
              ),
            ),
            const Icon(Icons.chevron_right_rounded,
                size: 18, color: AppColors.darkTextTertiary),
          ]),
        ),
      );
}

class _CognitiveRadarVitalsRow extends ConsumerWidget {
  final double readinessScore;

  const _CognitiveRadarVitalsRow({required this.readinessScore});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final userId =
        user?.id ?? ref.watch(firestoreServiceProvider).currentUserId ?? '';
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

    final streakDays = progress?.currentStreak ?? 1;

    return LayoutBuilder(
      builder: (context, constraints) {
        final isMobile = constraints.maxWidth < 650;

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
            trend:
                computedStability > 0 ? 'Active Decay Model' : 'No review data',
            color: const Color(0xFF61C9FF),
            icon: Icons.shield_rounded,
            progress: computedStability / 100.0,
          ),
          _VitalCard(
            title: 'Study Streak',
            value: '${streakDays}d',
            trend: 'Daily Habit Active',
            color: Colors.deepOrangeAccent,
            icon: Icons.local_fire_department_rounded,
            progress: (streakDays / 7.0).clamp(0.14, 1.0),
          ),
          _VitalCard(
            title: 'Today Focus',
            value: '${focusMinutes}m',
            trend: 'Firestore tracked',
            color: AppColors.electricViolet,
            icon: Icons.timelapse_rounded,
            progress: (focusMinutes / 60.0).clamp(0.0, 1.0),
          ),
        ];

        if (isMobile) {
          return GridView.count(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            crossAxisCount: 2,
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.45,
            children: items,
          );
        }

        return Row(
          children: [
            Expanded(child: items[0]),
            const SizedBox(width: 12),
            Expanded(child: items[1]),
            const SizedBox(width: 12),
            Expanded(child: items[2]),
            const SizedBox(width: 12),
            Expanded(child: items[3]),
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
