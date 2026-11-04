// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for Korean (`ko`).
class AppLocalizationsKo extends AppLocalizations {
  AppLocalizationsKo([String locale = 'ko']) : super(locale);

  @override
  String get appTitle => '하릅';

  @override
  String get failureUnexpected => '요청을 처리하지 못했습니다.';

  @override
  String get failureNetwork => '네트워크 연결을 확인해 주세요.';

  @override
  String get failureSerialization => '데이터를 읽을 수 없습니다.';

  @override
  String get failureTimeout => '요청 시간이 초과되었습니다. 다시 시도해 주세요.';

  @override
  String get failureCancelled => '요청이 취소되었습니다.';

  @override
  String get failureAuthorization => '접근 권한을 확인해 주세요.';

  @override
  String get failureNotFound => '요청한 정보를 찾을 수 없습니다.';

  @override
  String get failureServer => '서버에 문제가 발생했습니다. 다시 시도해 주세요.';

  @override
  String get failureRequest => '요청을 확인해 주세요.';

  @override
  String get mainWebSetupMessage =>
      '웹 Firebase 설정이 필요합니다. Firebase Console에서 Web 앱을 등록한 뒤 FIREBASE_WEB_API_KEY와 FIREBASE_WEB_APP_ID를 전달해 실행해 주세요.';

  @override
  String get settingsLanguageTitle => '언어';

  @override
  String get settingsLanguageSystem => '기기 설정 따르기';

  @override
  String get authProviderUnavailable => '로그인 제공자를 사용할 수 없습니다.';

  @override
  String get authCancelled => '로그인을 취소했습니다.';

  @override
  String get authInvalidEmail => '이메일 주소 형식이 올바르지 않습니다.';

  @override
  String get authEmailInUse => '이미 가입된 이메일입니다. 로그인해 주세요.';

  @override
  String get authWeakPassword => '비밀번호를 6자 이상 입력해 주세요.';

  @override
  String get authInvalidCredential => '이메일 또는 비밀번호를 확인해 주세요.';

  @override
  String get authTooManyRequests => '시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get authNotEnabled => 'Firebase Console에서 이 로그인 제공자를 활성화해 주세요.';

  @override
  String get appAuthUnavailable => 'Firebase 인증 설정을 사용할 수 없습니다.';

  @override
  String get recordsInvalidAnnotations => '수정한 내용을 확인해 주세요.';

  @override
  String get recordsChanged => '기록이 변경되었습니다. 다시 불러온 후 수정해 주세요.';

  @override
  String get recordsAlreadySaved => '이미 저장된 분석입니다.';

  @override
  String get waterAlreadyRegistered => '이미 등록된 물그릇입니다.';

  @override
  String get waterHistoryUnavailable => '수위 기록을 불러올 수 없습니다.';

  @override
  String get litterAlreadyRegistered => '이미 등록된 화장실입니다.';

  @override
  String get settingsLoadFailed => '앱 정보를 불러오지 못했습니다.';

  @override
  String get settingsOpenLinkFailed => '링크를 열지 못했습니다.';

  @override
  String get familyUnavailable => '가족 공유는 계정과 서버 연결 후 사용할 수 있습니다.';

  @override
  String get familyLoadFailed => '가족 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.';

  @override
  String get familyServerError => '서버에 문제가 있습니다.';

  @override
  String get analysisPhotoRequired => '필요한 사진을 선택해 주세요.';

  @override
  String get analysisPhotoTooLarge => '각 사진은 3MB 이하의 JPEG, PNG 또는 WebP여야 합니다.';

  @override
  String get analysisBaselineRequired => '기준 사진과 비교할 사진을 확인해 주세요.';

  @override
  String get analysisEachPhotoTooLarge => '분석할 사진은 각각 3MB 이하여야 합니다.';

  @override
  String get analysisUnsupportedType => 'JPEG, PNG 또는 WebP 사진만 분석할 수 있습니다.';

  @override
  String get analysisInvalidCounts => '수정한 횟수를 확인해 주세요.';

  @override
  String get analysisUnreliableWater => '물 감소율을 신뢰할 수 없어 분석할 수 없습니다.';

  @override
  String get analysisConfidenceUnknown => '분석 신뢰도를 확인할 수 없습니다.';

  @override
  String get analysisUnreliableLitter => '배설 흔적을 신뢰할 수 없어 분석할 수 없습니다.';

  @override
  String get analysisUnknownOutcome => '분석 결과 유형을 확인할 수 없습니다.';

  @override
  String get analysisServiceUnavailable => '사진 분석 서비스가 아직 준비되지 않았습니다.';

  @override
  String get storagePhotoNotFound => '저장된 사진 파일을 찾지 못했습니다. 사진 저장소 설정을 확인해 주세요.';

  @override
  String get storageBucketMissing =>
      '사진 저장소가 설정되지 않았습니다. Firebase Console에서 Storage 버킷을 생성해 주세요.';

  @override
  String get commonDelete => '삭제';

