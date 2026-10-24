import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_required_modal.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final isGuest = user == null;
    final userId =
        user?.id ?? ref.watch(firestoreServiceProvider).currentUserId ?? '';
    final progressAsync = userId.isNotEmpty
        ? ref.watch(userStudyProgressStreamProvider(userId))
        : null;
    final progress = progressAsync?.asData?.value;

    final studyHours = isGuest
        ? '0.0'
        : ((progress?.totalMinutes ?? 0) / 60.0).toStringAsFixed(1);
    final quizCount = isGuest ? 0 : (progress?.quizzesCompleted ?? 0);
    final cardCount = isGuest ? 0 : (progress?.flashcardsReviewed ?? 0);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text(
              'Progress & Analytics',
              style:
                  TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                if (isGuest) ...[
                  Container(
                    margin: const EdgeInsets.only(bottom: 20),
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.electricViolet.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                          color: AppColors.electricViolet.withOpacity(0.3)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.lock_outline_rounded,
                            color: AppColors.electricVioletLight, size: 22),
                        const SizedBox(width: 14),
                        const Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Guest Preview Mode',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 14,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white,
                                ),
                              ),
                              SizedBox(height: 2),
                              Text(
                                'Sign in to track real study minutes, quiz mastery, and retention stability.',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: Colors.white70,
                                ),
                              ),
                            ],
                          ),
                        ),
                        const SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () => AuthRequiredModal.show(
                            context,
                            title: 'Sign in to view your progress',
                            message:
                                'Sync your learning records, retain mastery analytics, and unlock custom study targets.',
                          ),
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.electricViolet,
                            foregroundColor: Colors.white,
                            padding: const EdgeInsets.symmetric(
                                horizontal: 14, vertical: 10),
                            shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(8)),
                          ),
                          child: const Text('Sign In',
                              style: TextStyle(
                                  fontWeight: FontWeight.w600, fontSize: 12)),
                        ),
                      ],
                    ),
                  ),
                ],

                // ── Stats Row ─────────────────────────────────────────────
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 500;
                    final cards = [
                      _StatCard(
                          label: 'Study Hours',
                          value: studyHours,
                          icon: '⏱️',
                          color: AppColors.electricViolet),
                      _StatCard(
                          label: 'Quizzes Done',
                          value: '$quizCount',
                          icon: '✅',
                          color: AppColors.teal),
                      _StatCard(
                          label: 'Cards Mastered',
                          value: '$cardCount',
                          icon: '🃏',
                          color: AppColors.skyBlue),
                    ];
                    if (isMobile) {
                      return Column(
                        children: cards
                            .map((c) => Padding(
                                padding: const EdgeInsets.only(bottom: 10),
                                child: c))
                            .toList(),
                      );
                    }
                    return Row(
                      children: [
                        cards[0],
                        const SizedBox(width: 12),
                        cards[1],
                        const SizedBox(width: 12),
                        cards[2],
                      ],
                    );
                  },
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // ── Study Time Chart ───────────────────────────────────────
                const _SectionTitle(title: 'Daily Study Time'),
                const SizedBox(height: 12),
                _StudyTimeChart(totalMinutes: progress?.totalMinutes ?? 0)
                    .animate(delay: 100.ms)
                    .fadeIn()
                    .slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // ── Subject Mastery ────────────────────────────────────────
                const _SectionTitle(title: 'Subject Mastery'),
                const SizedBox(height: 12),
                const _SubjectMasteryList().animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 24),

                // ── Weak Topics ────────────────────────────────────────────
                const _SectionTitle(title: 'Needs Attention'),
                const SizedBox(height: 12),
                const _WeakTopicsList().animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 24),

                // ── Achievements ───────────────────────────────────────────
                const _SectionTitle(title: 'Achievements'),
                const SizedBox(height: 12),
                const _AchievementsEmpty().animate(delay: 400.ms).fadeIn(),

                const SizedBox(height: 32),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String icon;
  final Color color;

  const _StatCard({
    required this.label,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerLow,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: AppColors.darkBorder),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(icon, style: const TextStyle(fontSize: 20)),
            const SizedBox(height: 8),
            Text(
              value,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 22,
                fontWeight: FontWeight.w700,
                color: color,
              ),
            ),
            Text(
              label,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 11,
                color: Colors.white.withOpacity(0.5),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _SectionTitle extends StatelessWidget {
  final String title;
  const _SectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Text(
      title,
      style: const TextStyle(
        fontFamily: 'Inter',
        fontSize: 17,
        fontWeight: FontWeight.w700,
        color: Colors.white,
      ),
    );
  }
}

