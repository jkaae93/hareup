// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class DesignLocalizationsKo extends DesignLocalizations {
  DesignLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get cancelAction => '취소';

  @override
  String get retryAction => '다시 시도';

  @override
  String get loadingLabel => '불러오는 중';

  @override
  String get photoEmpty => '선택된 사진이 없습니다.';

  @override
  String get photoError => '사진을 표시할 수 없습니다.';

  @override
  String get photoBeforeDefault => '기준 사진';

  @override
  String get photoAfterDefault => '비교 사진';

  @override
  String get photoCompareTitle => '사진 비교';

  @override
  String get photoDefaultWord => '사진';

  @override
  String takePhoto(String prefix) {
    return '$prefix 촬영';
  }

  @override
  String choosePhoto(String prefix) {
    return '$prefix 선택';
  }

  @override
  String get removePhoto => '사진 삭제';

  @override
  String decreaseCount(String label) {
    return '$label 줄이기';
  }

  @override
  String increaseCount(String label) {
    return '$label 늘리기';
  }
}
