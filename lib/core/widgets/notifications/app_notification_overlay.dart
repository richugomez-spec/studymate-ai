import 'package:flutter/material.dart';
import 'app_notification_card.dart';
import 'app_notification_type.dart';

/// Active handle for managing or transitioning a live notification (e.g. Loading -> Success).
class AppNotificationHandle {
  final String id;
  final VoidCallback _dismissCallback;
  final void Function({
    String? title,
    String? message,
    AppNotificationType? type,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) _updateCallback;

  AppNotificationHandle({
    required this.id,
    required VoidCallback dismissCallback,
    required void Function({
      String? title,
      String? message,
      AppNotificationType? type,
      IconData? icon,
      Duration? duration,
      String? actionLabel,
      VoidCallback? onAction,
    }) updateCallback,
  })  : _dismissCallback = dismissCallback,
        _updateCallback = updateCallback;

  /// Dismisses this notification immediately with smooth exit animation.
  void dismiss() => _dismissCallback();

  /// Updates this notification in-place.
  void update({
    String? title,
    String? message,
    AppNotificationType? type,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    _updateCallback(
      title: title,
      message: message,
      type: type,
      icon: icon,
      duration: duration,
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }

  /// Transition this notification to Success state.
  void success({required String message, String? title, Duration? duration}) {
    update(
      type: AppNotificationType.success,
      message: message,
      title: title ?? 'Success',
      duration: duration ?? const Duration(seconds: 4),
    );
  }

  /// Transition this notification to Error state.
  void error({
    required String message,
    String? title,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    update(
      type: AppNotificationType.error,
      message: message,
      title: title ?? 'Error',
      duration: duration ?? const Duration(seconds: 5),
      actionLabel: actionLabel,
      onAction: onAction,
    );
  }
}

/// Public model representing an active notification in the overlay queue.
class AppNotificationItemData {
  final String id;
  String? title;
  String message;
  AppNotificationType type;
  IconData? icon;
  Widget? customIcon;
  String? actionLabel;
  VoidCallback? onAction;
  Duration duration;
  bool showProgressBar;
  bool dismissible;

  AppNotificationItemData({
    required this.id,
    required this.message,
    required this.type,
    required this.duration,
    required this.showProgressBar,
    required this.dismissible,
    this.title,
    this.icon,
    this.customIcon,
    this.actionLabel,
    this.onAction,
  });
}

/// Overlay entry host widget that renders animated floating notifications.
class AppNotificationHost extends StatefulWidget {
  final VoidCallback onEmpty;

  const AppNotificationHost({
    required this.onEmpty,
    super.key,
  });

  @override
  State<AppNotificationHost> createState() => AppNotificationHostState();
}

class AppNotificationHostState extends State<AppNotificationHost> {
  final List<AppNotificationItemData> _items = [];
  final Map<String, GlobalKey<_NotificationItemWidgetState>> _itemKeys = {};

  void addItem(AppNotificationItemData item) {
    setState(() {
      // Keep up to 3 notifications visible at a time to prevent screen clutter
      if (_items.length >= 3) {
        final oldest = _items.first;
        _itemKeys[oldest.id]?.currentState?.dismiss();
      }
      _items.add(item);
      _itemKeys[item.id] = GlobalKey<_NotificationItemWidgetState>();
    });
  }

  void updateItem(
    String id, {
    String? title,
    String? message,
    AppNotificationType? type,
    IconData? icon,
    Duration? duration,
    String? actionLabel,
    VoidCallback? onAction,
  }) {
    final index = _items.indexWhere((element) => element.id == id);
    if (index != -1) {
      setState(() {
        final existing = _items[index];
        if (title != null) existing.title = title;
        if (message != null) existing.message = message;
        if (type != null) existing.type = type;
        if (icon != null) existing.icon = icon;
        if (duration != null) existing.duration = duration;
        if (actionLabel != null) existing.actionLabel = actionLabel;
        if (onAction != null) existing.onAction = onAction;
      });
      _itemKeys[id]?.currentState?.rebuild();
    }
  }

  void dismissItem(String id) {
    final key = _itemKeys[id];
    if (key?.currentState != null) {
      key!.currentState!.dismiss();
    } else {
      _removeItemImmediate(id);
    }
  }

  void dismissAll() {
    for (final key in _itemKeys.values) {
      key.currentState?.dismiss();
    }
  }

  void _removeItemImmediate(String id) {
    setState(() {
      _items.removeWhere((item) => item.id == id);
      _itemKeys.remove(id);
    });
    if (_items.isEmpty) {
      widget.onEmpty();
    }
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top + 12;

    return Positioned(
      top: topPadding,
      left: 0,
      right: 0,
      child: Material(
        type: MaterialType.transparency,
        child: SafeArea(
          top: false,
          child: Align(
            alignment: Alignment.topCenter,
            child: ConstrainedBox(
              constraints: const BoxConstraints(maxWidth: 480),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: _items.map((item) {
                  return _NotificationItemWidget(
                    key: _itemKeys[item.id],
                    data: item,
                    onDismissed: () => _removeItemImmediate(item.id),
                  );
                }).toList(),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class _NotificationItemWidget extends StatefulWidget {
  final AppNotificationItemData data;
  final VoidCallback onDismissed;

  const _NotificationItemWidget({
    required this.data,
    required this.onDismissed,
    super.key,
  });

  @override
  State<_NotificationItemWidget> createState() =>
      _NotificationItemWidgetState();
}

class _NotificationItemWidgetState extends State<_NotificationItemWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  late final Animation<double> _scaleAnimation;
  bool _isExiting = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 340),
      reverseDuration: const Duration(milliseconds: 260),
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -0.45),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutBack,
      reverseCurve: Curves.easeInCubic,
    ));

    _scaleAnimation = Tween<double>(
      begin: 0.92,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeIn,
    ));

    _controller.forward();
  }

  void rebuild() {
    if (mounted) setState(() {});
  }

  void dismiss() {
    if (_isExiting || !mounted) return;
    _isExiting = true;
    _controller.reverse().then((_) {
      if (mounted) {
        widget.onDismissed();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return SlideTransition(
      position: _slideAnimation,
      child: FadeTransition(
        opacity: _fadeAnimation,
        child: ScaleTransition(
          scale: _scaleAnimation,
          child: AppNotificationCard(
            key: ValueKey(
              '${widget.data.id}_${widget.data.type}_${widget.data.message}',
            ),
            title: widget.data.title,
            message: widget.data.message,
            type: widget.data.type,
            icon: widget.data.icon,
            customIcon: widget.data.customIcon,
            actionLabel: widget.data.actionLabel,
            onAction: widget.data.onAction,
            onDismiss: dismiss,
            duration: widget.data.duration,
            showProgressBar: widget.data.showProgressBar,
            dismissible: widget.data.dismissible,
          ),
        ),
      ),
    );
  }
}
