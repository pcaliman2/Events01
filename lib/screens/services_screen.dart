import 'package:flutter/material.dart';

import 'package:owa_flutter/useful/colors.dart' as colors;
import 'package:owa_flutter/useful/is_desktop_from_context.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/useful_widgets/owa_smooth_scroll.dart';
import 'package:owa_flutter/widgets/footer_section.dart';
import 'package:owa_flutter/widgets/mobile_footer.dart';
import 'package:owa_flutter/widgets/owa_nav_bar.dart';
import 'package:owa_flutter/widgets/therapies_section.dart';

class OWAServicesPage extends StatelessWidget {
  const OWAServicesPage({super.key});

  @override
  Widget build(BuildContext context) {
    final isDesktop = isDesktopFromContext(context);
    double s(double v) => SizeConfig.w(v);

    return Scaffold(
      backgroundColor: colors.backgroundColor,
      body: OWASmoothScroll(
        builder: (context, controller, scrollPhysics, usesSmoothScroll) {
          return SingleChildScrollView(
            controller: controller,
            physics: scrollPhysics,
            child: Column(
              children: [
                const OWANavBar(useWhiteForeground: false),
                SizedBox(height: isDesktop ? s(100) : SizeConfig.h(70)),
                if (isDesktop) ...[
                  SizedBox(
                    width: s(444),
                    child: const Center(
                      child: Text(
                        'Services',
                        style: TextStyle(
                          fontSize: 12,
                          letterSpacing: 1.2,
                          color: Color(0xFF1A1A1A),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(height: s(60)),
                ],
                if (isDesktop)
                  const OWATherapiesSection()
                else
                  const _MobileBody(),
                SizedBox(height: isDesktop ? s(80) : SizeConfig.h(48)),
                isDesktop
                    ? SizedBox(
                      width: s(1440),
                      child: OWAFooter(key: UniqueKey()),
                    )
                    : OWAMobileFooter(key: UniqueKey()),
              ],
            ),
          );
        },
      ),
    );
  }
}

class _MobileBody extends StatelessWidget {
  const _MobileBody();

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            const Text(
              'Therapies',
              style: TextStyle(
                fontSize: 14,
                letterSpacing: 1.1,
                fontWeight: FontWeight.w500,
                color: Color(0xFF1A1A1A),
              ),
            ),
            const SizedBox(width: 16),
            const Expanded(
              child: Divider(
                height: 1,
                thickness: 1,
                color: Color(0xFFB9B3AA),
              ),
            ),
            const SizedBox(width: 16),
            Text('2.0', style: OWATextStyles.sectionTitleIndex),
          ],
        ),
        const SizedBox(height: 16),
        Text(
          "OWA's brings you the latest methods and most powerful practices that balance body and mind.\n\nFrom contrast therapies to advanced technologies, each session invites you to invigorate, reset, restore, and realign.",
          style: OWATextStyles.sectionSubtitle,
        ),
        const SizedBox(height: 22),
        ClipRect(
          child: Image.asset('assets/follow_us_4.jpg', fit: BoxFit.cover),
        ),
        const SizedBox(height: 22),
        const SizedBox(height: 28),
        SizedBox(
          width: 257,
          height: 43,
          child: OutlinedButton(
            onPressed: null,
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: Color(0xFF1A1A1A), width: 1),
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.zero,
              ),
            ),
            child: const Text(
              'BOOK A SESSION',
              style: TextStyle(
                fontFamily: 'Instrument Sans',
                fontSize: 10,
                letterSpacing: 2.0,
                color: Color(0xFF1A1A1A),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
