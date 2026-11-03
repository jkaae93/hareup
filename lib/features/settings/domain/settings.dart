import 'package:hareup_core/core.dart';

class SettingsInfo {
  const SettingsInfo({
    required this.version,
    required this.buildNumber,
    this.privacyUrl,
    this.supportUrl,
    this.noticeUrl,
  });
  final String version;
  final String buildNumber;
  final Uri? privacyUrl;
  final Uri? supportUrl;
  final Uri? noticeUrl;
}

abstract interface class SettingsRepository {
  Future<Result<SettingsInfo>> load();
  Future<Result<void>> openExternal(Uri uri);
}