class _StudyTimeChart extends StatelessWidget {
  final int totalMinutes;
  const _StudyTimeChart({this.totalMinutes = 0});

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final todayWeekday = DateTime.now().weekday - 1; // 0 = Mon, 6 = Sun
    final studyHours = totalMinutes / 60.0;

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerLow,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: (studyHours > 3.0 ? studyHours + 1 : 4.0),
          barTouchData: BarTouchData(enabled: false),
          titlesData: FlTitlesData(
            show: true,
            bottomTitles: AxisTitles(
              sideTitles: SideTitles(
                showTitles: true,
                getTitlesWidget: (value, _) => Text(
                  days[value.toInt()],
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 10,
                    fontWeight: value.toInt() == todayWeekday
                        ? FontWeight.w700
                        : FontWeight.w400,
                    color: value.toInt() == todayWeekday
                        ? AppColors.electricViolet
                        : Colors.white.withOpacity(0.4),
                  ),
                ),
              ),
            ),
            leftTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            topTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
            rightTitles: AxisTitles(sideTitles: SideTitles(showTitles: false)),
          ),
          gridData: FlGridData(
            show: true,
            horizontalInterval: 1,
            getDrawingHorizontalLine: (_) => FlLine(
              color: Colors.white.withOpacity(0.05),
              strokeWidth: 1,
            ),
            drawVerticalLine: false,
          ),
          borderData: FlBorderData(show: false),
          barGroups: List.generate(7, (i) {
            final isToday = i == todayWeekday;
            final barVal = isToday ? studyHours : 0.0;
            return BarChartGroupData(
              x: i,
              barRods: [
                BarChartRodData(
                  toY: barVal,
                  width: 22,
                  borderRadius:
                      const BorderRadius.vertical(top: Radius.circular(6)),
                  color: isToday
                      ? AppColors.electricViolet
                      : AppColors.electricViolet.withOpacity(0.15),
                ),
              ],
            );
          }),
        ),
      ),
    );
  }
}

// Subject Mastery — derived from real flashcard known/total ratios
class _SubjectMasteryList extends StatelessWidget {
  const _SubjectMasteryList();

  @override
  Widget build(BuildContext context) {
    const flashcards = <dynamic>[];

    if (flashcards.isEmpty) {
      return _emptyCard(
        context: context,
        icon: Icons.bar_chart_rounded,
        message:
            'No subject mastery data yet.\nAdd notes and review flashcards to track progress.',
      );
    }

    final Map<String, List<dynamic>> byTopic = {};
    for (final card in flashcards) {
      final topic = (card.topic as String?) ?? 'General';
      byTopic.putIfAbsent(topic, () => []).add(card);
    }

    final colors = AppColors.subjectColors;
    final entries = byTopic.entries.toList();

    return Column(
      children: entries.asMap().entries.map((e) {
        final idx = e.key;
        final topic = e.value.key;
        final cards = e.value.value;
        final known = cards.where((c) => c.isKnown == true).length;
        final ratio = cards.isEmpty ? 0.0 : known / cards.length;
        final color = colors[idx % colors.length];

        return Padding(
          padding: const EdgeInsets.only(bottom: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.surfaceContainerLow,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        topic,
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 6),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(4),
                        child: LinearProgressIndicator(
                          value: ratio,
                          minHeight: 5,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '${(ratio * 100).round()}%',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: color,
                  ),
                ),
              ],
            ),
          )
              .animate(delay: Duration(milliseconds: 200 + idx * 50))
              .fadeIn()
              .slideX(begin: 0.05, end: 0),
        );
      }).toList(),
    );
  }
}

// Weak Topics — derived from real quiz incorrect-attempt counts
class _WeakTopicsList extends StatelessWidget {
  const _WeakTopicsList();

  @override
  Widget build(BuildContext context) {
    const quizzes = <dynamic>[];

    if (quizzes.isEmpty) {
      return _emptyCard(
        context: context,
        icon: Icons.warning_amber_rounded,
        message:
            'No weak topics identified yet.\nComplete quizzes to find areas that need attention.',
      );
    }

    final List<Map<String, dynamic>> weak = [];
    for (final quiz in quizzes) {
      for (final q in (quiz.questions ?? [])) {
        if ((q.incorrectAttempts ?? 0) > 0) {
          weak.add({
            'question': q.text ?? '',
            'topic': q.topic ?? 'General',
            'attempts': q.incorrectAttempts ?? 1
          });
        }
      }
    }

    if (weak.isEmpty) {
      return _emptyCard(
        context: context,
        icon: Icons.check_circle_outline_rounded,
        message:
            'Great work! No weak topics detected.\nKeep taking quizzes to track your performance.',
      );
    }

    weak.sort((a, b) => (b['attempts'] as int).compareTo(a['attempts'] as int));
    final display = weak.take(5).toList();

    return Column(
      children: display.map((t) {
        final attempts = (t['attempts'] as int).clamp(0, 5);
        return Container(
          margin: const EdgeInsets.only(bottom: 8),
          padding: const EdgeInsets.all(14),
          decoration: BoxDecoration(
            color: AppColors.error.withOpacity(0.05),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: AppColors.error.withOpacity(0.15)),
          ),
          child: Row(
            children: [
              const Icon(Icons.warning_amber_rounded,
                  size: 18, color: AppColors.error),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['question'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                          color: Colors.white),
                    ),
                    Text(
                      t['topic'] as String,
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 11,
                          color: Colors.white.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(
                    5,
                    (i) => Icon(
                          Icons.circle,
                          size: 7,
                          color: i < attempts
                              ? AppColors.error
                              : Colors.white.withOpacity(0.1),
                        )),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

// Achievements — empty state until real badge tracking is implemented
class _AchievementsEmpty extends StatelessWidget {
  const _AchievementsEmpty();

  @override
  Widget build(BuildContext context) {
    return _emptyCard(
      context: context,
      icon: Icons.emoji_events_outlined,
      message:
          'Achievements will appear here as you\nstudy, complete quizzes, and hit streaks.',
    );
  }
}

// Shared empty-state helper
Widget _emptyCard({
  required BuildContext context,
  required IconData icon,
  required String message,
}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
    decoration: BoxDecoration(
      color: Theme.of(context).colorScheme.surfaceContainerLow,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: Theme.of(context).colorScheme.outline),
    ),
    child: Column(
      children: [
        Icon(icon,
            size: 32, color: Theme.of(context).colorScheme.onSurfaceVariant),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
