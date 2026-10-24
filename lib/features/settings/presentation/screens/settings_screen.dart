import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/ai/ai_config.dart';
import '../../../../core/ai/ai_message.dart';
import '../../../../core/ai/services/gemini_api_key_provider.dart';
import '../../../../core/ai/services/api_key_manager.dart';
import '../../../../core/ai/providers/gemini_provider.dart';
import '../../../auth/presentation/providers/auth_provider.dart';
import '../providers/theme_provider.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen> {
  int _developerTapCount = 0;
  bool _developerUnlocked = false;
  bool _testingConnection = false;
  String _currentModel = ApiKeyManager.modelFallbacks.first;

  void _onAboutTileTap() {
    if (_developerUnlocked) return;
    _developerTapCount++;
    if (_developerTapCount >= 7) {
      setState(() => _developerUnlocked = true);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Developer Options unlocked')),
      );
      return;
    }
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
            '${7 - _developerTapCount} more taps to unlock Developer Options'),
        duration: const Duration(milliseconds: 700),
      ),
    );
  }

  Future<void> _resetApiKey() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset API Key'),
        content: const Text(
            'Remove the saved personal key and return to the predefined keys?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Reset'),
          ),
        ],
      ),
    );
    if (shouldReset != true) return;
    await ref.read(aiApiKeyProvider.notifier).setApiKey('');
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Saved API key reset.')),
      );
    }
  }

  Future<void> _testConnection() async {
    if (_testingConnection) return;
    setState(() => _testingConnection = true);
    try {
      final response = await ref.read(apiKeyManagerProvider).run(
            (apiKey, model) => GeminiProvider(AIConfig(
              providerType: AIProviderType.gemini,
              apiKey: apiKey,
              model: model,
              maxTokens: 8,
            )).complete(const AIRequest(messages: [
              AIMessage(role: AIRole.user, content: 'Reply with OK.'),
            ])),
          );
      if (!mounted) return;
      setState(() => _currentModel = response.model);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Connection successful (${response.model}).')),
      );
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Connection test failed.')),
        );
      }
    } finally {
      if (mounted) setState(() => _testingConnection = false);
    }
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref) {
    final currentKey = ref.read(aiApiKeyProvider) ?? '';
    final controller = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'AI Access Key',
          style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 17),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Enter an access key for AI study features.',
              style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: 13,
                  color: Theme.of(context).colorScheme.onSurfaceVariant,
                  height: 1.4),
            ),
            const SizedBox(height: 16),
            TextField(
              controller: controller,
              style: TextStyle(
                  fontFamily: 'JetBrains Mono',
                  fontSize: 12,
                  color: Theme.of(context).colorScheme.onSurface),
              decoration: InputDecoration(
                hintText: 'AIzaSy...',
                hintStyle: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                filled: true,
                fillColor:
                    Theme.of(context).colorScheme.surfaceContainerHighest,
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline)),
                enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.outline)),
                focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide(
                        color: Theme.of(context).colorScheme.primary)),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () {
              ref.read(aiApiKeyProvider.notifier).setApiKey(controller.text);
              Navigator.of(ctx).pop();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                    content: Text('AI access key updated successfully.')),
              );
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricViolet),
            child: const Text('Save Key',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;
    final apiKey = ref.watch(aiApiKeyProvider);
    final hasCustomKey = apiKey != null && apiKey.isNotEmpty;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        titleSpacing: 20,
        title: Text(
          'Settings',
          style: TextStyle(
            fontFamily: 'Inter',
            fontWeight: FontWeight.w600,
            fontSize: 18,
            color: Theme.of(context).colorScheme.onSurface,
          ),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(20),
        children: [
          // Profile card
          InkWell(
            onTap: () => context.push(AppRoutes.profile),
            borderRadius: BorderRadius.circular(8),
            child: const _ProfileCard(),
          ).animate().fadeIn(duration: 300.ms).slideY(begin: 0.1, end: 0),
          const SizedBox(height: 24),

          // Appearance section
          const _SectionLabel(label: 'APPEARANCE'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: isDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
            iconColor: AppColors.amber,
            title: 'Theme',
            subtitle: isDark ? 'Dark Mode' : 'Light Mode',
            trailing: Switch(
              value: isDark,
              onChanged: (_) =>
                  ref.read(themeModeNotifierProvider.notifier).toggle(),
              activeColor: AppColors.electricViolet,
            ),
            onTap: () => ref.read(themeModeNotifierProvider.notifier).toggle(),
          ).animate(delay: 100.ms).fadeIn().slideY(begin: 0.1, end: 0),

          const SizedBox(height: 20),

          // About
          const _SectionLabel(label: 'ABOUT'),
          const SizedBox(height: 8),
          _SettingsTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.teal,
            title: 'StudyMate AI',
            subtitle: 'Version 1.0.0 • AI Study Workspace',
            trailing: null,
            onTap: _onAboutTileTap,
          ).animate(delay: 150.ms).fadeIn().slideY(begin: 0.1, end: 0),

          if (_developerUnlocked) ...[
            const SizedBox(height: 16),
            const _SectionLabel(label: 'DEVELOPER OPTIONS'),
            const SizedBox(height: 8),
            _SettingsTile(
              icon: Icons.vpn_key_outlined,
              iconColor: AppColors.electricViolet,
              title: 'AI Access Key',
              subtitle: hasCustomKey
                  ? 'Personal key configured'
                  : 'Using predefined API keys',
              trailing: null,
              onTap: () => _showApiKeyDialog(context, ref),
            ),
            _SettingsTile(
              icon: Icons.cloud_outlined,
              iconColor: AppColors.teal,
              title: 'Current Provider',
              subtitle: 'Google Gemini',
              trailing: null,
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.memory_outlined,
              iconColor: AppColors.amber,
              title: 'Current Model',
              subtitle: _currentModel,
              trailing: null,
              onTap: () {},
            ),
            _SettingsTile(
              icon: Icons.edit_outlined,
              iconColor: AppColors.electricViolet,
              title: 'Edit API Key',
              subtitle: 'Update the saved personal key',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showApiKeyDialog(context, ref),
            ),
            _SettingsTile(
              icon: Icons.restart_alt_rounded,
              iconColor: AppColors.error,
              title: 'Reset API Key',
              subtitle: 'Remove saved key and use predefined keys',
              trailing: null,
              onTap: _resetApiKey,
            ),
            _SettingsTile(
              icon: Icons.wifi_tethering_rounded,
              iconColor: AppColors.teal,
              title: 'Test Connection',
              subtitle: 'Check the Gemini API connection',
              trailing: _testingConnection
                  ? const SizedBox.square(
                      dimension: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.chevron_right_rounded),
              onTap: _testConnection,
            ),
          ],

          const SizedBox(height: 32),

          // Sign out
          OutlinedButton.icon(
            onPressed: () async {
              final shouldLogout = await showDialog<bool>(
                context: context,
                builder: (dialogCtx) => AlertDialog(
                  backgroundColor:
                      Theme.of(dialogCtx).colorScheme.surfaceContainerLow,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                  ),
                  title: Text('Sign Out',
                      style: TextStyle(
                          fontFamily: 'Inter',
                          fontWeight: FontWeight.w700,
                          color: Theme.of(dialogCtx).colorScheme.onSurface)),
                  content: Text(
                    'Are you sure you want to sign out of StudyMate AI?',
                    style: TextStyle(
                        fontFamily: 'Inter',
                        color:
                            Theme.of(dialogCtx).colorScheme.onSurfaceVariant),
                  ),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.of(dialogCtx).pop(false),
                      child: Text('Cancel',
                          style: TextStyle(
                              color: Theme.of(dialogCtx)
                                  .colorScheme
                                  .onSurfaceVariant)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.error,
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12)),
                      ),
                      onPressed: () => Navigator.of(dialogCtx).pop(true),
                      child: const Text('Sign Out',
                          style: TextStyle(color: Colors.white)),
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
              style: TextStyle(
                  color: AppColors.error,
                  fontFamily: 'Inter',
                  fontWeight: FontWeight.w600),
            ),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppColors.error),
              padding: const EdgeInsets.symmetric(vertical: 14),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(14)),
              minimumSize: const Size(double.infinity, 52),
            ),
          ).animate(delay: 200.ms).fadeIn(),

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
    final displayName = user?.displayName ??
        (user?.email.isNotEmpty == true
            ? user!.email.split('@').first
            : 'Student');
    final email = user?.email ?? 'Not logged in';
    final initial = displayName.isNotEmpty ? displayName[0].toUpperCase() : 'S';

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.surfaceContainerHigh,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Theme.of(context).colorScheme.outlineVariant),
      ),
      child: Row(
        children: [
          CircleAvatar(
            radius: 26,
            backgroundColor: AppColors.electricViolet.withOpacity(0.2),
            backgroundImage:
                (user?.photoUrl != null && user!.photoUrl!.isNotEmpty)
                    ? NetworkImage(user.photoUrl!)
                    : null,
            child: (user?.photoUrl == null || user!.photoUrl!.isEmpty)
                ? Text(
                    initial,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 20,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  )
                : null,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  displayName,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.onSurface,
                  ),
                ),
                Text(
                  email,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                  ),
                ),
                const SizedBox(height: 4),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(
                    color: AppColors.electricViolet.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(4),
                  ),
                  child: Text(
                    'Active Learner',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Theme.of(context).colorScheme.primary,
                    ),
                  ),
                ),
              ],
            ),
          ),
          Icon(Icons.chevron_right_rounded,
              size: 20, color: Theme.of(context).colorScheme.onSurfaceVariant),
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
        style: TextStyle(
          fontFamily: 'JetBrains Mono',
          fontSize: 9.5,
          fontWeight: FontWeight.w600,
          letterSpacing: 0.8,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
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
        margin: const EdgeInsets.only(bottom: 6),
        padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.surfaceContainerHigh,
          borderRadius: BorderRadius.circular(8),
          border:
              Border.all(color: Theme.of(context).colorScheme.outlineVariant),
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
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 14,
                      fontWeight: FontWeight.w500,
                      color: Theme.of(context).colorScheme.onSurface,
                    ),
                  ),
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
            if (trailing != null) ...[
              const SizedBox(width: 8),
              DefaultTextStyle(
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant),
                child: IconTheme(
                  data: IconThemeData(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                      size: 18),
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
