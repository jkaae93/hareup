import 'dart:ui';

import 'package:flutter_bloc/flutter_bloc.dart';

import 'locale_store.dart';

/// Holds the user's language override. A null state follows the device
/// language, falling back to Korean for unsupported device languages.
class LocaleCubit extends Cubit<Locale?> {
  LocaleCubit(this._store, [Locale? initial]) : super(initial);

  final LocaleStore _store;

  Future<void> setOverride(Locale? locale) async {
    await _store.save(locale);
    if (!isClosed) emit(locale);
  }
}
