import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_routes.dart';

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
