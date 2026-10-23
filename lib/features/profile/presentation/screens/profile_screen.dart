import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/settings/developer_mode_preferences.dart';
import '../../../../services/firestore_service.dart';
import '../../../auth/presentation/providers/auth_provider.dart';

class ProfileScreen extends ConsumerStatefulWidget {
  const ProfileScreen({super.key});

  @override
  ConsumerState<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends ConsumerState<ProfileScreen> {
  int _avatarTapCount = 0;

  Future<void> _onAvatarTap() async {
    if (_avatarTapCount >= 7) return;
    final taps = _avatarTapCount + 1;
    setState(() => _avatarTapCount = taps);

    String? feedback;
    if (taps == 5) feedback = '2 more taps to unlock Developer Options';
    if (taps == 6) feedback = '1 more tap to unlock Developer Options';
    if (taps == 7) {
      await DeveloperModePreferences.enable();
      feedback = 'Developer Options Enabled';
    }
    if (feedback != null && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(feedback)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = ref.watch(currentUserProvider);
    final userId =
        user?.id ?? ref.watch(firestoreServiceProvider).currentUserId ?? '';
    final profileAsync =
        userId.isNotEmpty ? ref.watch(userProfileStreamProvider(userId)) : null;
    final profile = profileAsync?.asData?.value;

    final progressAsync = userId.isNotEmpty
        ? ref.watch(userStudyProgressStreamProvider(userId))
        : null;
    final progress = progressAsync?.asData?.value;
    final knowledgeItems = userId.isNotEmpty
        ? ref.watch(userKnowledgeStreamProvider(userId)).asData?.value ??
            const <Map<String, dynamic>>[]
        : const <Map<String, dynamic>>[];
    final noteCount =
        knowledgeItems.where((item) => item['kind'] == 'note').length;

    final name = profile?.name.isNotEmpty == true
        ? profile!.name
        : (user?.displayName != null && user!.displayName!.isNotEmpty)
            ? user.displayName!
            : (user?.email != null && user!.email.isNotEmpty)
                ? user.email.split('@').first
                : 'Student';

    final email = profile?.email.isNotEmpty == true
        ? profile!.email
        : (user?.email ?? 'student@studymate.ai');

    final initials = name
        .trim()
        .split(' ')
        .map((w) => w.isNotEmpty ? w[0] : '')
        .take(2)
        .join()
        .toUpperCase();

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
          'Student Profile',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 16,
            color: Colors.white,
          ),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 720),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // ── Header Card ──────────────────────────────────────────────
                Container(
                  padding: const EdgeInsets.all(24),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(10),
                    border: Border.all(color: AppColors.darkBorderSubtle),
                  ),
                  child: Row(
                    children: [
                      InkWell(
                        onTap: _onAvatarTap,
                        customBorder: const CircleBorder(),
                        child: CircleAvatar(
                          radius: 32,
                          backgroundColor:
                              AppColors.electricViolet.withOpacity(0.2),
                          child: Text(
                            initials.isNotEmpty ? initials : 'SM',
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 20,
                              fontWeight: FontWeight.w700,
                              color: AppColors.electricViolet,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 20,
                                fontWeight: FontWeight.w700,
                                color: AppColors.darkTextPrimary,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              email,
                              style: const TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 13,
                                color: AppColors.darkTextSecondary,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Container(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 8, vertical: 3),
                              decoration: BoxDecoration(
                                color: AppColors.emerald.withOpacity(0.12),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: const Text(
                                'ACTIVE SUBSCRIBER • FIRESTORE SYNCED',
                                style: TextStyle(
                                  fontFamily: 'JetBrains Mono',
                                  fontSize: 9.5,
                                  fontWeight: FontWeight.w700,
                                  color: AppColors.emerald,
                                  letterSpacing: 0.5,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                )
                    .animate()
                    .fadeIn(duration: 300.ms)
                    .slideY(begin: 0.05, end: 0),

                const SizedBox(height: 20),

                // ── Lifetime Statistics Grid ─────────────────────────────────
                Text(
                  'LIFETIME ACADEMIC METRICS',
                  style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 10,
                    fontWeight: FontWeight.w600,
                    color: AppColors.darkTextTertiary,
                    letterSpacing: 0.8,
                  ),
                ),
                const SizedBox(height: 10),
                LayoutBuilder(
                  builder: (context, constraints) {
                    final isMobile = constraints.maxWidth < 500;
                    final metrics = [
                      _ProfileMetricCard(
                        title: 'Focus Minutes',
                        value:
                            '${progress?.totalMinutes ?? profile?.totalStudyMinutes ?? 0}m',
                        icon: Icons.timer_outlined,
                        color: AppColors.electricViolet,
                      ),
                      _ProfileMetricCard(
                        title: 'Study Notes',
                        value: '$noteCount',
                        icon: Icons.note_alt_outlined,
                        color: AppColors.teal,
                      ),
                      _ProfileMetricCard(
                        title: 'Quizzes Completed',
                        value: '${progress?.quizzesCompleted ?? 0}',
                        icon: Icons.quiz_outlined,
                        color: AppColors.amber,
                      ),
                      _ProfileMetricCard(
                        title: 'Study Streak',
                        value:
                            '${profile?.streak ?? progress?.currentStreak ?? 1}d',
                        icon: Icons.local_fire_department_rounded,
                        color: Colors.deepOrangeAccent,
                      ),
                    ];

                    return GridView.count(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      crossAxisCount: isMobile ? 2 : 4,
                      crossAxisSpacing: 10,
                      mainAxisSpacing: 10,
                      childAspectRatio: isMobile ? 1.4 : 1.3,
                      children: metrics,
                    );
                  },
                ),

                const SizedBox(height: 24),

                // ── Account Details ──────────────────────────────────────────
                Text(
                  'ACCOUNT DETAILS',
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
                  decoration: BoxDecoration(
                    color: AppColors.darkSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: AppColors.darkBorderSubtle),
                  ),
                  child: Column(
                    children: [
                      _DetailRow(
                          label: 'Account UID',
                          value: userId.isNotEmpty ? userId : 'guest_session'),
                      const Divider(
                          color: AppColors.darkBorderSubtle, height: 20),
                      _DetailRow(
                          label: 'Authentication Provider',
                          value: 'Firebase Auth (Persistent)'),
                      const Divider(
                          color: AppColors.darkBorderSubtle, height: 20),
                      _DetailRow(
                        label: 'Member Since',
                        value: profile?.createdAt != null
                            ? '${profile!.createdAt.day}/${profile.createdAt.month}/${profile.createdAt.year}'
                            : 'October 2026',
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 24),

                // ── Actions ──────────────────────────────────────────────────
                ElevatedButton.icon(
                  onPressed: () async {
                    await ref.read(authNotifierProvider.notifier).signOut();
                    if (context.mounted) {
                      context.go(AppRoutes.login);
                    }
                  },
                  icon: const Icon(Icons.logout_rounded, size: 16),
                  label: const Text('Sign Out of StudyMate AI'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.redAccent.withOpacity(0.12),
                    foregroundColor: Colors.redAccent,
                    elevation: 0,
                    side: BorderSide(color: Colors.redAccent.withOpacity(0.3)),
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                    padding: const EdgeInsets.symmetric(
                        horizontal: 20, vertical: 14),
                    minimumSize: const Size(double.infinity, 44),
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

class _ProfileMetricCard extends StatelessWidget {
  final String title;
  final String value;
  final IconData icon;
  final Color color;

  const _ProfileMetricCard({
    required this.title,
    required this.value,
    required this.icon,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorderSubtle),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(height: 8),
          Text(
            value,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 18,
              fontWeight: FontWeight.w700,
              color: Colors.white,
            ),
          ),
          const SizedBox(height: 2),
          Text(
            title,
            style: TextStyle(
              fontFamily: 'Inter',
              fontSize: 10.5,
              color: Colors.white.withOpacity(0.5),
            ),
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
          ),
        ],
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  final String label;
  final String value;

  const _DetailRow({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: 12,
            color: Colors.white.withOpacity(0.6),
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontFamily: 'JetBrains Mono',
            fontSize: 11.5,
            fontWeight: FontWeight.w500,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
