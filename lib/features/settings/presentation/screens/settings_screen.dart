import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../../core/animations/animations.dart';
import '../../../../core/theme/app_colors.dart';
import '../../../../core/routing/app_routes.dart';
import '../../../../core/widgets/notifications/app_notification.dart';
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
    if (_developerUnlocked) {
      AppNotification.showInfo(
        context: context,
        message: 'Developer Options are already unlocked.',
      );
      return;
    }
    _developerTapCount++;
    if (_developerTapCount >= 7) {
      setState(() => _developerUnlocked = true);
      AppNotification.showSuccess(
        context: context,
        title: 'Developer Mode',
        message: 'Developer Options unlocked!',
      );
      return;
    }
    AppNotification.showInfo(
      context: context,
      message: '${7 - _developerTapCount} more taps to unlock Developer Options',
      duration: const Duration(milliseconds: 1200),
    );
  }

  Future<void> _resetApiKey() async {
    final shouldReset = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Reset Global API Key(s)'),
        content: const Text(
            'Remove the global API key(s) and return to predefined application keys?'),
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
      AppNotification.showWarning(
        context: context,
        title: 'API Keys Reset',
        message: 'Saved global API key(s) have been cleared.',
      );
    }
  }

  Future<void> _testConnection() async {
    if (_testingConnection) return;
    setState(() => _testingConnection = true);
    final loadingHandle = AppNotification.showLoading(
      context: context,
      title: 'Testing Gemini API',
      message: 'Connecting to AI backend...',
    );
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
      loadingHandle.success(
        title: 'Connection Successful',
        message: 'Active Model: ${response.model}',
      );
    } catch (e) {
      if (mounted) {
        loadingHandle.error(
          title: 'Connection Failed',
          message: 'Unable to reach Gemini API ($e)',
        );
      }
    } finally {
      if (mounted) setState(() => _testingConnection = false);
    }
  }

  void _showApiKeyDialog(BuildContext context, WidgetRef ref) {
    final configuredKeys = ref.read(aiApiKeyListProvider);
    final currentKey = configuredKeys.isNotEmpty
        ? configuredKeys.join('\n')
        : (ref.read(aiApiKeyProvider) ?? '');
    final controller = TextEditingController(text: currentKey);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: Theme.of(context).colorScheme.surfaceContainerLow,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Text(
          'Global Gemini API Keys',
          style: TextStyle(
              fontFamily: 'Inter',
              fontWeight: FontWeight.w700,
              color: Theme.of(context).colorScheme.onSurface,
              fontSize: 17),
        ),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Configure global Gemini API key(s) permanently for the application. All users will automatically use these keys with round-robin rotation and failover. Enter one key per line or comma-separated.',
                style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 13,
                    color: Theme.of(context).colorScheme.onSurfaceVariant,
                    height: 1.4),
              ),
              const SizedBox(height: 16),
              TextField(
                controller: controller,
                minLines: 2,
                maxLines: 6,
                style: TextStyle(
                    fontFamily: 'JetBrains Mono',
                    fontSize: 12,
                    color: Theme.of(context).colorScheme.onSurface),
                decoration: InputDecoration(
                  hintText: 'AIzaSy... (one key per line)',
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
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: Text('Cancel',
                style: TextStyle(
                    color: Theme.of(context).colorScheme.onSurfaceVariant)),
          ),
          ElevatedButton(
            onPressed: () async {
              final text = controller.text;
              await ref.read(aiApiKeyProvider.notifier).setApiKeysFromText(text);
              if (ctx.mounted) Navigator.of(ctx).pop();
              if (context.mounted) {
                AppNotification.showSuccess(
                  context: context,
                  message: 'Global API key(s) permanently saved.',
                );
              }
            },
            style: ElevatedButton.styleFrom(
                backgroundColor: AppColors.electricViolet),
            child: const Text('Save Keys',
                style: TextStyle(
                    color: Colors.white, fontWeight: FontWeight.w600)),
          ),
        ],
      ),
    );
  }

  void _showNotificationShowcase(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        final isDark = theme.brightness == Brightness.dark;

        return Container(
          decoration: BoxDecoration(
            color: isDark ? AppColors.darkSurface : Colors.white,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
            border: Border.all(
              color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            ),
          ),
          padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Handle bar
              Center(
                child: Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
              ),
              const SizedBox(height: 16),

              Row(
                children: [
                  Container(
                    width: 36,
                    height: 36,
                    decoration: BoxDecoration(
                      color: AppColors.electricViolet.withOpacity(0.15),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(
                      Icons.notifications_active_rounded,
                      color: AppColors.electricViolet,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Floating Notification System',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 16,
                            fontWeight: FontWeight.w700,
                            color: isDark
                                ? AppColors.darkTextPrimary
                                : AppColors.lightTextPrimary,
                          ),
                        ),
                        Text(
                          'Tap any item to test entrance animations, blur, & actions',
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            color: isDark
                                ? AppColors.darkTextSecondary
                                : AppColors.lightTextSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.close_rounded),
                    onPressed: () => Navigator.pop(sheetCtx),
                  ),
                ],
              ),
              const SizedBox(height: 20),

              // Notification Type Buttons Grid
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  // 1. Success
                  _buildShowcaseButton(
                    label: 'Success Notification',
                    icon: Icons.check_circle_rounded,
                    color: AppColors.success,
                    onTap: () {
                      AppNotification.showSuccess(
                        context: context,
                        title: 'Study Session Saved',
                        message: 'Quiz completed with 95% accuracy! +50 XP earned.',
                      );
                    },
                  ),

                  // 2. Error
                  _buildShowcaseButton(
                    label: 'Error Notification',
                    icon: Icons.error_outline_rounded,
                    color: AppColors.error,
                    onTap: () {
                      AppNotification.showError(
                        context: context,
                        title: 'Sync Failed',
                        message: 'Could not connect to the database. Tap Retry.',
                        actionLabel: 'Retry',
                        onAction: () {
                          AppNotification.showInfo(
                            context: context,
                            message: 'Retrying sync operation...',
                          );
                        },
                      );
                    },
                  ),

                  // 3. Warning
                  _buildShowcaseButton(
                    label: 'Warning Notification',
                    icon: Icons.warning_amber_rounded,
                    color: AppColors.warning,
                    onTap: () {
                      AppNotification.showWarning(
                        context: context,
                        title: 'Storage Warning',
                        message: 'Local offline cache is 88% full.',
                        actionLabel: 'Clean',
                        onAction: () {
                          AppNotification.showSuccess(
                            context: context,
                            message: 'Offline cache cleared (124 MB freed).',
                          );
                        },
                      );
                    },
                  ),

                  // 4. Loading
                  _buildShowcaseButton(
                    label: 'Loading Notification',
                    icon: Icons.autorenew_rounded,
                    color: AppColors.skyBlue,
                    onTap: () {
                      final handle = AppNotification.showLoading(
                        context: context,
                        title: 'AI Processing',
                        message: 'Extracting mind map nodes from lecture notes...',
                      );
                      // Auto-transition after 2.5s to showcase in-place morphing
                      Future.delayed(const Duration(milliseconds: 2500), () {
                        handle.success(
                          title: 'Mind Map Ready',
                          message: 'Generated 24 interactive concept nodes.',
                        );
                      });
                    },
                  ),

                  // 5. Information
                  _buildShowcaseButton(
                    label: 'Info Notification',
                    icon: Icons.info_outline_rounded,
                    color: AppColors.brandAccent,
                    onTap: () {
                      AppNotification.showInfo(
                        context: context,
                        title: 'System Notice',
                        message: 'Scheduled backup will start tonight at 2:00 AM.',
                      );
                    },
                  ),

                  // 6. Undo
                  _buildShowcaseButton(
                    label: 'Undo Notification',
                    icon: Icons.undo_rounded,
                    color: AppColors.electricViolet,
                    onTap: () {
                      AppNotification.showUndo(
                        context: context,
                        title: 'Topic Deleted',
                        message: 'Topic "Organic Chemistry" was deleted.',
                        onUndo: () {
                          AppNotification.showSuccess(
                            context: context,
                            message: 'Topic "Organic Chemistry" restored.',
                          );
                        },
                      );
                    },
                  ),
                ],
              ),
              const SizedBox(height: 16),

              // Dismiss all button
              OutlinedButton.icon(
                onPressed: () => AppNotification.dismissAll(),
                icon: const Icon(Icons.clear_all_rounded, size: 18),
                label: const Text('Dismiss All Floating Notifications'),
                style: OutlinedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildShowcaseButton({
    required String label,
    required IconData icon,
    required Color color,
    required VoidCallback onTap,
  }) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        hoverColor: color.withOpacity(0.12),
        child: Container(
          width: 190,
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
          decoration: BoxDecoration(
            color: color.withOpacity(isDark ? 0.12 : 0.08),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: color.withOpacity(isDark ? 0.35 : 0.25),
              width: 1,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, size: 18, color: color),
              const SizedBox(width: 8),
              Expanded(
                child: Text(
                  label,
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: 12.5,
                    fontWeight: FontWeight.w600,
                    color: isDark ? Colors.white : color,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showAnimationsShowcase(BuildContext context) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (sheetCtx) {
        final theme = Theme.of(sheetCtx);
        final isDark = theme.brightness == Brightness.dark;

        return StatefulBuilder(
          builder: (ctx, setSheetState) {
            return Container(
              constraints: BoxConstraints(
                maxHeight: MediaQuery.of(sheetCtx).size.height * 0.88,
              ),
              decoration: BoxDecoration(
                color: isDark ? AppColors.darkSurface : Colors.white,
                borderRadius: const BorderRadius.vertical(top: Radius.circular(24)),
                border: Border.all(
                  color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                ),
              ),
              padding: const EdgeInsets.fromLTRB(20, 16, 20, 32),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    // Handle bar
                    Center(
                      child: Container(
                        width: 40,
                        height: 4,
                        decoration: BoxDecoration(
                          color: (isDark ? Colors.white : Colors.black).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),

                    Row(
                      children: [
                        Container(
                          width: 36,
                          height: 36,
                          decoration: BoxDecoration(
                            color: AppColors.teal.withOpacity(0.15),
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: const Icon(
                            Icons.animation_rounded,
                            color: AppColors.teal,
                            size: 20,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'Tasteful Micro-Interactions',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                  color: isDark
                                      ? AppColors.darkTextPrimary
                                      : AppColors.lightTextPrimary,
                                ),
                              ),
                              Text(
                                'Responsive, polished feedback without excessive motion',
                                style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 12,
                                  color: isDark
                                      ? AppColors.darkTextSecondary
                                      : AppColors.lightTextSecondary,
                                ),
                              ),
                            ],
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.close_rounded),
                          onPressed: () => Navigator.pop(sheetCtx),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),

                    // Section 1: Hover & Elevation Card
                    _SectionLabel(label: '1. HOVER & ELEVATION CARD'),
                    const SizedBox(height: 8),
                    AppHoverCard(
                      borderRadius: BorderRadius.circular(14),
                      borderColor: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                      hoverBorderColor: AppColors.electricViolet,
                      glowColor: AppColors.electricViolet,
                      padding: const EdgeInsets.all(16),
                      onTap: () {
                        AppNotification.showSuccess(
                          context: context,
                          title: 'Card Interaction',
                          message: 'Hover lift and elevation spring detected!',
                        );
                      },
                      child: Row(
                        children: [
                          Container(
                            width: 42,
                            height: 42,
                            decoration: BoxDecoration(
                              color: AppColors.electricViolet.withOpacity(0.14),
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: const Icon(
                              Icons.touch_app_rounded,
                              color: AppColors.electricViolet,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 14),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'Hover Me (Desktop) / Tap Me (Mobile)',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 14,
                                    fontWeight: FontWeight.w600,
                                    color: isDark ? Colors.white : AppColors.lightTextPrimary,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Lifts -3px, expands outer glow shadow, and scales down on press.',
                                  style: TextStyle(
                                    fontFamily: 'Inter',
                                    fontSize: 12,
                                    color: isDark
                                        ? AppColors.darkTextSecondary
                                        : AppColors.lightTextSecondary,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios_rounded, size: 14),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section 2: Tactile Button Press & Ripple
                    _SectionLabel(label: '2. BUTTON PRESS & INK SPARKLE'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: AppInteractiveButton(
                            icon: const Icon(Icons.flash_on_rounded, size: 18, color: Colors.white),
                            backgroundColor: AppColors.brandAccent,
                            onPressed: () {
                              AppNotification.showInfo(
                                context: context,
                                message: 'Tactile press scale (0.965) triggered.',
                              );
                            },
                            child: const Text('Primary Pressable'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: AppPressable(
                            onTap: () {
                              AppNotification.showSuccess(
                                context: context,
                                message: 'Secondary button pressed with haptics.',
                              );
                            },
                            child: OutlinedButton.icon(
                              onPressed: () {
                                AppNotification.showSuccess(
                                  context: context,
                                  message: 'Secondary button pressed with haptics.',
                                );
                              },
                              icon: const Icon(Icons.replay_rounded, size: 18),
                              label: const Text('Spring Scale'),
                              style: OutlinedButton.styleFrom(
                                padding: const EdgeInsets.symmetric(vertical: 14),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 18),

                    // Section 3: Smooth Accordion Expansion
                    _SectionLabel(label: '3. SMOOTH ACCORDION EXPANSION'),
                    const SizedBox(height: 8),
                    AppExpansionCard(
                      leading: const Icon(Icons.auto_stories_rounded, color: AppColors.teal),
                      title: const Text(
                        'Quantum Computing Essentials',
                        style: TextStyle(fontWeight: FontWeight.w600, fontSize: 14),
                      ),
                      subtitle: const Text(
                        'Tap to trigger animated height & rotating chevron',
                        style: TextStyle(fontSize: 12),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Smooth animated height interpolation using easeOutCubic curve. Content cross-fades without clipping or abrupt layout jumping.',
                            style: TextStyle(
                              fontSize: 12.5,
                              height: 1.4,
                              color: isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary,
                            ),
                          ),
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 8,
                            children: [
                              Chip(label: const Text('Qubits')),
                              Chip(label: const Text('Superposition')),
                              Chip(label: const Text('Entanglement')),
                            ],
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),

                    // Section 4: Loading Shimmer & Skeletons
                    _SectionLabel(label: '4. LOADING SHIMMER & SKELETONS'),
                    const SizedBox(height: 8),
                    const AppSkeletonTopicCard(),
                    const SizedBox(height: 18),

                    // Section 5: Page Transitions Preview
                    _SectionLabel(label: '5. PAGE TRANSITIONS (LIVE TEST)'),
                    const SizedBox(height: 8),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(sheetCtx);
                              context.go(AppRoutes.library);
                            },
                            child: const Text('Fade Through (Tab)'),
                          ),
                        ),
                        const SizedBox(width: 8),
                        Expanded(
                          child: OutlinedButton(
                            onPressed: () {
                              Navigator.pop(sheetCtx);
                              context.push(AppRoutes.achievements);
                            },
                            child: const Text('Scale (Modal/Tool)'),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final themeMode = ref.watch(themeModeNotifierProvider);
    final isDark = themeMode == ThemeMode.dark;
    final apiKey = ref.watch(aiApiKeyProvider);
    final configuredList = ref.watch(aiApiKeyListProvider);
    final keyCount = configuredList.isNotEmpty
        ? configuredList.length
        : (apiKey != null && apiKey.isNotEmpty ? 1 : 0);
    final hasCustomKey = keyCount > 0;

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
              title: 'Global AI Access Keys',
              subtitle: hasCustomKey
                  ? '$keyCount key(s) active permanently for all users'
                  : 'Using predefined application keys',
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
              title: 'Edit Global API Keys',
              subtitle: 'Update or rotate keys permanently',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showApiKeyDialog(context, ref),
            ),
            _SettingsTile(
              icon: Icons.restart_alt_rounded,
              iconColor: AppColors.error,
              title: 'Reset Global API Keys',
              subtitle: 'Clear saved keys and revert to defaults',
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
            _SettingsTile(
              icon: Icons.notifications_active_outlined,
              iconColor: AppColors.electricViolet,
              title: 'Floating Notifications Showcase',
              subtitle: 'Test all 6 modern glass notification variants',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showNotificationShowcase(context),
            ),
            _SettingsTile(
              icon: Icons.animation_rounded,
              iconColor: AppColors.teal,
              title: 'Animations & Micro-interactions',
              subtitle: 'Test Fade Through, Slide, Scale, Shimmer, & Tactile feedback',
              trailing: const Icon(Icons.chevron_right_rounded),
              onTap: () => _showAnimationsShowcase(context),
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
          AppHero(
            tag: AppHeroTags.userAvatar(user?.id),
            child: CircleAvatar(
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
    return AppHoverCard(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      borderRadius: BorderRadius.circular(8),
      liftDistance: 2.0,
      backgroundColor: Theme.of(context).colorScheme.surfaceContainerHigh,
      borderColor: Theme.of(context).colorScheme.outlineVariant,
      hoverBorderColor: iconColor.withOpacity(0.50),
      glowColor: iconColor,
      onTap: onTap,
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
    );
  }
}
