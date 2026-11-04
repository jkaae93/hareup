import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_ko.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
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
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
    : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

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

  /// Application title shown by the operating system.
  ///
  /// In ko, this message translates to:
  /// **'하릅'**
  String get appTitle;

  /// Default message for unexpected failures.
  ///
  /// In ko, this message translates to:
  /// **'요청을 처리하지 못했습니다.'**
  String get failureUnexpected;

  /// Default message for network failures.
  ///
  /// In ko, this message translates to:
  /// **'네트워크 연결을 확인해 주세요.'**
  String get failureNetwork;

  /// Default message for serialization failures.
  ///
  /// In ko, this message translates to:
  /// **'데이터를 읽을 수 없습니다.'**
  String get failureSerialization;

  /// Default message for timeout failures.
  ///
  /// In ko, this message translates to:
  /// **'요청 시간이 초과되었습니다. 다시 시도해 주세요.'**
  String get failureTimeout;

  /// Default message for cancelled operations.
  ///
  /// In ko, this message translates to:
  /// **'요청이 취소되었습니다.'**
  String get failureCancelled;

  /// Default message for authorization failures.
  ///
  /// In ko, this message translates to:
  /// **'접근 권한을 확인해 주세요.'**
  String get failureAuthorization;

  /// Default message for not-found failures.
  ///
  /// In ko, this message translates to:
  /// **'요청한 정보를 찾을 수 없습니다.'**
  String get failureNotFound;

  /// Default message for server failures.
  ///
  /// In ko, this message translates to:
  /// **'서버에 문제가 발생했습니다. 다시 시도해 주세요.'**
  String get failureServer;

  /// Default message for invalid-request failures.
  ///
  /// In ko, this message translates to:
  /// **'요청을 확인해 주세요.'**
  String get failureRequest;

  /// Guidance shown when web Firebase options are missing.
  ///
  /// In ko, this message translates to:
  /// **'웹 Firebase 설정이 필요합니다. Firebase Console에서 Web 앱을 등록한 뒤 FIREBASE_WEB_API_KEY와 FIREBASE_WEB_APP_ID를 전달해 실행해 주세요.'**
  String get mainWebSetupMessage;

  /// Title for the language section in settings.
  ///
  /// In ko, this message translates to:
  /// **'언어'**
  String get settingsLanguageTitle;

  /// Language option that follows the device language.
  ///
  /// In ko, this message translates to:
  /// **'기기 설정 따르기'**
  String get settingsLanguageSystem;

  /// Shown when the requested login provider is not configured.
  ///
  /// In ko, this message translates to:
  /// **'로그인 제공자를 사용할 수 없습니다.'**
  String get authProviderUnavailable;

  /// Shown when the user cancels federated sign-in.
  ///
  /// In ko, this message translates to:
  /// **'로그인을 취소했습니다.'**
  String get authCancelled;

  /// Shown for malformed email addresses.
  ///
  /// In ko, this message translates to:
  /// **'이메일 주소 형식이 올바르지 않습니다.'**
  String get authInvalidEmail;

  /// Shown when signing up with a registered email.
  ///
  /// In ko, this message translates to:
  /// **'이미 가입된 이메일입니다. 로그인해 주세요.'**
  String get authEmailInUse;

  /// Shown for weak passwords.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호를 6자 이상 입력해 주세요.'**
  String get authWeakPassword;

  /// Shown for wrong email or password.
  ///
  /// In ko, this message translates to:
  /// **'이메일 또는 비밀번호를 확인해 주세요.'**
  String get authInvalidCredential;

  /// Shown after too many sign-in attempts.
  ///
  /// In ko, this message translates to:
  /// **'시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.'**
  String get authTooManyRequests;

  /// Shown when the provider is disabled in Firebase.
  ///
  /// In ko, this message translates to:
  /// **'Firebase Console에서 이 로그인 제공자를 활성화해 주세요.'**
  String get authNotEnabled;

  /// Shown when no auth repository is configured.
  ///
  /// In ko, this message translates to:
  /// **'Firebase 인증 설정을 사용할 수 없습니다.'**
  String get appAuthUnavailable;

  /// Shown for invalid record annotations.
  ///
  /// In ko, this message translates to:
  /// **'수정한 내용을 확인해 주세요.'**
  String get recordsInvalidAnnotations;

  /// Shown on conflicting record edits.
  ///
  /// In ko, this message translates to:
  /// **'기록이 변경되었습니다. 다시 불러온 후 수정해 주세요.'**
  String get recordsChanged;

  /// Shown for duplicate analysis saves.
  ///
  /// In ko, this message translates to:
  /// **'이미 저장된 분석입니다.'**
  String get recordsAlreadySaved;

  /// Shown for duplicate water bowls.
  ///
  /// In ko, this message translates to:
  /// **'이미 등록된 물그릇입니다.'**
  String get waterAlreadyRegistered;

  /// Shown when level history is unavailable.
  ///
  /// In ko, this message translates to:
  /// **'수위 기록을 불러올 수 없습니다.'**
  String get waterHistoryUnavailable;

  /// Shown for duplicate litter boxes.
  ///
  /// In ko, this message translates to:
  /// **'이미 등록된 화장실입니다.'**
  String get litterAlreadyRegistered;

  /// Shown when settings info fails to load.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보를 불러오지 못했습니다.'**
  String get settingsLoadFailed;

  /// Shown when an external link fails to open.
  ///
  /// In ko, this message translates to:
  /// **'링크를 열지 못했습니다.'**
  String get settingsOpenLinkFailed;

  /// Shown when family sharing is unavailable.
  ///
  /// In ko, this message translates to:
  /// **'가족 공유는 계정과 서버 연결 후 사용할 수 있습니다.'**
  String get familyUnavailable;

  /// Shown when family info fails to load.
  ///
  /// In ko, this message translates to:
  /// **'가족 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.'**
  String get familyLoadFailed;

  /// Shown for family server errors.
  ///
  /// In ko, this message translates to:
  /// **'서버에 문제가 있습니다.'**
  String get familyServerError;

  /// Shown when required photos are missing.
  ///
  /// In ko, this message translates to:
  /// **'필요한 사진을 선택해 주세요.'**
  String get analysisPhotoRequired;

  /// Shown for oversized or mistyped photos.
  ///
  /// In ko, this message translates to:
  /// **'각 사진은 3MB 이하의 JPEG, PNG 또는 WebP여야 합니다.'**
  String get analysisPhotoTooLarge;

  /// Shown when analysis photos are invalid.
  ///
  /// In ko, this message translates to:
  /// **'최근 사진과 비교할 사진을 확인해 주세요.'**
  String get analysisBaselineRequired;

  /// Shown when an analysis photo is too large.
  ///
  /// In ko, this message translates to:
  /// **'분석할 사진은 각각 3MB 이하여야 합니다.'**
  String get analysisEachPhotoTooLarge;

  /// Shown for unsupported photo types.
  ///
  /// In ko, this message translates to:
  /// **'JPEG, PNG 또는 WebP 사진만 분석할 수 있습니다.'**
  String get analysisUnsupportedType;

  /// Shown for invalid edited counts.
  ///
  /// In ko, this message translates to:
  /// **'수정한 횟수를 확인해 주세요.'**
  String get analysisInvalidCounts;

  /// Reason when water analysis is unreliable.
  ///
  /// In ko, this message translates to:
  /// **'물 감소율을 신뢰할 수 없어 분석할 수 없습니다.'**
  String get analysisUnreliableWater;

  /// Reason when confidence is unknown.
  ///
  /// In ko, this message translates to:
  /// **'분석 신뢰도를 확인할 수 없습니다.'**
  String get analysisConfidenceUnknown;

  /// Reason when litter analysis is unreliable.
  ///
  /// In ko, this message translates to:
  /// **'배설 흔적을 신뢰할 수 없어 분석할 수 없습니다.'**
  String get analysisUnreliableLitter;

  /// Reason for unknown outcome types.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과 유형을 확인할 수 없습니다.'**
  String get analysisUnknownOutcome;

  /// Reason when the analysis service is unavailable.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석 서비스가 아직 준비되지 않았습니다.'**
  String get analysisServiceUnavailable;

  /// Shown when a stored photo is missing.
  ///
  /// In ko, this message translates to:
  /// **'저장된 사진 파일을 찾지 못했습니다. 사진 저장소 설정을 확인해 주세요.'**
  String get storagePhotoNotFound;

  /// Shown when the Storage bucket is missing.
  ///
  /// In ko, this message translates to:
  /// **'사진 저장소가 설정되지 않았습니다. Firebase Console에서 Storage 버킷을 생성해 주세요.'**
  String get storageBucketMissing;

  /// No description provided for @selectionDeleteTitle.
  ///
  /// In ko, this message translates to:
  /// **'선택한 {count}개를 삭제할까요?'**
  String selectionDeleteTitle(int count);

  /// No description provided for @selectionDeleteAction.
  ///
  /// In ko, this message translates to:
  /// **'선택한 {count}개 삭제'**
  String selectionDeleteAction(int count);

  /// Label for delete buttons.
  ///
  /// In ko, this message translates to:
  /// **'삭제'**
  String get commonDelete;

  /// Title for target deletion dialogs.
  ///
  /// In ko, this message translates to:
  /// **'{name} 삭제'**
  String targetDeleteTitle(String name);

  /// Confirmation message for target deletion.
  ///
  /// In ko, this message translates to:
  /// **'목록에서 삭제할까요? 기존 사진과 관찰 기록은 보관됩니다. 삭제는 가족 관리자만 할 수 있습니다.'**
  String get targetDeleteMessage;

  /// Description for observation charts.
  ///
  /// In ko, this message translates to:
  /// **'각 막대는 한 번의 관찰 결과입니다. 오래된 기록부터 표시합니다.'**
  String get recordsChartDescription;

  /// Maximum label for observation charts.
  ///
  /// In ko, this message translates to:
  /// **'최대 {text}'**
  String recordsChartMaximumText(String text);

  /// Formats a chart value with its unit.
  ///
  /// In ko, this message translates to:
  /// **'{value}{unit}'**
  String recordsValueWithUnit(String value, String unit);

  /// Unit for litter counts.
  ///
  /// In ko, this message translates to:
  /// **'회'**
  String get recordsCountUnit;

  /// Status while checking records.
  ///
  /// In ko, this message translates to:
  /// **'기록 확인 중'**
  String get recordsChecking;

  /// Status when records fail to load.
  ///
  /// In ko, this message translates to:
  /// **'기록을 불러오지 못했습니다.'**
  String get recordsLoadFailed;

  /// Status when no analysis records exist.
  ///
  /// In ko, this message translates to:
  /// **'분석 기록 없음'**
  String get recordsEmpty;

  /// One-line water outcome summary.
  ///
  /// In ko, this message translates to:
  /// **'물 감소율 {percent}% (추정)'**
  String recordsWaterSummary(double percent);

  /// One-line litter outcome summary.
  ///
  /// In ko, this message translates to:
  /// **'소변 {urine}회 · 대변 {stool}회 (추정)'**
  String recordsLitterSummary(int urine, int stool);

  /// Short label for unavailable analysis.
  ///
  /// In ko, this message translates to:
  /// **'분석 불가'**
  String get recordsUnavailableShort;

  /// Latest record line with a summary.
  ///
  /// In ko, this message translates to:
  /// **'최근 기록 · {summary}'**
  String recordsRecentWith(String summary);

  /// Subtitle on the sign-up form.
  ///
  /// In ko, this message translates to:
  /// **'함께 돌보는 가족을 위한 계정을 만들어 주세요.'**
  String get authSignUpSubtitle;

  /// Subtitle on the sign-in form.
  ///
  /// In ko, this message translates to:
  /// **'매일 사진으로 기록하고 함께 살피는 반려동물 건강 케어'**
  String get authSignInSubtitle;

  /// Label for Google sign-in.
  ///
  /// In ko, this message translates to:
  /// **'Google로 계속'**
  String get authContinueWithGoogle;

  /// Label for Apple sign-in.
  ///
  /// In ko, this message translates to:
  /// **'Apple로 계속'**
  String get authContinueWithApple;

  /// Label for Kakao sign-in.
  ///
  /// In ko, this message translates to:
  /// **'카카오로 계속'**
  String get authContinueWithKakao;

  /// Divider text between provider and email sign-in.
  ///
  /// In ko, this message translates to:
  /// **'또는 이메일로 계속'**
  String get authOrEmail;

  /// Label for the optional name field.
  ///
  /// In ko, this message translates to:
  /// **'이름 (선택)'**
  String get authNameLabel;

  /// Label for the email field.
  ///
  /// In ko, this message translates to:
  /// **'이메일'**
  String get authEmailLabel;

  /// Validation error for email fields.
  ///
  /// In ko, this message translates to:
  /// **'이메일 주소를 확인해 주세요.'**
  String get authEmailInvalid;

  /// Label for the password field.
  ///
  /// In ko, this message translates to:
  /// **'비밀번호'**
  String get authPasswordLabel;

  /// Label for the sign-up button.
  ///
  /// In ko, this message translates to:
  /// **'가입하기'**
  String get authSignUpAction;

  /// Label for the sign-in button.
  ///
  /// In ko, this message translates to:
  /// **'로그인'**
  String get authSignInAction;

  /// Link to switch to sign-in.
  ///
  /// In ko, this message translates to:
  /// **'이미 계정이 있나요? 로그인'**
  String get authHaveAccount;

  /// Link to switch to sign-up.
  ///
  /// In ko, this message translates to:
  /// **'계정이 없나요? 가입하기'**
  String get authNeedAccount;

  /// Button to recheck the auth session.
  ///
  /// In ko, this message translates to:
  /// **'세션 다시 확인'**
  String get authRecheckSession;

  /// Title for the pet management page.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 관리'**
  String get petManageTitle;

  /// Label for adding a pet.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 추가'**
  String get petAddAction;

  /// Empty message for the pet list.
  ///
  /// In ko, this message translates to:
  /// **'등록된 반려동물이 없습니다.\n반려동물을 추가해 주세요.'**
  String get petEmptyMessage;

  /// Label for cats.
  ///
  /// In ko, this message translates to:
  /// **'고양이'**
  String get petSpeciesCat;

  /// Label for dogs.
  ///
  /// In ko, this message translates to:
  /// **'강아지'**
  String get petSpeciesDog;

  /// Pet age in months.
  ///
  /// In ko, this message translates to:
  /// **'{age}개월'**
  String petAgeMonths(int age);

  /// Label for female pets.
  ///
  /// In ko, this message translates to:
  /// **'암컷'**
  String get petSexFemale;

  /// Label for male pets.
  ///
  /// In ko, this message translates to:
  /// **'수컷'**
  String get petSexMale;

  /// Label for unknown pet sex.
  ///
  /// In ko, this message translates to:
  /// **'성별 모름'**
  String get petSexUnknown;

  /// Confirmation message for pet deletion.
  ///
  /// In ko, this message translates to:
  /// **'반려동물을 삭제하시겠어요? 연결된 기록의 보관 정책은 아직 정해지지 않았습니다.'**
  String get petDeleteMessage;

  /// Label for save buttons.
  ///
  /// In ko, this message translates to:
  /// **'저장'**
  String get commonSave;

  /// Notice when a pet photo is too large.
  ///
  /// In ko, this message translates to:
  /// **'사진은 10MB 이하로 선택해 주세요.'**
  String get petPhotoTooLarge;

  /// Notice when photo permission is denied.
  ///
  /// In ko, this message translates to:
  /// **'사진 접근 권한을 확인해 주세요. 사진 없이도 저장할 수 있습니다.'**
  String get petPhotoPermissionDenied;

  /// Notice when a photo cannot be fetched.
  ///
  /// In ko, this message translates to:
  /// **'사진을 가져오지 못했습니다. 다시 시도해 주세요.'**
  String get petPhotoUnavailable;

  /// Notice when a photo cannot be read.
  ///
  /// In ko, this message translates to:
  /// **'사진을 읽지 못했습니다. 다시 선택해 주세요.'**
  String get petPhotoReadFailed;

  /// Title for editing a pet.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 수정'**
  String get petEditTitle;

  /// Label for pet photos.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 사진'**
  String get petPhotoLabel;

  /// Hint under pet photo actions.
  ///
  /// In ko, this message translates to:
  /// **'선택한 사진은 반려동물 프로필에 표시됩니다.'**
  String get petPhotoHint;

  /// Label for the pet name field.
  ///
  /// In ko, this message translates to:
  /// **'이름'**
  String get petNameLabel;

  /// Validation error for empty names.
  ///
  /// In ko, this message translates to:
  /// **'이름을 입력해 주세요.'**
  String get petNameRequired;

  /// Label for the species field.
  ///
  /// In ko, this message translates to:
  /// **'종류'**
  String get petSpeciesLabel;

  /// Label for the age field.
  ///
  /// In ko, this message translates to:
  /// **'나이 (개월, 선택)'**
  String get petAgeLabel;

  /// Validation error for pet age.
  ///
  /// In ko, this message translates to:
  /// **'0 이상의 개월 수를 입력해 주세요.'**
  String get petAgeInvalid;

  /// Label for the sex field.
  ///
  /// In ko, this message translates to:
  /// **'성별 (선택)'**
  String get petSexLabel;

  /// Option for unspecified sex.
  ///
  /// In ko, this message translates to:
  /// **'미입력'**
  String get petSexUnspecified;

  /// Option for unknown sex.
  ///
  /// In ko, this message translates to:
  /// **'모름'**
  String get petSexNotKnown;

  /// Label for the weight field.
  ///
  /// In ko, this message translates to:
  /// **'체중 (kg, 선택)'**
  String get petWeightLabel;

  /// Validation error for pet weight.
  ///
  /// In ko, this message translates to:
  /// **'0보다 큰 체중을 입력해 주세요.'**
  String get petWeightInvalid;

  /// Title for the water level history page.
  ///
  /// In ko, this message translates to:
  /// **'수위 기록'**
  String get waterHistoryTitle;

  /// Empty message for water level history.
  ///
  /// In ko, this message translates to:
  /// **'저장된 수위 기록이 없습니다.'**
  String get waterHistoryEmpty;

  /// Title for the water level trend.
  ///
  /// In ko, this message translates to:
  /// **'수위 추이'**
  String get waterTrendTitle;

  /// Notice while level estimates are gated.
  ///
  /// In ko, this message translates to:
  /// **'수위 추정치는 정확도 검증 후 표시됩니다.'**
  String get waterTrendPending;

  /// Notice when no level records exist for the chart.
  ///
  /// In ko, this message translates to:
  /// **'그래프에 표시할 수위 기록이 없습니다.'**
  String get waterTrendNoData;

  /// Chart label for the current level.
  ///
  /// In ko, this message translates to:
  /// **'현재 수위 (추정)'**
  String get waterCurrentLevelEstimated;

  /// Card title with the current level.
  ///
  /// In ko, this message translates to:
  /// **'현재 수위 {current}% (추정)'**
  String waterCurrentLevelValue(String current);

  /// Card title when the level value is hidden.
  ///
  /// In ko, this message translates to:
  /// **'수위 분석 완료'**
  String get waterAnalysisDone;

  /// Label for a level decrease.
  ///
  /// In ko, this message translates to:
  /// **'감소'**
  String get waterChangeDecrease;

  /// Label for a level increase.
  ///
  /// In ko, this message translates to:
  /// **'증가'**
  String get waterChangeIncrease;

  /// Label for no level change.
  ///
  /// In ko, this message translates to:
  /// **'변화 없음'**
  String get waterChangeNone;

  /// Level change suffix for history cards.
  ///
  /// In ko, this message translates to:
  /// **' · {change} {value}%p'**
  String waterChangeWith(String change, String value);

  /// Title for the family selection page.
  ///
  /// In ko, this message translates to:
  /// **'가족 선택'**
  String get familySelectTitle;

  /// Badge on the family selection page.
  ///
  /// In ko, this message translates to:
  /// **'우리 가족 보금자리'**
  String get familyNestBadge;

  /// Question on the family selection page.
  ///
  /// In ko, this message translates to:
  /// **'어떤 가족과 함께 돌볼까요?'**
  String get familySelectQuestion;

  /// Hint on the family selection page.
  ///
  /// In ko, this message translates to:
  /// **'승인된 가족을 선택해 계속하세요.'**
  String get familySelectHint;

  /// Empty message for the family list.
  ///
  /// In ko, this message translates to:
  /// **'참여 중인 가족이 없습니다. 가족을 만들거나 초대 코드를 입력하세요.'**
  String get familyEmptyMessage;

  /// Title for the pending approval card.
  ///
  /// In ko, this message translates to:
  /// **'관리자 승인 대기 중'**
  String get familyPendingTitle;

  /// Message for the pending approval card.
  ///
  /// In ko, this message translates to:
  /// **'승인 후 새로고침하면 가족을 선택할 수 있습니다.'**
  String get familyPendingMessage;

  /// Tooltip for refreshing the approval status.
  ///
  /// In ko, this message translates to:
  /// **'승인 상태 새로고침'**
  String get familyRefreshStatus;

  /// Title for the family guidance.
  ///
  /// In ko, this message translates to:
  /// **'함께 돌보는 가족'**
  String get familyTogetherTitle;

  /// Message for the family guidance.
  ///
  /// In ko, this message translates to:
  /// **'가족 구성원이 같은 반려동물의 기록을 함께 확인할 수 있어요.'**
  String get familyTogetherMessage;

  /// Label for creating a family.
  ///
  /// In ko, this message translates to:
  /// **'가족 만들기'**
  String get familyCreateAction;

  /// Label for entering an invite code.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 입력'**
  String get familyEnterCodeAction;

  /// Label for the family name field.
  ///
  /// In ko, this message translates to:
  /// **'가족 이름'**
  String get familyNameLabel;

  /// Submit label for creating a family.
  ///
  /// In ko, this message translates to:
  /// **'만들기'**
  String get familyCreateSubmit;

  /// Validation error for empty family names.
  ///
  /// In ko, this message translates to:
  /// **'가족 이름을 입력해 주세요.'**
  String get familyNameRequired;

  /// Label for the invite code field.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드'**
  String get familyInviteCodeLabel;

  /// Submit label for join requests.
  ///
  /// In ko, this message translates to:
  /// **'가입 요청'**
  String get familyJoinRequestAction;

  /// Validation error for invite codes.
  ///
  /// In ko, this message translates to:
  /// **'6~12자의 영문 또는 숫자를 입력해 주세요.'**
  String get familyInviteCodeInvalid;

  /// Title for the settings page.
  ///
  /// In ko, this message translates to:
  /// **'설정'**
  String get settingsTitle;

  /// Empty message for settings.
  ///
  /// In ko, this message translates to:
  /// **'설정 정보가 없습니다.'**
  String get settingsEmptyMessage;

  /// Fallback label for the account row.
  ///
  /// In ko, this message translates to:
  /// **'내 계정'**
  String get settingsMyAccount;

  /// Label for a single registered pet.
  ///
  /// In ko, this message translates to:
  /// **'등록된 반려동물: {name}'**
  String settingsPetSingle(String name);

  /// Label for multiple registered pets.
  ///
  /// In ko, this message translates to:
  /// **'등록된 반려동물 {count}마리'**
  String settingsPetCount(int count);

  /// Title for the notification section.
  ///
  /// In ko, this message translates to:
  /// **'스마트 안심 알림 설정'**
  String get settingsNotificationTitle;

  /// Title for water bowl alerts.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 사진 분석 알림'**
  String get settingsWaterAlertTitle;

  /// Message for water bowl alerts.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 관찰 알림 기능은 준비 중입니다.'**
  String get settingsWaterAlertMessage;

  /// Title for litter alerts.
  ///
  /// In ko, this message translates to:
  /// **'화장실 이상 징후 알림'**
  String get settingsLitterAlertTitle;

  /// Message for litter alerts.
  ///
  /// In ko, this message translates to:
  /// **'화장실 관찰 알림 기능은 준비 중입니다.'**
  String get settingsLitterAlertMessage;

  /// Title for family sync.
  ///
  /// In ko, this message translates to:
  /// **'가족 돌봄 기록 실시간 동기화'**
  String get settingsFamilySyncTitle;

  /// Message for family sync.
  ///
  /// In ko, this message translates to:
  /// **'가족 기록은 앱에서 확인할 수 있습니다.'**
  String get settingsFamilySyncMessage;

  /// Title for the support section.
  ///
  /// In ko, this message translates to:
  /// **'앱 정보 및 지원'**
  String get settingsSupportTitle;

  /// Title for the notices row.
  ///
  /// In ko, this message translates to:
  /// **'공지사항 및 업데이트 소식'**
  String get settingsNoticeTitle;

  /// Title for the FAQ row.
  ///
  /// In ko, this message translates to:
  /// **'자주 묻는 질문 및 문의'**
  String get settingsFaqTitle;

  /// Title for the terms row.
  ///
  /// In ko, this message translates to:
  /// **'서비스 이용약관'**
  String get settingsTermsTitle;

  /// Label for unavailable features.
  ///
  /// In ko, this message translates to:
  /// **'준비 중'**
  String get settingsComingSoon;

  /// Title for the privacy row.
  ///
  /// In ko, this message translates to:
  /// **'개인정보처리방침'**
  String get settingsPrivacyTitle;

  /// Title for the version card.
  ///
  /// In ko, this message translates to:
  /// **'앱 버전 정보'**
  String get settingsVersionTitle;

  /// Label for signing out.
  ///
  /// In ko, this message translates to:
  /// **'로그아웃'**
  String get settingsSignOutAction;

  /// Confirmation for signing out.
  ///
  /// In ko, this message translates to:
  /// **'이 기기에서 로그아웃할까요?'**
  String get settingsSignOutConfirm;

  /// Hint for account deletion.
  ///
  /// In ko, this message translates to:
  /// **'하릅 회원 탈퇴 · 준비 중'**
  String get settingsWithdrawHint;

  /// Notice when a photo exceeds 3 MB.
  ///
  /// In ko, this message translates to:
  /// **'사진은 3MB 이하여야 합니다.'**
  String get waterPhotoTooLarge;

  /// Notice when a photo cannot be fetched.
  ///
  /// In ko, this message translates to:
  /// **'사진을 가져오지 못했습니다.'**
  String get photoFetchFailed;

  /// Notice when a photo cannot be read.
  ///
  /// In ko, this message translates to:
  /// **'사진을 읽지 못했습니다.'**
  String get photoReadFailed;

  /// Notice when the analysis service is missing.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석 서비스를 사용할 수 없습니다.'**
  String get waterServiceUnavailable;

  /// Notice when setup photos are incomplete.
  ///
  /// In ko, this message translates to:
  /// **'정수기의 앞·뒤·위 사진을 모두 선택해 주세요.'**
  String get waterSetupPhotosRequired;

  /// Notice when the reading photo is missing.
  ///
  /// In ko, this message translates to:
  /// **'정수기 사진을 선택해 주세요.'**
  String get waterReadingPhotoRequired;

  /// Notice with an unparsed level reason.
  ///
  /// In ko, this message translates to:
  /// **'수위를 확인할 수 없습니다. {reason}'**
  String waterLevelUnknownWith(String reason);

  /// Title for purifier setup.
  ///
  /// In ko, this message translates to:
  /// **'정수기 초기 설정'**
  String get waterSetupTitle;

  /// Title for level checks.
  ///
  /// In ko, this message translates to:
  /// **'수위 관찰'**
  String get waterObserveTitle;

  /// Guide title for setup.
  ///
  /// In ko, this message translates to:
  /// **'초기 설정 안내'**
  String get waterSetupGuideTitle;

  /// Guide title for level checks.
  ///
  /// In ko, this message translates to:
  /// **'수위 관찰 안내'**
  String get waterObserveGuideTitle;

  /// Guide message for setup.
  ///
  /// In ko, this message translates to:
  /// **'정수기의 앞·뒤·위 사진으로 초기 수위를 추정합니다.'**
  String get waterSetupGuideMessage;

  /// Guide message for level checks.
  ///
  /// In ko, this message translates to:
  /// **'정수기 사진 한 장을 올려 직전 수위와 비교합니다.'**
  String get waterObserveGuideMessage;

  /// Label for the front angle.
  ///
  /// In ko, this message translates to:
  /// **'앞'**
  String get waterAngleFront;

  /// Label for the back angle.
  ///
  /// In ko, this message translates to:
  /// **'뒤'**
  String get waterAngleBack;

  /// Label for the top angle.
  ///
  /// In ko, this message translates to:
  /// **'위'**
  String get waterAngleTop;

  /// Photo label for an angle.
  ///
  /// In ko, this message translates to:
  /// **'{angle} 사진'**
  String waterAnglePhoto(String angle);

  /// Label for purifier photos.
  ///
  /// In ko, this message translates to:
  /// **'정수기 사진'**
  String get waterPurifierPhoto;

  /// Button to analyze the setup.
  ///
  /// In ko, this message translates to:
  /// **'초기 설정 분석'**
  String get waterSetupAnalyzeAction;

  /// Button to analyze the level.
  ///
  /// In ko, this message translates to:
  /// **'수위 분석'**
  String get waterAnalyzeAction;

  /// Title for notice callouts.
  ///
  /// In ko, this message translates to:
  /// **'안내'**
  String get commonNotice;

  /// Title for analysis results.
  ///
  /// In ko, this message translates to:
  /// **'분석 결과'**
  String get analysisResultTitle;

  /// Current level reading line.
  ///
  /// In ko, this message translates to:
  /// **'현재 수위: {value}% (추정)'**
  String waterCurrentLevelReading(String value);

  /// Previous level reading line.
  ///
  /// In ko, this message translates to:
  /// **'직전 수위: {value}% (추정)'**
  String waterPreviousLevelReading(String value);

  /// Level decrease line.
  ///
  /// In ko, this message translates to:
  /// **'이전보다 {value}%p 감소'**
  String waterDecreasedSince(String value);

  /// Level increase line.
  ///
  /// In ko, this message translates to:
  /// **'이전보다 {value}%p 증가 (물 보충 가능)'**
  String waterIncreasedSince(String value);

  /// No level change line.
  ///
  /// In ko, this message translates to:
  /// **'이전과 변화 없음'**
  String get waterNoChange;

  /// Notice after saving while values are gated.
  ///
  /// In ko, this message translates to:
  /// **'분석을 저장했습니다. 수위 추정치는 정확도 검증 후 표시됩니다.'**
  String get waterSavedPending;

  /// Disclaimer for water estimates.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석 결과는 추정치이며 실제 음수량을 의미하지 않습니다.'**
  String get waterEstimateDisclaimer;

  /// Label for the home destination.
  ///
  /// In ko, this message translates to:
  /// **'홈'**
  String get navHome;

  /// Label for the water bowl destination.
  ///
  /// In ko, this message translates to:
  /// **'물그릇'**
  String get navWater;

  /// Label for the litter box destination.
  ///
  /// In ko, this message translates to:
  /// **'화장실'**
  String get navLitter;

  /// Label for the photo comparison destination.
  ///
  /// In ko, this message translates to:
  /// **'사진 비교'**
  String get navCompare;

  /// Label for the records destination.
  ///
  /// In ko, this message translates to:
  /// **'기록 목록'**
  String get navRecords;

  /// Error when targets fail to load.
  ///
  /// In ko, this message translates to:
  /// **'대상 목록을 확인한 뒤 다시 시도해 주세요.'**
  String get homeTargetListError;

  /// Title for picking a record target.
  ///
  /// In ko, this message translates to:
  /// **'기록 대상 선택'**
  String get homePickRecordsTarget;

  /// Title for picking a comparison target.
  ///
  /// In ko, this message translates to:
  /// **'사진 비교 대상 선택'**
  String get homePickCompareTarget;

  /// Hint for picking a record target.
  ///
  /// In ko, this message translates to:
  /// **'기록을 확인할 대상을 선택해 주세요.'**
  String get homePickRecordsHint;

  /// Hint for picking a comparison target.
  ///
  /// In ko, this message translates to:
  /// **'사진을 비교할 대상을 선택해 주세요.'**
  String get homePickCompareHint;

  /// Empty message for the target picker.
  ///
  /// In ko, this message translates to:
  /// **'먼저 물그릇이나 화장실을 등록해 주세요.'**
  String get homeNoTargets;

  /// Error when pets fail to load.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 목록을 확인한 뒤 다시 시도해 주세요.'**
  String get homePetError;

  /// Tooltip for switching families.
  ///
  /// In ko, this message translates to:
  /// **'가족 바꾸기'**
  String get homeSwitchFamily;

  /// Tooltip for managing the family.
  ///
  /// In ko, this message translates to:
  /// **'가족 관리'**
  String get homeManageFamily;

  /// Headline on the home page.
  ///
  /// In ko, this message translates to:
  /// **'함께 돌보는 하루'**
  String get homeHeadline;

  /// Subheadline on the home page.
  ///
  /// In ko, this message translates to:
  /// **'오늘도 반려동물의 일상을 살펴보세요.'**
  String get homeSubheadline;

  /// Notice for the local development preview.
  ///
  /// In ko, this message translates to:
  /// **'개발 미리보기 · 데이터는 앱을 종료하면 사라집니다.'**
  String get homeLocalPreview;

  /// Title for the pet section.
  ///
  /// In ko, this message translates to:
  /// **'반려동물'**
  String get homePetTitle;

  /// Empty message for the pet section.
  ///
  /// In ko, this message translates to:
  /// **'반려동물을 등록해 주세요.'**
  String get homePetEmpty;

  /// Pet count line.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 {count}마리'**
  String homePetCount(int count);

  /// No description provided for @homeEditAction.
  ///
  /// In ko, this message translates to:
  /// **'수정'**
  String get homeEditAction;

  /// Action to manage water bowls.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 관리'**
  String get homeWaterManage;

  /// Empty message for the water section.
  ///
  /// In ko, this message translates to:
  /// **'물그릇을 등록해 주세요.'**
  String get homeWaterEmpty;

  /// Action to manage litter boxes.
  ///
  /// In ko, this message translates to:
  /// **'화장실 관리'**
  String get homeLitterManage;

  /// Empty message for the litter section.
  ///
  /// In ko, this message translates to:
  /// **'화장실을 등록해 주세요.'**
  String get homeLitterEmpty;

  /// Estimate notice on the home page.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석 결과는 추정 정보이며, 검증된 항목만 표시됩니다.'**
  String get homeEstimateNotice;

  /// Notice when photo selection fails.
  ///
  /// In ko, this message translates to:
  /// **'사진 접근을 확인하고 다시 시도해 주세요.'**
  String get analysisPhotoAccessRetry;

  /// Notice when a photo exceeds 10 MB.
  ///
  /// In ko, this message translates to:
  /// **'사진은 10MB 이하여야 합니다.'**
  String get analysisPhotoTooBig10;

  /// Notice when the comparison photo is missing.
  ///
  /// In ko, this message translates to:
  /// **'비교할 사진을 선택해 주세요.'**
  String get analysisPhotoCompareRequired;

  /// Title for photo comparison.
  ///
  /// In ko, this message translates to:
  /// **'{name} 사진 비교'**
  String analysisCompareTitle(String name);

  /// Badge for water observations.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 사진 관찰'**
  String get analysisWaterObserve;

  /// Badge for litter observations.
  ///
  /// In ko, this message translates to:
  /// **'화장실 사진 관찰'**
  String get analysisLitterObserve;

  /// Baseline photo version line.
  ///
  /// In ko, this message translates to:
  /// **'{photo} {version}번째'**
  String analysisBaselineVersion(String photo, int version);

  /// Title for the photo guide.
  ///
  /// In ko, this message translates to:
  /// **'사진 촬영 가이드'**
  String get analysisPhotoGuideTitle;

  /// Photo guide for water bowls.
  ///
  /// In ko, this message translates to:
  /// **'등록한 정수기 사진과 같은 위치·거리·각도와 충분한 조명에서 정수기 전체가 보이도록 촬영하세요.'**
  String get analysisWaterGuide;

  /// Photo guide for litter boxes.
  ///
  /// In ko, this message translates to:
  /// **'최근 사진과 같은 위치·거리·각도와 충분한 조명에서 대상 전체가 보이도록 촬영하세요.'**
  String get analysisLitterGuide;

  /// Button to run photo analysis.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석'**
  String get analysisRunAction;

  /// Title when analysis is unavailable.
  ///
  /// In ko, this message translates to:
  /// **'분석할 수 없습니다'**
  String get analysisCannotTitle;

  /// Title for the model response page.
  ///
  /// In ko, this message translates to:
  /// **'모델 응답'**
  String get analysisModelResponseTitle;

  /// Button to view the model response.
  ///
  /// In ko, this message translates to:
  /// **'모델 응답 보기'**
  String get analysisViewModelResponse;

  /// Vet disclaimer for analysis results.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석 결과는 추정 정보이며 진단이 아닙니다. 필요한 경우 수의사와 상담하세요.'**
  String get analysisDisclaimerVet;

  /// Label for the decrease rate.
  ///
  /// In ko, this message translates to:
  /// **'최근 사진 대비 감소율 (추정)'**
  String get analysisDecreaseRate;

  /// Label for the decrease volume.
  ///
  /// In ko, this message translates to:
  /// **'감소량 (추정)'**
  String get analysisDecreaseVolume;

  /// Caveat for water results.
  ///
  /// In ko, this message translates to:
  /// **'보충, 증발, 쏟음 또는 공동 사용의 영향을 받을 수 있습니다.'**
  String get analysisWaterCaveat;

  /// Label for the original estimate.
  ///
  /// In ko, this message translates to:
  /// **'원래 추정'**
  String get analysisOriginalEstimate;

  /// Litter counts line.
  ///
  /// In ko, this message translates to:
  /// **'소변 {urine}회 · 대변 {stool}회'**
  String analysisLitterCounts(int urine, int stool);

  /// Notice for uncertain traces.
  ///
  /// In ko, this message translates to:
  /// **'흔적이 겹치거나 가려져 정확하지 않을 수 있습니다.'**
  String get analysisUncertainTraces;

  /// Observed quantity line.
  ///
  /// In ko, this message translates to:
  /// **'관찰량: {quantity} {unit} (추정)'**
  String analysisObservedQuantity(double quantity, String unit);

  /// Label for confirmed urine counts.
  ///
  /// In ko, this message translates to:
  /// **'확인한 소변 흔적 수'**
  String get analysisConfirmedUrine;

  /// Label for confirmed stool counts.
  ///
  /// In ko, this message translates to:
  /// **'확인한 대변 흔적 수'**
  String get analysisConfirmedStool;

  /// Title for cat selection.
  ///
  /// In ko, this message translates to:
  /// **'이용 고양이 선택'**
  String get analysisSelectCat;

  /// Option for an unidentified cat.
  ///
  /// In ko, this message translates to:
  /// **'미확인'**
  String get analysisCatUnknown;

  /// Title for the notes section.
  ///
  /// In ko, this message translates to:
  /// **'특이사항 메모'**
  String get recordsMemoTitle;

  /// Label for the notes field.
  ///
  /// In ko, this message translates to:
  /// **'특이사항 (선택)'**
  String get recordsMemoField;

  /// Hint for the notes field.
  ///
  /// In ko, this message translates to:
  /// **'관찰한 내용을 기록해 주세요.'**
  String get recordsMemoHint;

  /// Validation error for counts.
  ///
  /// In ko, this message translates to:
  /// **'0 이상의 횟수를 입력해 주세요.'**
  String get recordsCountInvalid;

  /// Button to save a record.
  ///
  /// In ko, this message translates to:
  /// **'기록 저장'**
  String get recordsSaveAction;

  /// Badge after saving a record.
  ///
  /// In ko, this message translates to:
  /// **'기록을 저장했습니다.'**
  String get recordsSavedBadge;

  /// Empty message for the family overview.
  ///
  /// In ko, this message translates to:
  /// **'가족 정보를 찾을 수 없습니다.'**
  String get familyOverviewEmpty;

  /// Guidance message for family management.
  ///
  /// In ko, this message translates to:
  /// **'가족 구성원과 반려동물의 사진 및 기록을 함께 확인할 수 있습니다.'**
  String get familyManageMessage;

  /// Description for the current family.
  ///
  /// In ko, this message translates to:
  /// **'현재 선택한 가족'**
  String get familyCurrentSelected;

  /// Family member count line.
  ///
  /// In ko, this message translates to:
  /// **'가족 구성원 {count}명'**
  String familyMemberCount(int count);

  /// Header for the member list.
  ///
  /// In ko, this message translates to:
  /// **'가족 구성원 {count}'**
  String familyMembersHeader(int count);

  /// Notice when the family has no members.
  ///
  /// In ko, this message translates to:
  /// **'구성원이 없습니다.'**
  String get familyNoMembers;

  /// Label for removing a member.
  ///
  /// In ko, this message translates to:
  /// **'{name} 제거'**
  String familyRemoveMemberTooltip(String name);

  /// Header for pending approvals.
  ///
  /// In ko, this message translates to:
  /// **'가입 승인 대기 {count}'**
  String familyPendingHeader(int count);

  /// Notice when no requests are pending.
  ///
  /// In ko, this message translates to:
  /// **'승인 대기 중인 가입 요청이 없습니다.'**
  String get familyNoPendingRequests;

  /// Subtitle for pending requests.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 입력 후 승인 대기 중'**
  String get familyInvitePendingSubtitle;

  /// Button to approve a request.
  ///
  /// In ko, this message translates to:
  /// **'승인'**
  String get familyApproveAction;

  /// Title for the invite section.
  ///
  /// In ko, this message translates to:
  /// **'가족 초대'**
  String get familyInviteTitle;

  /// Action to create an invite code.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 만들기'**
  String get familyCreateCodeAction;

  /// Message for creating an invite code.
  ///
  /// In ko, this message translates to:
  /// **'가족에게 전달할 코드를 발급합니다.'**
  String get familyCreateCodeMessage;

  /// Message for entering an invite code.
  ///
  /// In ko, this message translates to:
  /// **'다른 가족에게 받은 코드로 가입을 요청합니다.'**
  String get familyEnterCodeMessage;

  /// Title for the invite code page.
  ///
  /// In ko, this message translates to:
  /// **'가족 초대 코드'**
  String get familyInviteCodeTitle;

  /// Title for the dedicated code section.
  ///
  /// In ko, this message translates to:
  /// **'초대 전용 가족 코드'**
  String get familyDedicatedCodeTitle;

  /// Message for sharing the code.
  ///
  /// In ko, this message translates to:
  /// **'함께 돌볼 가족에게 이 코드를 전달해 주세요.'**
  String get familyShareCodeMessage;

  /// Notice after copying the code.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드를 복사했습니다.'**
  String get familyCodeCopied;

  /// Button to copy the code.
  ///
  /// In ko, this message translates to:
  /// **'초대 코드 복사하기'**
  String get familyCopyCodeAction;

  /// Title for the join guide.
  ///
  /// In ko, this message translates to:
  /// **'가족 합류 방법 안내'**
  String get familyJoinGuideTitle;

  /// Message for the join guide.
  ///
  /// In ko, this message translates to:
  /// **'가족이 로그인한 뒤 초대 코드를 입력하면 가입을 요청할 수 있습니다. 관리자가 승인하면 함께 이용할 수 있습니다.'**
  String get familyJoinGuideMessage;

  /// Label for close buttons.
  ///
  /// In ko, this message translates to:
  /// **'닫기'**
  String get commonClose;

  /// Notice after requesting to join.
  ///
  /// In ko, this message translates to:
  /// **'가입 요청을 보냈습니다. 관리자의 승인을 기다려 주세요.'**
  String get familyJoinRequested;

  /// Notice after approving a request.
  ///
  /// In ko, this message translates to:
  /// **'가입을 승인했습니다.'**
  String get familyApproved;

  /// Confirmation for removing a member.
  ///
  /// In ko, this message translates to:
  /// **'이 구성원의 가족 정보 접근이 중단됩니다.'**
  String get familyRemoveConfirm;

  /// Button to remove a member.
  ///
  /// In ko, this message translates to:
  /// **'제거'**
  String get familyRemoveAction;

  /// Notice after removing a member.
  ///
  /// In ko, this message translates to:
  /// **'구성원을 제거했습니다.'**
  String get familyMemberRemoved;

  /// Label for register buttons.
  ///
  /// In ko, this message translates to:
  /// **'등록'**
  String get commonRegister;

  /// Notice when deletion fails.
  ///
  /// In ko, this message translates to:
  /// **'삭제하지 못했습니다.'**
  String get commonDeleteFailed;

  /// Label for rename actions.
  ///
  /// In ko, this message translates to:
  /// **'이름 변경'**
  String get commonRename;

  /// Notice when renaming fails.
  ///
  /// In ko, this message translates to:
  /// **'이름을 변경하지 못했습니다.'**
  String get commonRenameFailed;

  /// Validation error for non-positive numbers.
  ///
  /// In ko, this message translates to:
  /// **'0보다 큰 숫자를 입력해 주세요.'**
  String get commonPositiveNumber;

  /// Ordinal version label.
  ///
  /// In ko, this message translates to:
  /// **'{version}번째'**
  String ordinalVersion(int version);

  /// Label for adding a litter box.
  ///
  /// In ko, this message translates to:
  /// **'화장실 추가'**
  String get litterAddAction;

  /// Empty message for the litter list.
  ///
  /// In ko, this message translates to:
  /// **'등록된 화장실이 없습니다.'**
  String get litterEmptyMessage;

  /// Title for litter registration.
  ///
  /// In ko, this message translates to:
  /// **'화장실 등록'**
  String get litterRegisterTitle;

  /// Badge for litter monitoring.
  ///
  /// In ko, this message translates to:
  /// **'배변 건강 모니터링'**
  String get litterHealthBadge;

  /// Hint for litter registration.
  ///
  /// In ko, this message translates to:
  /// **'깨끗한 모래 사진과 화장실 정보를 등록해 주세요.'**
  String get litterRegisterHint;

  /// Photo guide for litter boxes.
  ///
  /// In ko, this message translates to:
  /// **'깨끗한 모래와 화장실 전체가 보이도록 촬영해 주세요.'**
  String get litterPhotoGuide;

  /// Section title for automatic devices.
  ///
  /// In ko, this message translates to:
  /// **'자동화장실 기기 여부'**
  String get litterAutomaticSection;

  /// Label for automatic litter boxes.
  ///
  /// In ko, this message translates to:
  /// **'자동화장실'**
  String get litterAutomaticLabel;

  /// Title when automatic boxes are blocked.
  ///
  /// In ko, this message translates to:
  /// **'자동화장실 등록 제한 안내'**
  String get litterAutomaticBlockedTitle;

  /// Message when automatic boxes are blocked.
  ///
  /// In ko, this message translates to:
  /// **'자동화장실은 분석 대상으로 등록할 수 없습니다.'**
  String get litterAutomaticBlockedMessage;

  /// Title for baseline registration.
  ///
  /// In ko, this message translates to:
  /// **'최근 사진 등록'**
  String get litterBaselineRegisterTitle;

  /// Hint for baseline registration.
  ///
  /// In ko, this message translates to:
  /// **'청소 직후 깨끗한 모래 사진을 등록하세요.'**
  String get litterBaselineRegisterHint;

  /// Label for litter baseline photos.
  ///
  /// In ko, this message translates to:
  /// **'화장실 최근 사진'**
  String get litterBaselineLabel;

  /// Title for the litter profile section.
  ///
  /// In ko, this message translates to:
  /// **'화장실 프로필 및 치수'**
  String get litterProfileTitle;

  /// Label for the litter name field.
  ///
  /// In ko, this message translates to:
  /// **'화장실 이름'**
  String get litterNameLabel;

  /// Title for sharing cats.
  ///
  /// In ko, this message translates to:
  /// **'함께 사용하는 고양이'**
  String get litterSharedCats;

  /// Notice when no cats exist.
  ///
  /// In ko, this message translates to:
  /// **'먼저 고양이를 등록해 주세요.'**
  String get litterRegisterCatsFirst;

  /// Title for dimensions.
  ///
  /// In ko, this message translates to:
  /// **'상세 규격 치수 (선택)'**
  String get litterDimensionsTitle;

  /// Label for the width field.
  ///
  /// In ko, this message translates to:
  /// **'내부 가로 (cm, 선택)'**
  String get litterWidthLabel;

  /// Label for the length field.
  ///
  /// In ko, this message translates to:
  /// **'내부 세로 (cm, 선택)'**
  String get litterLengthLabel;

  /// Label for the height field.
  ///
  /// In ko, this message translates to:
  /// **'모래 높이 (cm, 선택)'**
  String get litterHeightLabel;

  /// Title for the quantity notice.
  ///
  /// In ko, this message translates to:
  /// **'관찰량 안내'**
  String get litterVolumeGuideTitle;

  /// Message for the quantity notice.
  ///
  /// In ko, this message translates to:
  /// **'관찰량 추정은 검증 전이며 치수를 입력해도 제공되지 않습니다.'**
  String get litterVolumeGuideMessage;

  /// Notice when cats or photos are missing.
  ///
  /// In ko, this message translates to:
  /// **'고양이와 최근 사진을 선택해 주세요.'**
  String get litterCatsAndPhotoRequired;

  /// Title for renaming.
  ///
  /// In ko, this message translates to:
  /// **'화장실 이름 변경'**
  String get litterRenameTitle;

  /// Notice when baseline change fails.
  ///
  /// In ko, this message translates to:
  /// **'최근 사진을 변경하지 못했습니다.'**
  String get litterBaselineChangeFailed;

  /// Button to delete a litter box.
  ///
  /// In ko, this message translates to:
  /// **'화장실 삭제'**
  String get litterDeleteAction;

  /// Baseline version title.
  ///
  /// In ko, this message translates to:
  /// **'최근 사진 {version}번째'**
  String litterBaselineVersion(int version);

  /// Prefix for new baseline photo actions.
  ///
  /// In ko, this message translates to:
  /// **'새 사진'**
  String get litterNewBaselinePrefix;

  /// Title for baseline history.
  ///
  /// In ko, this message translates to:
  /// **'사진 등록 이력'**
  String get litterBaselineHistoryTitle;

  /// Title for the baseline guide.
  ///
  /// In ko, this message translates to:
  /// **'최근 사진 안내'**
  String get litterBaselineGuideTitle;

  /// Message for the baseline guide.
  ///
  /// In ko, this message translates to:
  /// **'청소하거나 모래를 교체했다면 새 사진을 등록하세요. 이전 사진도 보관됩니다.\n사진 분석 결과는 검증된 경우에만 제공됩니다.'**
  String get litterBaselineGuideMessage;

  /// Button to view records.
  ///
  /// In ko, this message translates to:
  /// **'기록 보기'**
  String get litterViewRecords;

  /// Title for a target record page.
  ///
  /// In ko, this message translates to:
  /// **'{name} 기록'**
  String recordsTargetTitle(String name);

  /// Empty message for records.
  ///
  /// In ko, this message translates to:
  /// **'저장된 분석 기록이 없습니다.'**
  String get recordsEmptyMessage;

  /// Title for the litter trend chart.
  ///
  /// In ko, this message translates to:
  /// **'화장실 횟수 추이'**
  String get recordsLitterTrendTitle;

  /// Label for urine counts.
  ///
  /// In ko, this message translates to:
  /// **'소변'**
  String get recordsUrineLabel;

  /// Label for stool counts.
  ///
  /// In ko, this message translates to:
  /// **'대변'**
  String get recordsStoolLabel;

  /// Title for the health timeline.
  ///
  /// In ko, this message translates to:
  /// **'건강 체크 타임라인'**
  String get recordsTimelineTitle;

  /// Title for the records guidance.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석 기록'**
  String get recordsHistoryTitle;

  /// Disclaimer for records.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석 결과는 추정 정보이며 진단이 아닙니다.'**
  String get recordsEstimateDisclaimer;

  /// Filter chip for all records.
  ///
  /// In ko, this message translates to:
  /// **'전체'**
  String get recordsFilterAll;

  /// Empty message for filtered records.
  ///
  /// In ko, this message translates to:
  /// **'선택한 종류의 기록이 없습니다.'**
  String get recordsEmptyFiltered;

  /// Date label for record groups.
  ///
  /// In ko, this message translates to:
  /// **'{year}년 {month}월 {day}일'**
  String recordsDateLabel(int year, int month, int day);

  /// Label for record photos.
  ///
  /// In ko, this message translates to:
  /// **'기록 사진'**
  String get recordsPhotoLabel;

  /// Notice after copying share text.
  ///
  /// In ko, this message translates to:
  /// **'공유 문구가 클립보드에 복사되었습니다.'**
  String get recordsShareCopied;

  /// Notice when sharing fails.
  ///
  /// In ko, this message translates to:
  /// **'공유 화면을 열지 못했습니다.'**
  String get recordsShareFailed;

  /// Label for registration photos.
  ///
  /// In ko, this message translates to:
  /// **'등록 사진'**
  String get recordsRegistrationPhoto;

  /// Photo selection timestamp.
  ///
  /// In ko, this message translates to:
  /// **'사진 선택: {timestamp}'**
  String recordsPhotoSelectedAt(String timestamp);

  /// Analysis timestamp.
  ///
  /// In ko, this message translates to:
  /// **'분석 시각: {timestamp}'**
  String recordsAnalyzedAt(String timestamp);

  /// Disclaimer for outcomes.
  ///
  /// In ko, this message translates to:
  /// **'관찰 결과는 추정 정보이며 진단이 아닙니다.'**
  String get recordsOutcomeDisclaimer;

  /// Unavailable line with a reason.
  ///
  /// In ko, this message translates to:
  /// **'분석 불가: {text}'**
  String recordsUnavailableWith(String text);

  /// Label for the water percent.
  ///
  /// In ko, this message translates to:
  /// **'물 감소율 (추정)'**
  String get recordsWaterPercentLabel;

  /// Model confidence line.
  ///
  /// In ko, this message translates to:
  /// **'모델 자체 평가 신뢰도 {confidence}% (실제 정확도 아님)'**
  String recordsModelConfidence(double confidence);

  /// Label for the water volume.
  ///
  /// In ko, this message translates to:
  /// **'물 감소량 (추정)'**
  String get recordsWaterVolumeLabel;

  /// Caveat for water results.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 기준의 변화이며 개별 반려동물의 음수량은 아닙니다.'**
  String get recordsWaterCaveat;

  /// Label for user-confirmed values.
  ///
  /// In ko, this message translates to:
  /// **'사용자 확인'**
  String get recordsUserConfirmed;

  /// Observed quantity line.
  ///
  /// In ko, this message translates to:
  /// **'관찰량 {quantity} {unit} (추정)'**
  String recordsObservedQuantity(double quantity, String unit);

  /// Selected cat line.
  ///
  /// In ko, this message translates to:
  /// **'고양이: {name}'**
  String recordsCatWith(String name);

  /// Label when the cat cannot be verified.
  ///
  /// In ko, this message translates to:
  /// **'확인 불가'**
  String get recordsCatUnverified;

  /// Button to share a record.
  ///
  /// In ko, this message translates to:
  /// **'기록 공유하기'**
  String get recordsShareAction;

  /// Button to edit a record.
  ///
  /// In ko, this message translates to:
  /// **'기록 수정'**
  String get recordsEditAction;

  /// Title for the guardian check.
  ///
  /// In ko, this message translates to:
  /// **'보호자 관찰 확인'**
  String get recordsGuardianCheckTitle;

  /// Message for the guardian check.
  ///
  /// In ko, this message translates to:
  /// **'원래 분석 결과는 유지되며 확인한 값과 메모만 수정됩니다.'**
  String get recordsGuardianCheckMessage;

  /// Title for the confirmed section.
  ///
  /// In ko, this message translates to:
  /// **'확인한 관찰'**
  String get recordsConfirmedSection;

  /// Label for adding a water bowl.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 추가'**
  String get waterAddAction;

  /// Empty message for the water list.
  ///
  /// In ko, this message translates to:
  /// **'등록된 물그릇이 없습니다.'**
  String get waterEmptyMessage;

  /// Notice when photo permission is denied.
  ///
  /// In ko, this message translates to:
  /// **'사진 접근 권한을 확인해 주세요.'**
  String get photoPermissionCheck;

  /// Title for water registration.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 등록'**
  String get waterRegisterTitle;

  /// Badge for water monitoring.
  ///
  /// In ko, this message translates to:
  /// **'음수량 스마트 모니터링'**
  String get waterIntakeBadge;

  /// Headline for water registration.
  ///
  /// In ko, this message translates to:
  /// **'새 물그릇 등록'**
  String get waterNewRegisterHeadline;

  /// Hint for water registration.
  ///
  /// In ko, this message translates to:
  /// **'정수기 사진과 기본 정보를 입력해 주세요.'**
  String get waterRegisterHint;

  /// Photo guide for water bowls.
  ///
  /// In ko, this message translates to:
  /// **'정수기 전체가 잘 보이도록 서로 다른 각도에서 사진 3장을 촬영해 주세요.'**
  String get waterPhotoGuide;

  /// Hint for angle photos.
  ///
  /// In ko, this message translates to:
  /// **'정수기의 앞, 뒤, 위에서 촬영한 사진을 각각 등록해 주세요.'**
  String get waterAnglePhotosHint;

  /// Purifier photo label for an angle.
  ///
  /// In ko, this message translates to:
  /// **'정수기 {angle} 사진'**
  String waterPurifierAnglePhoto(String angle);

  /// Notice that an angle photo is selected.
  ///
  /// In ko, this message translates to:
  /// **'{angle} 사진 선택됨'**
  String waterAnglePhotoSelected(String angle);

  /// Title for the bowl info section.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 정보'**
  String get waterInfoTitle;

  /// Label for the bowl name field.
  ///
  /// In ko, this message translates to:
  /// **'그릇 이름'**
  String get waterNameLabel;

  /// Title for sharing pets.
  ///
  /// In ko, this message translates to:
  /// **'함께 사용하는 반려동물'**
  String get waterSharedPets;

  /// Notice when no pets exist.
  ///
  /// In ko, this message translates to:
  /// **'먼저 반려동물을 등록해 주세요.'**
  String get waterRegisterPetsFirst;

  /// Title for physical specs.
  ///
  /// In ko, this message translates to:
  /// **'선택 물리 사양'**
  String get waterSpecsTitle;

  /// Label for the empty weight field.
  ///
  /// In ko, this message translates to:
  /// **'빈 그릇 무게 (g, 선택)'**
  String get waterEmptyWeightLabel;

  /// Label for the full volume field.
  ///
  /// In ko, this message translates to:
  /// **'가득 찬 물의 양 (mL, 선택)'**
  String get waterFullVolumeLabel;

  /// Helper for the full volume field.
  ///
  /// In ko, this message translates to:
  /// **'그릇 무게를 제외한 물의 양'**
  String get waterFullVolumeHelper;

  /// Label for the photo notes field.
  ///
  /// In ko, this message translates to:
  /// **'사진 특이사항 (선택)'**
  String get waterPhotoNotesLabel;

  /// Hint for the photo notes field.
  ///
  /// In ko, this message translates to:
  /// **'예: 정수기에 물이 70% 차 있는 상태예요'**
  String get waterPhotoNotesHint;

  /// Title for the measurement notice.
  ///
  /// In ko, this message translates to:
  /// **'측정 유의사항'**
  String get waterMeasureCautionTitle;

  /// Message for the measurement notice.
  ///
  /// In ko, this message translates to:
  /// **'부피 추정 기능은 검증 전이며 입력값이 있어도 제공되지 않습니다.'**
  String get waterMeasureCautionMessage;

  /// Notice when pets or photos are missing.
  ///
  /// In ko, this message translates to:
  /// **'반려동물과 정수기의 앞·뒤·위 사진을 모두 선택해 주세요.'**
  String get waterPetsAndPhotosRequired;

  /// Notice after setup completes.
  ///
  /// In ko, this message translates to:
  /// **'정수기 초기 설정을 완료했습니다.'**
  String get waterSetupComplete;

  /// Notice when the initial level is unknown.
  ///
  /// In ko, this message translates to:
  /// **'정수기는 등록됐지만 초기 수위를 확인하지 못했습니다. 다시 분석해 주세요.'**
  String get waterSetupLevelUnknown;

  /// Notice with a setup failure detail.
  ///
  /// In ko, this message translates to:
  /// **'정수기는 등록됐지만 초기 설정에 실패했습니다: {detail}'**
  String waterSetupFailedDetail(String detail);

  /// Notice to retry the initial analysis.
  ///
  /// In ko, this message translates to:
  /// **'정수기는 등록됐습니다. 초기 분석을 다시 시도해 주세요.'**
  String get waterRegisteredRetryAnalysis;

  /// Title for renaming.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 이름 변경'**
  String get waterRenameTitle;

  /// Label for the bowl name field.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 이름'**
  String get waterBowlNameLabel;

  /// Notice to re-register photos.
  ///
  /// In ko, this message translates to:
  /// **'초기 설정을 위해 정수기 앞·뒤·위 사진을 다시 등록해 주세요.'**
  String get waterReregisterPhotos;

  /// Notice with an unknown level reason.
  ///
  /// In ko, this message translates to:
  /// **'초기 수위를 확인하지 못했습니다. {reason}'**
  String waterInitialLevelUnknown(String reason);

  /// Title for new photo notes.
  ///
  /// In ko, this message translates to:
  /// **'새 정수기 사진 특이사항'**
  String get waterNewPhotoNotesTitle;

  /// Hint for new photo notes.
  ///
  /// In ko, this message translates to:
  /// **'예: 물이 70% 차 있는 상태예요'**
  String get waterNewPhotoNotesHint;

  /// Button to save a purifier photo.
  ///
  /// In ko, this message translates to:
  /// **'정수기 사진 저장'**
  String get waterSavePhotoAction;

  /// Notice when photo change fails.
  ///
  /// In ko, this message translates to:
  /// **'정수기 사진을 변경하지 못했습니다.'**
  String get waterPhotoChangeFailed;

  /// Title for purifier details.
  ///
  /// In ko, this message translates to:
  /// **'정수기 상세 정보'**
  String get waterDetailTitle;

  /// Sharing description.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 · 반려동물 {count}마리와 함께 사용'**
  String waterSharedWithPets(int count);

  /// Button to delete a water bowl.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 삭제'**
  String get waterDeleteAction;

  /// Purifier photo version title.
  ///
  /// In ko, this message translates to:
  /// **'정수기 사진 {version}번째'**
  String waterPurifierPhotoVersion(int version);

  /// Recent registration line.
  ///
  /// In ko, this message translates to:
  /// **'최근 등록 {timestamp}'**
  String waterRecentlyRegistered(String timestamp);

  /// Hint for refills.
  ///
  /// In ko, this message translates to:
  /// **'물을 보충하거나 교체했다면 새 사진을 등록하세요.'**
  String get waterRefillHint;

  /// Purifier photo label for a bowl.
  ///
  /// In ko, this message translates to:
  /// **'{name} 정수기 사진'**
  String waterBowlPurifierPhoto(String name);

  /// Title for photo notes.
  ///
  /// In ko, this message translates to:
  /// **'사진 특이사항'**
  String get waterPhotoNotesTitle;

  /// Title for first photos.
  ///
  /// In ko, this message translates to:
  /// **'처음 등록한 정수기 사진'**
  String get waterFirstPhotosTitle;

  /// Title for device info.
  ///
  /// In ko, this message translates to:
  /// **'기기 정보'**
  String get waterDeviceTitle;

  /// Label for the full volume metric.
  ///
  /// In ko, this message translates to:
  /// **'가득 찬 물의 양'**
  String get waterFullVolumeMetric;

  /// Label for the empty weight metric.
  ///
  /// In ko, this message translates to:
  /// **'빈 기기 무게'**
  String get waterEmptyDeviceWeight;

  /// Title for photo history.
  ///
  /// In ko, this message translates to:
  /// **'정수기 사진 변경 이력'**
  String get waterPhotoHistoryTitle;

  /// Hint for photo history.
  ///
  /// In ko, this message translates to:
  /// **'이전 정수기 사진은 기록과 함께 보관됩니다.'**
  String get waterPhotoHistoryHint;

  /// Badge for the current baseline.
  ///
  /// In ko, this message translates to:
  /// **'최근 사진'**
  String get waterCurrentBaseline;

  /// Title for the outcome guide.
  ///
  /// In ko, this message translates to:
  /// **'관찰 결과 안내'**
  String get waterOutcomeGuideTitle;

  /// Message for the outcome guide.
  ///
  /// In ko, this message translates to:
  /// **'사진 분석은 최근 사진 대비 변화를 추정하며, 실제 반려동물의 음수량이나 건강 상태를 진단하지 않습니다.'**
  String get waterOutcomeGuideMessage;

  /// Button to reanalyze.
  ///
  /// In ko, this message translates to:
  /// **'등록 사진 다시 분석하기'**
  String get waterReanalyzeAction;

  /// Button to view level history.
  ///
  /// In ko, this message translates to:
  /// **'수위 기록 보기'**
  String get waterViewHistoryAction;

  /// Button to view past records.
  ///
  /// In ko, this message translates to:
  /// **'이전 분석 기록 보기'**
  String get waterViewPastRecords;

  /// Button to take a new photo.
  ///
  /// In ko, this message translates to:
  /// **'새 사진 촬영'**
  String get waterTakeNewPhoto;

  /// Button to choose a new photo.
  ///
  /// In ko, this message translates to:
  /// **'새 사진 선택'**
  String get waterChooseNewPhoto;

  /// Shown when health chat is unavailable.
  ///
  /// In ko, this message translates to:
  /// **'건강 상담 연결을 사용할 수 없습니다.'**
  String get chatUnavailable;

  /// Notice when photo selection fails.
  ///
  /// In ko, this message translates to:
  /// **'사진을 선택할 수 없습니다.'**
  String get chatPhotoSelectFailed;

  /// Title for the pet mention dialog.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 멘션'**
  String get chatMentionPets;

  /// Notice when no pets exist.
  ///
  /// In ko, this message translates to:
  /// **'등록된 반려동물이 없습니다.'**
  String get chatNoPets;

  /// Label for done buttons.
  ///
  /// In ko, this message translates to:
  /// **'완료'**
  String get commonDone;

  /// Title for the health chat page.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 건강 상담'**
  String get chatTitle;

  /// Disclaimer for health chat.
  ///
  /// In ko, this message translates to:
  /// **'AI 답변은 참고 정보이며 진단을 대신하지 않습니다. 멘션한 반려동물의 프로필과 최근 관찰 기록이 AI에 전달됩니다. 대화와 사진은 가족에게 공유됩니다.'**
  String get chatDisclaimer;

  /// Error when the conversation fails to load.
  ///
  /// In ko, this message translates to:
  /// **'대화를 불러오지 못했습니다.'**
  String get chatLoadFailed;

  /// Prompt for an empty conversation.
  ///
  /// In ko, this message translates to:
  /// **'반려동물의 건강에 관해 물어보세요.'**
  String get chatEmptyPrompt;

  /// Label for guardian messages.
  ///
  /// In ko, this message translates to:
  /// **'보호자'**
  String get chatGuardianLabel;

  /// Label for assistant messages.
  ///
  /// In ko, this message translates to:
  /// **'건강 상담'**
  String get chatAssistantLabel;

  /// Label while a photo loads.
  ///
  /// In ko, this message translates to:
  /// **'사진 불러오는 중'**
  String get chatPhotoLoading;

  /// Tooltip for removing a photo.
  ///
  /// In ko, this message translates to:
  /// **'사진 제거'**
  String get chatRemovePhoto;

  /// Tooltip for attaching a photo.
  ///
  /// In ko, this message translates to:
  /// **'사진 첨부'**
  String get chatAttachPhoto;

  /// Hint for the chat input.
  ///
  /// In ko, this message translates to:
  /// **'건강에 대해 물어보세요'**
  String get chatInputHint;

  /// Tooltip for sending.
  ///
  /// In ko, this message translates to:
  /// **'전송'**
  String get chatSendAction;

  /// Tooltip for editing a profile.
  ///
  /// In ko, this message translates to:
  /// **'프로필 수정'**
  String get petEditProfile;

  /// Error when health records fail to load.
  ///
  /// In ko, this message translates to:
  /// **'건강 기록을 불러오지 못했습니다.'**
  String get petHealthLoadFailed;

  /// Pet age line.
  ///
  /// In ko, this message translates to:
  /// **'나이 {age}개월'**
  String petAgeLine(int age);

  /// Pet weight line.
  ///
  /// In ko, this message translates to:
  /// **'몸무게 {weight} kg'**
  String petWeightLine(double weight);

  /// Title for the water section.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 관찰'**
  String get petWaterSection;

  /// Hint for the water section.
  ///
  /// In ko, this message translates to:
  /// **'함께 사용하는 물그릇의 수위입니다. 개별 음수량은 알 수 없습니다.'**
  String get petWaterSectionHint;

  /// Notice when no bowls are linked.
  ///
  /// In ko, this message translates to:
  /// **'연결된 물그릇이 없습니다.'**
  String get petNoBowls;

  /// Subtitle for shared bowls.
  ///
  /// In ko, this message translates to:
  /// **'여러 반려동물이 함께 사용'**
  String get petSharedBowl;

  /// Subtitle for linked bowls.
  ///
  /// In ko, this message translates to:
  /// **'연결된 물그릇'**
  String get petLinkedBowl;

  /// Error when level records fail to load.
  ///
  /// In ko, this message translates to:
  /// **'수위 기록을 불러오지 못했습니다.'**
  String get petLevelHistoryFailed;

  /// Title for level records.
  ///
  /// In ko, this message translates to:
  /// **'수위 관찰 기록'**
  String get petLevelRecord;

  /// Label for unknown times.
  ///
  /// In ko, this message translates to:
  /// **'시간 미확인'**
  String get petTimeUnknown;

  /// Notice when level records are unavailable.
  ///
  /// In ko, this message translates to:
  /// **'수위 기록을 사용할 수 없습니다.'**
  String get petLevelHistoryUnavailable;

  /// Title for the litter section.
  ///
  /// In ko, this message translates to:
  /// **'화장실 관찰'**
  String get petLitterSection;

  /// Hint for the litter section.
  ///
  /// In ko, this message translates to:
  /// **'이 반려동물을 이용자로 선택해 저장한 기록만 표시합니다.'**
  String get petLitterSectionHint;

  /// Notice when no boxes are linked.
  ///
  /// In ko, this message translates to:
  /// **'연결된 화장실이 없습니다.'**
  String get petNoBoxes;

  /// Linked boxes line.
  ///
  /// In ko, this message translates to:
  /// **'연결된 화장실: {names}'**
  String petLinkedBoxes(String names);

  /// Notice when no records exist.
  ///
  /// In ko, this message translates to:
  /// **'이 반려동물로 지정된 관찰 기록이 없습니다.'**
  String get petNoRecords;

  /// Counts suffix for record lines.
  ///
  /// In ko, this message translates to:
  /// **' · 소변 {urine}회 · 대변 {stool}회'**
  String petRecordCountsLine(int urine, int stool);

  /// Header for shared record text.
  ///
  /// In ko, this message translates to:
  /// **'[하릅 관찰 기록]'**
  String get shareHeader;

  /// Share line for water percent.
  ///
  /// In ko, this message translates to:
  /// **'물 감소율: {percent}% (추정)'**
  String shareWaterPercent(double percent);

  /// Share line for water volume.
  ///
  /// In ko, this message translates to:
  /// **'물 감소량: {volume} mL (추정)'**
  String shareWaterVolume(double volume);

  /// Share line for urine counts.
  ///
  /// In ko, this message translates to:
  /// **'확인한 소변: {count}회'**
  String shareConfirmedUrine(int count);

  /// Share line for stool counts.
  ///
  /// In ko, this message translates to:
  /// **'확인한 대변: {count}회'**
  String shareConfirmedStool(int count);

  /// Share line for notes.
  ///
  /// In ko, this message translates to:
  /// **'메모: {notes}'**
  String shareMemo(String notes);

  /// Bottom navigation label for HealthReport.
  ///
  /// In ko, this message translates to:
  /// **'건강리포트'**
  String get navHealthReport;

  /// Bottom navigation label for Chat.
  ///
  /// In ko, this message translates to:
  /// **'채팅'**
  String get navChat;

  /// Bottom navigation label for MyPage.
  ///
  /// In ko, this message translates to:
  /// **'마이페이지'**
  String get navMyPage;

  /// Health report: reportNoPets.
  ///
  /// In ko, this message translates to:
  /// **'건강리포트를 보려면 반려동물을 등록해 주세요.'**
  String get reportNoPets;

  /// Health report: reportPetSelect.
  ///
  /// In ko, this message translates to:
  /// **'반려동물 선택'**
  String get reportPetSelect;

  /// Health report: reportLoadFailed.
  ///
  /// In ko, this message translates to:
  /// **'건강리포트를 불러오지 못했습니다.'**
  String get reportLoadFailed;

  /// Health report: reportWaterIntakeTitle.
  ///
  /// In ko, this message translates to:
  /// **'음수량'**
  String get reportWaterIntakeTitle;

  /// Health report: reportWaterIntakeUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'반려동물별 음수량은 아직 측정할 수 없어 그래프를 제공하지 않습니다.'**
  String get reportWaterIntakeUnavailable;

  /// Health report: reportWaterContext.
  ///
  /// In ko, this message translates to:
  /// **'아래 그래프는 연결된 물그릇의 수위 변화이며, 반려동물의 음수량이 아닙니다.'**
  String get reportWaterContext;

  /// Health report: reportWaterLevelTitle.
  ///
  /// In ko, this message translates to:
  /// **'물그릇 수위 추이'**
  String get reportWaterLevelTitle;

  /// Health report: reportWaterLevelLabel.
  ///
  /// In ko, this message translates to:
  /// **'현재 수위 (추정)'**
  String get reportWaterLevelLabel;

  /// Health report: reportWaterUnverified.
  ///
  /// In ko, this message translates to:
  /// **'수위 추정치는 정확도 검증 후 표시됩니다.'**
  String get reportWaterUnverified;

  /// Health report: reportSharedBowl.
  ///
  /// In ko, this message translates to:
  /// **'{name} · 함께 사용하는 물그릇'**
  String reportSharedBowl(String name);

  /// Health report: reportLitterAmountTitle.
  ///
  /// In ko, this message translates to:
  /// **'배변량'**
  String get reportLitterAmountTitle;

  /// Health report: reportLitterAttribution.
  ///
  /// In ko, this message translates to:
  /// **'이 반려동물로 지정해 저장한 기록만 표시합니다.'**
  String get reportLitterAttribution;

  /// Health report: reportLitterAmountUnavailable.
  ///
  /// In ko, this message translates to:
  /// **'검증된 배변량 기록이 없어 양을 표시할 수 없습니다.'**
  String get reportLitterAmountUnavailable;

  /// Health report: reportLitterAmountLabel.
  ///
  /// In ko, this message translates to:
  /// **'관찰량 (추정)'**
  String get reportLitterAmountLabel;

  /// Health report: reportLitterCountTitle.
  ///
  /// In ko, this message translates to:
  /// **'배변 횟수 추이'**
  String get reportLitterCountTitle;

  /// Health report: reportLitterCountsUnverified.
  ///
  /// In ko, this message translates to:
  /// **'배변 흔적 횟수는 정확도 검증 후 표시됩니다.'**
  String get reportLitterCountsUnverified;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'ko'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'ko':
      return AppLocalizationsKo();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
