import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:owa_flutter/useful/colors.dart';
import 'package:owa_flutter/useful/custom_launch_url.dart';
import 'package:owa_flutter/useful/size_config.dart';
import 'package:owa_flutter/useful/text_styles.dart';

// IMPORTS DE NAVEGACIÓN
import 'package:owa_flutter/widgets/fade_in_widget.dart';

enum _FooterSectionContent { form, success }

enum _FooterSuccessVariant { contact, newsletter }

class OWAFooter extends StatefulWidget {
  const OWAFooter({super.key});

  @override
  State<OWAFooter> createState() => _OWAFooterState();
}

class _OWAFooterState extends State<OWAFooter> with TickerProviderStateMixin {
  // Contact form controllers
  final _contactEmailController = TextEditingController();
  final _contactPhoneController = TextEditingController();
  final _contactMessageController = TextEditingController();

  // Newsletter controller
  final _newsletterEmailController = TextEditingController();

  // Validation states
  bool _isContactEmailValid = true;
  bool _isContactPhoneValid = true;
  bool _isContactMessageValid = true;
  bool _isNewsletterEmailValid = true;
  _FooterSectionContent _contactContent = _FooterSectionContent.form;
  _FooterSectionContent _newsletterContent = _FooterSectionContent.form;
  late final AnimationController _contactTransitionController;
  late final AnimationController _newsletterTransitionController;
  static const String _addressMapUrl = 'https://maps.apple/p/GHz_u4dboTIpQI';
  static final String _cancelMembershipWhatsAppUrl =
      'https://wa.me/5215610297637?text=Hello%2C%20I%20am%20an%20OWA%20member%20and%20I%20need%20help%20to%20cancel%20my%20membership';

  void _openCancelMembershipWhatsApp() {
    customLaunchURL(_cancelMembershipWhatsAppUrl);
  }

