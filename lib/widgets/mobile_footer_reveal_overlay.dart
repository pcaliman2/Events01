import 'dart:math' as math;

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:owa_flutter/widgets/mobile_footer.dart';

class OWAMobileFooterRevealOverlay extends StatefulWidget {
  const OWAMobileFooterRevealOverlay({
    super.key,
    required this.controller,
    required this.footerKey,
    required this.footerHeight,
  });

  final ScrollController controller;
  final GlobalKey footerKey;
  final double footerHeight;

  @override
  State<OWAMobileFooterRevealOverlay> createState() =>
      _OWAMobileFooterRevealOverlayState();
}

class _OWAMobileFooterRevealOverlayState
    extends State<OWAMobileFooterRevealOverlay> {
  int? _activePointer;
  double? _initialTouchY;
  double? _lastTouchY;
  bool _isDragActive = false;

  double _trackOffset(BuildContext context) {
    if (!widget.controller.hasClients || widget.footerHeight <= 0) return 0.0;

    final position = widget.controller.position;
    if (!position.hasContentDimensions) return 0.0;

    final trackStart = (position.maxScrollExtent - widget.footerHeight).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    );

    return (position.pixels - trackStart).clamp(0.0, widget.footerHeight);
  }

  double _revealProgress(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final revealDistance = math.min(viewportHeight, widget.footerHeight);
    if (revealDistance <= 0) return 0.0;
    return (_trackOffset(context) / revealDistance).clamp(0.0, 1.0);
  }

  double _footerScrollOffset(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final revealDistance = math.min(viewportHeight, widget.footerHeight);
    final footerScrollRange = math.max(
      widget.footerHeight - viewportHeight,
      0.0,
    );
    final rawOffset = _trackOffset(context) - revealDistance;
    return rawOffset.clamp(0.0, footerScrollRange);
  }

  void _forwardPointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !widget.controller.hasClients) return;

    final position = widget.controller.position;
    if (!position.hasContentDimensions) return;

    final target = (position.pixels + event.scrollDelta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    ).toDouble();

    if ((target - position.pixels).abs() < 0.1) return;
    widget.controller.jumpTo(target);
  }

  void _handlePointerDown(PointerDownEvent event) {
    if (event.kind != PointerDeviceKind.touch) return;
    _activePointer = event.pointer;
    _initialTouchY = event.position.dy;
    _lastTouchY = event.position.dy;
    _isDragActive = false;
  }

  void _handlePointerMove(PointerMoveEvent event) {
    if (event.kind != PointerDeviceKind.touch) return;
    if (_activePointer != event.pointer || !widget.controller.hasClients) return;

    final initialTouchY = _initialTouchY;
    final lastTouchY = _lastTouchY;
    if (initialTouchY == null || lastTouchY == null) return;

    final dragDistance = event.position.dy - initialTouchY;
    if (!_isDragActive && dragDistance.abs() < 6) return;
    _isDragActive = true;

    final position = widget.controller.position;
    if (!position.hasContentDimensions) return;

    final deltaY = event.position.dy - lastTouchY;
    _lastTouchY = event.position.dy;

    if (deltaY.abs() < 0.1) return;

    final target = (position.pixels - deltaY).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    ).toDouble();

    if ((target - position.pixels).abs() < 0.1) return;
    widget.controller.jumpTo(target);
  }

  void _handlePointerEnd(PointerEvent event) {
    if (_activePointer != event.pointer) return;
    _activePointer = null;
    _initialTouchY = null;
    _lastTouchY = null;
    _isDragActive = false;
  }

  @override
  Widget build(BuildContext context) {
    final viewportHeight = MediaQuery.sizeOf(context).height;
    final visibleWindowHeight = math.min(viewportHeight, widget.footerHeight);

    return Positioned(
      left: 0,
      right: 0,
      bottom: 0,
      child: AnimatedBuilder(
        animation: widget.controller,
        child: RepaintBoundary(child: OWAMobileFooter(key: widget.footerKey)),
        builder: (context, child) {
          final reveal = Curves.easeInOutCubic.transform(
            _revealProgress(context),
          );
          final trackOffset = _trackOffset(context);

          if (trackOffset <= 0.001) {
            return const SizedBox.shrink();
          }

          final footerScrollOffset = _footerScrollOffset(context);
          final revealLift =
              math.min(visibleWindowHeight * 0.06, 28.0) * (1 - reveal);

          return Listener(
            behavior: HitTestBehavior.translucent,
            onPointerDown: _handlePointerDown,
            onPointerMove: _handlePointerMove,
            onPointerUp: _handlePointerEnd,
            onPointerCancel: _handlePointerEnd,
            onPointerSignal: _forwardPointerSignal,
            child: Transform.translate(
              offset: Offset(0, revealLift),
              child: ClipRect(
                child: Align(
                  alignment: Alignment.bottomCenter,
                  heightFactor: reveal,
                  child: SizedBox(
                    height: visibleWindowHeight,
                    width: double.infinity,
                    child: ClipRect(
                      child: OverflowBox(
                        alignment: Alignment.topCenter,
                        minHeight: 0,
                        maxHeight: double.infinity,
                        child: Transform.translate(
                          offset: Offset(0, -footerScrollOffset),
                          child: child,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
