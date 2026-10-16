import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';

class SummaryScreen extends ConsumerWidget {
  final String topicId;
  const SummaryScreen({super.key, required this.topicId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeDoc = ref.watch(activeDocumentProvider);

    final title = activeDoc?.summary.title ?? 'Operating Systems: Process Management & Synchronization';
    final overview = activeDoc?.summary.overview ??
        'Process synchronization and CPU scheduling form the foundational backbone of modern multi-tasking operating systems. Key guarantees include deadlock freedom, starvation prevention, and mutual exclusion across shared critical regions.';
    final takeaways = activeDoc?.summary.keyTakeaways ?? [
      'Preemptive algorithms ensure fairness at the expense of context-switching overhead.',
      'SJF minimizes average waiting time but requires a priori knowledge of burst durations.',
      'Semaphores (wait/signal) provide atomic guarantees against race conditions.',
      'Deadlocks require four concurrent conditions: Mutual Exclusion, Hold & Wait, No Preemption, Circular Wait.',
    ];
    final theorems = activeDoc?.summary.coreTheorems ?? [
      'Coffman Conditions: A system is in deadlock if and only if all four conditions hold simultaneously.',
      'Banker\'s Algorithm: Avoids deadlocks by verifying if granting a resource request leaves the system in a safe state.',
    ];
    final traps = activeDoc?.summary.examTraps ?? [
      'Assuming FCFS is starvation-free: while true, convoy effect drastically inflates average wait times.',
      'Confusing deadlock with starvation: starvation is indefinite delay for one process, whereas deadlock halts all involved processes.',
      'Neglecting context-switch latency in Round Robin time quantum calculations.',
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          activeDoc != null ? 'Summary: ${activeDoc.fileName}' : 'Executive Summary',
          style: const TextStyle(fontFamily: 'Inter', fontWeight: FontWeight.w700, fontSize: 16),
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.share_outlined),
            onPressed: () {},
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Header Card
          Container(
            padding: const EdgeInsets.all(18),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.electricViolet.withOpacity(0.18),
                  AppColors.teal.withOpacity(0.10),
                ],
              ),
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: AppColors.electricViolet.withOpacity(0.3)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: AppColors.electricViolet.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Text(
                        activeDoc != null ? 'SOURCE: ${activeDoc.fileType}' : 'EXECUTIVE SYNTHESIS',
                        style: const TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                          color: AppColors.electricViolet,
                          letterSpacing: 0.5,
                        ),
                      ),
                    ),
                    const Spacer(),
                    const Icon(Icons.auto_awesome, color: AppColors.teal, size: 16),
                    const SizedBox(width: 4),
                    const Text(
                      'AI Extracted',
                      style: TextStyle(fontFamily: 'Inter', fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.teal),
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  title,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 18,
                    fontWeight: FontWeight.w800,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  overview,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.8),
                    height: 1.5,
                  ),
                ),
              ],
            ),
          ).animate().fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 24),

          // Key Takeaways
          _SectionHeader(title: 'Key Takeaways & Core Concepts', icon: Icons.check_circle_outline_rounded, color: AppColors.teal),
          const SizedBox(height: 12),
          ...takeaways.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SummaryBullet(content: item, color: AppColors.teal),
          )),

          const SizedBox(height: 24),

          // Core Theorems & Guarantees
          _SectionHeader(title: 'Theorems & Formal Guarantees', icon: Icons.military_tech_outlined, color: AppColors.electricViolet),
          const SizedBox(height: 12),
          ...theorems.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SummaryBullet(content: item, color: AppColors.electricViolet),
          )),

          const SizedBox(height: 24),

          // Exam Traps & Pitfalls
          _SectionHeader(title: 'Exam Traps & Pitfalls', icon: Icons.warning_amber_rounded, color: AppColors.amber),
          const SizedBox(height: 12),
          ...traps.map((item) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: _SummaryBullet(content: item, color: AppColors.amber),
          )),

          const SizedBox(height: 32),

          // Action Buttons
          Row(
            children: [
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.push('/topic/quiz/${activeDoc?.id ?? "topic_1"}'),
                  icon: const Icon(Icons.quiz_outlined, size: 18),
                  label: const Text('Practice Quiz'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.teal,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: ElevatedButton.icon(
                  onPressed: () => context.go(AppRoutes.aiChat),
                  icon: const Icon(Icons.chat_bubble_outline_rounded, size: 18),
                  label: const Text('Discuss with AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.electricViolet,
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    padding: const EdgeInsets.symmetric(vertical: 14),
                  ),
                ),
              ),
            ],
          ),

          const SizedBox(height: 20),
        ],
      ),
    );
  }
}

class _SectionHeader extends StatelessWidget {
  final String title;
  final IconData icon;
  final Color color;

  const _SectionHeader({required this.title, required this.icon, required this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 18),
        const SizedBox(width: 8),
        Text(
          title,
          style: const TextStyle(
            fontFamily: 'Inter',
            fontSize: 15,
            fontWeight: FontWeight.w700,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}

class _SummaryBullet extends StatelessWidget {
  final String content;
  final Color color;

  const _SummaryBullet({required this.content, required this.color});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurface,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.2)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            margin: const EdgeInsets.only(top: 4),
            width: 6,
            height: 6,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              content,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 13,
                color: Colors.white.withOpacity(0.85),
                height: 1.45,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
