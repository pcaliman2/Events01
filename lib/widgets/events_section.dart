import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/widgets/build_separator.dart';
import 'package:owa_flutter/widgets/headline.dart';

class OWAEventsSection extends StatefulWidget {
  const OWAEventsSection({super.key});

  @override
  State<OWAEventsSection> createState() => _OWAEventsSectionState();
}

class _OWAEventsSectionState extends State<OWAEventsSection> {
  bool _isVisible = false;
  final GlobalKey _sectionKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkVisibility();
    });
  }

  void _checkVisibility() {
    if (_isVisible) return;

    final RenderBox? renderBox =
        _sectionKey.currentContext?.findRenderObject() as RenderBox?;

    if (renderBox == null || !renderBox.attached) return;

    final position = renderBox.localToGlobal(Offset.zero);
    final size = renderBox.size;
    final screenHeight = MediaQuery.of(context).size.height;

    final visibleTop = position.dy < screenHeight ? position.dy : screenHeight;
    final visibleBottom =
        position.dy + size.height > 0 ? position.dy + size.height : 0;

    final visibleHeight = visibleBottom - visibleTop;
    final visibilityRatio = visibleHeight / size.height;

    if (visibilityRatio >= 0.2 && !_isVisible) {
      setState(() {
        _isVisible = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> events = [
      {
        'imagePath': 'assets/events1.png',
        'title': 'BOOK YOUR SPOT',
        'date': '06 Jan 2026',
        'description': 'Soundhealing. King Lafa. 8:00 pm\n\$600 MXN PP',
        'precio': '\$600 MXN',
      },
      {
        'imagePath': 'assets/events2.png',
        'title': 'BOOK YOUR SPOT',
        'date': '06 Jan 2026',
        'description': 'Soundhealing. King Lafa. 8:00 pm\n\$600 MXN PP',
        'precio': '\$600 MXN',
      },
      {
        'imagePath': 'assets/events3.png',
        'title': 'BOOK YOUR SPOT',
        'date': '06 Jan 2026',
        'description': 'Soundhealing. King Lafa. 8:00 pm\n\$600 MXN PP',
        'precio': '\$600 MXN',
      },
      {
        'imagePath': 'assets/events4.png',
        'title': 'BOOK YOUR SPOT',
        'date': '06 Jan 2026',
        'description': 'Soundhealing. King Lafa. 8:00 pm\n\$600 MXN PP',
        'precio': '\$600 MXN',
      },
    ];

    return NotificationListener<ScrollNotification>(
      onNotification: (notification) {
        _checkVisibility();
        return false;
      },
      child: Container(
        key: _sectionKey,
        width: double.infinity,
        color: colors.backgroundColor,
        child: Align(
          alignment: Alignment.topCenter,
          child: ConstrainedBox(
            constraints: BoxConstraints(
              maxWidth: SizeConfig.w(1440),
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: SizeConfig.w(42),
                vertical: SizeConfig.h(80),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Headline(
                    child: Text(
                      'Events',
                      style: OWATextStyles.sectionTitle,
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(14)),
                  buildSeparator(),
                  SizedBox(height: SizeConfig.h(45)),
                  SizedBox(
                    width: SizeConfig.w(480),
                    child: Headline(
                      child: Text(
                        'From contrast therapies to advanced technologies, each session invites you to invigorate, reset, restore, and realign.',
                        style: OWATextStyles.sectionSubtitle,
                      ),
                    ),
                  ),
                  SizedBox(height: SizeConfig.h(50)),

                  LayoutBuilder(
                    builder: (context, constraints) {
                      const int cardsPerRow = 4;
                      final double gap = SizeConfig.w(14);
                      final double totalGap = gap * (cardsPerRow - 1);

                      final double cardWidth =
                          (constraints.maxWidth - totalGap) / cardsPerRow;

                      return Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: events.asMap().entries.map<Widget>((entry) {
                          final int index = entry.key;
                          final Map<String, String> event = entry.value;

                          return Padding(
                            padding: EdgeInsets.only(
                              right: index < events.length - 1 ? gap : 0,
                            ),
                            child: SizedBox(
                              width: cardWidth,
                              child: StaggeredEventCard(
                                index: index,
                                shouldAnimate: _isVisible,
                                child: EventCard(
                                  width: cardWidth,
                                  imagePath: event['imagePath']!,
                                  title: event['title']!,
                                  date: event['date']!,
                                  description: event['description']!,
                                  precio: event['precio']!,
                                  onTap: () {
                                    debugPrint('Event card $index tapped');
                                  },
                                ),
                              ),
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),

                  SizedBox(height: SizeConfig.h(60)),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class StaggeredEventCard extends StatefulWidget {
  final Widget child;
  final int index;
  final bool shouldAnimate;

  const StaggeredEventCard({
    super.key,
    required this.child,
    required this.index,
    required this.shouldAnimate,
  });

  @override
  State<StaggeredEventCard> createState() => _StaggeredEventCardState();
}

class _StaggeredEventCardState extends State<StaggeredEventCard>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;
  bool _hasAnimated = false;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      duration: const Duration(milliseconds: 600),
      vsync: this,
    );

    _fadeAnimation = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOut,
    );

    _slideAnimation = Tween<Offset>(
      begin: const Offset(-0.15, 0.0),
      end: Offset.zero,
    ).animate(
      CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ),
    );
  }

  @override
  void didUpdateWidget(covariant StaggeredEventCard oldWidget) {
    super.didUpdateWidget(oldWidget);

    if (widget.shouldAnimate && !_hasAnimated) {
      _hasAnimated = true;
      final int delay = widget.index * 150;

      Future.delayed(Duration(milliseconds: delay), () {
        if (mounted) {
          _controller.forward();
        }
      });
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: widget.child,
      ),
    );
  }
}

class EventCard extends StatefulWidget {
  final double width;
  final String imagePath;
  final String title;
  final String date;
  final String description;
  final String precio;
  final VoidCallback? onTap;

  const EventCard({
    super.key,
    required this.width,
    required this.imagePath,
    required this.title,
    required this.date,
    required this.description,
    this.precio = '\$600 MXN',
    this.onTap,
  });

  @override
  State<EventCard> createState() => _EventCardState();
}

class _EventCardState extends State<EventCard> {
  bool _isHovered = false;

  @override
  Widget build(BuildContext context) {
    const double imageRadius = 10.0;
    const double imageAspectRatio = 299.87 / 320.0;
    const double descLineHeight = 1.67;

    final double cardWidth = widget.width;
    final double imageHeight = cardWidth * imageAspectRatio;
    final double imageScale = _isHovered ? 1.02 : 1.0;

    return MouseRegion(
      cursor: SystemMouseCursors.click,
      onEnter: (_) => setState(() => _isHovered = true),
      onExit: (_) => setState(() => _isHovered = false),
      child: GestureDetector(
        onTap: widget.onTap,
        child: SizedBox(
          width: cardWidth,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(imageRadius),
                child: SizedBox(
                  width: cardWidth,
                  height: imageHeight,
                  child: Stack(
                    fit: StackFit.expand,
                    children: [
                      AnimatedScale(
                        scale: imageScale,
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeInOut,
                        child: Image.asset(
                          widget.imagePath,
                          fit: BoxFit.cover,
                        ),
                      ),
                      AnimatedContainer(
                        duration: const Duration(milliseconds: 400),
                        curve: Curves.easeOutCubic,
                        color: Colors.black.withValues(
                          alpha: _isHovered ? 0.20 : 0.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.h(20)),
              Row(
                children: [
                  Expanded(
                    child: Headline(
                      child: Text(
                        widget.date,
                        style: const TextStyle(
                          fontFamily: 'Basier Circle Mono',
                          fontWeight: FontWeight.w500,
                          fontSize: 11,
                          height: 1.73,
                          letterSpacing: 0,
                          color: Color(0xFF646464),
                        ),
                      ),
                    ),
                  ),
                  Headline(
                    child: Text(
                      widget.precio,
                      style: const TextStyle(
                        fontFamily: 'Basier Circle Mono',
                        fontWeight: FontWeight.w500,
                        fontSize: 11,
                        height: 1.73,
                        letterSpacing: 0,
                        color: Color(0xFF646464),
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(height: SizeConfig.h(8)),
              SizedBox(
                width: cardWidth,
                child: Headline(
                  child: Text(
                    widget.description,
                    style: const TextStyle(
                      fontFamily: 'Times Now',
                      fontWeight: FontWeight.w400,
                      fontSize: 14,
                      height: descLineHeight,
                      letterSpacing: 0,
                      color: Color(0xFF2C2C2C),
                    ),
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                  ),
                ),
              ),
              SizedBox(height: SizeConfig.h(12)),
              Headline(
                child: Text(
                  widget.title,
                  style: TextStyle(
                    fontFamily: 'Basier Square Mono',
                    fontWeight: FontWeight.w400,
                    fontSize: SizeConfig.t(11),
                    height: 1.45,
                    letterSpacing: 0,
                    color: const Color(0xFF2C2C2C),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}