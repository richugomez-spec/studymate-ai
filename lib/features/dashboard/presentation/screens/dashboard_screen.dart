import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/routing/app_routes.dart';
import '../../../../core/services/document_processing_service.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/utils/responsive.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../../../auth/presentation/widgets/auth_required_modal.dart';

/// Clean, Minimalist Modern Dashboard for StudyMate AI
///
/// Features:
/// - Welcome <username>
/// - Continue Learning (Selected Subject)
/// - Open Library
/// - AI Chat
/// - Study Tools (Mind Map, Flashcards, Quiz, Summary, Exam Prep)
/// - Recent Activity
class DashboardScreen extends ConsumerWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final activeSubjectName = ref.watch(activeKnowledgeSubjectNameProvider);
    final activeSubjectId = ref.watch(activeKnowledgeSubjectIdProvider);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: CustomScrollView(
        physics: const BouncingScrollPhysics(),
        slivers: [
          // ── App Bar ────────────────────────────────────────────────────────
          SliverAppBar(
            floating: true,
            pinned: false,
            backgroundColor: Theme.of(context).scaffoldBackgroundColor,
            surfaceTintColor: Colors.transparent,
            title: Text(
              'StudyMate AI',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 17,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
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
                tooltip: 'Open Library',
                icon: const Icon(Icons.menu_book_outlined,
                    size: 20, color: AppColors.electricVioletLight),
              ),
              if (user != null)
                IconButton(
                  onPressed: () => context.push(AppRoutes.profile),
                  tooltip: 'Profile',
                  icon: CircleAvatar(
                    radius: 14,
                    backgroundColor:
                        Theme.of(context).colorScheme.surfaceContainerHigh,
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

          // ── Dashboard Content ──────────────────────────────────────────────
          SliverPadding(
            padding: EdgeInsets.symmetric(
              horizontal: Responsive.horizontalPadding(context),
              vertical: 20,
            ),
            sliver: SliverList(
              delegate: SliverChildListDelegate([
                // 1. Welcome Header
                _WelcomeHeader(user: user)
                    .animate()
                    .fadeIn(duration: 350.ms)
                    .slideY(begin: 0.04, end: 0),

                const SizedBox(height: 28),

                // 2. Continue Learning Card
                _ContinueLearningCard(
                  subjectName: activeSubjectName,
                  subjectId: activeSubjectId,
                )
                    .animate(delay: 80.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.04, end: 0),

                const SizedBox(height: 28),

                // 3. AI Chat & Library Quick Launchers
                _QuickActionCards()
                    .animate(delay: 140.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.04, end: 0),

                const SizedBox(height: 32),

                // 4. Study Tools Section
                _StudyToolsSection(subjectId: activeSubjectId)
                    .animate(delay: 200.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.04, end: 0),

                const SizedBox(height: 32),

                // 5. Recent Activity
                _RecentActivitySection(userId: user?.id)
                    .animate(delay: 260.ms)
                    .fadeIn(duration: 400.ms)
                    .slideY(begin: 0.04, end: 0),

                const SizedBox(height: 48),
              ]),
            ),
          ),
        ],
      ),
    );
  }
}

// ── 1. Welcome Header ────────────────────────────────────────────────────────

class _WelcomeHeader extends ConsumerWidget {
  final dynamic user;

  const _WelcomeHeader({required this.user});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final firestoreUserAsync =
        user != null ? ref.watch(userProfileStreamProvider(user.id)) : null;
    final firestoreUser = firestoreUserAsync?.asData?.value;

    final displayName = firestoreUser?.name.isNotEmpty == true
        ? firestoreUser!.name
        : (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!
            : (user?.email != null && user!.email.isNotEmpty)
                ? user.email.split('@').first
                : 'Student';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Welcome, $displayName',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: Responsive.displayFont(context),
            fontWeight: FontWeight.w700,
            letterSpacing: -0.6,
            color: Theme.of(context).colorScheme.onSurface,
          ),
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
        const SizedBox(height: 6),
        Text(
          'Your personalized intelligent study companion',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: Responsive.bodyFont(context),
            fontWeight: FontWeight.w400,
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          ),
        ),
      ],
    );
  }
}

// ── 2. Continue Learning Card ────────────────────────────────────────────────

class _ContinueLearningCard extends StatelessWidget {
  final String? subjectName;
  final String? subjectId;

  const _ContinueLearningCard({
    required this.subjectName,
    required this.subjectId,
  });

