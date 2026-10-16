import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/ai/engines/ai_engine_providers.dart';
import '../../../../core/ai/engines/ai_learning_engine.dart';
import '../../../../core/services/document_processing_service.dart';
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
            backgroundColor: AppColors.darkBackground.withOpacity(0.85),
            surfaceTintColor: Colors.transparent,
            title: Row(
              children: [
                Container(
                  width: 38,
                  height: 38,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(12),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricViolet.withOpacity(0.35),
                        blurRadius: 10,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(Icons.psychology_rounded, color: Colors.white, size: 22),
                ),
                const SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'StudyMate AI',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 18,
                        fontWeight: FontWeight.w800,
                        letterSpacing: -0.5,
                        color: Colors.white,
                      ),
                    ),
                    Row(
                      children: [
                        Container(
                          width: 6,
                          height: 6,
                          decoration: const BoxDecoration(
                            color: Color(0xFF43D197),
                            shape: BoxShape.circle,
                          ),
                        ),
                        const SizedBox(width: 5),
                        Text(
                          'AI Learning OS • Active',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            color: Colors.white.withOpacity(0.55),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
            actions: [
              IconButton(
                onPressed: () => context.push(AppRoutes.uploadCenter),
                tooltip: 'Upload Study Materials',
                icon: Container(
                  padding: const EdgeInsets.all(8),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.darkBorder),
                  ),
                  child: const Icon(Icons.add_rounded, size: 20, color: Colors.white),
                ),
              ),
              IconButton(
                onPressed: () => context.push(AppRoutes.profile),
                tooltip: 'Study Profile',
                icon: CircleAvatar(
                  radius: 17,
                  backgroundColor: AppColors.electricViolet.withOpacity(0.2),
                  child: const Icon(Icons.person_outline_rounded, size: 18, color: AppColors.electricViolet),
                ),
              ),
              const SizedBox(width: 8),
            ],
          ),

          SliverPadding(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (activeDoc != null) ...[
                  _ActiveMaterialBanner(doc: activeDoc).animate().fadeIn().slideY(begin: 0.08, end: 0),
                  const SizedBox(height: 16),
                ] else ...[
                  _UploadPromptBanner().animate().fadeIn().slideY(begin: 0.08, end: 0),
                  const SizedBox(height: 16),
                ],

                // ── 1. Greeting & Academic Status ────────────────────────────
                _GreetingAndStatusHeader().animate().fadeIn(duration: 400.ms).slideY(begin: 0.08, end: 0),

                const SizedBox(height: 20),

                // ── 2. Today's Learning Mission (Hero Card) ──────────────────
                missionAsync.when(
                  data: (mission) => mission != null
                      ? _TodayLearningMissionCard(mission: mission)
                          .animate(delay: 100.ms).fadeIn().slideY(begin: 0.08, end: 0)
                      : const _EmptyLearningMissionCard()
                          .animate(delay: 100.ms).fadeIn().slideY(begin: 0.08, end: 0),
                  loading: () => const _MissionLoadingCard(),
                  error: (_, __) => const _EmptyLearningMissionCard(),
                ),

                const SizedBox(height: 20),

                // ── 3. Cognitive Radar & Vitals ──────────────────────────────
                examReadinessAsync.when(
                  data: (readiness) => _CognitiveRadarVitalsRow(readinessScore: readiness)
                      .animate(delay: 180.ms).fadeIn().slideY(begin: 0.08, end: 0),
                  loading: () => const _CognitiveRadarVitalsRow(readinessScore: 0.0),
                  error: (_, __) => const _CognitiveRadarVitalsRow(readinessScore: 0.0),
                ),

                const SizedBox(height: 20),

                // ── 4. High-Yield Gap Radar ──────────────────────────────────
                _HighYieldGapRadarCard().animate(delay: 240.ms).fadeIn().slideY(begin: 0.08, end: 0),

                const SizedBox(height: 20),

                // ── 5. Proactive AI Coach Feed ───────────────────────────────
                _ProactiveAICoachFeed().animate(delay: 300.ms).fadeIn().slideY(begin: 0.08, end: 0),

                const SizedBox(height: 24),

                // ── 6. Quick Cognitive Drills ────────────────────────────────
                const _SectionHeader(title: 'Cognitive Learning Tools'),
                const SizedBox(height: 12),
                _QuickCognitiveActionsGrid().animate(delay: 360.ms).fadeIn(),

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
    final activeDoc = ref.watch(activeDocumentProvider);

    final hour = DateTime.now().hour;
    final timeGreeting = hour < 12
        ? '☀️ Good morning'
        : hour < 17
            ? '⛅ Good afternoon'
            : '🌙 Good evening';

    final displayName = (user?.displayName != null && user!.displayName!.isNotEmpty)
        ? user.displayName!
        : (user?.email != null && user!.email.isNotEmpty)
            ? user.email.split('@').first
            : 'Student';

    final headline = activeDoc != null
        ? 'Active Study: ${activeDoc.fileName}'
        : 'Welcome to your Learning OS';

    final subtitle = activeDoc != null
        ? '${activeDoc.concepts.length} concepts indexed • ${activeDoc.quizzes.length} quiz questions ready'
        : 'Upload study materials to begin personalized AI learning.';

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF16102C), Color(0xFF1F173D)],
        ),
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.electricViolet.withOpacity(0.2)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.3),
            blurRadius: 16,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                '$timeGreeting, $displayName',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white.withOpacity(0.65),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF9F43).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFFFF9F43).withOpacity(0.4)),
                ),
                child: const Row(
                  children: [
                    Text('🔥 ', style: TextStyle(fontSize: 12)),
                    Text(
                      'Day 1 Streak',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF9F43),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            headline,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            subtitle,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              fontWeight: FontWeight.w400,
              color: Colors.white.withOpacity(0.7),
            ),
          ),
          const SizedBox(height: 14),
          Row(
            children: [
              const _StatusPill(
                icon: Icons.bolt_rounded,
                label: '0 C-XP',
                color: AppColors.electricViolet,
              ),
              const SizedBox(width: 8),
              _StatusPill(
                icon: Icons.school_rounded,
                label: user?.course ?? (user?.yearOfStudy != null ? 'Year ${user!.yearOfStudy}' : 'Semester 1'),
                color: AppColors.teal,
              ),
              const SizedBox(width: 8),
              const _StatusPill(
                icon: Icons.timer_outlined,
                label: '0m studied',
                color: Color(0xFF5F85DB),
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
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF211545), Color(0xFF160E30)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.electricViolet.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricViolet.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [Color(0xFF7B61FF), Color(0xFF61C9FF)],
                  ),
                  borderRadius: BorderRadius.circular(20),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
                    SizedBox(width: 5),
                    Text(
                      "TODAY'S MISSION",
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 10,
                        fontWeight: FontWeight.w800,
                        letterSpacing: 0.8,
                        color: Colors.white,
                      ),
                    ),
                  ],
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                decoration: BoxDecoration(
                  color: const Color(0xFFFF6B6B).withOpacity(0.15),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: const Color(0xFFFF6B6B).withOpacity(0.35)),
                ),
                child: const Row(
                  children: [
                    Icon(Icons.trending_down_rounded, size: 12, color: Color(0xFFFF6B6B)),
                    SizedBox(width: 4),
                    Text(
                      'Decay Alert: -19%',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                        color: Color(0xFFFF6B6B),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Text(
            mission.title,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            mission.description,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.45,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 16),
          Row(
            children: [
              _MissionMetaTag(
                icon: Icons.timer_outlined,
                text: '${mission.estimatedMinutes} Mins',
                color: const Color(0xFF61C9FF),
              ),
              const SizedBox(width: 10),
              _MissionMetaTag(
                icon: Icons.trending_up_rounded,
                text: '+${mission.expectedMasteryGainPercent}% Mastery',
                color: const Color(0xFF43D197),
              ),
              const SizedBox(width: 10),
              _MissionMetaTag(
                icon: Icons.book_outlined,
                text: mission.subjectName,
                color: const Color(0xFFFF9F43),
              ),
            ],
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricViolet.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () {
                  final targetId = mission.targetConcepts.isNotEmpty
                      ? mission.targetConcepts.first.topicId
                      : 'general';
                  context.push(AppRoutes.quiz.replaceFirst(':topicId', targetId));
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.rocket_launch_rounded, color: Colors.white, size: 18),
                label: Text(
                  mission.callToAction,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _EmptyLearningMissionCard extends StatelessWidget {
  const _EmptyLearningMissionCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(22),
      decoration: BoxDecoration(
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF211545), Color(0xFF160E30)],
        ),
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.electricViolet.withOpacity(0.4), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: AppColors.electricViolet.withOpacity(0.2),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFF7B61FF), Color(0xFF61C9FF)],
              ),
              borderRadius: BorderRadius.circular(20),
            ),
            child: const Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.auto_awesome_rounded, size: 13, color: Colors.white),
                SizedBox(width: 5),
                Text(
                  "TODAY'S MISSION",
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: FontWeight.w800,
                    letterSpacing: 0.8,
                    color: Colors.white,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 14),
          const Text(
            'Ready to Begin Your First Mission',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 20,
              fontWeight: FontWeight.w800,
              letterSpacing: -0.4,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'Upload your course notes, slides, or syllabus to automatically extract micro-concepts and generate your daily active recall mission.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.45,
              color: Colors.white.withOpacity(0.75),
            ),
          ),
          const SizedBox(height: 18),
          SizedBox(
            width: double.infinity,
            height: 52,
            child: DecoratedBox(
              decoration: BoxDecoration(
                gradient: AppColors.primaryGradient,
                borderRadius: BorderRadius.circular(16),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.electricViolet.withOpacity(0.35),
                    blurRadius: 14,
                    offset: const Offset(0, 4),
                  ),
                ],
              ),
              child: ElevatedButton.icon(
                onPressed: () => context.push(AppRoutes.uploadCenter),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.transparent,
                  shadowColor: Colors.transparent,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                ),
                icon: const Icon(Icons.upload_file_rounded, color: Colors.white, size: 18),
                label: const Text(
                  'Upload Study Material',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
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

class _MissionLoadingCard extends StatelessWidget {
  const _MissionLoadingCard();

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 200,
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(24),
      ),
      child: const Center(
        child: CircularProgressIndicator(color: AppColors.electricViolet),
      ),
    );
  }
}

