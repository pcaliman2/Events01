import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/useful_widgets/headline.dart';
import 'package:owa_flutter/widgets/build_separator.dart';
import 'package:owa_flutter/useful_widgets/animated_menu_icon_stack.dart';
import 'package:url_launcher/url_launcher.dart';

class OWADropInSection extends StatefulWidget {
  const OWADropInSection({super.key});

  @override
  State<OWADropInSection> createState() => _OWADropInSectionState();
}

class _OWADropInSectionState extends State<OWADropInSection>
    with TickerProviderStateMixin {
  String? _expandedItem;
  String _selectedItem = _dropInItems.first.title;

  double s(double v) => SizeConfig.w(v);

  double get _pageW => s(1440);
  double get _padX => s(42);

  double get _figTitleW => s(444);
  double get _figTitleH => s(30);

  double get _figDividerW => s(1355.5625);
  double get _figDividerH => s(1);

  double get _figDescW => s(521.93);
  double get _figDescH => s(52);

  double get _gapTitleToDivider => s(12.95);
  double get _gapDividerToDesc => s(44.43);

  double get _leftColW => s(507.50439453125);
  double get _itemLineW => s(507.504);

  double get _plusBox => SizeConfig.w(9.92) * 1.6;

  double get _accDescW => s(429.49);

  double get _benefitsGap => s(60.91);

  double get _gapDescToList => s(156.97);

  double get _imageW => 511.46;
  double get _imageH => 520.0;
  double get _imageRadius => 10;
  double get _imageTopOffset => s(14.44);

  double get _itemHeaderH => s(35.0);
  double get _itemStroke => s(0.75);
  double get _itemNudgeY => s(-1.2);

  static const String _pageDescription =
      'Flexible access to OWA experiences whenever you want them, with no long-term commitment required.';

  static const String _bookButtonText = 'BOOK A DROP-IN';
  static const String _bookButtonUrl = 'https://example.com';

  @override
  Widget build(BuildContext context) {
    final selectedItem = _dropInItems.firstWhere(
      (item) => item.title == _selectedItem,
      orElse: () => _dropInItems.first,
    );

    return Container(
      width: _pageW,
      color: colors.backgroundColor,
      padding: EdgeInsets.symmetric(horizontal: _padX),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _figDividerW,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                SizedBox(
                  width: _figTitleW,
                  height: _figTitleH,
                  child: Align(
                    alignment: Alignment.centerLeft,
                    child: Headline(
                      child: Text('Drop-In', style: OWATextStyles.sectionTitle),
                    ),
                  ),
                ),
                const Spacer(),
                Headline(
                  child: Text('2.1', style: OWATextStyles.sectionTitleIndex),
                ),
              ],
            ),
          ),

          SizedBox(height: _gapTitleToDivider),

          buildSeparator(),

          SizedBox(height: _gapDividerToDesc),

          SizedBox(
            width: _figDescW,
            child: Headline(
              child: Text(
                _pageDescription,
                style: OWATextStyles.sectionSubtitle,
              ),
            ),
          ),

          SizedBox(height: _gapDescToList),

          SizedBox(
            width: _figDividerW,
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Expanded(
                        child: SizedBox(
                          width: _leftColW,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              ..._dropInItems.map(_buildDropInRow),
                              SizedBox(height: s(40)),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        width: SizeConfig.w(772.54 - (507.50439453125 + 42)),
                      ),
                    ],
                  ),
                ),

                Expanded(
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Padding(
                        padding: EdgeInsets.only(top: _imageTopOffset),
                        child: SizedBox(
                          width: _imageW,
                          height: _imageH,
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(_imageRadius),
                            child: AnimatedSwitcher(
                              duration: const Duration(milliseconds: 600),
                              switchInCurve: Curves.easeIn,
                              switchOutCurve: Curves.easeOut,
                              layoutBuilder: (
                                Widget? currentChild,
                                List<Widget> previousChildren,
                              ) {
                                return Stack(
                                  alignment: Alignment.center,
                                  children: <Widget>[
                                    ...previousChildren,
                                    if (currentChild != null) currentChild,
                                  ],
                                );
                              },
                              transitionBuilder: (
                                Widget child,
                                Animation<double> animation,
                              ) {
                                final fadeAnimation = CurvedAnimation(
                                  parent: animation,
                                  curve: Curves.easeInOut,
                                );
                                return FadeTransition(
                                  opacity: fadeAnimation,
                                  child: child,
                                );
                              },
                              child: Image.asset(
                                selectedItem.imagePath,
                                key: ValueKey(_selectedItem),
                                fit: BoxFit.cover,
                                alignment: Alignment.center,
                                width: double.infinity,
                                height: double.infinity,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          SizedBox(height: s(123)),

          Align(
            alignment: Alignment.center,
            child: OutlinedButton(
              onPressed: () async {
                final uri = Uri.parse(_bookButtonUrl);
                if (await canLaunchUrl(uri)) {
                  await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              },
              style: OutlinedButton.styleFrom(
                side: const BorderSide(color: Colors.black, width: 1),
                shape: const RoundedRectangleBorder(
                  borderRadius: BorderRadius.zero,
                ),
                padding: EdgeInsets.symmetric(
                  horizontal: SizeConfig.w(60),
                  vertical: SizeConfig.h(22),
                ),
              ),
              child: Text(
                _bookButtonText,
                style: TextStyle(
                  fontFamily: 'Arbeit',
                  color: Colors.black,
                  letterSpacing: 1.5,
                  fontSize: SizeConfig.t(10),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),

          SizedBox(height: s(60)),
        ],
      ),
    );
  }

  Widget _buildDropInRow(_DropInItem item) {
    final isExpanded = _expandedItem == item.title;

    final titleStyle = TextStyle(
      fontFamily: 'Basier Square Mono',
      fontWeight: FontWeight.w400,
      fontSize: s(14),
      height: 0.90,
      letterSpacing: 0.12 * s(14),
      color: Colors.black,
      decoration: TextDecoration.none,
    );

    const double spaceBetweenRowsHeight = 92.71;

    return SizedBox(
      width: _itemLineW,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: _itemLineW,
            height: _itemHeaderH,
            child: Stack(
              children: [
                Positioned.fill(
                  child: InkWell(
                    hoverColor: Colors.transparent,
                    splashColor: Colors.transparent,
                    highlightColor: Colors.transparent,
                    onTap: () {
                      setState(() {
                        _expandedItem = isExpanded ? null : item.title;
                        _selectedItem = item.title;
                      });
                    },
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Transform.translate(
                          offset: Offset(0, _itemNudgeY),
                          child: SizedBox(
                            height: s(13),
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: Text(item.title, style: titleStyle),
                            ),
                          ),
                        ),
                        const Spacer(),
                        AnimatedMenuIconStack(
                          size: _plusBox,
                          color: Colors.black,
                          lineThickness: 0.7,
                          duration: const Duration(milliseconds: 800),
                          isExpanded: !isExpanded,
                          onTap: () {},
                        ),
                      ],
                    ),
                  ),
                ),
                Positioned(
                  left: 0,
                  right: 0,
                  bottom: 0,
                  child: Container(
                    height: _itemStroke,
                    color: const Color(0xFF656565),
                  ),
                ),
              ],
            ),
          ),

          ClipRect(
            child: AnimatedSize(
              duration: const Duration(milliseconds: 800),
              curve: Curves.easeOutQuart,
              alignment: Alignment.topCenter,
              child: ConstrainedBox(
                constraints:
                    isExpanded
                        ? const BoxConstraints()
                        : const BoxConstraints(maxHeight: 0),
                child: Padding(
                  padding: EdgeInsets.only(top: s(21.2)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: _accDescW,
                        child: Text(
                          item.description,
                          style: TextStyle(
                            fontFamily: 'Times Now',
                            fontWeight: FontWeight.w400,
                            fontSize: SizeConfig.t(14),
                            height: 20 / 14,
                            color: Colors.black.withValues(alpha: 0.85),
                            decoration: TextDecoration.none,
                          ),
                        ),
                      ),
                      SizedBox(height: s(31.51)),
                      _buildBenefitsTwoCols(item.benefits),
                      SizedBox(height: SizeConfig.h(spaceBetweenRowsHeight)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildBenefitsTwoCols(List<String> benefits) {
    final left = benefits.take(3).toList();
    final right = benefits.skip(3).take(3).toList();

    final style = TextStyle(
      fontFamily: 'Instrument Sans',
      fontWeight: FontWeight.w500,
      fontSize: SizeConfig.t(12),
      height: 20 / 12,
      color: Colors.black,
      decoration: TextDecoration.none,
    );

    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          flex: 2,
          child: Text(
            left.join('\n'),
            style: style,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
        SizedBox(width: _benefitsGap),
        Expanded(
          flex: 1,
          child: Text(
            right.join('\n'),
            style: style,
            softWrap: true,
            overflow: TextOverflow.visible,
          ),
        ),
      ],
    );
  }
}

class _DropInItem {
  final String title;
  final String description;
  final List<String> benefits;
  final String imagePath;

  const _DropInItem({
    required this.title,
    required this.description,
    required this.benefits,
    required this.imagePath,
  });
}

const List<_DropInItem> _dropInItems = [
  _DropInItem(
    title: 'SAUNA',
    description:
        'Enjoy access to our sauna experience on your own schedule. Ideal for quick recovery, stress reduction, and a restorative reset during your day.',
    benefits: [
      'Muscle recovery',
      'Stress relief',
      'Circulation support',
      'Relaxation',
      'Detox support',
    ],
    imagePath: 'assets/follow_us.png',
  ),
  _DropInItem(
    title: 'MASSAGE',
    description:
        'A focused cold exposure session designed to help improve recovery, alertness, and resilience through controlled temperature contrast.',
    benefits: [
      'Recovery support',
      'Mental clarity',
      'Inflammation response',
      'Energy boost',
      'Resilience training',
    ],
    imagePath: 'assets/events3.png',
  ),
  _DropInItem(
    title: 'HYPERBARIC',
    description:
        'Step into a high-oxygen recovery environment that supports physical restoration, mental sharpness, and performance readiness.',
    benefits: [
      'Recovery enhancement',
      'Focus support',
      'Wellness optimization',
      'Energy restoration',
      'Performance readiness',
    ],
    imagePath: 'assets/dropin_hyperbaric.jpg',
  ),
];
