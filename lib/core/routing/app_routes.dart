/// Route name constants for GoRouter
abstract final class AppRoutes {
  // Auth
  static const splash = '/';
  static const onboarding = '/onboarding';
  static const login = '/login';

  // Shell (bottom nav)
  static const home = '/home';
  static const library = '/library';
  static const aiChat = '/ai-chat';
  static const studyTools = '/study-tools';
  static const progress = '/progress';
  static const settings = '/settings';

  // Semester / Subject / Unit / Topic
  static const semester = '/semester/:semesterId';
  static const subject = '/subject/:subjectId';
  static const unit = '/unit/:unitId';
  static const topic = '/topic/:topicId';

  // AI Features
  static const summary = '/summary/:topicId';
  static const quiz = '/quiz/:topicId';
  static const flashcards = '/flashcards/:topicId';
  static const mindMap = '/mind-map/:topicId';
  static const questionPaperAnalyzer = '/analyzer/:topicId';
  static const examGenerator = '/exam/:topicId';

  // Tools
  static const voiceTutor = '/voice-tutor';
  static const studyPlanner = '/planner';
  static const analytics = '/analytics';
  static const achievements = '/achievements';
  static const profile = '/profile';
  static const aiSettings = '/settings/ai';
}