  @override
  Widget build(BuildContext context) {
    final hasSubject = subjectName != null && subjectName!.trim().isNotEmpty;

    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHighest,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: hasSubject
              ? AppColors.electricViolet.withOpacity(0.35)
              : AppColors.darkBorderSubtle,
        ),
        boxShadow: hasSubject
            ? [
                BoxShadow(
                  color: AppColors.electricViolet.withOpacity(0.08),
                  blurRadius: 20,
                  offset: const Offset(0, 6),
                ),
              ]
            : null,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                padding: const EdgeInsets.all(8),
                decoration: BoxDecoration(
                  color: hasSubject
                      ? AppColors.electricViolet.withOpacity(0.15)
                      : Colors.white.withOpacity(0.06),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Icon(
                  hasSubject ? Icons.play_circle_fill_rounded : Icons.menu_book_rounded,
                  color: hasSubject ? AppColors.electricVioletLight : Colors.white60,
                  size: 20,
                ),
              ),
              const SizedBox(width: 12),
              Text(
                hasSubject ? 'CONTINUE LEARNING' : 'ACTIVE SUBJECT',
                style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  letterSpacing: 0.8,
                  color: hasSubject
                      ? AppColors.electricVioletLight
                      : Theme.of(context).colorScheme.onSurfaceVariant,
                ),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Text(
            hasSubject ? subjectName! : 'No Subject Selected',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 22,
              fontWeight: FontWeight.w700,
              letterSpacing: -0.4,
              color: Theme.of(context).colorScheme.onSurface,
            ),
          ),
          const SizedBox(height: 8),
          Text(
            hasSubject
                ? 'Resume your notes, mind map, flashcards, and quizzes for this subject.'
                : 'Choose a subject from your Library to begin studying.',
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 13,
              height: 1.4,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ),
          const SizedBox(height: 20),
          Wrap(
            spacing: 12,
            runSpacing: 10,
            children: [
              ElevatedButton.icon(
                onPressed: () {
                  if (hasSubject && subjectId != null) {
                    context.push('/subject/$subjectId');
                  } else {
                    context.push(AppRoutes.library);
                  }
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricViolet,
                  foregroundColor: Colors.white,
                  elevation: 0,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                icon: Icon(
                  hasSubject ? Icons.arrow_forward_rounded : Icons.folder_open_rounded,
                  size: 16,
                ),
                label: Text(
                  hasSubject ? 'Continue in Library' : 'Open Library',
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              if (hasSubject && subjectId != null)
                OutlinedButton.icon(
                  onPressed: () => context.push('/mind-map/$subjectId'),
                  style: OutlinedButton.styleFrom(
                    foregroundColor: Theme.of(context).colorScheme.onSurface,
                    side: const BorderSide(color: AppColors.darkBorder),
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  icon: const Icon(Icons.account_tree_outlined, size: 16),
                  label: const Text(
                    'Mind Map',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
            ],
          ),
        ],
      ),
    );
  }
}

// ── 3. Quick Action Cards (AI Chat & Library) ────────────────────────────────

class _QuickActionCards extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWide = constraints.maxWidth > 580;

        final chatCard = _FeatureTile(
          icon: Icons.auto_awesome_rounded,
          title: 'AI Chat Tutor',
          subtitle: 'Ask doubts, explain concepts, and brainstorm in real-time.',
          color: AppColors.teal,
          onTap: () => context.go(AppRoutes.aiChat),
        );

        final libraryCard = _FeatureTile(
          icon: Icons.menu_book_rounded,
          title: 'Open Library',
          subtitle: 'Manage your subjects, topics, subtopics, and study notes.',
          color: AppColors.electricViolet,
          onTap: () => context.push(AppRoutes.library),
        );

        if (isWide) {
          return Row(
            children: [
              Expanded(child: chatCard),
              const SizedBox(width: 16),
              Expanded(child: libraryCard),
            ],
          );
        }

        return Column(
          children: [
            chatCard,
            const SizedBox(height: 12),
            libraryCard,
          ],
        );
      },
    );
  }
}

class _FeatureTile extends StatelessWidget {
  final IconData icon;
  final String title;
  final String subtitle;
  final Color color;
  final VoidCallback onTap;

  const _FeatureTile({
    required this.icon,
    required this.title,
    required this.subtitle,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHighest,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppColors.darkBorderSubtle),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: color.withOpacity(0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, size: 22, color: color),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 15,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right_rounded,
              size: 20,
              color: Theme.of(context).colorScheme.onSurfaceVariant,
            ),
          ],
        ),
      ),
    );
  }
}

// ── 4. Study Tools Section ───────────────────────────────────────────────────

class _StudyToolsSection extends StatelessWidget {
  final String? subjectId;

  const _StudyToolsSection({required this.subjectId});

