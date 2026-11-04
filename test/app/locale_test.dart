import 'dart:ui';

import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/app/locale_cubit.dart';
import 'package:hareup/app/locale_store.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  test('memory store round-trips the override', () async {
    final store = MemoryLocaleStore();
    expect(await store.load(), isNull);
    await store.save(const Locale('en'));
    expect(await store.load(), const Locale('en'));
    await store.save(null);
    expect(await store.load(), isNull);
  });

  test('preferences store round-trips the override', () async {
    SharedPreferences.setMockInitialValues({});
    final prefs = await SharedPreferences.getInstance();
    final store = SharedPreferencesLocaleStore(prefs);
    expect(await store.load(), isNull);
    await store.save(const Locale('ko'));
    expect(await store.load(), const Locale('ko'));
    await store.save(null);
    expect(await store.load(), isNull);
  });

  test('preferences store ignores unknown codes', () async {
    SharedPreferences.setMockInitialValues({'hareup.locale': 'ja'});
    final prefs = await SharedPreferences.getInstance();
    expect(await SharedPreferencesLocaleStore(prefs).load(), isNull);
  });

  test('cubit persists overrides', () async {
    final store = MemoryLocaleStore();
    final cubit = LocaleCubit(store);
    expect(cubit.state, isNull);
    await cubit.setOverride(const Locale('en'));
    expect(cubit.state, const Locale('en'));
    expect(await store.load(), const Locale('en'));
    await cubit.close();
  });
}
