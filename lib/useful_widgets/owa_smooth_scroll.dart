import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';

typedef OWASmoothScrollBuilder =
    Widget Function(
      BuildContext context,
      ScrollController controller,
      ScrollPhysics physics,
      bool usesSmoothScroll,
    );

class OWASmoothScroll extends StatefulWidget {
  const OWASmoothScroll({
    super.key,
    required this.builder,
    this.controller,
    this.scrollSpeed = 1.18,
    this.scrollAnimationLength = 220,
    this.curve = Curves.easeOutQuart,
  });

  final OWASmoothScrollBuilder builder;
  final ScrollController? controller;
  final double scrollSpeed;
  final int scrollAnimationLength;
  final Curve curve;

  static bool isDesktopWebPlatform() {
    if (!kIsWeb) return false;

    switch (defaultTargetPlatform) {
      case TargetPlatform.macOS:
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return true;
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  static bool shouldUseCustomSmoothScroll({required bool isDesktopLayout}) {
    if (!kIsWeb || !isDesktopLayout) return false;

    switch (defaultTargetPlatform) {
      case TargetPlatform.windows:
      case TargetPlatform.linux:
        return true;
      case TargetPlatform.macOS:
      case TargetPlatform.android:
      case TargetPlatform.iOS:
      case TargetPlatform.fuchsia:
        return false;
    }
  }

  static ScrollPhysics physicsFor({required bool isDesktopLayout}) {
    if (shouldUseCustomSmoothScroll(isDesktopLayout: isDesktopLayout)) {
      return const NeverScrollableScrollPhysics();
    }

    if (!isDesktopLayout) {
      return const BouncingScrollPhysics(
        parent: AlwaysScrollableScrollPhysics(),
      );
    }

    if (kIsWeb) {
      return const ClampingScrollPhysics();
    }

    switch (defaultTargetPlatform) {
      case TargetPlatform.iOS:
      case TargetPlatform.macOS:
        return const BouncingScrollPhysics(
          parent: AlwaysScrollableScrollPhysics(),
        );
      case TargetPlatform.android:
      case TargetPlatform.fuchsia:
      case TargetPlatform.linux:
      case TargetPlatform.windows:
        return const ClampingScrollPhysics();
    }
  }

  @override
  State<OWASmoothScroll> createState() => _OWASmoothScrollState();
}

class _OWASmoothScrollState extends State<OWASmoothScroll>
    with SingleTickerProviderStateMixin {
  late final ScrollController _internalController;
  late final Ticker _ticker;
  double _currentOffset = 0.0;
  double _targetOffset = 0.0;
  Duration? _lastElapsed;

  ScrollController get _controller => widget.controller ?? _internalController;
  bool get _ownsController => widget.controller == null;
  bool get _isWindowsDesktopWeb =>
      defaultTargetPlatform == TargetPlatform.windows;
  double get _effectiveScrollSpeed =>
      _isWindowsDesktopWeb ? widget.scrollSpeed * 1.08 : widget.scrollSpeed;
  int get _effectiveAnimationLength => _isWindowsDesktopWeb
      ? (widget.scrollAnimationLength * 1.12).round()
      : widget.scrollAnimationLength;

  @override
  void initState() {
    super.initState();
    _internalController = ScrollController();
    _ticker = createTicker(_tickSmoothScroll);
    _controller.addListener(_syncOffsetsFromController);
  }

  @override
  void didUpdateWidget(covariant OWASmoothScroll oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.controller != widget.controller) {
      (oldWidget.controller ?? _internalController).removeListener(
        _syncOffsetsFromController,
      );
      _controller.addListener(_syncOffsetsFromController);
      _syncOffsetsFromController();
    }
  }

  @override
  void dispose() {
    _ticker.dispose();
    _controller.removeListener(_syncOffsetsFromController);
    if (_ownsController) {
      _internalController.dispose();
    }
    super.dispose();
  }

  void _syncOffsetsFromController() {
    if (_ticker.isActive || !_controller.hasClients) return;
    _currentOffset = _controller.offset;
    _targetOffset = _controller.offset;
  }

  void _handlePointerSignal(PointerSignalEvent event) {
    if (event is! PointerScrollEvent || !_controller.hasClients) return;

    final position = _controller.position;
    final minScroll = position.minScrollExtent;
    final maxScroll = position.maxScrollExtent;

    _targetOffset =
        (_targetOffset + (event.scrollDelta.dy * _effectiveScrollSpeed))
        .clamp(minScroll, maxScroll)
        .toDouble();

    if (!_ticker.isActive) {
      _currentOffset = _controller.offset;
      _lastElapsed = null;
      _ticker.start();
    }
  }

  void _tickSmoothScroll(Duration elapsed) {
    if (!_controller.hasClients) {
      _ticker.stop();
      _lastElapsed = null;
      return;
    }

    final deltaMs =
        _lastElapsed == null
            ? 16.0
            : (elapsed - _lastElapsed!).inMicroseconds / 1000.0;
    _lastElapsed = elapsed;

    final normalizedStep = (deltaMs / _effectiveAnimationLength).clamp(
      0.0,
      1.0,
    );
    final smoothing = widget.curve.transform(normalizedStep);
    final distance = _targetOffset - _currentOffset;

    _currentOffset += distance * smoothing;

    if (distance.abs() <= 0.6) {
      _currentOffset = _targetOffset;
      _controller.jumpTo(_targetOffset);
      _ticker.stop();
      _lastElapsed = null;
      return;
    }

    _controller.jumpTo(_currentOffset);
  }

  @override
  Widget build(BuildContext context) {
    final isDesktopLayout = MediaQuery.of(context).size.width >= 900;
    final usesSmoothScroll = OWASmoothScroll.shouldUseCustomSmoothScroll(
      isDesktopLayout: isDesktopLayout,
    );
    final physics = OWASmoothScroll.physicsFor(
      isDesktopLayout: isDesktopLayout,
    );

    final child = widget.builder(
      context,
      _controller,
      physics,
      usesSmoothScroll,
    );

    if (!usesSmoothScroll) {
      return child;
    }

    return Listener(
      onPointerSignal: _handlePointerSignal,
      child: child,
    );
  }
}