  @override
  Widget build(BuildContext context) {
    final effectiveTarget = subjectId ?? 'all';

    final tools = [
      _ToolItem(
        title: 'Mind Map',
        subtitle: 'Interactive Tree',
        icon: Icons.account_tree_rounded,
        color: const Color(0xFF6366F1),
        onTap: () => context.push('/mind-map/$effectiveTarget'),
      ),
      _ToolItem(
        title: 'Flashcards',
        subtitle: 'Active Recall',
        icon: Icons.style_rounded,
        color: const Color(0xFFEC4899),
        onTap: () => context.push('/flashcards/$effectiveTarget'),
      ),
      _ToolItem(
        title: 'Quiz',
        subtitle: 'Practice Tests',
        icon: Icons.quiz_rounded,
        color: const Color(0xFF10B981),
        onTap: () => context.push('/quiz/$effectiveTarget'),
      ),
      _ToolItem(
        title: 'Summary',
        subtitle: 'High-Yield Notes',
        icon: Icons.article_rounded,
        color: const Color(0xFFF59E0B),
        onTap: () => context.push('/summary/$effectiveTarget'),
      ),
      _ToolItem(
        title: 'Exam Generator',
        subtitle: 'KJU University Style',
        icon: Icons.assignment_turned_in_rounded,
        color: const Color(0xFF8B5CF6),
        onTap: () => context.push('/exam/$effectiveTarget'),
      ),
      _ToolItem(
        title: 'PYQ Analyzer',
        subtitle: 'Past Question Papers',
        icon: Icons.analytics_outlined,
        color: const Color(0xFF06B6D4),
        onTap: () => context.push('/analyzer/$effectiveTarget'),
      ),
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              'Study Tools',
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 18,
                fontWeight: FontWeight.w700,
                color: Theme.of(context).colorScheme.onSurface,
              ),
            ),
            TextButton(
              onPressed: () => context.push(AppRoutes.studyTools),
              child: const Text('View All'),
            ),
          ],
        ),
        const SizedBox(height: 12),
        LayoutBuilder(
          builder: (context, constraints) {
            final crossAxisCount = constraints.maxWidth > 800
                ? 6
                : constraints.maxWidth > 500
                    ? 3
                    : 2;

            return GridView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: tools.length,
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: crossAxisCount,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.15,
              ),
              itemBuilder: (context, index) {
                final tool = tools[index];
                return InkWell(
                  onTap: tool.onTap,
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color:
                          Theme.of(context).colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: AppColors.darkBorderSubtle),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: tool.color.withOpacity(0.14),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Icon(tool.icon, size: 20, color: tool.color),
                        ),
                        const Spacer(),
                        Text(
                          tool.title,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 13,
                            fontWeight: FontWeight.w600,
                            color: Theme.of(context).colorScheme.onSurface,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          tool.subtitle,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 11,
                            color:
                                Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ],
    );
  }
}

class _ToolItem {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  _ToolItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });
}

// ── 5. Recent Activity Section ───────────────────────────────────────────────

class _RecentActivitySection extends ConsumerWidget {
  final String? userId;

  const _RecentActivitySection({required this.userId});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    if (userId == null || userId!.isEmpty) {
      return const SizedBox.shrink();
    }

    final subjectsAsync = ref.watch(userSubjectsStreamProvider(userId!));

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Subjects',
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 18,
            fontWeight: FontWeight.w700,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
        const SizedBox(height: 12),
        subjectsAsync.when(
          data: (subjects) {
            if (subjects.isEmpty) {
              return Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.surfaceContainerHighest,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppColors.darkBorderSubtle),
                ),
                child: Text(
                  'No subjects added yet. Add a subject in your Library to get started.',
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
              );
            }

            final recentList = subjects.take(3).toList();

            return Column(
              children: recentList.map((subject) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 8),
                  child: InkWell(
                    onTap: () {
                      final sId = subject['id']?.toString() ?? '';
                      final sName = subject['name']?.toString() ?? 'Subject';
                      ref.read(activeKnowledgeSubjectIdProvider.notifier).state =
                          sId;
                      ref
                          .read(activeKnowledgeSubjectNameProvider.notifier)
                          .state = sName;
                      context.push('/subject/$sId');
                    },
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 16, vertical: 14),
                      decoration: BoxDecoration(
                        color: Theme.of(context)
                            .colorScheme
                            .surfaceContainerHighest,
                        borderRadius: BorderRadius.circular(10),
                        border: Border.all(color: AppColors.darkBorderSubtle),
                      ),
                      child: Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: AppColors.electricViolet.withOpacity(0.12),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Icon(
                              Icons.folder_outlined,
                              size: 18,
                              color: AppColors.electricVioletLight,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Text(
                              subject['name']?.toString() ?? 'Subject',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 14,
                                fontWeight: FontWeight.w600,
                                color: Theme.of(context).colorScheme.onSurface,
                              ),
                            ),
                          ),
                          Icon(
                            Icons.arrow_forward_ios_rounded,
                            size: 14,
                            color: Theme.of(context).colorScheme.onSurfaceVariant,
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            );
          },
          loading: () => const SizedBox(
            height: 40,
            child: Center(
              child: SizedBox(
                width: 20,
                height: 20,
                child: CircularProgressIndicator(strokeWidth: 2),
              ),
            ),
          ),
          error: (_, __) => const SizedBox.shrink(),
        ),
      ],
    );
  }
}
