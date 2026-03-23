bool _introSeen = false;

Future<bool> readIntroSeen(String key) async => _introSeen;

Future<void> writeIntroSeen(String key, bool value) async {
  _introSeen = value;
}
