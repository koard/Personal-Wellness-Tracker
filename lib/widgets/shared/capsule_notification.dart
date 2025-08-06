import 'package:flutter/material.dart';

enum NotificationType {
  success,
  error,
  warning,
  info,
}

class CapsuleNotification extends StatelessWidget {
  final String message;
  final NotificationType type;
  final IconData? icon;
  final Duration duration;
  final VoidCallback? onTap;

  const CapsuleNotification({
    super.key,
    required this.message,
    this.type = NotificationType.info,
    this.icon,
    this.duration = const Duration(seconds: 3),
    this.onTap,
  });

  Color get _backgroundColor {
    switch (type) {
      case NotificationType.success:
        return const Color(0xFF10B981); // Green
      case NotificationType.error:
        return const Color(0x00ef4444); // Red
      case NotificationType.warning:
        return const Color(0xFFF59E0B); // Amber
      case NotificationType.info:
        return const Color(0xFF3B82F6); // Blue
    }
  }

  IconData get _defaultIcon {
    switch (type) {
      case NotificationType.success:
        return Icons.check_circle;
      case NotificationType.error:
        return Icons.error;
      case NotificationType.warning:
        return Icons.warning;
      case NotificationType.info:
        return Icons.info;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      color: Colors.transparent,
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: _backgroundColor,
          borderRadius: BorderRadius.circular(25),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.15),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: InkWell(
          onTap: onTap,
          borderRadius: BorderRadius.circular(25),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(
                icon ?? _defaultIcon,
                color: Colors.white,
                size: 20,
              ),
              const SizedBox(width: 12),
              Flexible(
                child: Text(
                  message,
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class CapsuleNotificationHelper {
  static OverlayEntry? _currentOverlay;

  static void show(
    BuildContext context, {
    required String message,
    NotificationType type = NotificationType.info,
    IconData? icon,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    // Remove any existing notification
    hide();

    final overlay = Overlay.of(context);
    final notification = CapsuleNotification(
      message: message,
      type: type,
      icon: icon,
      duration: duration,
      onTap: onTap,
    );

    _currentOverlay = OverlayEntry(
      builder: (context) => _CapsuleNotificationOverlay(
        notification: notification,
        duration: duration,
        onDismiss: hide,
      ),
    );

    overlay.insert(_currentOverlay!);
  }

  static void hide() {
    _currentOverlay?.remove();
    _currentOverlay = null;
  }

  // Convenience methods for different types
  static void showSuccess(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.success,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showError(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 4),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.error,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showWarning(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.warning,
      duration: duration,
      onTap: onTap,
    );
  }

  static void showInfo(
    BuildContext context, {
    required String message,
    Duration duration = const Duration(seconds: 3),
    VoidCallback? onTap,
  }) {
    show(
      context,
      message: message,
      type: NotificationType.info,
      duration: duration,
      onTap: onTap,
    );
  }
}

class _CapsuleNotificationOverlay extends StatefulWidget {
  final CapsuleNotification notification;
  final Duration duration;
  final VoidCallback onDismiss;

  const _CapsuleNotificationOverlay({
    required this.notification,
    required this.duration,
    required this.onDismiss,
  });

  @override
  State<_CapsuleNotificationOverlay> createState() => _CapsuleNotificationOverlayState();
}

class _CapsuleNotificationOverlayState extends State<_CapsuleNotificationOverlay>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Offset> _slideAnimation;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    
    _animationController = AnimationController(
      duration: const Duration(milliseconds: 400),
      reverseDuration: const Duration(milliseconds: 300),
      vsync: this,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, -1),
      end: const Offset(0, 0),
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.elasticOut,
      reverseCurve: Curves.easeInBack,
    ));

    _fadeAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(
      parent: _animationController,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    ));

    // Start the animation
    _animationController.forward();

    // Auto dismiss after duration
    Future.delayed(widget.duration, () {
      if (mounted) {
        _dismiss();
      }
    });
  }

  void _dismiss() async {
    await _animationController.reverse();
    widget.onDismiss();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MediaQuery.of(context).padding.top + 10,
      left: 0,
      right: 0,
      child: SlideTransition(
        position: _slideAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: GestureDetector(
            onTap: _dismiss,
            onPanUpdate: (details) {
              // Allow swipe up to dismiss
              if (details.delta.dy < -5) {
                _dismiss();
              }
            },
            child: widget.notification,
          ),
        ),
      ),
    );
  }
}
