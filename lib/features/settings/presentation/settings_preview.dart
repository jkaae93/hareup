import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter/widget_previews.dart';
import 'package:hareup_core/core.dart';
import '../domain/settings.dart';
import 'settings_page.dart';

class _PreviewSettingsRepository implements SettingsRepository {
  @override
  Future<Result<SettingsInfo>> load() async => Success(
    SettingsInfo(
      version: '1.0.0',
      buildNumber: '1',
      privacyUrl: Uri(scheme: 'https', host: 'example.com', path: 'privacy'),
      supportUrl: Uri(scheme: 'https', host: 'example.com', path: 'support'),
    ),
  );

  @override
  Future<Result<void>> openExternal(Uri uri) async =>
      const Failure(RequestFailure('미리보기에서는 외부 링크를 열지 않습니다.'));
}

@Preview(name: '설정', group: '계정')
Widget settingsPreview() => MaterialApp(
  theme: HareupTheme.light,
  home: SettingsPage(repository: _PreviewSettingsRepository()),
);
