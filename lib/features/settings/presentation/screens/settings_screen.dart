import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: AppColors.darkBackground,
        elevation: 0,
        titleSpacing: 20,
        title: const Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Colors.white,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile card
          _ProfileCard().animate().fadeIn(duration: 400.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // AI Provider section
          _SectionLabel(label: 'AI PROVIDER'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.auto_awesome_rounded,
            iconColor: AppColors.electricViolet,
            title: 'AI Provider',
            subtitle: 'Gemini 1.5 Flash (active)',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () => context.push(AppRoutes.aiSettings),
          ).animate(delay: 50.ms).fadeIn().slideY(begin: 0.1, end: 0),
          _SettingsTile(
            icon: Icons.vpn_key_outlined,
            iconColor: AppColors.skyBlue,
            title: 'API Keys',
            subtitle: 'Manage provider credentials',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ).animate(delay: 80.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

          // Appearance section
          _SectionLabel(label: 'APPEARANCE'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: AppColors.amber,
            title: 'Theme',
            subtitle: isDark ? 'Dark Mode' : 'Light Mode',
            trailing: Switch(
              value: isDark,
              onChanged: (_) => ref.read(themeModeNotifierProvider.notifier).toggle(),
              activeColor: AppColors.electricViolet,
            ),
            onTap: () => ref.read(themeModeNotifierProvider.notifier).toggle(),
          ).animate(delay: 120.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

          // Study section
          _SectionLabel(label: 'STUDY PREFERENCES'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.psychology_outlined,
            iconColor: AppColors.teal,
            title: 'Explanation Style',
            subtitle: 'Intermediate',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),
          _SettingsTile(
            icon: Icons.alarm_rounded,
            iconColor: AppColors.coral,
            title: 'Daily Study Goal',
            subtitle: '2 hours / day',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ).animate(delay: 180.ms).fadeIn().slideY(begin: 0.1, end: 0),
          _SettingsTile(
            icon: Icons.notifications_outlined,
            iconColor: AppColors.electricViolet,
            title: 'Notifications',
            subtitle: 'Daily reminders enabled',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ).animate(delay: 210.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

          // Data section
          _SectionLabel(label: 'DATA & PRIVACY'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.cloud_sync_rounded,
            iconColor: AppColors.skyBlue,
            title: 'Cloud Sync',
            subtitle: 'Last synced: 2 min ago',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ).animate(delay: 240.ms).fadeIn().slideY(begin: 0.1, end: 0),
          _SettingsTile(
            icon: Icons.download_rounded,
            iconColor: AppColors.teal,
            title: 'Export Data',
            subtitle: 'Download all your study data',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ).animate(delay: 270.ms).fadeIn().slideY(begin: 0.1, end: 0),
          _SettingsTile(
            icon: Icons.delete_outline_rounded,
            iconColor: AppColors.error,
            title: 'Delete Account',
            subtitle: 'Permanently remove all data',
            trailing: const Icon(Icons.chevron_right_rounded),
            onTap: () {},
          ).animate(delay: 300.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

          // About
          _SectionLabel(label: 'ABOUT'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.darkTextSecondary,
            title: 'StudyMate AI',
            subtitle: 'Version 1.0.0 • Build 1',
            trailing: null,
            onTap: () {},
          ).animate(delay: 330.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 32),

          // Sign out
          OutlinedButton.icon(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor: AppColors.darkSurface,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                    side: const BorderSide(color: AppColors.darkBorder),
                  ),
                  title: const Text(
                    'Sign Out',
                    style: TextStyle(
                      color: Colors.white,
                      fontFamily: 'Inter',
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  content: const Text(
                    'Are you sure you want to sign out of your account?',
                    style: TextStyle(color: Colors.white70, fontFamily: 'Inter'),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      child: Text(
                        'Cancel',
                        style: TextStyle(color: Colors.white.withOpacity(0.6)),
                      ),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                      ),
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      child: const Text('Sign Out', style: TextStyle(color: Colors.white)),
                    ),
                  ],
                ),
              );

              if (shouldLogout == true) {
                await ref.read(authNotifierProvider.notifier).signOut();
                if (context.mounted) {
                  context.go(AppRoutes.login);
                }
              }
            },
            icon: const Icon(Icons.logout_rounded, color: AppColors.error),
            label: const Text(
              'Sign Out',
              style: TextStyle(color: AppColors.error, fontFamily: 'Inter', fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
              minimumSize: const Size(double.infinity, 52),
            ),
          ).animate(delay: 360.ms).fadeIn(),

          const SizedBox(height: 40),
        ],
      ),
    );
  }
}

class _ProfileCard extends ConsumerWidget {
  const _ProfileCard();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final user = ref.watch(currentUserProvider);
    final displayName = user?.displayName ?? (user?.email.isNotEmpty == true ? user!.email.split('@').first : 'Student');
    final email = user?.email ?? 'Not logged in';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.darkSurfaceVariant,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: AppColors.darkBorderSubtle),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 28,
            backgroundColor: AppColors.electricViolet.withOpacity(0.2),
            backgroundImage: (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                ? NetworkImage(user.photoUrl!)
                : null,
            child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                ? Text(
                    initial,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 22,
                      fontWeight: FontWeight.w700,
                      color: AppColors.electricViolet,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: const TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Colors.white,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Colors.white.withOpacity(0.5),
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                  decoration: BoxDecoration(
                    color: AppColors.electricViolet.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(6),
                  ),
                  child: const Text(
                    'Engineering • Year 4',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 11,
                      fontWeight: FontWeight.w500,
                      color: AppColors.electricViolet,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.edit_outlined, size: 18, color: Colors.white.withOpacity(0.3)),
        ],
      ),
    );
  }
}

class _SectionLabel extends StatelessWidget {
  final String label;
  const _SectionLabel({required this.label});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 2, bottom: 4),
      child: Text(
        label,
        style: const TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: AppColors.darkTextTertiary,
        ),
      ),
    );
  }
}

class _SettingsTile extends StatelessWidget {
  final IconData icon;
  final Color iconColor;
  final String title;
  final String subtitle;
  final Widget? trailing;
  final VoidCallback onTap;

  const _SettingsTile({
    required this.icon,
    required this.iconColor,
    required this.title,
    required this.subtitle,
    required this.trailing,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        margin: const EdgeInsets.only(bottom: 1),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.darkSurfaceVariant,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.darkBorderSubtle),
        ),
        child: Row(
          children: [
            Container(
              width: 32,
              height: 32,
              decoration: BoxDecoration(
                color: iconColor.withOpacity(0.10),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, size: 16, color: iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Colors.white,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12,
                      color: Colors.white.withOpacity(0.45),
                    ),
                  ),
                ],
              ),
            ),
            if (trailing != null) ...[
              const SizedBox(width: 8),
              DefaultTextStyle(
                style: TextStyle(color: Colors.white.withOpacity(0.3)),
                child: IconTheme(
                  data: IconThemeData(color: Colors.white.withOpacity(0.3), size: 18),
                  child: trailing!,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