  @override
  String targetDeleteTitle(String name) {
    return '$name 삭제';
  }

  @override
  String get targetDeleteMessage =>
      '목록에서 삭제할까요? 기존 사진과 관찰 기록은 보관됩니다. 삭제는 가족 관리자만 할 수 있습니다.';

  @override
  String get recordsChartDescription => '각 막대는 한 번의 관찰 결과입니다. 오래된 기록부터 표시합니다.';

  @override
  String recordsChartMaximumText(String text) {
    return '최대 $text';
  }

  @override
  String recordsValueWithUnit(String value, String unit) {
    return '$value$unit';
  }

  @override
  String get recordsCountUnit => '회';

  @override
  String get recordsChecking => '기록 확인 중';

  @override
  String get recordsLoadFailed => '기록을 불러오지 못했습니다.';

  @override
  String get recordsEmpty => '분석 기록 없음';

  @override
  String recordsWaterSummary(double percent) {
    return '물 감소율 $percent% (추정)';
  }

  @override
  String recordsLitterSummary(int urine, int stool) {
    return '소변 $urine회 · 대변 $stool회 (추정)';
  }

  @override
  String get recordsUnavailableShort => '분석 불가';

  @override
  String recordsRecentWith(String summary) {
    return '최근 기록 · $summary';
  }

  @override
  String get authSignUpSubtitle => '함께 돌보는 가족을 위한 계정을 만들어 주세요.';

  @override
  String get authSignInSubtitle => '매일 사진으로 기록하고 함께 살피는 반려동물 건강 케어';

  @override
  String get authContinueWithGoogle => 'Google로 계속';

  @override
  String get authContinueWithApple => 'Apple로 계속';

  @override
  String get authContinueWithKakao => '카카오로 계속';

  @override
  String get authOrEmail => '또는 이메일로 계속';

  @override
  String get authNameLabel => '이름 (선택)';

  @override
  String get authEmailLabel => '이메일';

  @override
  String get authEmailInvalid => '이메일 주소를 확인해 주세요.';

  @override
  String get authPasswordLabel => '비밀번호';

  @override
  String get authSignUpAction => '가입하기';

  @override
  String get authSignInAction => '로그인';

  @override
  String get authHaveAccount => '이미 계정이 있나요? 로그인';

  @override
  String get authNeedAccount => '계정이 없나요? 가입하기';

  @override
  String get authRecheckSession => '세션 다시 확인';

  @override
  String get petManageTitle => '반려동물 관리';

  @override
  String get petAddAction => '반려동물 추가';

  @override
  String get petEmptyMessage => '등록된 반려동물이 없습니다.\n반려동물을 추가해 주세요.';

  @override
  String get petSpeciesCat => '고양이';

  @override
  String get petSpeciesDog => '강아지';

  @override
  String petAgeMonths(int age) {
    return '$age개월';
  }

  @override
  String get petSexFemale => '암컷';

  @override
  String get petSexMale => '수컷';

  @override
  String get petSexUnknown => '성별 모름';

  @override
  String get petDeleteMessage => '반려동물을 삭제하시겠어요? 연결된 기록의 보관 정책은 아직 정해지지 않았습니다.';

  @override
  String get commonSave => '저장';

  @override
  String get petPhotoTooLarge => '사진은 10MB 이하로 선택해 주세요.';

  @override
  String get petPhotoPermissionDenied =>
      '사진 접근 권한을 확인해 주세요. 사진 없이도 저장할 수 있습니다.';

  @override
  String get petPhotoUnavailable => '사진을 가져오지 못했습니다. 다시 시도해 주세요.';

  @override
  String get petPhotoReadFailed => '사진을 읽지 못했습니다. 다시 선택해 주세요.';

  @override
  String get petEditTitle => '반려동물 수정';

  @override
  String get petPhotoLabel => '반려동물 사진';

  @override
  String get petPhotoHint => '선택한 사진은 반려동물 프로필에 표시됩니다.';

  @override
  String get petNameLabel => '이름';

  @override
  String get petNameRequired => '이름을 입력해 주세요.';

  @override
  String get petSpeciesLabel => '종류';

  @override
  String get petAgeLabel => '나이 (개월, 선택)';

  @override
  String get petAgeInvalid => '0 이상의 개월 수를 입력해 주세요.';

  @override
  String get petSexLabel => '성별 (선택)';

  @override
  String get petSexUnspecified => '미입력';

  @override
  String get petSexNotKnown => '모름';

  @override
  String get petWeightLabel => '체중 (kg, 선택)';

  @override
  String get petWeightInvalid => '0보다 큰 체중을 입력해 주세요.';

  @override
  String get waterHistoryTitle => '수위 기록';

  @override
  String get waterHistoryEmpty => '저장된 수위 기록이 없습니다.';

  @override
  String get waterTrendTitle => '수위 추이';

  @override
  String get waterTrendPending => '수위 추정치는 정확도 검증 후 표시됩니다.';

  @override
  String get waterTrendNoData => '그래프에 표시할 수위 기록이 없습니다.';