// ── 3. Cognitive Radar & Vitals Row ──────────────────────────────────────────

class _CognitiveRadarVitalsRow extends StatelessWidget {
  final double readinessScore;

  const _CognitiveRadarVitalsRow({required this.readinessScore});

  @override
  Widget build(BuildContext context) {
    final hasReadiness = readinessScore > 0;
    return Row(
      children: [
        Expanded(
          child: _VitalCard(
            title: 'Exam Readiness',
            value: hasReadiness ? '${readinessScore.toInt()}%' : '0%',
            trend: hasReadiness ? 'Calculated' : 'No data yet',
            color: const Color(0xFF43D197),
            icon: Icons.military_tech_rounded,
            progress: readinessScore / 100.0,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _VitalCard(
            title: 'Memory Stability',
            value: hasReadiness ? '${(readinessScore * 0.9).toInt()}%' : '0%',
            trend: hasReadiness ? 'Active Decay' : 'No data yet',
            color: const Color(0xFF61C9FF),
            icon: Icons.shield_rounded,
            progress: hasReadiness ? (readinessScore * 0.9) / 100.0 : 0.0,
          ),
        ),
        const SizedBox(width: 12),
        const Expanded(
          child: _VitalCard(
            title: 'Focus Today',
            value: '0m',
            trend: 'Target: 60m',
            color: AppColors.electricViolet,
            icon: Icons.timelapse_rounded,
            progress: 0.0,
          ),
        ),
      ],
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
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Icon(icon, size: 16, color: color),
              Text(
                value,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 18,
                  fontWeight: FontWeight.w800,
                  color: color,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w600,
              color: Colors.white.withOpacity(0.85),
            ),
          ),
          const SizedBox(height: 4),
          Text(
            trend,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10,
              color: Colors.white.withOpacity(0.45),
            ),
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: progress.clamp(0.0, 1.0),
            backgroundColor: Colors.white.withOpacity(0.08),
            valueColor: AlwaysStoppedAnimation<Color>(color),
            borderRadius: BorderRadius.circular(4),
            minHeight: 4,
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
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(22),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Row(
            children: [
              Icon(Icons.radar_rounded, color: AppColors.electricViolet, size: 18),
              SizedBox(width: 8),
              Text(
                'HIGH-YIELD GAP RADAR',
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 12,
                  fontWeight: FontWeight.w800,
                  letterSpacing: 0.6,
                  color: Colors.white,
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
        childAspectRatio: 2.1,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
      ),
      itemBuilder: (_, index) {
        final a = actions[index];
        return InkWell(
          onTap: a.onTap,
          borderRadius: BorderRadius.circular(16),
          child: Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: a.color.withOpacity(0.2)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: a.color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(a.icon, color: a.color, size: 20),
                ),
                const SizedBox(width: 12),
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
                          fontWeight: FontWeight.w700,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        a.subtitle,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          color: Colors.white.withOpacity(0.5),
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