  @override
  void initState() {
    super.initState();
    _contactTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
      value: 1.0,
    );
    _newsletterTransitionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1450),
      value: 1.0,
    );
  }

  @override
  void dispose() {
    _contactTransitionController.dispose();
    _newsletterTransitionController.dispose();
    _contactEmailController.dispose();
    _contactPhoneController.dispose();
    _contactMessageController.dispose();
    _newsletterEmailController.dispose();
    super.dispose();
  }

  // Email validation
  bool _validateEmail(String email) {
    if (email.isEmpty) return true;
    final emailRegex = RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$');
    return emailRegex.hasMatch(email);
  }

  // Phone validation
  bool _validatePhone(String phone) {
    if (phone.isEmpty) return true;
    return phone.length >= 10;
  }

  // Message validation
  bool _validateMessage(String message) {
    if (message.isEmpty) return true;
    return message.length >= 10;
  }

  Future<void> _playSectionSuccessTransition({
    required bool isContact,
    Duration visibleDuration = const Duration(seconds: 3),
  }) async {
    final controller =
        isContact ? _contactTransitionController : _newsletterTransitionController;

    if (controller.isAnimating) return;

    await controller.reverse();
    if (!mounted) return;

    setState(() {
      if (isContact) {
        _contactContent = _FooterSectionContent.success;
      } else {
        _newsletterContent = _FooterSectionContent.success;
      }
    });

    await controller.forward();
    if (!mounted) return;

    await Future.delayed(visibleDuration);
    if (!mounted) return;

    await controller.reverse();
    if (!mounted) return;

    setState(() {
      if (isContact) {
        _contactContent = _FooterSectionContent.form;
      } else {
        _newsletterContent = _FooterSectionContent.form;
      }
    });

    await controller.forward();
  }

  Widget _buildSectionTransition({
    required bool isContact,
    required Widget child,
  }) {
    final controller =
        isContact ? _contactTransitionController : _newsletterTransitionController;
    final fade = CurvedAnimation(
      parent: controller,
      curve: Curves.easeOutQuart,
      reverseCurve: Curves.easeInOutCubic,
    );

    return FadeTransition(
      opacity: fade,
      child: SlideTransition(
        position: Tween<Offset>(
          begin: const Offset(0, 0.006),
          end: Offset.zero,
        ).animate(fade),
        child: ScaleTransition(
          scale: Tween<double>(
            begin: 0.997,
            end: 1.0,
          ).animate(fade),
          child: child,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: SizeConfig.w(1440),
      constraints: const BoxConstraints(minHeight: 539),
      color: footerBackgroundColor,
      padding: EdgeInsets.only(left: SizeConfig.w(42), right: SizeConfig.w(42)),
      child: SingleChildScrollView(
        physics: const NeverScrollableScrollPhysics(),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 6598.29 - 6512.23),
            SvgPicture.asset(
              'assets/footer_icon.svg',
              fit: BoxFit.fill,
              alignment: Alignment.topLeft,
              clipBehavior: Clip.none,
              colorFilter: ColorFilter.mode(
                Color.fromRGBO(159, 145, 129, 1),
                BlendMode.srcIn,
              ),
            ),
            SizedBox(height: 6702.48 - (6598.29 + 41.91)),

            // Main footer content
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                /// GET IN TOUCH + EXPLORE + BOOK + CONNECT
                Expanded(
                  child: Column(
                    children: [
                      /// GET IN TOUCH + EXPLORE + BOOK
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // GET IN TOUCH section
                          SizedBox(
                            width: SizeConfig.w(290),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'GET IN TOUCH',
                                  style: OWATextStyles.footerTitleSection,
                                ),
                                SizedBox(height: SizeConfig.h(20)),
                                InkWell(
                                  onTap: () => customLaunchURL(_addressMapUrl),
                                  child: Text(
                                    'Sinaloa 49 Col. Roma Norte\nMéxico, CDMX. CP. 6700',
                                    style: TextStyle(
                                      fontFamily: 'Basier Square Mono',
                                      fontWeight: FontWeight.w500,
                                      fontSize: SizeConfig.t(12),
                                      height: 1.73,
                                      letterSpacing: 0,
                                      color: const Color(0xFFCFC6BC),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),

                          // EXPLORE section
                          Expanded(child: _buildSectionExplore(context)),

                          // BOOK section
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'BOOK',
                                  style: OWATextStyles.footerTitleSection,
                                ),
                                SizedBox(height: SizeConfig.h(20)),
                                _buildFooterLink(context, 'Book a Session'),
                                _buildFooterLink(context, 'Become a Member'),
                                _buildFooterLink(context, 'Stay at OWA'),
                                _buildFooterLink(context, 'Host Your Event'),
                                _buildFooterLink(
                                  context,
                                  'Cancel Membership',
                                  onTap: _openCancelMembershipWhatsApp,
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      SizedBox(height: 6859.98 - (6752.98 + 63)),

                      /// CONNECT
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          SizedBox(
                            width: SizeConfig.w(290),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                // CORRECCIÓN: Email Clickeable
                                InkWell(
                                  onTap:
                                      () => customLaunchURL(
                                        'mailto:hello@owawellness.com',
                                      ),
                                  child: Text(
                                    'hello@owawellness.com',
                                    style: TextStyle(
                                      fontFamily: 'Basier Square Mono',
                                      fontWeight: FontWeight.w500,
                                      fontSize: SizeConfig.t(12),
                                      height: 1.73,
                                      letterSpacing: 0,
                                      color: const Color(0xFFCFC6BC),
                                      decoration:
                                          TextDecoration
                                              .underline, // Opcional: para indicar enlace
                                    ),
                                  ),
                                ),

                                SizedBox(height: SizeConfig.h(15)),

                                // CORRECCIÓN: Teléfono Clickeable
                                InkWell(
                                  onTap:
                                      () =>
                                          customLaunchURL('tel:+525555057158'),
                                  child: Text(
                                    '+52 555 505 7158',
                                    style: TextStyle(
                                      fontFamily: 'Basier Square Mono',
                                      fontWeight: FontWeight.w500,
                                      fontSize: SizeConfig.t(12),
                                      height: 1.73,
                                      letterSpacing: 0,
                                      color: const Color(0xFFCFC6BC),
                                      decoration:
                                          TextDecoration.underline, // Opcional
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Expanded(child: _buildSectionConnect(context)),
                          Expanded(
                            child: _buildSectionConnectInvisible(context),
                          ),
                        ],
                      ),

                      SizedBox(height: SizeConfig.h(80)),
                    ],
                  ),
                ),

                /// CONTACT + NEWSLETTER
                Expanded(
                  child: Column(
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // CONTACT section
                          Expanded(child: _buildContactSection()),

                          SizedBox(width: SizeConfig.w(40)),

                          // NEWSLETTER section
                          Expanded(child: _buildNewsletterSection()),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Divider line
            HorizontalFadeInWidget(
              child: Container(
                height: 1,
                color: Colors.white.withValues(alpha: 0.3), // Sintaxis moderna
                margin: EdgeInsets.only(bottom: SizeConfig.h(30)),
              ),
            ),

            // Bottom section
            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap:
                      () => customLaunchURL('https://www.latentestudio.com/en'),
                  child: Text(
                    'Creative Strategy @ Latente',
                    style: OWATextStyles.footerBottomItem,
                  ),
                ),
                Text(
                  '© All rights reserved ${DateTime.now().year}',
                  style: OWATextStyles.footerBottomItem,
                ),
              ],
            ),
            SizedBox(height: SizeConfig.h(30)),
          ],
        ),
      ),
    );
  }

  Widget _buildContactSection() {
    final content =
        _contactContent == _FooterSectionContent.success
            ? _buildInlineSuccessState(
              key: const ValueKey('contact-success'),
              title: 'CONTACT',
              message: 'Thank you.',
              caption: 'Your message has been received. Our team will be in touch shortly.',
              variant: _FooterSuccessVariant.contact,
            )
            : Column(
              key: const ValueKey('contact-form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONTACT', style: OWATextStyles.footerTitleSection),
        SizedBox(height: SizeConfig.h(20)),

        // Email field
        _buildFormField(
          controller: _contactEmailController,
          hintText: 'Email',
          isValid: _isContactEmailValid,
          onChanged: (value) {
            setState(() {
              _isContactEmailValid = _validateEmail(value);
            });
          },
        ),
        SizedBox(height: SizeConfig.h(15)),

        // Phone field
        _buildFormField(
          controller: _contactPhoneController,
          hintText: 'Phone',
          isValid: _isContactPhoneValid,
          keyboardType: TextInputType.phone,
          onChanged: (value) {
            setState(() {
              _isContactPhoneValid = _validatePhone(value);
            });
          },
        ),
        SizedBox(height: SizeConfig.h(15)),

        // Message field
        _buildFormField(
          controller: _contactMessageController,
          hintText: 'Message',
          isValid: _isContactMessageValid,
          maxLines: 3,
          onChanged: (value) {
            setState(() {
              _isContactMessageValid = _validateMessage(value);
            });
          },
        ),
        SizedBox(height: SizeConfig.h(20)),

        // Submit button
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              // Validate all fields
              setState(() {
                _isContactEmailValid = _validateEmail(
                  _contactEmailController.text,
                );
                _isContactPhoneValid = _validatePhone(
                  _contactPhoneController.text,
                );
                _isContactMessageValid = _validateMessage(
                  _contactMessageController.text,
                );
              });

              if (_isContactEmailValid &&
                  _isContactPhoneValid &&
                  _isContactMessageValid &&
                  _contactEmailController.text.isNotEmpty &&
                  _contactPhoneController.text.isNotEmpty &&
                  _contactMessageController.text.isNotEmpty) {
                // Handle form submission
                print('Contact form submitted:');
                print('Email: ${_contactEmailController.text}');
                print('Phone: ${_contactPhoneController.text}');
                print('Message: ${_contactMessageController.text}');

                // Clear form
                _contactEmailController.clear();
                _contactPhoneController.clear();
                _contactMessageController.clear();
                _playSectionSuccessTransition(isContact: true);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Submit',
                  style: TextStyle(
                    fontFamily: 'Basier Square Mono',
                    fontWeight: FontWeight.w500,
                    fontSize: SizeConfig.t(12),
                    height: 1.73,
                    letterSpacing: 0,
                    color: const Color(0xFFCFC6BC),
                  ),
                ),
                SizedBox(width: SizeConfig.w(8)),
                Icon(
                  Icons.arrow_forward,
                  color: const Color(0xFFCFC6BC),
                  size: SizeConfig.t(16),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return _buildSectionTransition(isContact: true, child: content);
  }

  Widget _buildNewsletterSection() {
    final content =
        _newsletterContent == _FooterSectionContent.success
            ? _buildInlineSuccessState(
              key: const ValueKey('newsletter-success'),
              title: 'NEWSLETTER',
              message: 'SUBSCRIPTION CONFIRMED',
              caption: 'You are on the list. Expect thoughtful updates soon.',
              description:
                  'Be the first to know about our new\nexperiences and collaborations',
              variant: _FooterSuccessVariant.newsletter,
            )
            : Column(
              key: const ValueKey('newsletter-form'),
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('NEWSLETTER', style: OWATextStyles.footerTitleSection),
        SizedBox(height: SizeConfig.h(20)),

        Text(
          'Be the first to know about our new\nexperiences and collaborations',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w400,
            fontSize: SizeConfig.t(12),
            height: 1.73,
            letterSpacing: 0,
            color: const Color(0xFFCFC6BC),
          ),
        ),
        SizedBox(height: SizeConfig.h(30)),

        // Email Address field
        _buildFormField(
          controller: _newsletterEmailController,
          hintText: 'Email Address',
          isValid: _isNewsletterEmailValid,
          onChanged: (value) {
            setState(() {
              _isNewsletterEmailValid = _validateEmail(value);
            });
          },
        ),
        SizedBox(height: SizeConfig.h(20)),

        // Submit button
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              // Validate email
              setState(() {
                _isNewsletterEmailValid = _validateEmail(
                  _newsletterEmailController.text,
                );
              });

              if (_isNewsletterEmailValid &&
                  _newsletterEmailController.text.isNotEmpty) {
                // Handle newsletter subscription
                print(
                  'Newsletter subscription: ${_newsletterEmailController.text}',
                );

                // Clear form
                _newsletterEmailController.clear();
                _playSectionSuccessTransition(isContact: false);
              }
            },
            child: Row(
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(
                  'Submit',
                  style: TextStyle(
                    fontFamily: 'Basier Square Mono',
                    fontWeight: FontWeight.w500,
                    fontSize: SizeConfig.t(12),
                    height: 1.73,
                    letterSpacing: 0,
                    color: const Color(0xFFCFC6BC),
                  ),
                ),
                SizedBox(width: SizeConfig.w(8)),
                Icon(
                  Icons.arrow_forward,
                  color: const Color(0xFFCFC6BC),
                  size: SizeConfig.t(16),
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return _buildSectionTransition(isContact: false, child: content);
  }

  Widget _buildInlineSuccessState({
    Key? key,
    required String title,
    required String message,
    String? description,
    String? caption,
    required _FooterSuccessVariant variant,
  }) {
    return Column(
      key: key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(title, style: OWATextStyles.footerTitleSection),
        SizedBox(height: SizeConfig.h(20)),
        if (description != null) ...[
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w400,
              fontSize: SizeConfig.t(12),
              height: 1.73,
              letterSpacing: 0,
              color: const Color(0xFFCFC6BC),
            ),
          ),
          SizedBox(height: SizeConfig.h(30)),
        ],
        TweenAnimationBuilder<double>(
          tween: Tween(begin: 0, end: 1),
          duration: Duration(
            milliseconds:
                variant == _FooterSuccessVariant.contact ? 1650 : 1200,
          ),
          curve:
              variant == _FooterSuccessVariant.contact
                  ? Curves.easeOutQuart
                  : Curves.easeOutCubic,
          builder: (context, value, child) {
            return Opacity(
              opacity: value,
              child: Transform.translate(
                offset: Offset(
                  0,
                  (1 - value) *
                      (variant == _FooterSuccessVariant.contact ? 10 : 14),
                ),
                child: Transform.scale(
                  scale:
                      (variant == _FooterSuccessVariant.contact ? 0.996 : 0.992) +
                      ((variant == _FooterSuccessVariant.contact ? 0.004 : 0.008) *
                          value),
                  alignment: Alignment.topCenter,
                  child: child,
                ),
              ),
            );
          },
          child:
              variant == _FooterSuccessVariant.contact
                  ? Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.w(22),
                      vertical: SizeConfig.h(24),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15100E),
                      border: Border.all(
                        color: const Color(0xFFCFC6BC).withValues(alpha: 0.42),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          'MESSAGE RECEIVED',
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Basier Square Mono',
                            fontWeight: FontWeight.w500,
                            fontSize: SizeConfig.t(10),
                            height: 1.4,
                            letterSpacing: SizeConfig.t(10) * 0.18,
                            color: const Color(0xFFCFC6BC).withValues(
                              alpha: 0.7,
                            ),
                          ),
                        ),
                        SizedBox(height: SizeConfig.h(18)),
                        Container(
                          width: SizeConfig.w(42),
                          height: 1,
                          color: const Color(0xFFCFC6BC).withValues(alpha: 0.55),
                        ),
                        SizedBox(height: SizeConfig.h(18)),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Arbeit',
                            fontWeight: FontWeight.w300,
                            fontSize: SizeConfig.t(25),
                            height: 1.1,
                            letterSpacing: 0,
                            color: const Color(0xFFF4EEE7),
                          ),
                        ),
                        if (caption != null) ...[
                          SizedBox(height: SizeConfig.h(14)),
                          SizedBox(
                            width: SizeConfig.w(250),
                            child: Text(
                              caption,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Arbeit',
                                fontWeight: FontWeight.w300,
                                fontSize: SizeConfig.t(13),
                                height: 1.7,
                                letterSpacing: 0,
                                color: const Color(0xFFCFC6BC).withValues(
                                  alpha: 0.78,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                  : Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                      horizontal: SizeConfig.w(18),
                      vertical: SizeConfig.h(20),
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191311),
                      border: Border.all(
                        color: const Color(0xFFCFC6BC).withValues(alpha: 0.55),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: SizeConfig.w(32),
                          height: 1,
                          color: const Color(0xFFCFC6BC).withValues(alpha: 0.75),
                        ),
                        SizedBox(height: SizeConfig.h(16)),
                        Text(
                          message,
                          style: TextStyle(
                            fontFamily: 'Basier Square Mono',
                            fontWeight: FontWeight.w500,
                            fontSize: SizeConfig.t(12),
                            height: 1.6,
                            letterSpacing: SizeConfig.t(12) * 0.12,
                            color: const Color(0xFFF3ECE4),
                          ),
                        ),
                        if (caption != null) ...[
                          SizedBox(height: SizeConfig.h(10)),
                          Text(
                            caption,
                            style: TextStyle(
                              fontFamily: 'Arbeit',
                              fontWeight: FontWeight.w300,
                              fontSize: SizeConfig.t(13),
                              height: 1.6,
                              letterSpacing: 0,
                              color: const Color(0xFFCFC6BC).withValues(
                                alpha: 0.82,
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  ),
        ),
      ],
    );
  }

  Widget _buildFormField({
    required TextEditingController controller,
    required String hintText,
    required bool isValid,
    required Function(String) onChanged,
    TextInputType keyboardType = TextInputType.text,
    int maxLines = 1,
  }) {
    return Container(
      decoration: BoxDecoration(
        border: Border(
          bottom: BorderSide(
            color: isValid ? const Color(0xFFCFC6BC) : Colors.red,
            width: 1,
          ),
        ),
      ),
      child: TextFormField(
        controller: controller,
        keyboardType: keyboardType,
        maxLines: maxLines,
        onChanged: onChanged,
        style: TextStyle(
          fontFamily: 'Basier Square Mono',
          fontWeight: FontWeight.w400,
          fontSize: SizeConfig.t(12),
          height: 1.73,
          letterSpacing: 0,
          color: const Color(0xFFCFC6BC),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w400,
            fontSize: SizeConfig.t(12),
            height: 1.73,
            letterSpacing: 0,
            color: const Color(0xFFCFC6BC).withValues(alpha: 0.5),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.only(
            bottom: SizeConfig.h(10),
            top: SizeConfig.h(10),
          ),
        ),
      ),
    );
  }

  Column _buildSectionExplore(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('EXPLORE', style: OWATextStyles.footerTitleSection),
        SizedBox(height: SizeConfig.h(20)),
        _buildFooterLink(context, 'The OWA Experience'),
        // _buildFooterLink(context, 'The Science'),
        _buildFooterLink(
          context,
          'First Timers and FAQ\'s',
          onTap: () => Navigator.of(context).pushNamed('/faq'),
        ),
        // Policies
        _buildFooterLink(
          context,
          'Policies',
          onTap: () => Navigator.of(context).pushNamed('/privacy-notice'),
        ),
      ],
    );
  }

  Column _buildSectionConnect(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text('CONNECT', style: OWATextStyles.footerTitleSection),
        SizedBox(height: SizeConfig.h(20)),

        // CORRECCIÓN: Instagram
        _buildFooterLink(
          context,
          'Instagram',
          onTap: () => customLaunchURL('https://www.instagram.com/weare.owa/'),
        ),

        // CORRECCIÓN: Spotify (Placeholder URL si no tienes una especÃ­fica)
        _buildFooterLink(
          context,
          'Spotify',
          onTap: () => customLaunchURL('https://open.spotify.com/'),
        ),

        _buildFooterLink(context, 'Careers'),
      ],
    );
  }

  Column _buildSectionConnectInvisible(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONNECT',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: SizeConfig.t(14),
            height: 1.45,
            letterSpacing: SizeConfig.t(14) * 0.04,
            color: Colors.transparent,
          ),
        ),
      ],
    );
  }

  Widget _buildFooterLink(
    BuildContext context,
    String text, {
    VoidCallback? onTap,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: SizeConfig.h(8)),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: SizeConfig.t(12),
            height: 1.73,
            letterSpacing: 0,
            color: const Color(0xFFCFC6BC),
          ),
        ),
      ),
    );
  }
}