  @override
  String get waterCurrentLevelEstimated => '현재 수위 (추정)';

  @override
  String waterCurrentLevelValue(String current) {
    return '현재 수위 $current% (추정)';
  }

  @override
  String get waterAnalysisDone => '수위 분석 완료';

  @override
  String get waterChangeDecrease => '감소';

  @override
  String get waterChangeIncrease => '증가';

  @override
  String get waterChangeNone => '변화 없음';

  @override
  String waterChangeWith(String change, String value) {
    return ' · $change $value%p';
  }

  @override
  String get familySelectTitle => '가족 선택';

  @override
  String get familyNestBadge => '우리 가족 보금자리';

  @override
  String get familySelectQuestion => '어떤 가족과 함께 돌볼까요?';

  @override
  String get familySelectHint => '승인된 가족을 선택해 계속하세요.';

  @override
  String get familyEmptyMessage => '참여 중인 가족이 없습니다. 가족을 만들거나 초대 코드를 입력하세요.';

  @override
  String get familyPendingTitle => '관리자 승인 대기 중';

  @override
  String get familyPendingMessage => '승인 후 새로고침하면 가족을 선택할 수 있습니다.';

  @override
  String get familyRefreshStatus => '승인 상태 새로고침';

  @override
  String get familyTogetherTitle => '함께 돌보는 가족';

  @override
  String get familyTogetherMessage => '가족 구성원이 같은 반려동물의 기록을 함께 확인할 수 있어요.';

  @override
  String get familyCreateAction => '가족 만들기';

  @override
  String get familyEnterCodeAction => '초대 코드 입력';

  @override
  String get familyNameLabel => '가족 이름';

  @override
  String get familyCreateSubmit => '만들기';

  @override
  String get familyNameRequired => '가족 이름을 입력해 주세요.';

  @override
  String get familyInviteCodeLabel => '초대 코드';

  @override
  String get familyJoinRequestAction => '가입 요청';

  @override
  String get familyInviteCodeInvalid => '6~12자의 영문 또는 숫자를 입력해 주세요.';

  @override
  String get settingsTitle => '설정';

  @override
  String get settingsEmptyMessage => '설정 정보가 없습니다.';

  @override
  String get settingsMyAccount => '내 계정';

  @override
  String settingsPetSingle(String name) {
    return '등록된 반려동물: $name';
  }

  @override
  String settingsPetCount(int count) {
    return '등록된 반려동물 $count마리';
  }

  @override
  String get settingsNotificationTitle => '스마트 안심 알림 설정';

  @override
  String get settingsWaterAlertTitle => '물그릇 사진 분석 알림';

  @override
  String get settingsWaterAlertMessage => '물그릇 관찰 알림 기능은 준비 중입니다.';

  @override
  String get settingsLitterAlertTitle => '화장실 이상 징후 알림';

  @override
  String get settingsLitterAlertMessage => '화장실 관찰 알림 기능은 준비 중입니다.';

  @override
  String get settingsFamilySyncTitle => '가족 돌봄 기록 실시간 동기화';

  @override
  String get settingsFamilySyncMessage => '가족 기록은 앱에서 확인할 수 있습니다.';

  @override
  String get settingsSupportTitle => '앱 정보 및 지원';

  @override
  String get settingsNoticeTitle => '공지사항 및 업데이트 소식';

  @override
  String get settingsFaqTitle => '자주 묻는 질문 및 문의';

  @override
  String get settingsTermsTitle => '서비스 이용약관';

  @override
  String get settingsComingSoon => '준비 중';

  @override
  String get settingsPrivacyTitle => '개인정보처리방침';

  @override
  String get settingsVersionTitle => '앱 버전 정보';

  @override
  String get settingsSignOutAction => '로그아웃';

  @override
  String get settingsSignOutConfirm => '이 기기에서 로그아웃할까요?';

  @override
  String get settingsWithdrawHint => '하릅 회원 탈퇴 · 준비 중';

  @override
  String get waterPhotoTooLarge => '사진은 3MB 이하여야 합니다.';

  @override
  String get photoFetchFailed => '사진을 가져오지 못했습니다.';

  @override
  String get photoReadFailed => '사진을 읽지 못했습니다.';

  @override
  String get waterServiceUnavailable => '사진 분석 서비스를 사용할 수 없습니다.';

  @override
  String get waterSetupPhotosRequired => '정수기의 앞·뒤·위 사진을 모두 선택해 주세요.';

  @override
  String get waterReadingPhotoRequired => '정수기 사진을 선택해 주세요.';

  @override
  String waterLevelUnknownWith(String reason) {
    return '수위를 확인할 수 없습니다. $reason';
  }

  @override
  String get waterSetupTitle => '정수기 초기 설정';

  @override
  String get waterObserveTitle => '수위 관찰';

  @override
  String get waterSetupGuideTitle => '초기 설정 안내';

  @override
  String get waterObserveGuideTitle => '수위 관찰 안내';

