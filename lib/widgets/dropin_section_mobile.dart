import 'package:flutter/material.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/useful_widgets/headline.dart';
import 'package:owa_flutter/widgets/build_separator.dart';
import 'package:owa_flutter/useful_widgets/animated_menu_icon_stack.dart';
import 'package:url_launcher/url_launcher.dart';

class OWADropInSectionMobile extends StatefulWidget {
  const OWADropInSectionMobile({super.key});

  @override
  State<OWADropInSectionMobile> createState() => _OWADropInSectionMobileState();
}

class _OWADropInSectionMobileState extends State<OWADropInSectionMobile>
    with TickerProviderStateMixin {
  String? _expandedItem;
  String _selectedItem = _dropInItems.first.title;

  double w(double v) => SizeConfig.w(v);
  double h(double v) => SizeConfig.h(v);
  double t(double v) => SizeConfig.t(v);

  double get _padX => w(20);
  double get _topSpace => h(56);

  double get _itemStroke => w(0.75);
  double get _plusBox => w(11.5) * 1.6;
  double get _imageRadius => 10;

  static const String _pageDescription =
      'Flexible access to OWA experiences whenever you want them, with no long-term commitment required.';

  static const String _bookButtonText = 'BOOK A DROP-IN';
  static const String _bookButtonUrl = 'https://example.com';

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      color: colors.backgroundColor,
      padding: EdgeInsets.fromLTRB(_padX, _topSpace, _padX, h(48)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Headline(
                  child: Text('Drop-In', style: OWATextStyles.sectionTitle),
                ),
              ),
              Headline(
                child: Text('2.1', style: OWATextStyles.sectionTitleIndex),
              ),
            ],
          ),

          SizedBox(height: h(12)),

          buildSeparator(),

          SizedBox(height: h(28)),

          SizedBox(
            width: double.infinity,
            child: Headline(
              child: Text(
                _pageDescription,
                style: OWATextStyles.sectionSubtitle,
              ),
            ),
          ),

          SizedBox(height: h(52)),

          ..._dropInItems.map(_buildDropInRow),

          SizedBox(height: h(56)),

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
                  horizontal: w(36),
                  vertical: h(18),
                ),
              ),
              child: Text(
                _bookButtonText,
                style: TextStyle(
                  fontFamily: 'Arbeit',
                  color: Colors.black,
                  letterSpacing: 1.5,
                  fontSize: t(10),
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDropInRow(_DropInItem item) {
    final isExpanded = _expandedItem == item.title;

    final titleStyle = TextStyle(
      fontFamily: 'Basier Square Mono',
      fontWeight: FontWeight.w400,
      fontSize: t(13),
      height: 0.95,
      letterSpacing: 0.12 * t(13),
      color: Colors.black,
      decoration: TextDecoration.none,
    );

    final bodyStyle = TextStyle(
      fontFamily: 'Times Now',
      fontWeight: FontWeight.w400,
      fontSize: t(14),
      height: 20 / 14,
      color: Colors.black.withValues(alpha: 0.85),
      decoration: TextDecoration.none,
    );

    final priceStyle = TextStyle(
      fontFamily: 'Instrument Sans',
      fontWeight: FontWeight.w500,
      fontSize: t(12),
      height: 1.0,
      color: const Color(0xFF6B6B6B),
      decoration: TextDecoration.none,
    );

    return SizedBox(
      width: double.infinity,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: h(34),
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
                        Expanded(child: Text(item.title, style: titleStyle)),
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
                  padding: EdgeInsets.only(top: h(20), bottom: h(28)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(item.description, style: bodyStyle),

                      if (item.price != null) ...[
                        SizedBox(height: h(20)),
                        Text(item.price!, style: priceStyle),
                      ],

                      SizedBox(height: h(24)),

                      _buildBenefitsMobile(item.benefits),

                      SizedBox(height: h(24)),

                      ClipRRect(
                        borderRadius: BorderRadius.circular(_imageRadius),
                        child: SizedBox(
                          width: double.infinity,
                          height: h(240),
                          child: Image.asset(
                            item.imagePath,
                            fit: BoxFit.cover,
                            alignment: Alignment.center,
                          ),
                        ),
                      ),
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

  Widget _buildBenefitsMobile(List<String> benefits) {
    final style = TextStyle(
      fontFamily: 'Instrument Sans',
      fontWeight: FontWeight.w500,
      fontSize: t(12),
      height: 20 / 12,
      color: Colors.black,
      decoration: TextDecoration.none,
    );

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children:
          benefits.map((benefit) {
            return Padding(
              padding: EdgeInsets.only(bottom: h(6)),
              child: Text(
                benefit,
                style: style,
                softWrap: true,
                overflow: TextOverflow.visible,
              ),
            );
          }).toList(),
    );
  }
}

class _DropInItem {
  final String title;
  final String description;
  final List<String> benefits;
  final String imagePath;
  final String? price;

  const _DropInItem({
    required this.title,
    required this.description,
    required this.benefits,
    required this.imagePath,
    this.price,
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
    price: '\$600 MXN',
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
    price: '\$600 MXN',
  ),
];
