// Flutter
import 'package:flutter/material.dart';

class OverlayManager {
  static final OverlayManager _instance = OverlayManager._internal();
  factory OverlayManager() => _instance;
  OverlayManager._internal();

  final Map<String, _OverlayWrapper> _overlays = {};
  ModalRoute? _blockingRoute;

  void show({
    required BuildContext context,
    required String overlayId,
    required Widget child,
    OverlayPosition position = const OverlayPosition.center(),
    bool dismissible = true,
    Duration? duration,
    Color? barrierColor,
    bool barrierDismissible = true,
    VoidCallback? onDismiss,
    bool blockNavigation = false, // New parameter to block all navigation
  }) {
    hide(overlayId);
    final overlayState = _getOverlayState(context);
    // Create a blocking route if needed
    if (blockNavigation) {
      _blockingRoute = ModalRoute.of(context);
      _blockingRoute?.addScopedWillPopCallback(() async {
        if (!dismissible) return false;
        onDismiss?.call();
        hide(overlayId);
        return true;
      });
    }

    final entry = OverlayEntry(
      builder: (context) {
        Widget overlayChild = Positioned(
          top: position.top,
          left: position.left,
          right: position.right,
          bottom: position.bottom,
          child: child,
        );
        if (position.animation != null) {
          overlayChild = AnimatedBuilder(
            animation: position.animation!,
            builder: (context, child) {
              return Transform.translate(
                offset: position.animationOffset?.call(position.animation!.value) ?? Offset.zero,
                child: child,
              );
            },
            child: overlayChild,
          );
        }

        overlayChild = WillPopScope(
          onWillPop: () async {
            if (!dismissible) return false;
            onDismiss?.call();
            hide(overlayId);
            return true;
          },
          child: overlayChild,
        );

        if (barrierColor != null) {
          return Stack(
            children: [
              if (barrierDismissible)
                GestureDetector(
                  onTap: () {
                    if (!dismissible) return;
                    onDismiss?.call();
                    hide(overlayId);
                  },
                  child: Container(color: barrierColor),
                ),
              overlayChild,
            ],
          );
        }

        return overlayChild;
      },
    );

    overlayState.insert(entry);

    if (duration != null) {
      Future.delayed(duration, () => hide(overlayId));
    }

    _overlays[overlayId] = _OverlayWrapper(
      entry: entry,
      dismissible: dismissible,
      onDismiss: onDismiss,
      blockNavigation: blockNavigation,
    );
  }

  OverlayState _getOverlayState(BuildContext context) {
    try {
      // First try to get overlay from the given context
      return Overlay.of(context);
    } catch (e) {
      // If that fails, try to find the nearest overlay
      final navigator = Navigator.of(context, rootNavigator: true);
      return navigator.overlay!;
    }
  }

  void hide(String overlayId) {
    final wrapper = _overlays[overlayId];
    if (wrapper != null) {
      wrapper.entry.remove();
      _overlays.remove(overlayId);

      if (wrapper.blockNavigation) {
        bool hasOtherBlockingOverlays = _overlays.values.any((w) => w.blockNavigation);
        if (!hasOtherBlockingOverlays && _blockingRoute != null) {
          _blockingRoute?.removeScopedWillPopCallback(() async {
            return false;
          });
          _blockingRoute = null;
        }
      }

      wrapper.onDismiss?.call();
    }
  }

  bool isVisible(String overlayId) => _overlays.containsKey(overlayId);

  void updatePosition(String overlayId, OverlayPosition newPosition) {
    final wrapper = _overlays[overlayId];
    if (wrapper != null) {
      wrapper.entry.markNeedsBuild();
    }
  }

  void hideAll() {
    if (_blockingRoute != null) {
      _blockingRoute?.removeScopedWillPopCallback(() async {
        return false;
      });
      _blockingRoute = null;
    }

    for (final wrapper in _overlays.values) {
      wrapper.entry.remove();
      wrapper.onDismiss?.call();
    }
    _overlays.clear();
  }
}

class _OverlayWrapper {
  final OverlayEntry entry;
  final bool dismissible;
  final VoidCallback? onDismiss;
  final bool blockNavigation;

  _OverlayWrapper({
    required this.entry,
    required this.dismissible,
    this.onDismiss,
    this.blockNavigation = false,
  });
}

class OverlayPosition {
  final double? top;
  final double? left;
  final double? right;
  final double? bottom;
  final Alignment? alignment;
  final Animation<double>? animation;
  final Offset Function(double value)? animationOffset;

  const OverlayPosition({
    this.top,
    this.left,
    this.right,
    this.bottom,
    this.alignment,
    this.animation,
    this.animationOffset,
  });

  const OverlayPosition.center() : this(alignment: Alignment.center);

  const OverlayPosition.topCenter() : this(alignment: Alignment.topCenter);

  const OverlayPosition.bottomCenter() : this(alignment: Alignment.bottomCenter);

  const OverlayPosition.topLeft() : this(top: 0, left: 0);

  const OverlayPosition.topRight() : this(top: 0, right: 0);

  const OverlayPosition.bottomLeft() : this(bottom: 0, left: 0);

  const OverlayPosition.bottomRight() : this(bottom: 0, right: 0);

  factory OverlayPosition.animated({
    required AnimationController controller,
    Offset Function(double value)? offsetBuilder,
    double? top,
    double? left,
    double? right,
    double? bottom,
    Alignment? alignment,
  }) {
    return OverlayPosition(
      top: top,
      left: left,
      right: right,
      bottom: bottom,
      alignment: alignment,
      animation: controller,
      animationOffset: offsetBuilder,
    );
  }
}