  @override
  String get waterSetupGuideMessage => '정수기의 앞·뒤·위 사진으로 초기 수위를 추정합니다.';

  @override
  String get waterObserveGuideMessage => '정수기 사진 한 장을 올려 직전 수위와 비교합니다.';

  @override
  String get waterAngleFront => '앞';

  @override
  String get waterAngleBack => '뒤';

  @override
  String get waterAngleTop => '위';

  @override
  String waterAnglePhoto(String angle) {
    return '$angle 사진';
  }

  @override
  String get waterPurifierPhoto => '정수기 사진';

  @override
  String get waterSetupAnalyzeAction => '초기 설정 분석';

  @override
  String get waterAnalyzeAction => '수위 분석';

  @override
  String get commonNotice => '안내';

  @override
  String get analysisResultTitle => '분석 결과';

  @override
  String waterCurrentLevelReading(String value) {
    return '현재 수위: $value% (추정)';
  }

  @override
  String waterPreviousLevelReading(String value) {
    return '직전 수위: $value% (추정)';
  }

  @override
  String waterDecreasedSince(String value) {
    return '이전보다 $value%p 감소';
  }

  @override
  String waterIncreasedSince(String value) {
    return '이전보다 $value%p 증가 (물 보충 가능)';
  }

  @override
  String get waterNoChange => '이전과 변화 없음';

  @override
  String get waterSavedPending => '분석을 저장했습니다. 수위 추정치는 정확도 검증 후 표시됩니다.';

  @override
  String get waterEstimateDisclaimer => '사진 분석 결과는 추정치이며 실제 음수량을 의미하지 않습니다.';

  @override
  String get navHome => '홈';

  @override
  String get navWater => '물그릇';

  @override
  String get navLitter => '화장실';

  @override
  String get navCompare => '사진 비교';

  @override
  String get navRecords => '기록 목록';

  @override
  String get homeTargetListError => '대상 목록을 확인한 뒤 다시 시도해 주세요.';

  @override
  String get homePickRecordsTarget => '기록 대상 선택';

  @override
  String get homePickCompareTarget => '사진 비교 대상 선택';

  @override
  String get homePickRecordsHint => '기록을 확인할 대상을 선택해 주세요.';

  @override
  String get homePickCompareHint => '사진을 비교할 대상을 선택해 주세요.';

  @override
  String get homeNoTargets => '먼저 물그릇이나 화장실을 등록해 주세요.';

  @override
  String get homePetError => '반려동물 목록을 확인한 뒤 다시 시도해 주세요.';

  @override
  String get homeSwitchFamily => '가족 바꾸기';

  @override
  String get homeManageFamily => '가족 관리';

  @override
  String get homeHeadline => '함께 돌보는 하루';

  @override
  String get homeSubheadline => '오늘도 반려동물의 일상을 살펴보세요.';

  @override
  String get homeLocalPreview => '개발 미리보기 · 데이터는 앱을 종료하면 사라집니다.';

  @override
  String get homePetTitle => '반려동물';

  @override
  String get homePetEmpty => '반려동물을 등록해 주세요.';

  @override
  String homePetCount(int count) {
    return '반려동물 $count마리';
  }

  @override
  String get homeWaterManage => '물그릇 관리';

  @override
  String get homeWaterEmpty => '물그릇을 등록해 주세요.';

  @override
  String get homeLitterManage => '화장실 관리';

  @override
  String get homeLitterEmpty => '화장실을 등록해 주세요.';

  @override
  String get homeEstimateNotice => '사진 분석 결과는 추정 정보이며, 검증된 항목만 표시됩니다.';

  @override
  String get analysisPhotoAccessRetry => '사진 접근을 확인하고 다시 시도해 주세요.';

  @override
  String get analysisPhotoTooBig10 => '사진은 10MB 이하여야 합니다.';

  @override
  String get analysisPhotoCompareRequired => '비교할 사진을 선택해 주세요.';

  @override
  String analysisCompareTitle(String name) {
    return '$name 사진 비교';
  }

  @override
  String get analysisWaterObserve => '물그릇 사진 관찰';

  @override
  String get analysisLitterObserve => '화장실 사진 관찰';

  @override
  String analysisBaselineVersion(String photo, int version) {
    return '$photo $version번째';
  }

  @override
  String get analysisPhotoGuideTitle => '사진 촬영 가이드';

  @override
  String get analysisWaterGuide =>
      '등록한 정수기 사진과 같은 위치·거리·각도와 충분한 조명에서 정수기 전체가 보이도록 촬영하세요.';

  @override
  String get analysisLitterGuide =>
      '기준 사진과 같은 위치·거리·각도와 충분한 조명에서 대상 전체가 보이도록 촬영하세요.';

  @override
  String get analysisRunAction => '사진 분석';

  @override
  String get analysisCannotTitle => '분석할 수 없습니다';

  @override
  String get analysisModelResponseTitle => '모델 응답';

  @override
  String get analysisViewModelResponse => '모델 응답 보기';

