import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:fl_chart/fl_chart.dart';

import '../../../../core/theme/app_colors.dart';

class AnalyticsScreen extends ConsumerWidget {
  const AnalyticsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
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
            actions: [
              TextButton(
                onPressed: () {},
                child: const Text('This Week', style: TextStyle(color: AppColors.electricViolet, fontSize: 13)),
              ),
            ],
          ),
          SliverPadding(
            padding: const EdgeInsets.all(20),
            sliver: SliverList(
              delegate: SliverChildListDelegate([

                // ── Stats Row ─────────────────────────────────────────────
                Row(
                  children: [
                    _StatCard(label: 'Study Hours', value: '14.5', icon: '⏱️', color: AppColors.electricViolet),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Quizzes', value: '23', icon: '✅', color: AppColors.teal),
                    const SizedBox(width: 12),
                    _StatCard(label: 'Flashcards', value: '148', icon: '🃏', color: AppColors.skyBlue),
                  ],
                ).animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // ── Study Time Chart ───────────────────────────────────────
                _SectionTitle(title: 'Daily Study Time'),
                const SizedBox(height: 12),
                _StudyTimeChart().animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),

                const SizedBox(height: 24),

                // ── Subject Mastery ────────────────────────────────────────
                _SectionTitle(title: 'Subject Mastery'),
                const SizedBox(height: 12),
                _SubjectMasteryList().animate(delay: 200.ms).fadeIn(),

                const SizedBox(height: 24),

                // ── Weak Topics ────────────────────────────────────────────
                _SectionTitle(title: 'Needs Attention'),
                const SizedBox(height: 12),
                _WeakTopicsList().animate(delay: 300.ms).fadeIn(),

                const SizedBox(height: 24),

                // ── Achievement Previews ───────────────────────────────────
                _SectionTitle(title: 'Recent Achievements'),
                const SizedBox(height: 12),
                _AchievementsRow().animate(delay: 400.ms).fadeIn(),

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

class _StudyTimeChart extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final data = [1.5, 2.0, 0.5, 3.0, 2.5, 1.0, 3.5];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];

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
          barGroups: data.asMap().entries.map((e) {
            final isToday = e.key == 6;
            return BarChartGroupData(
              x: e.key,
              barRods: [
                BarChartRodData(
                  toY: e.value,
                  width: 22,
                  borderRadius: const BorderRadius.vertical(top: Radius.circular(6)),
                  gradient: isToday ? AppColors.primaryGradient : LinearGradient(
                    begin: Alignment.bottomCenter,
                    end: Alignment.topCenter,
                    colors: [
                      AppColors.electricViolet.withOpacity(0.3),
                      AppColors.electricViolet.withOpacity(0.6),
                    ],
                  ),
                ),
              ],
            );
          }).toList(),
        ),
      ),
    );
  }
}

class _SubjectMasteryList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final subjects = [
      ('Data Structures', 0.82, AppColors.subjectColors[1]),
      ('Operating Systems', 0.65, AppColors.subjectColors[0]),
      ('Database Management', 0.51, AppColors.subjectColors[4]),
      ('Computer Networks', 0.34, AppColors.subjectColors[3]),
    ];

    return Column(
      children: subjects.asMap().entries.map((e) {
        final s = e.value;
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
                        s.$1,
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
                          value: s.$2,
                          minHeight: 5,
                          backgroundColor: Colors.white.withOpacity(0.08),
                          valueColor: AlwaysStoppedAnimation<Color>(s.$3),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 14),
                Text(
                  '${(s.$2 * 100).round()}%',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: s.$3,
                  ),
                ),
              ],
            ),
          ).animate(delay: Duration(milliseconds: 200 + e.key * 50)).fadeIn().slideX(begin: 0.05, end: 0),
        );
      }).toList(),
    );
  }
}

class _WeakTopicsList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final topics = [
      ('Semaphores & Mutex', 'Operating Systems', 2),
      ('Deadlock Detection', 'Operating Systems', 3),
      ('Virtual Memory', 'Operating Systems', 5),
    ];

    return Column(
      children: topics.map((t) {
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
                    Text(t.$1, style: const TextStyle(fontFamily: 'Inter', fontSize: 13, fontWeight: FontWeight.w500, color: Colors.white)),
                    Text(t.$2, style: TextStyle(fontFamily: 'Inter', fontSize: 11, color: Colors.white.withOpacity(0.4))),
                  ],
                ),
              ),
              Row(
                children: List.generate(5, (i) => Icon(
                  Icons.circle,
                  size: 7,
                  color: i < t.$3 ? AppColors.error : Colors.white.withOpacity(0.1),
                )),
              ),
            ],
          ),
        );
      }).toList(),
    );
  }
}

class _AchievementsRow extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final achievements = [
      ('🔥', '14-Day Streak', AppColors.amber),
      ('⚡', 'Quiz Master', AppColors.electricViolet),
      ('📚', '50 Topics', AppColors.teal),
    ];

    return Row(
      children: achievements.map((a) {
        return Expanded(
          child: Container(
            margin: const EdgeInsets.symmetric(horizontal: 4),
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.darkSurface,
              borderRadius: BorderRadius.circular(14),
              border: Border.all(color: AppColors.darkBorder),
            ),
            child: Column(
              children: [
                Text(a.$1, style: const TextStyle(fontSize: 24)),
                const SizedBox(height: 6),
                Text(
                  a.$2,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: Colors.white),
                ),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }
}
