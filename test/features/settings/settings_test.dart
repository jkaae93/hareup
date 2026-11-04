import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:hareup/features/settings/data/platform_settings_repository.dart';
import 'package:hareup/features/settings/domain/settings.dart';
import 'package:hareup/features/settings/presentation/settings_page.dart';
import 'package:hareup_core/core.dart';
import 'package:package_info_plus/package_info_plus.dart';

class FakeSettings implements SettingsRepository {
  FakeSettings({this.failLoad = false, this.privacyUrl});
  bool failLoad;
  final Uri? privacyUrl;
  int loads = 0;
  int opens = 0;
  @override
  Future<Result<SettingsInfo>> load() async {
    loads++;
    return failLoad
        ? const Failure(NetworkFailure())
        : Success(
            SettingsInfo(
              version: '1.2.3',
              buildNumber: '4',
              privacyUrl: privacyUrl,
            ),
          );
  }

  @override
  Future<Result<void>> openExternal(Uri uri) async {
    opens++;
    return const Failure(UnexpectedFailure('링크 열기 실패'));
  }
}

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  test(
    'reads installed version and refuses unapproved or insecure links',
    () async {
      PackageInfo.setMockInitialValues(
        appName: '하릅',
        packageName: 'com.overcomplex.hareup.mobile',
        version: '1.2.3',
        buildNumber: '4',
        buildSignature: '',
      );
      final repo = PlatformSettingsRepository(
        privacyUrl: Uri.parse('https://example.com/privacy'),
      );
      final info = (await repo.load() as Success<SettingsInfo>).value;
      expect(info.version, '1.2.3');
      expect(info.buildNumber, '4');
      expect(
        await repo.openExternal(Uri.parse('https://other.example/')),
        isA<Failure<void>>(),
      );
      final insecure = PlatformSettingsRepository(
        privacyUrl: Uri.parse('http://example.com'),
      );
      expect(await insecure.load(), isA<Failure<SettingsInfo>>());
    },
  );
  testWidgets(
    'shows version, disables missing links and reports launch failure',
    (tester) async {
      final fake = FakeSettings(
        privacyUrl: Uri.parse('https://example.com/privacy'),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          localizationsDelegates: testLocalizationsDelegates,
          locale: const Locale('ko'),
          supportedLocales: appSupportedLocales,
          home: SettingsPage(repository: fake),
        ),
      );
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('v1.2.3 (4)'), 200);
      expect(find.text('v1.2.3 (4)'), findsOneWidget);
      for (final label in ['자주 묻는 질문 및 문의', '공지사항 및 업데이트 소식']) {
        final tile = tester.widget<ListTile>(
          find.ancestor(of: find.text(label), matching: find.byType(ListTile)),
        );
        expect(tile.enabled, isFalse);
      }
      await tester.ensureVisible(find.text('개인정보처리방침'));
      await tester.tap(find.text('개인정보처리방침'));
      await tester.pump();
      expect(find.text('링크 열기 실패'), findsOneWidget);
      expect(fake.opens, 1);
    },
  );
  testWidgets('load failure can be retried', (tester) async {
    final fake = FakeSettings(failLoad: true);
    await tester.pumpWidget(
      MaterialApp(
        theme: testTheme,
        localizationsDelegates: testLocalizationsDelegates,
        locale: const Locale('ko'),
        supportedLocales: appSupportedLocales,
        home: SettingsPage(repository: fake),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('네트워크 연결을 확인해 주세요.'), findsOneWidget);
    fake.failLoad = false;
    await tester.tap(find.text('다시 시도'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('v1.2.3 (4)'), 200);
    expect(find.text('v1.2.3 (4)'), findsOneWidget);
    expect(fake.loads, 2);
  });
}
