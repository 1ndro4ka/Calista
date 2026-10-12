import 'dart:async';
import 'package:flutter/material.dart';
import '../theme/app_colors.dart';
import '../theme/app_radius.dart';
import '../theme/app_typography.dart';

/// Top-layer banner notification rendered in the root overlay.
/// Guarantees that neither bottom sheets, dialogs, keyboards, nor bottom navigation
/// bars can overlap or hide error / status messages.
class AppTopNotification {
  static OverlayEntry? _activeEntry;
  static Timer? _activeTimer;
  static _TopNotificationWidgetState? _activeWidgetState;

  static void show(
    BuildContext context, {
    required String message,
    bool isError = false,
    Duration duration = const Duration(seconds: 4),
    GlobalKey<NavigatorState>? rootNavKey,
  }) {
    // 1. Immediately dismiss any currently active toast
    dismiss();

    // 2. Locate the root overlay so this sits above all modal routes and bottom sheets
    final overlay = Overlay.maybeOf(context, rootOverlay: true) ??
        rootNavKey?.currentState?.overlay;

    if (overlay == null) {
      // Fallback for edge cases where overlay is unmounted
      final messenger = ScaffoldMessenger.maybeOf(context);
      messenger?.clearSnackBars();
      messenger?.showSnackBar(
        SnackBar(
          content: Text(
            message,
            style: AppTypography.bodyMedium.copyWith(color: AppColors.textInverse),
          ),
          backgroundColor: isError ? AppColors.error : AppColors.primary,
          behavior: SnackBarBehavior.floating,
          shape: const RoundedRectangleBorder(borderRadius: AppRadius.radiusMd),
          duration: duration,
          margin: const EdgeInsets.all(16.0),
        ),
      );
      return;
    }

    late final OverlayEntry entry;
    entry = OverlayEntry(
      builder: (ctx) => _TopNotificationWidget(
        key: ValueKey(entry.hashCode),
        message: message,
        isError: isError,
        onDismiss: () => _removeEntry(entry),
        onStateCreated: (state) => _activeWidgetState = state,
      ),
    );

    _activeEntry = entry;
    overlay.insert(entry);

    _activeTimer = Timer(duration, () {
      if (_activeEntry == entry) {
        _activeWidgetState?.handleDismiss();
      }
    });
  }

  static void dismiss() {
    _activeTimer?.cancel();
    _activeTimer = null;
    if (_activeWidgetState != null) {
      _activeWidgetState?.handleDismiss();
      _activeWidgetState = null;
    } else if (_activeEntry != null) {
      try {
        _activeEntry?.remove();
      } catch (_) {}
      _activeEntry = null;
    }
  }

  static void _removeEntry(OverlayEntry entry) {
    if (_activeEntry == entry) {
      _activeTimer?.cancel();
      _activeTimer = null;
      _activeEntry = null;
      _activeWidgetState = null;
      try {
        entry.remove();
      } catch (_) {}
    }
  }
}

class _TopNotificationWidget extends StatefulWidget {
  final String message;
  final bool isError;
  final VoidCallback onDismiss;
  final ValueChanged<_TopNotificationWidgetState> onStateCreated;

  const _TopNotificationWidget({
    super.key,
    required this.message,
    required this.isError,
    required this.onDismiss,
    required this.onStateCreated,
  });

  @override
  State<_TopNotificationWidget> createState() => _TopNotificationWidgetState();
}

class _TopNotificationWidgetState extends State<_TopNotificationWidget>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _offsetAnimation;
  late final Animation<double> _fadeAnimation;
  bool _isDismissing = false;

  @override
  void initState() {
    super.initState();
    widget.onStateCreated(this);

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 260),
    );

    _offsetAnimation = Tween<Offset>(
      begin: const Offset(0.0, -1.0),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
      reverseCurve: Curves.easeInCubic,
    ));

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
      reverseCurve: Curves.easeIn,
    );

    _controller.forward();
  }

  Future<void> handleDismiss() async {
    if (_isDismissing) return;
    _isDismissing = true;
    try {
      await _controller.reverse();
    } catch (_) {}
    if (mounted) {
      widget.onDismiss();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final topPadding = mediaQuery.padding.top;

    return Positioned(
      top: topPadding + 10.0,
      left: 16.0,
      right: 16.0,
      child: SlideTransition(
        position: _offsetAnimation,
        child: FadeTransition(
          opacity: _fadeAnimation,
          child: Material(
            type: MaterialType.transparency,
            child: GestureDetector(
              onTap: handleDismiss,
              onVerticalDragUpdate: (details) {
                if (details.primaryDelta != null && details.primaryDelta! < -4) {
                  handleDismiss();
                }
              },
              child: Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                decoration: BoxDecoration(
                  color: widget.isError ? AppColors.error : AppColors.primary,
                  borderRadius: AppRadius.radiusMd,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.black.withValues(alpha: 0.20),
                      blurRadius: 16.0,
                      offset: const Offset(0, 6),
                    ),
                  ],
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Icon(
                      widget.isError
                          ? Icons.error_outline_rounded
                          : Icons.check_circle_outline_rounded,
                      color: Colors.white,
                      size: 22.0,
                    ),
                    const SizedBox(width: 12.0),
                    Expanded(
                      child: Text(
                        widget.message,
                        style: AppTypography.bodyMedium.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w500,
                        ),
                        maxLines: 4,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                    const SizedBox(width: 8.0),
                    InkWell(
                      borderRadius: BorderRadius.circular(12.0),
                      onTap: handleDismiss,
                      child: const Padding(
                        padding: EdgeInsets.all(4.0),
                        child: Icon(
                          Icons.close_rounded,
                          color: Colors.white70,
                          size: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
