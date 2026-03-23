import 'package:flutter/material.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter_svg/svg.dart';
import 'package:owa_flutter/useful/colors.dart';
import 'package:owa_flutter/useful/custom_launch_url.dart';
import 'package:owa_flutter/useful/text_styles.dart';
import 'package:owa_flutter/widgets/fade_in_widget.dart';

enum _FooterSectionContent { form, success }

enum _FooterSuccessVariant { contact, newsletter }

class OWAMobileFooter extends StatefulWidget {
  const OWAMobileFooter({super.key});

  @override
  State<OWAMobileFooter> createState() => _OWAMobileFooterState();
}

class _OWAMobileFooterState extends State<OWAMobileFooter>
    with TickerProviderStateMixin {
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
  int? _activeScrollPointer;
  double? _initialScrollTouchY;
  double? _lastScrollTouchY;
  bool _isFooterDragActive = false;

  void _openCancelMembershipWhatsApp() {
    customLaunchURL(_cancelMembershipWhatsAppUrl);
  }

  ScrollPosition? _resolveScrollPosition() {
    if (!mounted) return null;

    final scrollable = Scrollable.maybeOf(context);
    if (scrollable != null) {
      return scrollable.position;
    }

    final primaryController = PrimaryScrollController.maybeOf(context);
    if (primaryController != null && primaryController.hasClients) {
      return primaryController.position;
    }

    return null;
  }

  void _handleFooterPointerDown(PointerDownEvent event) {
    if (!mounted) return;
    if (event.kind != PointerDeviceKind.touch) return;
    _activeScrollPointer = event.pointer;
    _initialScrollTouchY = event.position.dy;
    _lastScrollTouchY = event.position.dy;
    _isFooterDragActive = false;
  }

  void _handleFooterPointerMove(PointerMoveEvent event) {
    if (!mounted) return;
    if (event.kind != PointerDeviceKind.touch) return;
    if (_activeScrollPointer != event.pointer) return;

    final lastTouchY = _lastScrollTouchY;
    final position = _resolveScrollPosition();

    if (lastTouchY == null || position == null || !position.hasPixels) return;

    final initialTouchY = _initialScrollTouchY;
    if (!_isFooterDragActive && initialTouchY != null) {
      final dragDistance = event.position.dy - initialTouchY;
      if (dragDistance.abs() < 6) return;
      _isFooterDragActive = true;
    }

    final deltaY = event.position.dy - lastTouchY;
    _lastScrollTouchY = event.position.dy;

    if (deltaY.abs() < 0.1) return;

    final target = (position.pixels - deltaY).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    ).toDouble();

    if ((target - position.pixels).abs() < 0.1) return;
    position.jumpTo(target);
  }

  void _handleFooterPointerEnd(PointerEvent event) {
    if (!mounted) return;
    if (_activeScrollPointer != event.pointer) return;
    _activeScrollPointer = null;
    _initialScrollTouchY = null;
    _lastScrollTouchY = null;
    _isFooterDragActive = false;
  }

  void _handleFooterPointerSignal(PointerSignalEvent event) {
    if (!mounted) return;
    if (event is! PointerScrollEvent) return;

    final position = _resolveScrollPosition();
    if (position == null || !position.hasPixels) return;

    final target = (position.pixels + event.scrollDelta.dy).clamp(
      position.minScrollExtent,
      position.maxScrollExtent,
    ).toDouble();

    if ((target - position.pixels).abs() < 0.1) return;
    position.jumpTo(target);
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
    _activeScrollPointer = null;
    _initialScrollTouchY = null;
    _lastScrollTouchY = null;
    _isFooterDragActive = false;
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
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;

    return Listener(
      behavior: HitTestBehavior.translucent,
      onPointerDown: _handleFooterPointerDown,
      onPointerMove: _handleFooterPointerMove,
      onPointerUp: _handleFooterPointerEnd,
      onPointerCancel: _handleFooterPointerEnd,
      onPointerSignal: _handleFooterPointerSignal,
      child: Container(
        width: double.infinity,
        color: const Color(0xFF120705), // Same as desktop footer
        padding: EdgeInsets.fromLTRB(20, 40, 20, 40 + bottomInset),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Logo/Icon
            FadeInWidget(
              child: SvgPicture.asset(
                'assets/footer_icon.svg',
                fit: BoxFit.fill,
                alignment: Alignment.topLeft,
                clipBehavior: Clip.none,
                colorFilter: ColorFilter.mode(
                  Color.fromRGBO(159, 145, 129, 1),
                  BlendMode.srcIn,
                ),
              ),
            ),

            SizedBox(height: 40),

            // Sections in 2 columns layout
            FadeInWidget(
              child: Column(
                children: [
                  // Row 1: GET IN TOUCH + EXPLORE
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(child: _buildMobileSectionGetInTouch()),
                      SizedBox(width: 20),
                      Expanded(
                        child: _buildMobileSection('EXPLORE', [
                          'The OWA Experience',
                          // 'The Science',
                          'First Timers and FAQ\'s',
                          'Policies',
                        ]),
                      ),
                    ],
                  ),

                  SizedBox(height: 32),

                  // Row 2: BOOK + CONNECT
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: _buildMobileSectionBook(),
                      ),
                      SizedBox(width: 20),
                      Expanded(child: _buildMobileSectionConnect()),
                    ],
                  ),

                  SizedBox(height: 40),

                  // CONTACT FORM (Full width)
                  _buildContactSection(),

                  SizedBox(height: 32),

                  // NEWSLETTER FORM (Full width)
                  _buildNewsletterSection(),
                ],
              ),
            ),

            SizedBox(height: 48),

            // Divider line
            Container(
              height: 1,
              color: Colors.white.withOpacity(0.3),
              margin: EdgeInsets.only(bottom: 24),
            ),

            Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                GestureDetector(
                  onTap:
                      () => customLaunchURL(
                        'https://www.latentestudio.com/en',
                      ),
                  child: Text(
                    'Creative Strategy @ Latente',
                    style: OWATextStyles.footerBottomItem,
                  ),
                ),
                Text(
                  '© All rights reserved OWA 2026',
                  style: OWATextStyles.footerBottomItem,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMobileSectionGetInTouch() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'GET IN TOUCH',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () => customLaunchURL(_addressMapUrl),
          child: Text(
            'Sinaloa 49 Col. Roma Norte\nMéxico, CDMX. CP. 6700',
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.73,
              letterSpacing: 0,
              color: Color(0xFFCFC6BC),
            ),
          ),
        ),
        SizedBox(height: 12),
        InkWell(
          onTap: () => customLaunchURL('mailto:hello@owawellness.com'),
          child: Text(
            'hello@owawellness.com',
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.73,
              letterSpacing: 0,
              color: Color(0xFFCFC6BC),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
        SizedBox(height: 8),
        InkWell(
          onTap: () => customLaunchURL('tel:+525555057158'),
          child: Text(
            '+52 555 505 7158',
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w500,
              fontSize: 11,
              height: 1.73,
              letterSpacing: 0,
              color: Color(0xFFCFC6BC),
              decoration: TextDecoration.underline,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileSectionConnect() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'CONNECT',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 12),
        _buildMobileFooterLink(
          'Instagram',
          onTap: () => customLaunchURL('https://www.instagram.com/weare.owa/'),
        ),
        _buildMobileFooterLink(
          'Spotify',
          onTap: () => customLaunchURL('https://open.spotify.com/'),
        ),
        _buildMobileFooterLink('Careers'),
      ],
    );
  }

  Widget _buildMobileSectionBook() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'BOOK',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 12),
        _buildMobileFooterLink('Book a Session'),
        _buildMobileFooterLink('Become a Member'),
        _buildMobileFooterLink('Stay at OWA'),
        _buildMobileFooterLink('Host Your Event'),
        _buildMobileFooterLink(
          'Cancel Membership',
          onTap: _openCancelMembershipWhatsApp,
        ),
      ],
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
        Text(
          'CONTACT',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 16),

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
        SizedBox(height: 12),

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
        SizedBox(height: 12),

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
        SizedBox(height: 16),

        // Submit button
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
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
                print('Contact form submitted');
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
                    fontSize: 11,
                    height: 1.73,
                    letterSpacing: 0,
                    color: Color(0xFFCFC6BC),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Color(0xFFCFC6BC), size: 14),
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
        Text(
          'NEWSLETTER',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 16),

        Text(
          'Be the first to know about our new\nexperiences and collaborations',
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.73,
            letterSpacing: 0,
            color: Color(0xFFCFC6BC),
          ),
        ),
        SizedBox(height: 20),

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
        SizedBox(height: 16),

        // Submit button
        Align(
          alignment: Alignment.centerRight,
          child: InkWell(
            onTap: () {
              setState(() {
                _isNewsletterEmailValid = _validateEmail(
                  _newsletterEmailController.text,
                );
              });

              if (_isNewsletterEmailValid &&
                  _newsletterEmailController.text.isNotEmpty) {
                print(
                  'Newsletter subscription: ${_newsletterEmailController.text}',
                );
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
                    fontSize: 11,
                    height: 1.73,
                    letterSpacing: 0,
                    color: Color(0xFFCFC6BC),
                  ),
                ),
                SizedBox(width: 8),
                Icon(Icons.arrow_forward, color: Color(0xFFCFC6BC), size: 14),
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
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 16),
        if (description != null) ...[
          Text(
            description,
            style: TextStyle(
              fontFamily: 'Basier Square Mono',
              fontWeight: FontWeight.w400,
              fontSize: 11,
              height: 1.73,
              letterSpacing: 0,
              color: Color(0xFFCFC6BC),
            ),
          ),
          SizedBox(height: 20),
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
                      (variant == _FooterSuccessVariant.contact ? 9 : 12),
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
                    padding: const EdgeInsets.symmetric(
                      horizontal: 18,
                      vertical: 20,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF15100E),
                      border: Border.all(
                        color: const Color(0xFFCFC6BC).withOpacity(0.42),
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
                            fontSize: 10,
                            height: 1.4,
                            letterSpacing: 10 * 0.16,
                            color: const Color(0xFFCFC6BC).withOpacity(0.7),
                          ),
                        ),
                        SizedBox(height: 14),
                        Container(
                          width: 36,
                          height: 1,
                          color: const Color(0xFFCFC6BC).withOpacity(0.55),
                        ),
                        SizedBox(height: 14),
                        Text(
                          message,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Arbeit',
                            fontWeight: FontWeight.w300,
                            fontSize: 22,
                            height: 1.1,
                            letterSpacing: 0,
                            color: const Color(0xFFF4EEE7),
                          ),
                        ),
                        if (caption != null) ...[
                          SizedBox(height: 12),
                          SizedBox(
                            width: 240,
                            child: Text(
                              caption,
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: 'Arbeit',
                                fontWeight: FontWeight.w300,
                                fontSize: 12,
                                height: 1.65,
                                letterSpacing: 0,
                                color: const Color(0xFFCFC6BC).withOpacity(0.78),
                              ),
                            ),
                          ),
                        ],
                      ],
                    ),
                  )
                  : Container(
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 18,
                    ),
                    decoration: BoxDecoration(
                      color: const Color(0xFF191311),
                      border: Border.all(
                        color: const Color(0xFFCFC6BC).withOpacity(0.55),
                        width: 1,
                      ),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Container(
                          width: 28,
                          height: 1,
                          color: const Color(0xFFCFC6BC).withOpacity(0.75),
                        ),
                        SizedBox(height: 14),
                        Text(
                          message,
                          style: TextStyle(
                            fontFamily: 'Basier Square Mono',
                            fontWeight: FontWeight.w500,
                            fontSize: 11,
                            height: 1.6,
                            letterSpacing: 11 * 0.1,
                            color: const Color(0xFFF3ECE4),
                          ),
                        ),
                        if (caption != null) ...[
                          SizedBox(height: 8),
                          Text(
                            caption,
                            style: TextStyle(
                              fontFamily: 'Arbeit',
                              fontWeight: FontWeight.w300,
                              fontSize: 12,
                              height: 1.6,
                              letterSpacing: 0,
                              color: const Color(0xFFCFC6BC).withOpacity(0.82),
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
            color: isValid ? Color(0xFFCFC6BC) : Colors.red,
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
          fontSize: 11,
          height: 1.73,
          letterSpacing: 0,
          color: Color(0xFFCFC6BC),
        ),
        decoration: InputDecoration(
          hintText: hintText,
          hintStyle: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w400,
            fontSize: 11,
            height: 1.73,
            letterSpacing: 0,
            color: Color(0xFFCFC6BC).withOpacity(0.5),
          ),
          border: InputBorder.none,
          isDense: true,
          contentPadding: EdgeInsets.only(bottom: 8, top: 8),
        ),
      ),
    );
  }

  Widget _buildMobileSection(String title, List<String> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 12,
            height: 1.45,
            letterSpacing: 0.04 * 12,
            color: sectionFontColor,
          ),
        ),
        SizedBox(height: 12),
        ...items.map((item) => _buildMobileFooterLink(item)).toList(),
      ],
    );
  }

  Widget _buildMobileFooterLink(String text, {VoidCallback? onTap}) {
    return Padding(
      padding: EdgeInsets.only(bottom: 8),
      child: InkWell(
        onTap: onTap,
        child: Text(
          text,
          style: TextStyle(
            fontFamily: 'Basier Square Mono',
            fontWeight: FontWeight.w500,
            fontSize: 11,
            height: 1.73,
            letterSpacing: 0,
            color: Color(0xFFCFC6BC),
          ),
        ),
      ),
    );
  }
}



