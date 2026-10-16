import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/providers/active_document_provider.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDoc = ref.watch(activeDocumentProvider);
    final quizCount = activeDoc?.quizzes.length ?? 0;
    final cardCount = activeDoc?.flashcards.length ?? 0;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            title: const Text(
              'Progress',
              style: TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700),
            ),
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Stats Row ─────────────────────────────────────────────
                Row(
                  children: [
                    const _StatCard(label: 'Study Hours', value: '0.0', icon: '⏱️', color: AppColors.electricViolet),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Quizzes', value: '$quizCount', icon: '✅', color: AppColors.teal),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Flashcards', value: '$cardCount', icon: '🃏', color: AppColors.skyBlue),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // ── Study Time Chart ───────────────────────────────────────
                const _SectionTitle(title: 'Daily Study Time'),
                const SizedBox(height: 12),
                const _StudyTimeChart().animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // ── Subject Mastery ────────────────────────────────────────
                const _SectionTitle(title: 'Subject Mastery'),
                const SizedBox(height: 12),
                _SubjectMasteryList(activeDoc: activeDoc).animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 24),

                // ── Weak Topics ────────────────────────────────────────────
                const _SectionTitle(title: 'Needs Attention'),
                const SizedBox(height: 12),
                _WeakTopicsList(activeDoc: activeDoc).animate(delay: 300.ms).fadeIn(),

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
          color: AppColors.darkSurface,
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

// Study Time Chart — shows empty bars until real session tracking is implemented
class _StudyTimeChart extends StatelessWidget {
  const _StudyTimeChart();

  @override
  Widget build(BuildContext context) {
    const days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

    return Container(
      height: 180,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: AppColors.darkBorder),
      ),
      child: BarChart(
        BarChartData(
          alignment: BarChartAlignment.spaceAround,
          maxY: 4,
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
                    color: Colors.white.withOpacity(0.4),
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
          barGroups: List.generate(7, (i) => BarChartGroupData(
            x: i,
            barRods: [
              BarChartRodData(
                toY: 0,
                width: 22,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                color: AppColors.electricViolet.withOpacity(0.2),
              ),
            ],
          )),
        ),
      ),
    );
  }
}

// Subject Mastery — derived from real flashcard known/total ratios
class _SubjectMasteryList extends StatelessWidget {
  final dynamic activeDoc;
  const _SubjectMasteryList({this.activeDoc});

  @override
  Widget build(BuildContext context) {
    final flashcards = activeDoc?.flashcards ?? [];

    if (flashcards.isEmpty) {
      return _emptyCard(
        icon: Icons.bar_chart_rounded,
        message: 'No subject mastery data yet.\nUpload documents and review flashcards to track progress.',
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
              color: AppColors.darkSurface,
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
          ).animate(delay: Duration(milliseconds: 200 + idx * 50)).fadeIn().slideX(begin: 0.05, end: 0),
        );
      }).toList(),
    );
  }
}

// Weak Topics — derived from real quiz incorrect-attempt counts
class _WeakTopicsList extends StatelessWidget {
  final dynamic activeDoc;
  const _WeakTopicsList({this.activeDoc});

  @override
  Widget build(BuildContext context) {
    final quizzes = activeDoc?.quizzes ?? [];

    if (quizzes.isEmpty) {
      return _emptyCard(
        icon: Icons.warning_amber_rounded,
        message: 'No weak topics identified yet.\nComplete quizzes to find areas that need attention.',
      );
    }

    final List<Map<String, dynamic>> weak = [];
    for (final quiz in quizzes) {
      for (final q in (quiz.questions ?? [])) {
        if ((q.incorrectAttempts ?? 0) > 0) {
          weak.add({'question': q.text ?? '', 'topic': q.topic ?? 'General', 'attempts': q.incorrectAttempts ?? 1});
        }
      }
    }

    if (weak.isEmpty) {
      return _emptyCard(
        icon: Icons.check_circle_outline_rounded,
        message: 'Great work! No weak topics detected.\nKeep taking quizzes to track your performance.',
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
              const Icon(Icons.warning_amber_rounded, size: 18, color: AppColors.error),
              const SizedBox(width: 10),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      t['question'] as String,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white),
                    ),
                    Text(
                      t['topic'] as String,
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.4)),
                    ),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  Icons.circle,
                  size: 7,
                  color: i < attempts ? AppColors.error : Colors.white.withOpacity(0.1),
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
      icon: Icons.emoji_events_outlined,
      message: 'Achievements will appear here as you\nstudy, complete quizzes, and hit streaks.',
    );
  }
}

// Shared empty-state helper
Widget _emptyCard({required IconData icon, required String message}) {
  return Container(
    width: double.infinity,
    padding: const EdgeInsets.symmetric(vertical: 28, horizontal: 20),
    decoration: BoxDecoration(
      color: AppColors.darkSurface,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(color: AppColors.darkBorder),
    ),
    child: Column(
      children: [
        Icon(icon, size: 32, color: Colors.white.withOpacity(0.2)),
        const SizedBox(height: 10),
        Text(
          message,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 13,
            color: Colors.white.withOpacity(0.4),
            height: 1.5,
          ),
        ),
      ],
    ),
  );
}
