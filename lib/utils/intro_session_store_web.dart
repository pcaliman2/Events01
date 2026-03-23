import 'dart:html' as html;

Future<bool> readIntroSeen(String key) async {
  return html.window.localStorage[key] == 'true';
}

Future<void> writeIntroSeen(String key, bool value) async {
  html.window.localStorage[key] = value.toString();
}
