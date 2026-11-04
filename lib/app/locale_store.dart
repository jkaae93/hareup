import 'dart:ui';

import 'package:shared_preferences/shared_preferences.dart';

/// Persists the user's language override. Null follows the device language.
abstract interface class LocaleStore {
  Future<Locale?> load();
  Future<void> save(Locale? locale);
}

class SharedPreferencesLocaleStore implements LocaleStore {
  SharedPreferencesLocaleStore(this._prefs);

  final SharedPreferences _prefs;

  static const _key = 'hareup.locale';
  static const supportedCodes = ['ko', 'en'];

  @override
  Future<Locale?> load() async {
    final code = _prefs.getString(_key);
    if (code == null || !supportedCodes.contains(code)) return null;
    return Locale(code);
  }

  @override
  Future<void> save(Locale? locale) async {
    if (locale == null) {
      await _prefs.remove(_key);
    } else {
      await _prefs.setString(_key, locale.languageCode);
    }
  }
}

/// In-memory override for previews, tests, and hosts without preferences.
class MemoryLocaleStore implements LocaleStore {
  MemoryLocaleStore([this._locale]);

  Locale? _locale;

  @override
  Future<Locale?> load() async => _locale;

  @override
  Future<void> save(Locale? locale) async => _locale = locale;
}