  @override
  String get analysisDisclaimerVet =>
      '사진 분석 결과는 추정 정보이며 진단이 아닙니다. 필요한 경우 수의사와 상담하세요.';

  @override
  String get analysisDecreaseRate => '기준 대비 감소율 (추정)';

  @override
  String get analysisDecreaseVolume => '감소량 (추정)';

  @override
  String get analysisWaterCaveat => '보충, 증발, 쏟음 또는 공동 사용의 영향을 받을 수 있습니다.';

  @override
  String get analysisOriginalEstimate => '원래 추정';

  @override
  String analysisLitterCounts(int urine, int stool) {
    return '소변 $urine회 · 대변 $stool회';
  }

  @override
  String get analysisUncertainTraces => '흔적이 겹치거나 가려져 정확하지 않을 수 있습니다.';

  @override
  String analysisObservedQuantity(double quantity, String unit) {
    return '관찰량: $quantity $unit (추정)';
  }

  @override
  String get analysisConfirmedUrine => '확인한 소변 흔적 수';

  @override
  String get analysisConfirmedStool => '확인한 대변 흔적 수';

  @override
  String get analysisSelectCat => '이용 고양이 선택';

  @override
  String get analysisCatUnknown => '미확인';

  @override
  String get recordsMemoTitle => '특이사항 메모';

  @override
  String get recordsMemoField => '특이사항 (선택)';

  @override
  String get recordsMemoHint => '관찰한 내용을 기록해 주세요.';

  @override
  String get recordsCountInvalid => '0 이상의 횟수를 입력해 주세요.';

  @override
  String get recordsSaveAction => '기록 저장';

  @override
  String get recordsSavedBadge => '기록을 저장했습니다.';

  @override
  String get familyOverviewEmpty => '가족 정보를 찾을 수 없습니다.';

  @override
  String get familyManageMessage => '가족 구성원과 반려동물의 사진 및 기록을 함께 확인할 수 있습니다.';

  @override
  String get familyCurrentSelected => '현재 선택한 가족';

  @override
  String familyMemberCount(int count) {
    return '가족 구성원 $count명';
  }

  @override
  String familyMembersHeader(int count) {
    return '가족 구성원 $count';
  }

  @override
  String get familyNoMembers => '구성원이 없습니다.';

  @override
  String familyRemoveMemberTooltip(String name) {
    return '$name 제거';
  }

  @override
  String familyPendingHeader(int count) {
    return '가입 승인 대기 $count';
  }

  @override
  String get familyNoPendingRequests => '승인 대기 중인 가입 요청이 없습니다.';

  @override
  String get familyInvitePendingSubtitle => '초대 코드 입력 후 승인 대기 중';

  @override
  String get familyApproveAction => '승인';

  @override
  String get familyInviteTitle => '가족 초대';

  @override
  String get familyCreateCodeAction => '초대 코드 만들기';

  @override
  String get familyCreateCodeMessage => '가족에게 전달할 코드를 발급합니다.';

  @override
  String get familyEnterCodeMessage => '다른 가족에게 받은 코드로 가입을 요청합니다.';

  @override
  String get familyInviteCodeTitle => '가족 초대 코드';

  @override
  String get familyDedicatedCodeTitle => '초대 전용 가족 코드';

  @override
  String get familyShareCodeMessage => '함께 돌볼 가족에게 이 코드를 전달해 주세요.';

  @override
  String get familyCodeCopied => '초대 코드를 복사했습니다.';

  @override
  String get familyCopyCodeAction => '초대 코드 복사하기';

  @override
  String get familyJoinGuideTitle => '가족 합류 방법 안내';

  @override
  String get familyJoinGuideMessage =>
      '가족이 로그인한 뒤 초대 코드를 입력하면 가입을 요청할 수 있습니다. 관리자가 승인하면 함께 이용할 수 있습니다.';

  @override
  String get commonClose => '닫기';

  @override
  String get familyJoinRequested => '가입 요청을 보냈습니다. 관리자의 승인을 기다려 주세요.';

  @override
  String get familyApproved => '가입을 승인했습니다.';

  @override
  String get familyRemoveConfirm => '이 구성원의 가족 정보 접근이 중단됩니다.';

  @override
  String get familyRemoveAction => '제거';

  @override
  String get familyMemberRemoved => '구성원을 제거했습니다.';

  @override
  String get commonRegister => '등록';

  @override
  String get commonDeleteFailed => '삭제하지 못했습니다.';

  @override
  String get commonRename => '이름 변경';

  @override
  String get commonRenameFailed => '이름을 변경하지 못했습니다.';

  @override
  String get commonPositiveNumber => '0보다 큰 숫자를 입력해 주세요.';

  @override
  String ordinalVersion(int version) {
    return '$version번째';
  }

  @override
  String get litterAddAction => '화장실 추가';

  @override
  String get litterEmptyMessage => '등록된 화장실이 없습니다.';

  @override
  String get litterRegisterTitle => '화장실 등록';

  @override
  String get litterHealthBadge => '배변 건강 모니터링';

