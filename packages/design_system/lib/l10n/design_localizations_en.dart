// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'design_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class DesignLocalizationsEn extends DesignLocalizations {
  DesignLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get cancelAction => 'Cancel';

  @override
  String get retryAction => 'Try again';

  @override
  String get loadingLabel => 'Loading';

  @override
  String get photoEmpty => 'No photo selected.';

  @override
  String get photoError => 'Cannot display the photo.';

  @override
  String get photoBeforeDefault => 'Baseline photo';

  @override
  String get photoAfterDefault => 'Comparison photo';

  @override
  String get photoCompareTitle => 'Compare photos';

  @override
  String get photoDefaultWord => 'photo';

  @override
  String takePhoto(String prefix) {
    return 'Take $prefix';
  }

  @override
  String choosePhoto(String prefix) {
    return 'Choose $prefix';
  }

  @override
  String get removePhoto => 'Remove photo';

  @override
  String decreaseCount(String label) {
    return 'Decrease $label';
  }

  @override
  String increaseCount(String label) {
    return 'Increase $label';
  }
}
