import 'package:owa_flutter/useful_widgets/blended_text.dart';
import 'package:owa_flutter/useful_widgets/inverted_underline.dart';
import 'package:flutter/material.dart';

class PreciseAnimatedNavItem extends StatefulWidget {
  final String text;
  final Color textColor;
  final bool isActive;
  final bool useInvertedText;

  const PreciseAnimatedNavItem({
    super.key,
    required this.text,
    this.textColor = Colors.white,
    this.isActive = false,
    this.useInvertedText = false,
  });

  @override
  State<PreciseAnimatedNavItem> createState() => PreciseAnimatedNavItemState();
}

class PreciseAnimatedNavItemState extends State<PreciseAnimatedNavItem>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _scaleAnimation;
  bool _isHovered = false;
  late TextStyle _baseStyle;
  late TextStyle _hoverStyle;
  double? _baseTextWidth;
  double? _hoverTextWidth;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _scaleAnimation = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: _controller, curve: Curves.easeOutCubic));

    _configureStylesAndMetrics();

    if (widget.isActive) {
      _controller.value = 1.0;
    }
  }

  @override
  void didUpdateWidget(PreciseAnimatedNavItem oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.text != oldWidget.text || widget.textColor != oldWidget.textColor) {
      _configureStylesAndMetrics();
    }
    if (widget.isActive != oldWidget.isActive) {
      if (widget.isActive) {
        _controller.forward();
      } else if (!_isHovered) {
        _controller.reverse();
      }
    }
  }

  void _configureStylesAndMetrics() {
    _baseStyle = TextStyle(
      fontFamily: 'Inter',
      fontWeight: FontWeight.w400,
      fontSize: 10,
      letterSpacing: 0.0,
      height: .95,
      fontStyle: FontStyle.normal,
      color: widget.textColor,
      decoration: TextDecoration.none,
    );
    _hoverStyle = _baseStyle.copyWith(
      fontWeight: FontWeight.w500,
      fontSize: 9.9,
    );
    _baseTextWidth = _measureTextWidth(_baseStyle);
    _hoverTextWidth = _measureTextWidth(_hoverStyle);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onEnter() {
    if (!widget.isActive) {
      setState(() {
        _isHovered = true;
      });
      _controller.forward();
    }
  }

  void _onExit() {
    if (!widget.isActive) {
      setState(() {
        _isHovered = false;
      });
      _controller.reverse();
    }
  }

  @override
  Widget build(BuildContext context) {
    final style = (_isHovered || widget.isActive) ? _hoverStyle : _baseStyle;
    final textWidth =
        (_isHovered || widget.isActive)
            ? (_hoverTextWidth ?? _baseTextWidth ?? 0)
            : (_baseTextWidth ?? _hoverTextWidth ?? 0);

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => _onEnter(),
      onExit: (_) => _onExit(),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            children: [
              Expanded(
                child: AnimatedDefaultTextStyle(
                  duration: const Duration(milliseconds: 180),
                  curve: Curves.easeOutCubic,
                  style: style,
                  child:
                      widget.useInvertedText
                          ? RepaintBoundary(
                            child: BlendedText(
                              widget.text,
                              style: style,
                              textAlign: TextAlign.start,
                            ),
                          )
                          : Text(widget.text, style: style),
                ),
              ),
            ],
          ),

          const SizedBox(height: 4),
          Align(
            alignment: Alignment.centerLeft,
            child: AnimatedBuilder(
              animation: _scaleAnimation,
              builder: (context, child) {
                return Transform(
                  alignment:
                      !(_controller.status == AnimationStatus.reverse)
                          ? Alignment.centerLeft
                          : Alignment.centerRight,
                  transform:
                      Matrix4.identity()..scale(_scaleAnimation.value, 1.0),
                  child: child,
                );
              },
              child:
                  widget.useInvertedText
                      ? RepaintBoundary(
                        child: InvertedUnderline(
                          width: textWidth,
                          height: widget.isActive ? 1.0 : 0.7,
                        ),
                      )
                      : Container(
                        width: textWidth,
                        height: widget.isActive ? 1.0 : 0.7,
                        decoration: BoxDecoration(
                          color: widget.textColor,
                          borderRadius: const BorderRadius.all(
                            Radius.circular(1),
                          ),
                        ),
                      ),
            ),
          ),
        ],
      ),
    );
  }

  double _measureTextWidth(TextStyle style) {
    final TextPainter textPainter = TextPainter(
      text: TextSpan(text: widget.text, style: style),
      maxLines: 1,
      textDirection: TextDirection.ltr,
    );
    textPainter.layout();
    return textPainter.width;
  }
}