  @override
  String get litterRegisterHint => '깨끗한 모래 사진과 화장실 정보를 등록해 주세요.';

  @override
  String get litterPhotoGuide => '깨끗한 모래와 화장실 전체가 보이도록 촬영해 주세요.';

  @override
  String get litterAutomaticSection => '자동화장실 기기 여부';

  @override
  String get litterAutomaticLabel => '자동화장실';

  @override
  String get litterAutomaticBlockedTitle => '자동화장실 등록 제한 안내';

  @override
  String get litterAutomaticBlockedMessage => '자동화장실은 분석 대상으로 등록할 수 없습니다.';

  @override
  String get litterBaselineRegisterTitle => '기준 사진 등록';

  @override
  String get litterBaselineRegisterHint => '청소 직후 깨끗한 모래 상태를 기준으로 등록하세요.';

  @override
  String get litterBaselineLabel => '화장실 기준 사진';

  @override
  String get litterProfileTitle => '화장실 프로필 및 치수';

  @override
  String get litterNameLabel => '화장실 이름';

  @override
  String get litterSharedCats => '함께 사용하는 고양이';

  @override
  String get litterRegisterCatsFirst => '먼저 고양이를 등록해 주세요.';

  @override
  String get litterDimensionsTitle => '상세 규격 치수 (선택)';

  @override
  String get litterWidthLabel => '내부 가로 (cm, 선택)';

  @override
  String get litterLengthLabel => '내부 세로 (cm, 선택)';

  @override
  String get litterHeightLabel => '모래 높이 (cm, 선택)';

  @override
  String get litterVolumeGuideTitle => '관찰량 안내';

  @override
  String get litterVolumeGuideMessage => '관찰량 추정은 검증 전이며 치수를 입력해도 제공되지 않습니다.';

  @override
  String get litterCatsAndPhotoRequired => '고양이와 기준 사진을 선택해 주세요.';

  @override
  String get litterRenameTitle => '화장실 이름 변경';

  @override
  String get litterBaselineChangeFailed => '기준 사진을 변경하지 못했습니다.';

  @override
  String get litterDeleteAction => '화장실 삭제';

  @override
  String litterBaselineVersion(int version) {
    return '기준 사진 $version번째';
  }

  @override
  String get litterNewBaselinePrefix => '새 기준';

  @override
  String get litterBaselineHistoryTitle => '기준 사진 이력';

  @override
  String get litterBaselineGuideTitle => '기준 사진 안내';

  @override
  String get litterBaselineGuideMessage =>
      '청소하거나 모래를 교체했다면 새 기준 사진을 등록하세요. 이전 기준은 유지됩니다.\n사진 분석 결과는 검증된 경우에만 제공됩니다.';

  @override
  String get litterViewRecords => '기록 보기';

  @override
  String recordsTargetTitle(String name) {
    return '$name 기록';
  }

  @override
  String get recordsEmptyMessage => '저장된 분석 기록이 없습니다.';

  @override
  String get recordsLitterTrendTitle => '화장실 횟수 추이';

  @override
  String get recordsUrineLabel => '소변';

  @override
  String get recordsStoolLabel => '대변';

  @override
  String get recordsTimelineTitle => '건강 체크 타임라인';

  @override
  String get recordsHistoryTitle => '사진 분석 기록';

  @override
  String get recordsEstimateDisclaimer => '사진 분석 결과는 추정 정보이며 진단이 아닙니다.';

  @override
  String get recordsFilterAll => '전체';

  @override
  String get recordsEmptyFiltered => '선택한 종류의 기록이 없습니다.';

  @override
  String recordsDateLabel(int year, int month, int day) {
    return '$year년 $month월 $day일';
  }

  @override
  String get recordsPhotoLabel => '기록 사진';

  @override
  String get recordsShareCopied => '공유 문구가 클립보드에 복사되었습니다.';

  @override
  String get recordsShareFailed => '공유 화면을 열지 못했습니다.';

  @override
  String get recordsRegistrationPhoto => '등록 사진';

  @override
  String recordsPhotoSelectedAt(String timestamp) {
    return '사진 선택: $timestamp';
  }

  @override
  String recordsAnalyzedAt(String timestamp) {
    return '분석 시각: $timestamp';
  }

  @override
  String get recordsOutcomeDisclaimer => '관찰 결과는 추정 정보이며 진단이 아닙니다.';

  @override
  String recordsUnavailableWith(String text) {
    return '분석 불가: $text';
  }

  @override
  String get recordsWaterPercentLabel => '물 감소율 (추정)';

  @override
  String recordsModelConfidence(double confidence) {
    return '모델 자체 평가 신뢰도 $confidence% (실제 정확도 아님)';
  }

  @override
  String get recordsWaterVolumeLabel => '물 감소량 (추정)';

  @override
  String get recordsWaterCaveat => '물그릇 기준의 변화이며 개별 반려동물의 음수량은 아닙니다.';

  @override
  String get recordsUserConfirmed => '사용자 확인';

