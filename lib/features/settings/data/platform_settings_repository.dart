import 'package:hareup_core/core.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import '../domain/settings.dart';

/// Optional links must be approved by product operations before being supplied.
class PlatformSettingsRepository implements SettingsRepository {
  const PlatformSettingsRepository({
    this.privacyUrl,
    this.supportUrl,
    this.noticeUrl,
  });
  final Uri? privacyUrl;
  final Uri? supportUrl;
  final Uri? noticeUrl;
  bool _valid(Uri? uri) =>
      uri == null ||
      (uri.scheme == 'https' && uri.host.isNotEmpty && uri.userInfo.isEmpty);
  @override
  Future<Result<SettingsInfo>> load() async {
    try {
      if (!_valid(privacyUrl) || !_valid(supportUrl) || !_valid(noticeUrl)) {
        return const Failure(RequestFailure());
      }
      final info = await PackageInfo.fromPlatform();
      return Success(
        SettingsInfo(
          version: info.version,
          buildNumber: info.buildNumber,
          privacyUrl: privacyUrl,
          supportUrl: supportUrl,
          noticeUrl: noticeUrl,
        ),
      );
    } catch (_) {
      return const Failure(
        UnexpectedFailure(
          '앱 정보를 불러오지 못했습니다.',
          FailureMessageKeys.settingsLoadFailed,
        ),
      );
    }
  }

  @override
  Future<Result<void>> openExternal(Uri uri) async {
    if (!_valid(uri) || ![privacyUrl, supportUrl, noticeUrl].contains(uri)) {
      return const Failure(AuthorizationFailure());
    }
    try {
      if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
        return const Failure(
          UnexpectedFailure(
            '링크를 열지 못했습니다.',
            FailureMessageKeys.settingsOpenLinkFailed,
          ),
        );
      }
      return const Success(null);
    } catch (_) {
      return const Failure(
        UnexpectedFailure(
          '링크를 열지 못했습니다.',
          FailureMessageKeys.settingsOpenLinkFailed,
        ),
      );
    }
  }
}
