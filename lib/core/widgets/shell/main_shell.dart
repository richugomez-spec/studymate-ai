import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/routing/app_routes.dart';
import '../../../features/auth/presentation/providers/auth_provider.dart';
import '../../../features/auth/presentation/widgets/auth_required_modal.dart';

/// Main navigation shell with sidebar (desktop) or bottom nav (mobile).
/// Wraps all ShellRoute tabs using GoRouter.
class MainShell extends ConsumerStatefulWidget {
  final Widget child;
  const MainShell({required this.child, super.key});

  @override
  ConsumerState<MainShell> createState() => _MainShellState();
}

class _MainShellState extends ConsumerState<MainShell> {
  static const _sectionedNav = [
    _NavSection(label: 'WORKSPACE', destinations: [
      _NavDestination(
          route: AppRoutes.home,
          icon: Icons.home_outlined,
          selectedIcon: Icons.home_rounded,
          label: 'Home'),
      _NavDestination(
          route: AppRoutes.library,
          icon: Icons.menu_book_outlined,
          selectedIcon: Icons.menu_book_rounded,
          label: 'Library'),
      _NavDestination(
          route: AppRoutes.aiChat,
          icon: Icons.auto_awesome_outlined,
          selectedIcon: Icons.auto_awesome_rounded,
          label: 'AI Chat'),
    ]),
    _NavSection(label: 'STUDY TOOLS', destinations: [
      _NavDestination(
          route: '/flashcards/current',
          icon: Icons.flip_to_front_outlined,
          selectedIcon: Icons.flip_to_front_rounded,
          label: 'Flashcards'),
      _NavDestination(
          route: '/quiz/current',
          icon: Icons.quiz_outlined,
          selectedIcon: Icons.quiz_rounded,
          label: 'Quiz'),
      _NavDestination(
          route: '/mind-map/current',
          icon: Icons.hub_outlined,
          selectedIcon: Icons.hub_rounded,
          label: 'Mind Map'),
      _NavDestination(
          route: '/summary/current',
          icon: Icons.summarize_outlined,
          selectedIcon: Icons.summarize_rounded,
          label: 'Smart Summary'),
      _NavDestination(
          route: '/analyzer/current',
          icon: Icons.analytics_outlined,
          selectedIcon: Icons.analytics_rounded,
          label: 'PYQ Analyzer'),
      _NavDestination(
          route: '/exam/current',
          icon: Icons.assignment_outlined,
          selectedIcon: Icons.assignment_rounded,
          label: 'Exam Generator'),
    ]),
    _NavSection(label: 'ACCOUNT', destinations: [
      _NavDestination(
          route: AppRoutes.progress,
          icon: Icons.bar_chart_outlined,
          selectedIcon: Icons.bar_chart_rounded,
          label: 'Progress'),
      _NavDestination(
          route: AppRoutes.settings,
          icon: Icons.settings_outlined,
          selectedIcon: Icons.settings_rounded,
          label: 'Settings'),
    ]),
  ];

  static final _allDestinations =
      _sectionedNav.expand((s) => s.destinations).toList();

  int _calculateSelectedIndex(BuildContext context) {
    final location = GoRouterState.of(context).matchedLocation;
    for (int i = 0; i < _allDestinations.length; i++) {
      final route = _allDestinations[i].route;
      if (location == route) return i;
      if (route != '/' && location.startsWith(route)) return i;
      // Tool path prefix matching (e.g. /flashcards matches /flashcards/current)
      final basePrefix = route.split('/')[1];
      if (basePrefix.isNotEmpty && location.startsWith('/$basePrefix'))
        return i;
    }
    return 0;
  }

  void _onDestinationSelected(int index) {
    context.go(_allDestinations[index].route);
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final isDesktop = screenWidth >= 900;
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final selectedIndex = _calculateSelectedIndex(context);

    if (isDesktop) {
      return Scaffold(
        backgroundColor:
            isDark ? AppColors.darkBackground : AppColors.lightBackground,
        body: Row(
          children: [
            _StudyMateSidebar(
              selectedIndex: selectedIndex,
              sectionedNav: _sectionedNav,
              allDestinations: _allDestinations,
              onDestinationSelected: _onDestinationSelected,
            ),
            VerticalDivider(
              width: 1,
              thickness: 1,
              color:
                  isDark ? AppColors.darkBorderSubtle : AppColors.lightBorder,
            ),
            Expanded(child: widget.child),
          ],
        ),
      );
    }

    // Mobile bottom nav — workspace + account tabs only
    final mobileDestinations = [
      _allDestinations[0], // Home
      _allDestinations[1], // Library
      _allDestinations[2], // AI Chat
      _allDestinations[9], // Progress
      _allDestinations[10], // Settings
    ];

    return Scaffold(
      body: widget.child,
      bottomNavigationBar: _StudyMateBottomNav(
        selectedIndex: selectedIndex,
        destinations: mobileDestinations,
        onDestinationSelected: _onDestinationSelected,
      ),
    );
  }
}

