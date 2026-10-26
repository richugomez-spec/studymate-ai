import 'package:flutter/material.dart';
import '../../theme/app_colors.dart';

/// Notification types supported by StudyMate AI's floating notification system.
enum AppNotificationType {
  success,
  error,
  warning,
  loading,
  info,
  undo;

  /// Default title for each notification type.
  String get defaultTitle {
    switch (this) {
      case AppNotificationType.success:
        return 'Success';
      case AppNotificationType.error:
        return 'Error';
      case AppNotificationType.warning:
        return 'Warning';
      case AppNotificationType.loading:
        return 'Loading';
      case AppNotificationType.info:
        return 'Information';
      case AppNotificationType.undo:
        return 'Action performed';
    }
  }

  /// Primary accent color for borders, icon containers, and highlights.
  Color color(BuildContext context) {
    switch (this) {
      case AppNotificationType.success:
        return AppColors.success;
      case AppNotificationType.error:
        return AppColors.error;
      case AppNotificationType.warning:
        return AppColors.warning;
      case AppNotificationType.loading:
        return AppColors.skyBlue;
      case AppNotificationType.info:
        return AppColors.brandAccent;
      case AppNotificationType.undo:
        return AppColors.electricViolet;
    }
  }

  /// Default icon associated with each notification type.
  IconData get defaultIcon {
    switch (this) {
      case AppNotificationType.success:
        return Icons.check_circle_rounded;
      case AppNotificationType.error:
        return Icons.error_outline_rounded;
      case AppNotificationType.warning:
        return Icons.warning_amber_rounded;
      case AppNotificationType.loading:
        return Icons.autorenew_rounded;
      case AppNotificationType.info:
        return Icons.info_outline_rounded;
      case AppNotificationType.undo:
        return Icons.undo_rounded;
    }
  }
}
