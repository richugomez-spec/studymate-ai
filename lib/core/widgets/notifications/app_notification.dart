import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';

import 'app_notification_card.dart';
import 'app_notification_overlay.dart';
import 'app_notification_type.dart';

export 'app_notification_card.dart';
export 'app_notification_overlay.dart';
export 'app_notification_type.dart';

/// Global controller & entry point for StudyMate AI's floating notification system.
class AppNotification {
  AppNotification._();

  static final GlobalKey<NavigatorState> globalNavigatorKey =
      GlobalKey<NavigatorState>(debugLabel: 'appNotificationNavigator');

  static OverlayEntry? _overlayEntry;
  static final GlobalKey<AppNotificationHostState> _hostKey =
      GlobalKey<AppNotificationHostState>();
  static const _uuid = Uuid();

  /// Ensures the overlay host is mounted and returns the host state.
  static AppNotificationHostState? _ensureHost(BuildContext? context) {
    if (_hostKey.currentState != null) {
      return _hostKey.currentState;
    }

    OverlayState? overlay;
    if (context != null) {
      overlay = Overlay.maybeOf(context, rootOverlay: true);
    }
    overlay ??= globalNavigatorKey.currentState?.overlay;

    if (overlay == null) {
      return null;
    }

    if (_overlayEntry == null) {
      _overlayEntry = OverlayEntry(
        builder: (ctx) => AppNotificationHost(
          key: _hostKey,
          onEmpty: () {
            _overlayEntry?.remove();
            _overlayEntry = null;
          },
        ),
      );
      overlay.insert(_overlayEntry!);
    }

    return _hostKey.currentState;
  }