  @override
  String recordsObservedQuantity(double quantity, String unit) {
    return '관찰량 $quantity $unit (추정)';
  }

  @override
  String recordsCatWith(String name) {
    return '고양이: $name';
  }

  @override
  String get recordsCatUnverified => '확인 불가';

  @override
  String get recordsShareAction => '기록 공유하기';

  @override
  String get recordsEditAction => '기록 수정';

  @override
  String get recordsGuardianCheckTitle => '보호자 관찰 확인';

  @override
  String get recordsGuardianCheckMessage => '원래 분석 결과는 유지되며 확인한 값과 메모만 수정됩니다.';

  @override
  String get recordsConfirmedSection => '확인한 관찰';

  @override
  String get waterAddAction => '물그릇 추가';

  @override
  String get waterEmptyMessage => '등록된 물그릇이 없습니다.';

  @override
  String get photoPermissionCheck => '사진 접근 권한을 확인해 주세요.';

  @override
  String get waterRegisterTitle => '물그릇 등록';

  @override
  String get waterIntakeBadge => '음수량 스마트 모니터링';

  @override
  String get waterNewRegisterHeadline => '새 물그릇 등록';

  @override
  String get waterRegisterHint => '정수기 사진과 기본 정보를 입력해 주세요.';

  @override
  String get waterPhotoGuide => '정수기 전체가 잘 보이도록 서로 다른 각도에서 사진 3장을 촬영해 주세요.';

  @override
  String get waterAnglePhotosHint => '정수기의 앞, 뒤, 위에서 촬영한 사진을 각각 등록해 주세요.';

  @override
  String waterPurifierAnglePhoto(String angle) {
    return '정수기 $angle 사진';
  }

  @override
  String waterAnglePhotoSelected(String angle) {
    return '$angle 사진 선택됨';
  }

  @override
  String get waterInfoTitle => '물그릇 정보';

  @override
  String get waterNameLabel => '그릇 이름';

  @override
  String get waterSharedPets => '함께 사용하는 반려동물';

  @override
  String get waterRegisterPetsFirst => '먼저 반려동물을 등록해 주세요.';

  @override
  String get waterSpecsTitle => '선택 물리 사양';

  @override
  String get waterEmptyWeightLabel => '빈 그릇 무게 (g, 선택)';

  @override
  String get waterFullVolumeLabel => '가득 찬 물의 양 (mL, 선택)';

  @override
  String get waterFullVolumeHelper => '그릇 무게를 제외한 물의 양';

  @override
  String get waterPhotoNotesLabel => '사진 특이사항 (선택)';

  @override
  String get waterPhotoNotesHint => '예: 정수기에 물이 70% 차 있는 상태예요';

  @override
  String get waterMeasureCautionTitle => '측정 유의사항';

  @override
  String get waterMeasureCautionMessage =>
      '부피 추정 기능은 검증 전이며 입력값이 있어도 제공되지 않습니다.';

  @override
  String get waterPetsAndPhotosRequired => '반려동물과 정수기의 앞·뒤·위 사진을 모두 선택해 주세요.';

  @override
  String get waterSetupComplete => '정수기 초기 설정을 완료했습니다.';

  @override
  String get waterSetupLevelUnknown =>
      '정수기는 등록됐지만 초기 수위를 확인하지 못했습니다. 다시 분석해 주세요.';

  @override
  String waterSetupFailedDetail(String detail) {
    return '정수기는 등록됐지만 초기 설정에 실패했습니다: $detail';
  }

  @override
  String get waterRegisteredRetryAnalysis => '정수기는 등록됐습니다. 초기 분석을 다시 시도해 주세요.';

  @override
  String get waterRenameTitle => '물그릇 이름 변경';

  @override
  String get waterBowlNameLabel => '물그릇 이름';

  @override
  String get waterReregisterPhotos => '초기 설정을 위해 정수기 앞·뒤·위 사진을 다시 등록해 주세요.';

  @override
  String waterInitialLevelUnknown(String reason) {
    return '초기 수위를 확인하지 못했습니다. $reason';
  }

  @override
  String get waterNewPhotoNotesTitle => '새 정수기 사진 특이사항';

  @override
  String get waterNewPhotoNotesHint => '예: 물이 70% 차 있는 상태예요';

  @override
  String get waterSavePhotoAction => '정수기 사진 저장';

  @override
  String get waterPhotoChangeFailed => '정수기 사진을 변경하지 못했습니다.';

  @override
  String get waterDetailTitle => '정수기 상세 정보';

  @override
  String waterSharedWithPets(int count) {
    return '물그릇 · 반려동물 $count마리와 함께 사용';
  }

  @override
  String get waterDeleteAction => '물그릇 삭제';

  @override
  String waterPurifierPhotoVersion(int version) {
    return '정수기 사진 $version번째';
  }

  @override
  String waterRecentlyRegistered(String timestamp) {
    return '최근 등록 $timestamp';
  }

  @override
  String get waterRefillHint => '물을 보충하거나 교체했다면 새 사진을 등록하세요.';

