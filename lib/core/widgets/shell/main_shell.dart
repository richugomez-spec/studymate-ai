import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/auth/presentation/widgets/auth_required_modal.dart';

/// Main navigation shell with bottom navigation bar.
/// Wraps all 5 bottom-nav tabs using GoRouter's ShellRoute.
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({super.key, required this.child});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  int _selectedIndex = 0;

  static const _destinations = [
    _NavDestination(
      route: AppRoutes.home,
      icon: Icons.home_outlined,
      selectedIcon: Icons.home_rounded,
      label: 'Home',
    ),
    _NavDestination(
      route: AppRoutes.library,
      icon: Icons.menu_book_outlined,
      selectedIcon: Icons.menu_book_rounded,
      label: 'Library',
    ),
    _NavDestination(
      route: AppRoutes.aiChat,
      icon: Icons.auto_awesome_outlined,
      selectedIcon: Icons.auto_awesome_rounded,
      label: 'AI Chat',
    ),
    _NavDestination(
      route: AppRoutes.progress,
      icon: Icons.bar_chart_outlined,
      selectedIcon: Icons.bar_chart_rounded,
      label: 'Progress',
    ),
    _NavDestination(
      route: AppRoutes.settings,
      icon: Icons.settings_outlined,
      selectedIcon: Icons.settings_rounded,
      label: 'Settings',
    ),
  ];

  void _onDestinationSelected(int index) {
    if (_selectedIndex == index) return;
    setState(() => _selectedIndex = index);
    context.go(_destinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (isDesktop) {
      return Scaffold(
        backgroundColor: isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Row(
          children: [
            _StudyMateSidebar(
              selectedIndex: _selectedIndex,
              destinations: _destinations,
              onDestinationSelected: _onDestinationSelected,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorder,
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _StudyMateBottomNav(
        selectedIndex: _selectedIndex,
        destinations: _destinations,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}

class _StudyMateSidebar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  const _StudyMateSidebar({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      width: 230,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Workspace Identifier / Logo Header
          Row(
            children: [
              Container(
                width: 24,
                height: 24,
                decoration: BoxDecoration(
                  color: isDark ? AppColors.darkSurfaceContainerHigh : AppColors.lightSurfaceVariant,
                  borderRadius: BorderRadius.circular(5),
                  border: Border.all(
                    color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    width: 1,
                  ),
                ),
                child: const Center(
                  child: Text(
                    'S',
                    style: TextStyle(
                      fontFamily: 'JetBrains Mono',
                      fontSize: 12,
                      fontWeight: FontWeight.w700,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'StudyMate AI',
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 13,
                      fontWeight: FontWeight.w700,
                      letterSpacing: -0.2,
                      color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 20),

          // Section label
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 4),
            child: Text(
              'WORKSPACES',
              style: TextStyle(
                fontFamily: 'JetBrains Mono',
                fontSize: 9.5,
                fontWeight: FontWeight.w600,
                color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                letterSpacing: 0.8,
              ),
            ),
          ),
          const SizedBox(height: 4),

          // Navigation list
          ...List.generate(destinations.length, (i) {
            final dest = destinations[i];
            final isSelected = selectedIndex == i;

            return Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: InkWell(
                onTap: () => onDestinationSelected(i),
                borderRadius: BorderRadius.circular(5),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                  decoration: BoxDecoration(
                    color: isSelected
                        ? (isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceVariant)
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(5),
                    border: isSelected
                        ? Border.all(
                            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
                            width: 1,
                          )
                        : null,
                  ),
                  child: Row(
                    children: [
                      Icon(
                        isSelected ? dest.selectedIcon : dest.icon,
                        size: 16,
                        color: isSelected
                            ? (isDark ? Colors.white : AppColors.brandAccent)
                            : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                      ),
                      const SizedBox(width: 9),
                      Text(
                        dest.label,
                        style: TextStyle(
                          fontFamily: 'Inter',
                          fontSize: 12.5,
                          fontWeight: isSelected ? FontWeight.w600 : FontWeight.w400,
                          color: isSelected
                              ? (isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary)
                              : (isDark ? AppColors.darkTextSecondary : AppColors.lightTextSecondary),
                        ),
                      ),
                      const Spacer(),
                      Text(
                        '${i + 1}',
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 10,
                          color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }),

          const Spacer(),

          // Bottom Account / Guest action
          Consumer(
            builder: (context, ref, _) {
              final user = ref.watch(currentUserProvider);
              if (user == null) {
                return InkWell(
                  onTap: () => AuthRequiredModal.show(
                    context,
                    title: 'Sign in to StudyMate AI',
                    message: 'Unlock your AI tutor, uploaded lecture notes, and automated flashcards.',
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.electricViolet.withOpacity(0.12),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(color: AppColors.electricViolet.withOpacity(0.25)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.login_rounded, size: 16, color: AppColors.electricVioletLight),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: AppColors.electricVioletLight,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              }

              final name = user.displayName?.isNotEmpty == true
                  ? user.displayName!
                  : user.email.split('@').first;

              return InkWell(
                onTap: () => context.push(AppRoutes.profile),
                borderRadius: BorderRadius.circular(8),
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 6),
                  decoration: BoxDecoration(
                    color: isDark ? AppColors.darkSurfaceContainer : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(color: isDark ? AppColors.darkBorderSubtle : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      CircleAvatar(
                        radius: 12,
                        backgroundColor: AppColors.electricViolet.withOpacity(0.2),
                        child: Text(
                          name[0].toUpperCase(),
                          style: const TextStyle(
                            fontFamily: 'JetBrains Mono',
                            fontSize: 11,
                            fontWeight: FontWeight.w700,
                            color: AppColors.electricViolet,
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          name,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 12,
                            fontWeight: FontWeight.w500,
                            color: isDark ? AppColors.darkTextPrimary : AppColors.lightTextPrimary,
                          ),
                        ),
                      ),
                      Icon(Icons.more_vert_rounded, size: 14, color: isDark ? AppColors.darkTextTertiary : AppColors.lightTextTertiary),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}

class _StudyMateBottomNav extends StatelessWidget {
  final int selectedIndex;
  final List<_NavDestination> destinations;
  final ValueChanged<int> onDestinationSelected;

  const _StudyMateBottomNav({
    required this.selectedIndex,
    required this.destinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Container(
      decoration: BoxDecoration(
        color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
        border: Border(
          top: BorderSide(
            color: isDark ? AppColors.darkBorder : AppColors.lightBorder,
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        child: SizedBox(
          height: 64,
          child: Row(
            children: List.generate(destinations.length, (i) {
              final dest = destinations[i];
              final isSelected = selectedIndex == i;

              return Expanded(
                child: GestureDetector(
                  onTap: () => onDestinationSelected(i),
                  behavior: HitTestBehavior.opaque,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 200),
                    curve: Curves.easeInOut,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // AI Chat center button — special styling
                        if (i == 2)
                          AnimatedContainer(
                            duration: const Duration(milliseconds: 200),
                            width: 48,
                            height: 36,
                            decoration: BoxDecoration(
                              gradient: isSelected ? AppColors.primaryGradient : null,
                              color: isSelected ? null : Colors.transparent,
                              borderRadius: BorderRadius.circular(12),
                              boxShadow: isSelected
                                  ? [
                                      BoxShadow(
                                        color: AppColors.electricViolet.withOpacity(0.3),
                                        blurRadius: 12,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: Icon(
                              isSelected ? dest.selectedIcon : dest.icon,
                              size: 22,
                              color: isSelected
                                  ? Colors.white
                                  : isDark
                                      ? AppColors.darkTextTertiary
                                      : AppColors.lightTextTertiary,
                            ),
                          )
                        else
                          Icon(
                            isSelected ? dest.selectedIcon : dest.icon,
                            size: 22,
                            color: isSelected
                                ? AppColors.electricViolet
                                : isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                          ).animate(target: isSelected ? 1 : 0).scaleXY(
                            end: 1.15,
                            duration: 200.ms,
                            curve: Curves.elasticOut,
                          ),

                        const SizedBox(height: 4),

                        AnimatedDefaultTextStyle(
                          duration: const Duration(milliseconds: 200),
                          style: TextStyle(
                            fontFamily: 'Inter',
                            fontSize: 10,
                            fontWeight:
                                isSelected ? FontWeight.w600 : FontWeight.w400,
                            color: isSelected
                                ? AppColors.electricViolet
                                : isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                          ),
                          child: Text(dest.label),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            }),
          ),
        ),
      ),
    );
  }
}

class _NavDestination {
  final String route;
  final IconData icon;
  final IconData selectedIcon;
  final String label;

  const _NavDestination({
    required this.route,
    required this.icon,
    required this.selectedIcon,
    required this.label,
  });
}
