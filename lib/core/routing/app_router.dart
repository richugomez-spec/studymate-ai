import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:riverpod_annotation/riverpod_annotation.dart';

import '../../features/auth/presentation/providers/auth_provider.dart';
import '../../features/auth/presentation/screens/splash_screen.dart';
import '../../features/auth/presentation/screens/onboarding_screen.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/dashboard/presentation/screens/dashboard_screen.dart';
import '../../features/semester/presentation/screens/library_screen.dart';
import '../../features/ai_chat/presentation/screens/chat_screen.dart';
import '../../features/analytics/presentation/screens/analytics_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/subject/presentation/screens/subject_screen.dart';
import '../../features/unit/presentation/screens/unit_screen.dart';
import '../../features/topic/presentation/screens/topic_screen.dart';
import '../../features/quiz/presentation/screens/quiz_screen.dart';
import '../../features/flashcard/presentation/screens/flashcard_screen.dart';
import '../../features/summary/presentation/screens/summary_screen.dart';
import '../../features/mind_map/presentation/screens/mind_map_screen.dart';
import '../../features/upload/presentation/screens/upload_center_screen.dart';
import '../../features/planner/presentation/screens/planner_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../widgets/shell/main_shell.dart';
import 'app_routes.dart';

part 'app_router.g.dart';

class GoRouterRefreshStream extends ChangeNotifier {
  late final StreamSubscription<dynamic> _subscription;

  GoRouterRefreshStream(Stream<dynamic> stream) {
    notifyListeners();
    _subscription = stream.asBroadcastStream().listen((_) => notifyListeners());
  }

  @override
  void dispose() {
    _subscription.cancel();
    super.dispose();
  }
}

@riverpod
GoRouter appRouter(AppRouterRef ref) {
  final authRepository = ref.watch(authRepositoryProvider);
  final refreshNotifier = GoRouterRefreshStream(authRepository.authStateChanges);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    initialLocation: AppRoutes.splash,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final isAuthenticated = user != null;
      final location = state.matchedLocation;

      // Allow splash to manage initial boot
      if (location == AppRoutes.splash) {
        return null;
      }

      final isAuthRoute = location == AppRoutes.login || location == AppRoutes.onboarding;

      // Unauthenticated users attempting to access protected routes are sent to Login
      if (!isAuthenticated && !isAuthRoute) {
        return AppRoutes.login;
      }

      // Authenticated users attempting to access auth routes are sent to Dashboard
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      return null;
    },
    debugLogDiagnostics: true,
    routes: [
      // ── Auth Routes ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        builder: (_, __) => const SplashScreen(),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        builder: (_, __) => const OnboardingScreen(),
      ),
      GoRoute(
        path: AppRoutes.login,
        builder: (_, __) => const LoginScreen(),
      ),

      // ── Shell (Bottom Navigation) ─────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, __) => const NoTransitionPage(child: DashboardScreen()),
          ),
          GoRoute(
            path: AppRoutes.library,
            pageBuilder: (_, __) => const NoTransitionPage(child: LibraryScreen()),
          ),
          GoRoute(
            path: AppRoutes.aiChat,
            pageBuilder: (_, __) => const NoTransitionPage(child: ChatScreen()),
          ),
          GoRoute(
            path: AppRoutes.progress,
            pageBuilder: (_, __) => const NoTransitionPage(child: AnalyticsScreen()),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, __) => const NoTransitionPage(child: SettingsScreen()),
          ),
        ],
      ),

      // ── Content Routes ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.subject,
        builder: (_, state) => SubjectScreen(
          subjectId: state.pathParameters['subjectId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.unit,
        builder: (_, state) => UnitScreen(
          unitId: state.pathParameters['unitId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.topic,
        builder: (_, state) => TopicScreen(
          topicId: state.pathParameters['topicId']!,
        ),
      ),

      // ── AI Feature Routes ─────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.quiz,
        builder: (_, state) => QuizScreen(
          topicId: state.pathParameters['topicId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.flashcards,
        builder: (_, state) => FlashcardScreen(
          topicId: state.pathParameters['topicId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.summary,
        builder: (_, state) => SummaryScreen(
          topicId: state.pathParameters['topicId']!,
        ),
      ),
      GoRoute(
        path: AppRoutes.mindMap,
        builder: (_, state) => MindMapScreen(
          topicId: state.pathParameters['topicId']!,
        ),
      ),

      // ── Tool Routes ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.uploadCenter,
        builder: (_, __) => const UploadCenterScreen(),
      ),
      GoRoute(
        path: AppRoutes.studyPlanner,
        builder: (_, __) => const PlannerScreen(),
      ),
      GoRoute(
        path: AppRoutes.profile,
        builder: (_, __) => const ProfileScreen(),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        builder: (_, __) => const AchievementsScreen(),
      ),
    ],
  );
}