  @override
  String waterBowlPurifierPhoto(String name) {
    return '$name 정수기 사진';
  }

  @override
  String get waterPhotoNotesTitle => '사진 특이사항';

  @override
  String get waterFirstPhotosTitle => '처음 등록한 정수기 사진';

  @override
  String get waterDeviceTitle => '기기 정보';

  @override
  String get waterFullVolumeMetric => '가득 찬 물의 양';

  @override
  String get waterEmptyDeviceWeight => '빈 기기 무게';

  @override
  String get waterPhotoHistoryTitle => '정수기 사진 변경 이력';

  @override
  String get waterPhotoHistoryHint => '이전 정수기 사진은 기록과 함께 보관됩니다.';

  @override
  String get waterCurrentBaseline => '현재 기준';

  @override
  String get waterOutcomeGuideTitle => '관찰 결과 안내';

  @override
  String get waterOutcomeGuideMessage =>
      '사진 분석은 기준 대비 변화를 추정하며, 실제 반려동물의 음수량이나 건강 상태를 진단하지 않습니다.';

  @override
  String get waterReanalyzeAction => '등록 사진 다시 분석하기';

  @override
  String get waterViewHistoryAction => '수위 기록 보기';

  @override
  String get waterViewPastRecords => '이전 분석 기록 보기';

  @override
  String get waterTakeNewPhoto => '새 사진 촬영';

  @override
  String get waterChooseNewPhoto => '새 사진 선택';

  @override
  String get chatUnavailable => '건강 상담 연결을 사용할 수 없습니다.';

  @override
  String get chatPhotoSelectFailed => '사진을 선택할 수 없습니다.';

  @override
  String get chatMentionPets => '반려동물 멘션';

  @override
  String get chatNoPets => '등록된 반려동물이 없습니다.';

  @override
  String get commonDone => '완료';

  @override
  String get chatTitle => '반려동물 건강 상담';

  @override
  String get chatDisclaimer =>
      'AI의 답변은 참고 정보이며 진단을 대신하지 않습니다. 대화와 사진은 가족에게 공유됩니다.';

  @override
  String get chatLoadFailed => '대화를 불러오지 못했습니다.';

  @override
  String get chatEmptyPrompt => '반려동물의 건강에 관해 물어보세요.';

  @override
  String get chatGuardianLabel => '보호자';

  @override
  String get chatAssistantLabel => '건강 상담';

  @override
  String get chatPhotoLoading => '사진 불러오는 중';

  @override
  String get chatRemovePhoto => '사진 제거';

  @override
  String get chatAttachPhoto => '사진 첨부';

  @override
  String get chatInputHint => '건강에 대해 물어보세요';

  @override
  String get chatSendAction => '전송';

  @override
  String get petEditProfile => '프로필 수정';

  @override
  String get petHealthLoadFailed => '건강 기록을 불러오지 못했습니다.';

  @override
  String petAgeLine(int age) {
    return '나이 $age개월';
  }

  @override
  String petWeightLine(double weight) {
    return '몸무게 $weight kg';
  }

  @override
  String get petWaterSection => '물그릇 관찰';

  @override
  String get petWaterSectionHint => '함께 사용하는 물그릇의 수위입니다. 개별 음수량은 알 수 없습니다.';

  @override
  String get petNoBowls => '연결된 물그릇이 없습니다.';

  @override
  String get petSharedBowl => '여러 반려동물이 함께 사용';

  @override
  String get petLinkedBowl => '연결된 물그릇';

  @override
  String get petLevelHistoryFailed => '수위 기록을 불러오지 못했습니다.';

  @override
  String get petLevelRecord => '수위 관찰 기록';

  @override
  String get petTimeUnknown => '시간 미확인';

  @override
  String get petLevelHistoryUnavailable => '수위 기록을 사용할 수 없습니다.';

  @override
  String get petLitterSection => '화장실 관찰';

  @override
  String get petLitterSectionHint => '이 반려동물을 이용자로 선택해 저장한 기록만 표시합니다.';

  @override
  String get petNoBoxes => '연결된 화장실이 없습니다.';

  @override
  String petLinkedBoxes(String names) {
    return '연결된 화장실: $names';
  }

  @override
  String get petNoRecords => '이 반려동물로 지정된 관찰 기록이 없습니다.';

  @override
  String petRecordCountsLine(int urine, int stool) {
    return ' · 소변 $urine회 · 대변 $stool회';
  }

  @override
  String get shareHeader => '[하릅 관찰 기록]';

  @override
  String shareWaterPercent(double percent) {
    return '물 감소율: $percent% (추정)';
  }

  @override
  String shareWaterVolume(double volume) {
    return '물 감소량: $volume mL (추정)';
  }

  @override
  String shareConfirmedUrine(int count) {
    return '확인한 소변: $count회';
  }

  @override
  String shareConfirmedStool(int count) {
    return '확인한 대변: $count회';
  }

  @override
  String shareMemo(String notes) {
    return '메모: $notes';
  }
}
