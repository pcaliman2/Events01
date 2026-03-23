import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:owa_flutter/useful/colors.dart' as owa_colors;

class OWAIntroGate extends StatefulWidget {
  const OWAIntroGate({
    super.key,
    required this.child,
    required this.enabled,
  });

  final Widget child;
  final bool enabled;

  @override
  State<OWAIntroGate> createState() => _OWAIntroGateState();
}

class OWAIntroRevealScope extends InheritedNotifier<ValueNotifier<double>> {
  const OWAIntroRevealScope({
    super.key,
    required ValueNotifier<double> progress,
    required super.child,
  }) : super(notifier: progress);

  static double progressOf(BuildContext context) {
    final scope =
        context.dependOnInheritedWidgetOfExactType<OWAIntroRevealScope>();
    return scope?.notifier?.value ?? 1.0;
  }
}

class _OWAIntroGateState extends State<OWAIntroGate>
    with SingleTickerProviderStateMixin {
  static const Duration _timelineDuration = Duration(milliseconds: 7000);
  static const AssetImage _introBackgroundImage = AssetImage(
    'assets/follow_us.png',
  );
  static const AssetImage _heroBackgroundImage = AssetImage(
    'assets/discover_4.jpg',
  );

  late final AnimationController _controller;
  late final ValueNotifier<double> _childRevealProgress;
  bool _introCompleted = false;
  bool _introReady = false;

  @override
  void initState() {
    super.initState();
    _introCompleted = !widget.enabled;
    _controller = AnimationController(vsync: this, duration: _timelineDuration);
    _childRevealProgress = ValueNotifier<double>(widget.enabled ? 0.0 : 1.0);

    if (widget.enabled) {
      _controller.addListener(_syncChildRevealProgress);
      _controller.addStatusListener((status) {
        if (status == AnimationStatus.completed && mounted) {
          setState(() {
            _introCompleted = true;
          });
        }
      });
      WidgetsBinding.instance.addPostFrameCallback((_) async {
        if (!mounted) return;
        await _prepareIntro();
      });
    } else {
      _introReady = true;
    }
  }

  double _computeChildReveal() {
    if (!widget.enabled || !_introReady) return 1.0;
    return Curves.easeOutQuart.transform(
      ((_controller.value - 0.76) / 0.24).clamp(0.0, 1.0),
    );
  }

  void _syncChildRevealProgress() {
    final nextValue = _computeChildReveal();
    if (_childRevealProgress.value != nextValue) {
      _childRevealProgress.value = nextValue;
    }
  }

  Future<void> _prepareIntro() async {
    try {
      await precacheImage(_introBackgroundImage, context);
      await precacheImage(_heroBackgroundImage, context);
    } catch (_) {
      // Keep the intro usable even if asset warmup fails.
    }

    if (!mounted) return;
    setState(() {
      _introReady = true;
    });
    _syncChildRevealProgress();
    _controller.forward();
  }

  @override
  void dispose() {
    _childRevealProgress.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final childReveal = _computeChildReveal();
    final childVeilFade =
        widget.enabled && _introReady
            ? Curves.easeInOutCubic.transform(
              ((_controller.value - 0.84) / 0.16).clamp(0.0, 1.0),
            )
            : 1.0;
    final childScale = lerpDouble(1.02, 1.0, childReveal)!;
    final childTranslateY = lerpDouble(28, 0, childReveal)!;
    final childBlur = lerpDouble(14, 0, childReveal)!;
    final childVeilOpacity = lerpDouble(0.68, 0.0, childVeilFade)!;

    return Stack(
      fit: StackFit.expand,
      children: [
        OWAIntroRevealScope(
          progress: _childRevealProgress,
          child: Opacity(
            opacity: childReveal,
            child: ImageFiltered(
              imageFilter: ImageFilter.blur(
                sigmaX: childBlur,
                sigmaY: childBlur,
              ),
              child: Transform.translate(
                offset: Offset(0, childTranslateY),
                child: Transform.scale(
                  scale: childScale,
                  alignment: Alignment.center,
                  child: widget.child,
                ),
              ),
            ),
          ),
        ),
        if (childVeilOpacity > 0)
          Positioned.fill(
            child: IgnorePointer(
              child: ColoredBox(
                color: owa_colors.backgroundColor.withValues(
                  alpha: childVeilOpacity,
                ),
              ),
            ),
          ),
        if (!_introCompleted)
          Positioned.fill(
            child: IgnorePointer(
              ignoring: true,
              child:
                  _introReady
                      ? AnimatedBuilder(
                        animation: _controller,
                        builder: (context, _) {
                          return _OWAIntroOverlay(
                            progress: _controller.value,
                            backgroundImage: _introBackgroundImage,
                          );
                        },
                      )
                      : const ColoredBox(color: owa_colors.backgroundColor),
            ),
          ),
      ],
    );
  }
}

