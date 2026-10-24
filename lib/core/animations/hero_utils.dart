import 'package:flutter/material.dart';

/// Hero animation utilities and tag generators for StudyMate AI.
/// Provides artifact-free flight shuttle builders and natural arc tweens.

/// 1. Glitch-Free Hero Wrapper
class AppHero extends StatelessWidget {
  final Object tag;
  final Widget child;
  final CreateRectTween? createRectTween;
  final HeroFlightShuttleBuilder? flightShuttleBuilder;
  final HeroPlaceholderBuilder? placeholderBuilder;

  const AppHero({
    required this.tag,
    required this.child,
    super.key,
    this.createRectTween,
    this.flightShuttleBuilder,
    this.placeholderBuilder,
  });

  @override
  Widget build(BuildContext context) {
    return Hero(
      tag: tag,
      createRectTween: createRectTween ?? _defaultRectTween,
      placeholderBuilder: placeholderBuilder,
      flightShuttleBuilder: flightShuttleBuilder ?? _defaultFlightShuttle,
      child: child,
    );
  }

  static RectTween _defaultRectTween(Rect? begin, Rect? end) {
    return MaterialRectArcTween(begin: begin, end: end);
  }

  static Widget _defaultFlightShuttle(
    BuildContext flightContext,
    Animation<double> animation,
    HeroFlightDirection flightDirection,
    BuildContext fromHeroContext,
    BuildContext toHeroContext,
  ) {
    final Hero toHero = toHeroContext.widget as Hero;
    return Material(
      color: Colors.transparent,
      type: MaterialType.transparency,
      child: toHero.child,
    );
  }
}

/// 2. Centralized Registry of Hero Tags
abstract final class AppHeroTags {
  static String subjectIcon(String subjectId) => 'hero_subject_icon_$subjectId';
  static String subjectTitle(String subjectId) => 'hero_subject_title_$subjectId';
  static String userAvatar(String? userId) => 'hero_user_avatar_${userId ?? "current"}';
  static String studyTool(String toolRoute) => 'hero_study_tool_$toolRoute';
  static String topicCard(String topicId) => 'hero_topic_card_$topicId';
}