  /// Displays a floating notification.
  static AppNotificationHandle show({
    required String message,
    BuildContext? context,
    String? title,
    AppNotificationType type = AppNotificationType.info,
    IconData? icon,
    Widget? customIcon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool showProgressBar = true,
    bool dismissible = true,
  }) {
    final id = _uuid.v4();
    final itemData = AppNotificationItemData(
      id: id,
      title: title,
      message: message,
      type: type,
      icon: icon,
      customIcon: customIcon,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      showProgressBar: showProgressBar,
      dismissible: dismissible,
    );

    // If overlay is not immediately ready (e.g. first frame), post-frame callback
    final host = _ensureHost(context);
    if (host != null) {
      host.addItem(itemData);
    } else {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        final delayedHost = _ensureHost(context);
        delayedHost?.addItem(itemData);
      });
    }

    return AppNotificationHandle(
      id: id,
      dismissCallback: () => dismiss(id),
      updateCallback: ({
        title,
        message,
        type,
        icon,
        duration,
        actionLabel,
        onAction,
      }) {
        _hostKey.currentState?.updateItem(
          id,
          title: title,
          message: message,
          type: type,
          icon: icon,
          duration: duration,
          actionLabel: actionLabel,
          onAction: onAction,
        );
      },
    );
  }

  /// 1. Success Notification
  static AppNotificationHandle showSuccess({
    required String message,
    BuildContext? context,
    String? title,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      title: title ?? 'Success',
      type: AppNotificationType.success,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 2. Error Notification
  static AppNotificationHandle showError({
    required String message,
    BuildContext? context,
    String? title,
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      title: title ?? 'Error',
      type: AppNotificationType.error,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 3. Warning Notification
  static AppNotificationHandle showWarning({
    required String message,
    BuildContext? context,
    String? title,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      title: title ?? 'Warning',
      type: AppNotificationType.warning,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 4. Loading Notification
  /// Note: Loading notifications do not auto-dismiss by default. Use the returned
  /// [AppNotificationHandle] to call [handle.success()], [handle.error()], or [handle.dismiss()].
  static AppNotificationHandle showLoading({
    required String message,
    BuildContext? context,
    String? title = 'Processing',
  }) {
    return show(
      context: context,
      message: message,
      title: title,
      type: AppNotificationType.loading,
      duration: Duration.zero,
      showProgressBar: false,
      dismissible: false,
    );
  }

  /// 5. Information Notification
  static AppNotificationHandle showInfo({
    required String message,
    BuildContext? context,
    String? title,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return show(
      context: context,
      message: message,
      title: title ?? 'Information',
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// 6. Undo Notification
  /// Displays an interactive Undo button with animated countdown timer.
  static AppNotificationHandle showUndo({
    required String message,
    required VoidCallback onUndo,
    BuildContext? context,
    String? title,
    String actionLabel = 'Undo',
    Duration duration = const Duration(seconds: 5),
  }) {
    return show(
      context: context,
      message: message,
      title: title,
      type: AppNotificationType.undo,
      actionLabel: actionLabel,
      onAction: onUndo,
      duration: duration,
    );
  }

  /// Dismisses a specific notification by ID.
  static void dismiss(String id) {
    _hostKey.currentState?.dismissItem(id);
  }

  /// Dismisses all visible floating notifications.
  static void dismissAll() {
    _hostKey.currentState?.dismissAll();
  }

  /// Creates a modern SnackBar drop-in replacement wrapping [AppNotificationCard].
  /// Useful if code specifically passes a SnackBar to [ScaffoldMessenger].
  static SnackBar createSnackBar({
    required BuildContext context,
    required String message,
    String? title,
    AppNotificationType type = AppNotificationType.info,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool showProgressBar = true,
  }) {
    return SnackBar(
      elevation: 0,
      backgroundColor: Colors.transparent,
      behavior: SnackBarBehavior.floating,
      margin: EdgeInsets.zero,
      padding: EdgeInsets.zero,
      duration: duration,
      content: AppNotificationCard(
        message: message,
        title: title,
        type: type,
        actionLabel: actionLabel,
        onAction: onAction,
        duration: duration,
        showProgressBar: showProgressBar,
        onDismiss: () => ScaffoldMessenger.of(context).hideCurrentSnackBar(),
      ),
    );
  }
}

/// Convenience extensions on [BuildContext] for clean, readable syntax.
extension AppNotificationContextExtension on BuildContext {
  AppNotificationHandle showNotification({
    required String message,
    String? title,
    AppNotificationType type = AppNotificationType.info,
    IconData? icon,
    Widget? customIcon,
    String? actionLabel,
    VoidCallback? onAction,
    Duration duration = const Duration(seconds: 4),
    bool showProgressBar = true,
    bool dismissible = true,
  }) {
    return AppNotification.show(
      context: this,
      message: message,
      title: title,
      type: type,
      icon: icon,
      customIcon: customIcon,
      actionLabel: actionLabel,
      onAction: onAction,
      duration: duration,
      showProgressBar: showProgressBar,
      dismissible: dismissible,
    );
  }

  AppNotificationHandle showSuccessNotification(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return AppNotification.showSuccess(
      context: this,
      message: message,
      title: title,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  AppNotificationHandle showErrorNotification(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 5),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return AppNotification.showError(
      context: this,
      message: message,
      title: title,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  AppNotificationHandle showWarningNotification(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return AppNotification.showWarning(
      context: this,
      message: message,
      title: title,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  AppNotificationHandle showLoadingNotification(
    String message, {
    String? title = 'Processing',
  }) {
    return AppNotification.showLoading(
      context: this,
      message: message,
      title: title,
    );
  }

  AppNotificationHandle showInfoNotification(
    String message, {
    String? title,
    Duration duration = const Duration(seconds: 4),
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    return AppNotification.showInfo(
      context: this,
      message: message,
      title: title,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  AppNotificationHandle showUndoNotification(
    String message, {
    required VoidCallback onUndo,
    String? title,
    String actionLabel = 'Undo',
    Duration duration = const Duration(seconds: 5),
  }) {
    return AppNotification.showUndo(
      context: this,
      message: message,
      onUndo: onUndo,
      title: title,
      actionLabel: actionLabel,
      duration: duration,
    );
  }
}