class _OWAIntroOverlay extends StatelessWidget {
  const _OWAIntroOverlay({
    required this.progress,
    required this.backgroundImage,
  });

  final double progress;
  final ImageProvider backgroundImage;

  static const String _tagline = 'INTEGRATIVE WELLBEING, ALL IN ONE PLACE';
  static const double _timelineMs = 7000;

  double _segment(
    double startMs,
    double endMs, {
    Curve curve = Curves.linear,
  }) {
    final start = startMs / _timelineMs;
    final end = endMs / _timelineMs;
    if (progress <= start) return 0;
    if (progress >= end) return 1;
    return curve.transform((progress - start) / (end - start));
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final isDesktop = size.width >= 900;

    final logoIn = _segment(0, 1500, curve: Curves.easeOutCubic);
    final logoOut = _segment(3050, 3800, curve: Curves.easeInOutCubic);
    final taglineIn = _segment(3950, 5100, curve: Curves.easeOutCubic);
    final overlayOut = _segment(5600, 7000, curve: Curves.easeInOutCubic);

    final overlayOpacity = 1 - overlayOut;
    final logoOpacity = logoIn * (1 - logoOut);
    final logoScale = lerpDouble(0.95, 1.0, logoIn)!;
    final taglineOpacity = taglineIn;
    final backgroundVeilOpacity =
        lerpDouble(0.36, 0.58, taglineOpacity.clamp(0, 1).toDouble())!;

    final logoWidth = isDesktop ? size.width * 0.30 : size.width * 0.60;
    final taglineFontSize = isDesktop ? 32.0 : 19.0;
    final taglineLetterSpacing = isDesktop ? 0.0 : 19 * 0.12;

    return Opacity(
      opacity: overlayOpacity.clamp(0, 1),
      child: ColoredBox(
        color: owa_colors.backgroundColor,
        child: Stack(
          fit: StackFit.expand,
          children: [
            Transform.scale(
              scale: 1.06,
              child: Image(
                image: backgroundImage,
                fit: BoxFit.cover,
                alignment: Alignment.center,
              ),
            ),
            ColoredBox(
              color: owa_colors.backgroundColor.withValues(
                alpha: backgroundVeilOpacity,
              ),
            ),
            Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: isDesktop ? 40 : 24),
                child: SizedBox(
                  width: double.infinity,
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Padding(
                        padding: EdgeInsets.symmetric(
                          vertical: isDesktop ? 28 : 20,
                        ),
                        child: Center(
                          child:
                              taglineOpacity > 0.001
                                  ? Opacity(
                                    opacity: taglineOpacity.clamp(0, 1),
                                    child: Transform.translate(
                                      offset: Offset(
                                        0,
                                        (1 - taglineOpacity) * 10,
                                      ),
                                      child: Text(
                                        _tagline,
                                        textAlign: TextAlign.center,
                                        style: TextStyle(
                                          fontFamily:
                                              isDesktop
                                                  ? 'Times Now'
                                                  : 'Basier Square Mono',
                                          fontSize: taglineFontSize,
                                          height: 1.51,
                                          fontWeight: FontWeight.w400,
                                          letterSpacing: taglineLetterSpacing,
                                          decoration: TextDecoration.none,
                                          decorationColor: Colors.transparent,
                                          decorationThickness: 0,
                                          color: const Color(
                                            0xFF120705,
                                          ).withValues(alpha: 0.9),
                                        ),
                                      ),
                                    ),
                                  )
                                  : Opacity(
                                    opacity: logoOpacity.clamp(0, 1),
                                    child: Transform.scale(
                                      scale: logoScale,
                                      child: SvgPicture.asset(
                                        'assets/OWA_Logo.svg',
                                        width: logoWidth,
                                        fit: BoxFit.fitWidth,
                                        colorFilter: const ColorFilter.mode(
                                          Color(0xFF120705),
                                          BlendMode.srcIn,
                                        ),
                                      ),
                                    ),
                                  ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
