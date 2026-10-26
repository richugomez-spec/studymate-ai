import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_required_modal.dart';

class StudyToolsScreen extends ConsumerWidget {
  const StudyToolsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final activeSubjectId = ref.watch(activeKnowledgeSubjectIdProvider) ??
        ref.watch(activeKnowledgeWorkspaceIdProvider);
    final user = ref.watch(currentUserProvider);

    void navigateOrPrompt(String routeTemplate, {String? query}) {
      if (user == null) {
        AuthRequiredModal.show(
          context,
          title: 'Sign in to access Study Tools',
          message:
              'Create a free account or sign in to practice active quizzes, review flashcards, and analyze exam trends.',
        );
        return;
      }

      if (activeSubjectId == null || activeSubjectId.isEmpty) {
        context.go(AppRoutes.library);
      } else {
        context.push(
            '${routeTemplate.replaceFirst(':topicId', activeSubjectId)}${query ?? ''}');
      }
    }

    final tools = [
      _ToolItem(
        icon: Icons.auto_awesome_rounded,
        title: 'AI Socratic Coach',
        subtitle:
            'Conversational 1-on-1 reasoning tutor grounded in your course materials.',
        badge: 'Real Reasoning',
        color: AppColors.electricVioletLight,
        onTap: () => context.go(AppRoutes.aiChat),
      ),
      _ToolItem(
        icon: Icons.flip_to_front_rounded,
        title: '3D Flashcards',
        subtitle:
            'SuperMemo SM-2 interval scheduling with automated active recall scoring.',
        badge: 'Spaced Repetition',
        color: AppColors.teal,
        onTap: () => navigateOrPrompt(AppRoutes.flashcards),
      ),
      _ToolItem(
        icon: Icons.quiz_rounded,
        title: 'Active Quiz Generator',
        subtitle:
            'Multi-format quizzes (MCQ, True/False, Fill in Blank) with weak topic tracking.',
        badge: 'Custom Drills',
        color: AppColors.electricViolet,
        onTap: () => navigateOrPrompt(AppRoutes.quiz),
      ),
      _ToolItem(
        icon: Icons.auto_stories_rounded,
        title: 'Smart Summary',
        subtitle:
            'Executive summaries in Short (1-2m), Medium (5m), and Detailed revision modes.',
        badge: 'Persistent Revision',
        color: AppColors.skyBlue,
        onTap: () => navigateOrPrompt(AppRoutes.summary),
      ),
      _ToolItem(
        icon: Icons.functions_rounded,
        title: 'Formula Sheet',
        subtitle: 'Build a formula reference from your workspace knowledge.',
        badge: 'AI Generated',
        color: AppColors.skyBlue,
        onTap: () =>
            navigateOrPrompt(AppRoutes.summary, query: '?mode=formula'),
      ),
      _ToolItem(
        icon: Icons.hub_rounded,
        title: 'Interactive Mind Map',
        subtitle:
            'Zoomable semantic knowledge graph displaying concept relationships & formulas.',
        badge: 'Visual DAG',
        color: const Color(0xFFFF9F43),
        onTap: () => navigateOrPrompt(AppRoutes.mindMap),
      ),
      _ToolItem(
        icon: Icons.analytics_outlined,
        title: 'PYQ Question Paper Analyzer',
        subtitle:
            'Repeated questions detector, topic weightage distributions, and exam predictors.',
        badge: 'Exam Radar',
        color: const Color(0xFF10B981),
        onTap: () => navigateOrPrompt(AppRoutes.questionPaperAnalyzer),
      ),
      _ToolItem(
        icon: Icons.assignment_outlined,
        title: 'Mock Exam Generator',
        subtitle:
            'Complete mock papers with custom marks, time limits, and answer keys.',
        badge: 'Exam Simulation',
        color: const Color(0xFFEC4899),
        onTap: () => navigateOrPrompt(AppRoutes.examGenerator),
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        title: const Text(
          'Study Tools',
          style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              fontSize: 18,
              color: Colors.white),
        ),
        actions: [
          const SizedBox(width: 8),
        ],
      ),
      body: CustomScrollView(
        slivers: [
          SliverPadding(
            padding: const EdgeInsets.fromLTRB(20, 10, 20, 32),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // Header Banner
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color:
                        Theme.of(context).colorScheme.surfaceContainerHighest,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: AppColors.darkBorderSubtle),
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.electricViolet.withOpacity(0.12),
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: const Icon(Icons.psychology_rounded,
                            color: AppColors.electricVioletLight, size: 28),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              ref.watch(activeKnowledgeSubjectNameProvider) ??
                                  'Active Learning Suite',
                              style: const TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 15,
                                  fontWeight: FontWeight.w700,
                                  color: Colors.white),
                            ),
                            const SizedBox(height: 3),
                            Text(
                              'Select any tool to practice, synthesize, or evaluate your course knowledge.',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12.5,
                                  color: Colors.white.withOpacity(0.65)),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ).animate().fadeIn(duration: 350.ms),

                const SizedBox(height: 20),

                Text(
                  'AVAILABLE STUDY ENGINES',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 12),

                // Tools List
                ...tools.map((tool) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: AppHoverCard(
                        onTap: tool.onTap,
                        borderRadius: BorderRadius.circular(12),
                        backgroundColor: Theme.of(context)
                            .colorScheme
                            .surfaceContainerLow,
                        borderColor: AppColors.darkBorder,
                        hoverBorderColor: tool.color.withOpacity(0.55),
                        glowColor: tool.color,
                        padding: const EdgeInsets.all(16),
                        child: Row(
                          children: [
                            AppHero(
                              tag: AppHeroTags.studyTool(tool.title),
                              child: Container(
                                width: 44,
                                height: 44,
                                decoration: BoxDecoration(
                                  color: tool.color.withOpacity(0.12),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Icon(tool.icon,
                                    color: tool.color, size: 22),
                              ),
                            ),
                            const SizedBox(width: 14),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Wrap(
                                    crossAxisAlignment: WrapCrossAlignment.center,
                                    spacing: 6,
                                    runSpacing: 4,
                                    children: [
                                      Text(
                                        tool.title,
                                        style: const TextStyle(
                                            fontFamily: 'Inter',
                                            fontSize: 15,
                                            fontWeight: FontWeight.w700,
                                            color: Colors.white),
                                      ),
                                      Container(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 6, vertical: 2),
                                        decoration: BoxDecoration(
                                          color: tool.color.withOpacity(0.15),
                                          borderRadius:
                                              BorderRadius.circular(4),
                                        ),
                                        child: Text(
                                          tool.badge,
                                          style: TextStyle(
                                              fontFamily: 'JetBrains Mono',
                                              fontSize: 9.5,
                                              fontWeight: FontWeight.w700,
                                              color: tool.color),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                  Text(
                                    tool.subtitle,
                                    style: TextStyle(
                                        fontFamily: 'Inter',
                                        fontSize: 12.5,
                                        color: Colors.white.withOpacity(0.65),
                                        height: 1.35),
                                  ),
                                ],
                              ),
                            ),
                            const SizedBox(width: 10),
                            Icon(Icons.arrow_forward_ios_rounded,
                                size: 14,
                                color: Colors.white.withOpacity(0.3)),
                          ],
                        ),
                      ),
                    )),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

class _ToolItem {
  final IconData icon;
  final String title;
  final String subtitle;
  final String badge;
  final Color color;
  final VoidCallback onTap;

  const _ToolItem({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.badge,
    required this.color,
    required this.onTap,
  });
}
