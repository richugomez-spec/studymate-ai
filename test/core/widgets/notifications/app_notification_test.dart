import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:studymate_ai/core/widgets/notifications/app_notification.dart';

void main() {
  group('AppNotificationCard Tests', () {
    testWidgets('renders Success notification card with icon, title, and message',
        (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationCard(
              message: 'Study session saved successfully.',
              type: AppNotificationType.success,
              title: 'Success',
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Success'), findsOneWidget);
      expect(find.text('Study session saved successfully.'), findsOneWidget);
      expect(find.byIcon(Icons.check_circle_rounded), findsOneWidget);
    });

    testWidgets('renders Error notification card with action button',
        (tester) async {
      bool actionTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationCard(
              message: 'Failed to sync with cloud.',
              type: AppNotificationType.error,
              title: 'Error',
              actionLabel: 'Retry',
              onAction: () => actionTriggered = true,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Error'), findsOneWidget);
      expect(find.text('Failed to sync with cloud.'), findsOneWidget);
      expect(find.text('Retry'), findsOneWidget);

      await tester.tap(find.text('Retry'));
      expect(actionTriggered, isTrue);
    });

    testWidgets('renders Warning notification card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationCard(
              message: 'Cache limit reached.',
              type: AppNotificationType.warning,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Warning'), findsOneWidget);
      expect(find.text('Cache limit reached.'), findsOneWidget);
      expect(find.byIcon(Icons.warning_amber_rounded), findsOneWidget);
    });

    testWidgets('renders Loading notification card with spinner', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationCard(
              message: 'Generating summary with AI...',
              type: AppNotificationType.loading,
              title: 'Processing',
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Processing'), findsOneWidget);
      expect(find.text('Generating summary with AI...'), findsOneWidget);
      expect(find.byType(CircularProgressIndicator), findsOneWidget);
    });

    testWidgets('renders Information notification card', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationCard(
              message: 'New update available.',
              type: AppNotificationType.info,
              title: 'Notice',
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Notice'), findsOneWidget);
      expect(find.text('New update available.'), findsOneWidget);
      expect(find.byIcon(Icons.info_outline_rounded), findsOneWidget);
    });

    testWidgets('renders Undo notification card and fires callback', (tester) async {
      bool undoTriggered = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: AppNotificationCard(
              message: 'Topic deleted.',
              type: AppNotificationType.undo,
              onAction: () => undoTriggered = true,
              onDismiss: () {},
            ),
          ),
        ),
      );

      expect(find.text('Topic deleted.'), findsOneWidget);
      expect(find.text('Undo'), findsOneWidget);
      expect(find.byIcon(Icons.undo_rounded), findsOneWidget);

      await tester.tap(find.text('Undo'));
      expect(undoTriggered, isTrue);
    });
  });
}
