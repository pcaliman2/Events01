import 'package:owa_flutter/utils/intro_session_store_stub.dart'
    if (dart.library.html) 'package:owa_flutter/utils/intro_session_store_web.dart'
    as store;

Future<bool> readIntroSeen(String key) => store.readIntroSeen(key);

Future<void> writeIntroSeen(String key, bool value) =>
    store.writeIntroSeen(key, value);
