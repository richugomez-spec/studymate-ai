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
import '../../features/quiz/presentation/screens/question_paper_analyzer_screen.dart';
import '../../features/quiz/presentation/screens/exam_generator_screen.dart';
import '../../features/flashcard/presentation/screens/flashcard_screen.dart';
import '../../features/summary/presentation/screens/summary_screen.dart';
import '../../features/mind_map/presentation/screens/mind_map_screen.dart';
import '../../features/planner/presentation/screens/planner_screen.dart';
import '../../features/profile/presentation/screens/profile_screen.dart';
import '../../features/achievements/presentation/screens/achievements_screen.dart';
import '../../features/study_tools/presentation/screens/study_tools_screen.dart';
import '../animations/animations.dart';
import '../widgets/notifications/app_notification.dart';
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
  final refreshNotifier =
      GoRouterRefreshStream(authRepository.authStateChanges);
  ref.onDispose(refreshNotifier.dispose);

  return GoRouter(
    navigatorKey: AppNotification.globalNavigatorKey,
    initialLocation: AppRoutes.home,
    refreshListenable: refreshNotifier,
    redirect: (context, state) {
      final user = authRepository.currentUser;
      final isAuthenticated = user != null;
      final location = state.matchedLocation;

      final isAuthRoute =
          location == AppRoutes.login || location == AppRoutes.onboarding;

      // Authenticated users navigating to login are redirected back to home
      if (isAuthenticated && isAuthRoute) {
        return AppRoutes.home;
      }

      // Guest visitors can browse Home, Library, AI Chat, Study Tools, Progress, Settings in preview mode
      return null;
    },
    debugLogDiagnostics: true,
    routes: [
      // ── Auth Routes ────────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.splash,
        pageBuilder: (_, state) => AppPageTransitions.fadeThrough(
          key: state.pageKey,
          child: const SplashScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.onboarding,
        pageBuilder: (_, state) => AppPageTransitions.fadeThrough(
          key: state.pageKey,
          child: const OnboardingScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.login,
        pageBuilder: (_, state) => AppPageTransitions.fadeThrough(
          key: state.pageKey,
          child: const LoginScreen(),
        ),
      ),

      // ── Shell (Bottom Navigation) ─────────────────────────────────────────
      ShellRoute(
        builder: (_, __, child) => MainShell(child: child),
        routes: [
          GoRoute(
            path: AppRoutes.home,
            pageBuilder: (_, state) => AppPageTransitions.fadeThrough(
              key: state.pageKey,
              child: const DashboardScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.library,
            pageBuilder: (_, state) => AppPageTransitions.fadeThrough(
              key: state.pageKey,
              child: const LibraryScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.aiChat,
            pageBuilder: (_, state) => AppPageTransitions.fadeThrough(
              key: state.pageKey,
              child: const ChatScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.studyTools,
            pageBuilder: (_, state) => AppPageTransitions.fadeThrough(
              key: state.pageKey,
              child: const StudyToolsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.flashcards,
            pageBuilder: (_, state) => AppPageTransitions.slide(
              key: state.pageKey,
              child: FlashcardScreen(topicId: state.pathParameters['topicId']),
            ),
          ),
          GoRoute(
            path: AppRoutes.quiz,
            pageBuilder: (_, state) => AppPageTransitions.slide(
              key: state.pageKey,
              child: QuizScreen(
                  topicId: state.pathParameters['topicId'] ?? 'current'),
            ),
          ),
          GoRoute(
            path: AppRoutes.summary,
            pageBuilder: (_, state) => AppPageTransitions.slide(
              key: state.pageKey,
              child: SummaryScreen(
                topicId: state.pathParameters['topicId'] ?? 'current',
                initialMode: state.uri.queryParameters['mode'],
              ),
            ),
          ),
          GoRoute(
            path: AppRoutes.mindMap,
            pageBuilder: (_, state) => AppPageTransitions.slide(
              key: state.pageKey,
              child: MindMapScreen(
                  topicId: state.pathParameters['topicId'] ?? 'current'),
            ),
          ),
          GoRoute(
            path: AppRoutes.questionPaperAnalyzer,
            pageBuilder: (_, state) => AppPageTransitions.slide(
              key: state.pageKey,
              child: QuestionPaperAnalyzerScreen(
                  topicId: state.pathParameters['topicId'] ?? 'current'),
            ),
          ),
          GoRoute(
            path: AppRoutes.examGenerator,
            pageBuilder: (_, state) => AppPageTransitions.slide(
              key: state.pageKey,
              child: ExamGeneratorScreen(
                  topicId: state.pathParameters['topicId'] ?? 'current'),
            ),
          ),
          GoRoute(
            path: AppRoutes.progress,
            pageBuilder: (_, state) => AppPageTransitions.fadeThrough(
              key: state.pageKey,
              child: const AnalyticsScreen(),
            ),
          ),
          GoRoute(
            path: AppRoutes.settings,
            pageBuilder: (_, state) => AppPageTransitions.fadeThrough(
              key: state.pageKey,
              child: const SettingsScreen(),
            ),
          ),
        ],
      ),

      // ── Content Routes ────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.subject,
        pageBuilder: (_, state) => AppPageTransitions.slide(
          key: state.pageKey,
          child: SubjectScreen(
            subjectId: state.pathParameters['subjectId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.unit,
        pageBuilder: (_, state) => AppPageTransitions.slide(
          key: state.pageKey,
          child: UnitScreen(
            unitId: state.pathParameters['unitId']!,
          ),
        ),
      ),
      GoRoute(
        path: AppRoutes.topic,
        pageBuilder: (_, state) => AppPageTransitions.slide(
          key: state.pageKey,
          child: TopicScreen(
            topicId: state.pathParameters['topicId']!,
          ),
        ),
      ),

      // ── Tool Routes ───────────────────────────────────────────────────────
      GoRoute(
        path: AppRoutes.studyPlanner,
        pageBuilder: (_, state) => AppPageTransitions.scale(
          key: state.pageKey,
          child: const PlannerScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.profile,
        pageBuilder: (_, state) => AppPageTransitions.scale(
          key: state.pageKey,
          child: const ProfileScreen(),
        ),
      ),
      GoRoute(
        path: AppRoutes.achievements,
        pageBuilder: (_, state) => AppPageTransitions.scale(
          key: state.pageKey,
          child: const AchievementsScreen(),
        ),
      ),
    ],
  );
}
