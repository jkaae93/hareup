import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'design_localizations_en.dart';
import 'design_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of DesignLocalizations
/// returned by `DesignLocalizations.of(context)`.
///
/// Applications need to include `DesignLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/design_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: DesignLocalizations.localizationsDelegates,
///   supportedLocales: DesignLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the DesignLocalizations.supportedLocales
/// property.
abstract class DesignLocalizations {
  DesignLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static DesignLocalizations? of(BuildContext context) {
    return Localizations.of<DesignLocalizations>(context, DesignLocalizations);
  }

  static const LocalizationsDelegate<DesignLocalizations> delegate =
      _DesignLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
        delegate,
        GlobalMaterialLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('ko'),
  ];

  /// Label for cancel buttons.
  ///
  /// In ko, this message translates to:
  /// **'취소'**
  String get cancelAction;

  /// Label for retry buttons on error notices.
  ///
  /// In ko, this message translates to:
  /// **'다시 시도'**
  String get retryAction;

  /// Accessibility label for loading indicators.
  ///
  /// In ko, this message translates to:
  /// **'불러오는 중'**
  String get loadingLabel;

  /// Default empty state for photo previews.
  ///
  /// In ko, this message translates to:
  /// **'선택된 사진이 없습니다.'**
  String get photoEmpty;

  /// Default error state for photo previews.
  ///
  /// In ko, this message translates to:
  /// **'사진을 표시할 수 없습니다.'**
  String get photoError;

  /// Default label for the before photo in comparisons.
  ///
  /// In ko, this message translates to:
  /// **'기준 사진'**
  String get photoBeforeDefault;

  /// Default label for the after photo in comparisons.
  ///
  /// In ko, this message translates to:
  /// **'비교 사진'**
  String get photoAfterDefault;

  /// Title for photo comparisons.
  ///
  /// In ko, this message translates to:
  /// **'사진 비교'**
  String get photoCompareTitle;

  /// Default word composed into photo action labels.
  ///
  /// In ko, this message translates to:
  /// **'사진'**
  String get photoDefaultWord;

  /// Label for taking a photo.
  ///
  /// In ko, this message translates to:
  /// **'{prefix} 촬영'**
  String takePhoto(String prefix);

  /// Label for choosing a photo.
  ///
  /// In ko, this message translates to:
  /// **'{prefix} 선택'**
  String choosePhoto(String prefix);

  /// Label for removing a photo.
  ///
  /// In ko, this message translates to:
  /// **'사진 삭제'**
  String get removePhoto;

  /// Tooltip for decreasing a count field.
  ///
  /// In ko, this message translates to:
  /// **'{label} 줄이기'**
  String decreaseCount(String label);

  /// Tooltip for increasing a count field.
  ///
  /// In ko, this message translates to:
  /// **'{label} 늘리기'**
  String increaseCount(String label);
}

class _DesignLocalizationsDelegate
    extends LocalizationsDelegate<DesignLocalizations> {
  const _DesignLocalizationsDelegate();

  @override
  Future<DesignLocalizations> load(Locale locale) {
    return SynchronousFuture<DesignLocalizations>(
      lookupDesignLocalizations(locale),
    );
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_DesignLocalizationsDelegate old) => false;
}

DesignLocalizations lookupDesignLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return DesignLocalizationsEn();
    case 'ko':
      return DesignLocalizationsKo();
  }

  throw FlutterError(
    'DesignLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