// ── Sidebar ──────────────────────────────────────────────────────────────────

class _StudyMateSidebar extends StatelessWidget {
  final int selectedIndex;
  final List<_NavSection> sectionedNav;
  final List<_NavDestination> allDestinations;
  final ValueChanged<int> onDestinationSelected;

  const _StudyMateSidebar({
    required this.selectedIndex,
    required this.sectionedNav,
    required this.allDestinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    int globalIndex = 0;

    return Container(
      width: 228,
      color: isDark ? AppColors.darkSurface : AppColors.lightSurface,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Logo header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                Container(
                  width: 26,
                  height: 26,
                  decoration: BoxDecoration(
                    gradient: AppColors.primaryGradient,
                    borderRadius: BorderRadius.circular(7),
                    boxShadow: [
                      BoxShadow(
                        color: AppColors.electricViolet.withOpacity(0.35),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Center(
                    child: Text(
                      'S',
                      style: TextStyle(
                        fontFamily: 'JetBrains Mono',
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
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
                        fontSize: 13.5,
                        fontWeight: FontWeight.w700,
                        letterSpacing: -0.3,
                        color: isDark
                            ? AppColors.darkTextPrimary
                            : AppColors.lightTextPrimary,
                      ),
                    ),
                    Text(
                      'AI-Powered Workspace',
                      style: TextStyle(
                        fontFamily: 'Inter',
                        fontSize: 9.5,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 22),

          // Sectioned nav
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: sectionedNav.map((section) {
                final items = section.destinations.map((dest) {
                  final idx = globalIndex++;
                  return _SidebarItem(
                    destination: dest,
                    isSelected: selectedIndex == idx,
                    isDark: isDark,
                    onTap: () => onDestinationSelected(idx),
                  );
                }).toList();

                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(6, 8, 6, 4),
                      child: Text(
                        section.label,
                        style: TextStyle(
                          fontFamily: 'JetBrains Mono',
                          fontSize: 9,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary,
                          letterSpacing: 0.9,
                        ),
                      ),
                    ),
                    ...items,
                    const SizedBox(height: 4),
                  ],
                );
              }).toList(),
            ),
          ),

          // User card / sign in
          Consumer(
            builder: (context, ref, _) {
              final user = ref.watch(currentUserProvider);
              if (user == null) {
                return InkWell(
                  onTap: () => AuthRequiredModal.show(
                    context,
                    title: 'Sign in to StudyMate AI',
                    message:
                        'Unlock your AI tutor, subject notes, and automated flashcards.',
                  ),
                  borderRadius: BorderRadius.circular(8),
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 9),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          AppColors.electricViolet.withOpacity(0.18),
                          AppColors.skyBlue.withOpacity(0.10),
                        ],
                      ),
                      borderRadius: BorderRadius.circular(8),
                      border: Border.all(
                          color: AppColors.electricViolet.withOpacity(0.3)),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.login_rounded,
                            size: 15, color: AppColors.electricVioletLight),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Sign In',
                            style: TextStyle(
                              fontFamily: 'Inter',
                              fontSize: 12.5,
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
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 7),
                  decoration: BoxDecoration(
                    color: isDark
                        ? AppColors.darkSurfaceContainer
                        : AppColors.lightSurfaceVariant,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                        color: isDark
                            ? AppColors.darkBorder
                            : AppColors.lightBorder),
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 26,
                        height: 26,
                        decoration: const BoxDecoration(
                          gradient: AppColors.primaryGradient,
                          shape: BoxShape.circle,
                        ),
                        child: Center(
                          child: Text(
                            name[0].toUpperCase(),
                            style: const TextStyle(
                              fontFamily: 'JetBrains Mono',
                              fontSize: 11,
                              fontWeight: FontWeight.w700,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              name,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 12,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.darkTextPrimary
                                    : AppColors.lightTextPrimary,
                              ),
                            ),
                            Text(
                              'View Profile',
                              style: TextStyle(
                                fontFamily: 'Inter',
                                fontSize: 10,
                                color: isDark
                                    ? AppColors.darkTextTertiary
                                    : AppColors.lightTextTertiary,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Icon(
                        Icons.chevron_right_rounded,
                        size: 14,
                        color: isDark
                            ? AppColors.darkTextTertiary
                            : AppColors.lightTextTertiary,
                      ),
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

// ── Sidebar Item with hover ───────────────────────────────────────────────────

class _SidebarItem extends StatefulWidget {
  final _NavDestination destination;
  final bool isSelected;
  final bool isDark;
  final VoidCallback onTap;

  const _SidebarItem({
    required this.destination,
    required this.isSelected,
    required this.isDark,
    required this.onTap,
  });

  @override
  State<_SidebarItem> createState() => _SidebarItemState();
}

class _SidebarItemState extends State<_SidebarItem> {
  bool _hovered = false;

  @override
  Widget build(BuildContext context) {
    final isSelected = widget.isSelected;
    final isDark = widget.isDark;

    Color bgColor = Colors.transparent;
    if (isSelected) {
      bgColor = isDark
          ? AppColors.darkSurfaceContainer
          : AppColors.lightSurfaceVariant;
    } else if (_hovered) {
      bgColor = isDark
          ? AppColors.darkSurfaceVariant.withOpacity(0.7)
          : AppColors.lightSurfaceVariant.withOpacity(0.6);
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 1),
      child: MouseRegion(
        onEnter: (_) => setState(() => _hovered = true),
        onExit: (_) => setState(() => _hovered = false),
        child: GestureDetector(
          onTap: widget.onTap,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 150),
            padding: const EdgeInsets.symmetric(horizontal: 9, vertical: 7),
            decoration: BoxDecoration(
              color: bgColor,
              borderRadius: BorderRadius.circular(6),
              border: isSelected
                  ? Border.all(
                      color:
                          isDark ? AppColors.darkBorder : AppColors.lightBorder,
                    )
                  : null,
            ),
            child: Row(
              children: [
                Icon(
                  isSelected
                      ? widget.destination.selectedIcon
                      : widget.destination.icon,
                  size: 15,
                  color: isSelected
                      ? (isDark
                          ? AppColors.electricVioletLight
                          : AppColors.brandAccent)
                      : (_hovered
                          ? (isDark
                              ? AppColors.darkTextSecondary
                              : AppColors.lightTextSecondary)
                          : (isDark
                              ? AppColors.darkTextTertiary
                              : AppColors.lightTextTertiary)),
                ),
                const SizedBox(width: 9),
                Expanded(
                  child: Text(
                    widget.destination.label,
                    style: TextStyle(
                      fontFamily: 'Inter',
                      fontSize: 12.5,
                      fontWeight:
                          isSelected ? FontWeight.w600 : FontWeight.w400,
                      color: isSelected
                          ? (isDark
                              ? AppColors.darkTextPrimary
                              : AppColors.lightTextPrimary)
                          : (_hovered
                              ? (isDark
                                  ? AppColors.darkTextSecondary
                                  : AppColors.lightTextSecondary)
                              : (isDark
                                  ? AppColors.darkTextTertiary
                                  : AppColors.lightTextTertiary)),
                    ),
                  ),
                ),
                if (isSelected)
                  Container(
                    width: 5,
                    height: 5,
                    decoration: const BoxDecoration(
                      color: AppColors.electricViolet,
                      shape: BoxShape.circle,
                    ),
                  ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// ── Bottom Navigation Bar (Mobile) ──────────────────────────────────────────

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
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      if (i == 2)
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 200),
                          width: 48,
                          height: 34,
                          decoration: BoxDecoration(
                            gradient:
                                isSelected ? AppColors.primaryGradient : null,
                            color: isSelected ? null : Colors.transparent,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: isSelected
                                ? [
                                    BoxShadow(
                                      color: AppColors.electricViolet
                                          .withOpacity(0.35),
                                      blurRadius: 12,
                                    ),
                                  ]
                                : null,
                          ),
                          child: Icon(
                            isSelected ? dest.selectedIcon : dest.icon,
                            size: 20,
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
                      const SizedBox(height: 3),
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
              );
            }),
          ),
        ),
      ),
    );
  }
}

// ── Data Models ──────────────────────────────────────────────────────────────

class _NavSection {
  final String label;
  final List<_NavDestination> destinations;
  const _NavSection({required this.label, required this.destinations});
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
