import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/features/settings/domain/settings.dart';
import 'package:hareup/features/settings/presentation/settings_page.dart';
import 'package:hareup_core/core.dart';

import '../../test_support.dart';

class _FakeSettings implements SettingsRepository {
  @override
  Future<Result<SettingsInfo>> load() async =>
      const Success(SettingsInfo(version: '1.2.3', buildNumber: '4'));

  @override
  Future<Result<void>> openExternal(Uri uri) async => const Success(null);
}

Future<void> _pump(
  WidgetTester tester,
  Locale locale, {
  Locale? override,
  ValueChanged<Locale?>? onChanged,
}) => tester.pumpWidget(
  MaterialApp(
    theme: testTheme,
    localizationsDelegates: testLocalizationsDelegates,
    supportedLocales: appSupportedLocales,
    locale: locale,
    home: SettingsPage(
      repository: _FakeSettings(),
      languageOverride: override,
      onLanguageChanged: onChanged,
    ),
  ),
);

void main() {
  testWidgets('language section is hidden without a callback', (tester) async {
    await _pump(tester, const Locale('ko'));
    await tester.pumpAndSettle();
    expect(find.text('언어'), findsNothing);
    expect(find.text('English'), findsNothing);
  });

  testWidgets('language selection reports the override', (tester) async {
    Locale? selected;
    await _pump(
      tester,
      const Locale('ko'),
      onChanged: (value) => selected = value,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('English'));
    expect(selected, const Locale('en'));

    await _pump(
      tester,
      const Locale('ko'),
      override: const Locale('en'),
      onChanged: (value) => selected = value,
    );
    await tester.pumpAndSettle();
    expect(find.text('기기 설정 따르기'), findsOneWidget);
    await tester.tap(find.text('기기 설정 따르기'));
    expect(selected, isNull);
  });

  testWidgets('language section renders in English', (tester) async {
    await _pump(tester, const Locale('en'), onChanged: (_) {});
    await tester.pumpAndSettle();
    expect(find.text('Language'), findsOneWidget);
    expect(find.text('Follow device language'), findsOneWidget);
    expect(find.text('한국어'), findsOneWidget);
  });
}
