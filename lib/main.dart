import 'package:flutter/material.dart';
import 'package:owa_flutter/owa_app.dart';
import 'package:owa_flutter/utils/intro_session_store.dart';
import 'package:flutter_web_plugins/url_strategy.dart';

const String _kOwaIntroSeenKey = 'owa_intro_seen';
const bool _debugAlwaysShowIntro = false;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Remove the # from URLs in Flutter Web
  usePathUrlStrategy();

  final hasSeenIntro = await readIntroSeen(_kOwaIntroSeenKey);
  final shouldShowIntro = _debugAlwaysShowIntro || !hasSeenIntro;

  if (!hasSeenIntro) {
    await writeIntroSeen(_kOwaIntroSeenKey, true);
  }

  runApp(OWAApp(showIntroOnStartup: shouldShowIntro));
}
