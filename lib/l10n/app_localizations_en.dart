// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Hareup';

  @override
  String get failureUnexpected => 'Something went wrong.';

  @override
  String get failureNetwork => 'Check your network connection.';

  @override
  String get failureSerialization => 'Could not read the data.';

  @override
  String get failureTimeout => 'The request timed out. Please try again.';

  @override
  String get failureCancelled => 'The request was cancelled.';

  @override
  String get failureAuthorization => 'Check your access permission.';

  @override
  String get failureNotFound => 'The requested information was not found.';

  @override
  String get failureServer => 'There was a server problem. Please try again.';

  @override
  String get failureRequest => 'Check your request.';

  @override
  String get mainWebSetupMessage =>
      'Web Firebase configuration is required. Register a Web app in the Firebase Console, then relaunch with FIREBASE_WEB_API_KEY and FIREBASE_WEB_APP_ID.';

  @override
  String get settingsLanguageTitle => 'Language';

  @override
  String get settingsLanguageSystem => 'Follow device language';

  @override
  String get authProviderUnavailable => 'This sign-in provider is unavailable.';

  @override
  String get authCancelled => 'Sign-in was cancelled.';

  @override
  String get authInvalidEmail => 'The email address format is invalid.';

  @override
  String get authEmailInUse =>
      'This email is already registered. Please sign in.';

  @override
  String get authWeakPassword => 'Use a password of at least 6 characters.';

  @override
  String get authInvalidCredential => 'Check your email or password.';

  @override
  String get authTooManyRequests =>
      'Too many attempts. Please try again later.';

  @override
  String get authNotEnabled =>
      'Enable this sign-in provider in the Firebase Console.';

  @override
  String get appAuthUnavailable => 'Firebase authentication is unavailable.';

  @override
  String get recordsInvalidAnnotations => 'Check your edits.';

  @override
  String get recordsChanged => 'The record changed. Reload and try again.';

  @override
  String get recordsAlreadySaved => 'This analysis is already saved.';

  @override
  String get waterAlreadyRegistered => 'This water bowl is already registered.';

  @override
  String get waterHistoryUnavailable =>
      'Could not load the water level history.';

  @override
  String get litterAlreadyRegistered =>
      'This litter box is already registered.';

  @override
  String get settingsLoadFailed => 'Could not load app info.';

  @override
  String get settingsOpenLinkFailed => 'Could not open the link.';

  @override
  String get familyUnavailable =>
      'Family sharing needs an account and a server connection.';

  @override
  String get familyLoadFailed =>
      'Could not load family info. Please try again later.';

  @override
  String get familyServerError => 'There is a server problem.';

  @override
  String get analysisPhotoRequired => 'Select the required photos.';

  @override
  String get analysisPhotoTooLarge =>
      'Each photo must be a JPEG, PNG, or WebP under 3 MB.';

  @override
  String get analysisBaselineRequired =>
      'Check the baseline and comparison photos.';

  @override
  String get analysisEachPhotoTooLarge =>
      'Each photo to analyze must be under 3 MB.';

  @override
  String get analysisUnsupportedType =>
      'Only JPEG, PNG, or WebP photos can be analyzed.';

  @override
  String get analysisInvalidCounts => 'Check your edited counts.';

  @override
  String get analysisUnreliableWater =>
      'The water decrease rate is unreliable, so analysis is unavailable.';

  @override
  String get analysisConfidenceUnknown => 'The analysis confidence is unknown.';

  @override
  String get analysisUnreliableLitter =>
      'The waste traces are unreliable, so analysis is unavailable.';

  @override
  String get analysisUnknownOutcome => 'The analysis result type is unknown.';

  @override
  String get analysisServiceUnavailable => 'Photo analysis is not ready yet.';

  @override
  String get storagePhotoNotFound =>
      'The saved photo was not found. Check the photo storage settings.';

  @override
  String get storageBucketMissing =>
      'Photo storage is not set up. Create a Storage bucket in the Firebase Console.';

  @override
  String get commonDelete => 'Delete';

  @override
  String targetDeleteTitle(String name) {
    return 'Delete $name';
  }

  @override
  String get targetDeleteMessage =>
      'Remove it from the list? Existing photos and observation records are kept. Only a family admin can delete.';

  @override
  String get recordsChartDescription =>
      'Each bar is one observation. Oldest records first.';

  @override
  String recordsChartMaximumText(String text) {
    return 'Max $text';
  }

  @override
  String recordsValueWithUnit(String value, String unit) {
    return '$value $unit';
  }

  @override
  String get recordsCountUnit => 'times';

  @override
  String get recordsChecking => 'Checking records';

  @override
  String get recordsLoadFailed => 'Could not load records';

  @override
  String get recordsEmpty => 'No analysis records';

  @override
  String recordsWaterSummary(double percent) {
    return 'Water decrease $percent% (estimated)';
  }

  @override
  String recordsLitterSummary(int urine, int stool) {
    return 'Urine $urine times · Stool $stool times (estimated)';
  }

  @override
  String get recordsUnavailableShort => 'Unavailable';

  @override
  String recordsRecentWith(String summary) {
    return 'Latest record · $summary';
  }

  @override
  String get authSignUpSubtitle =>
      'Create an account for your caregiving family.';

  @override
  String get authSignInSubtitle =>
      'Pet health care with daily photo check-ins, together.';

  @override
  String get authContinueWithGoogle => 'Continue with Google';

  @override
  String get authContinueWithApple => 'Continue with Apple';

  @override
  String get authContinueWithKakao => 'Continue with Kakao';

  @override
  String get authOrEmail => 'Or continue with email';

  @override
  String get authNameLabel => 'Name (optional)';

  @override
  String get authEmailLabel => 'Email';

  @override
  String get authEmailInvalid => 'Check your email address.';

  @override
  String get authPasswordLabel => 'Password';

  @override
  String get authSignUpAction => 'Sign up';

  @override
  String get authSignInAction => 'Sign in';

  @override
  String get authHaveAccount => 'Already have an account? Sign in';

  @override
  String get authNeedAccount => 'No account yet? Sign up';

  @override
  String get authRecheckSession => 'Recheck session';

  @override
  String get petManageTitle => 'Manage pets';

  @override
  String get petAddAction => 'Add pet';

  @override
  String get petEmptyMessage => 'No pets registered.\nAdd your pet.';

  @override
  String get petSpeciesCat => 'Cat';

  @override
  String get petSpeciesDog => 'Dog';

  @override
  String petAgeMonths(int age) {
    return '$age months';
  }

  @override
  String get petSexFemale => 'Female';

  @override
  String get petSexMale => 'Male';

  @override
  String get petSexUnknown => 'Unknown sex';

  @override
  String get petDeleteMessage =>
      'Delete this pet? The retention policy for linked records is not decided yet.';

  @override
  String get commonSave => 'Save';

  @override
  String get petPhotoTooLarge => 'Select a photo under 10 MB.';

  @override
  String get petPhotoPermissionDenied =>
      'Check photo access permission. You can save without a photo.';

  @override
  String get petPhotoUnavailable =>
      'Could not get the photo. Please try again.';

  @override
  String get petPhotoReadFailed =>
      'Could not read the photo. Please select again.';

  @override
  String get petEditTitle => 'Edit pet';

  @override
  String get petPhotoLabel => 'Pet photo';

  @override
  String get petPhotoHint => 'The selected photo appears on the pet profile.';

  @override
  String get petNameLabel => 'Name';

  @override
  String get petNameRequired => 'Enter a name.';

  @override
  String get petSpeciesLabel => 'Species';

  @override
  String get petAgeLabel => 'Age (months, optional)';

  @override
  String get petAgeInvalid => 'Enter 0 months or more.';

  @override
  String get petSexLabel => 'Sex (optional)';

  @override
  String get petSexUnspecified => 'Not specified';

  @override
  String get petSexNotKnown => 'Unknown';

  @override
  String get petWeightLabel => 'Weight (kg, optional)';

  @override
  String get petWeightInvalid => 'Enter a weight greater than 0.';

  @override
  String get waterHistoryTitle => 'Water level history';

  @override
  String get waterHistoryEmpty => 'No saved water level records.';

  @override
  String get waterTrendTitle => 'Water level trend';

  @override
  String get waterTrendPending =>
      'Level estimates appear after accuracy validation.';

  @override
  String get waterTrendNoData => 'No level records to chart.';

  @override
  String get waterCurrentLevelEstimated => 'Current level (estimated)';

  @override
  String waterCurrentLevelValue(String current) {
    return 'Current level $current% (estimated)';
  }

  @override
  String get waterAnalysisDone => 'Level analysis complete';

  @override
  String get waterChangeDecrease => 'Decreased';

  @override
  String get waterChangeIncrease => 'Increased';

  @override
  String get waterChangeNone => 'No change';

  @override
  String waterChangeWith(String change, String value) {
    return ' · $change ${value}pp';
  }

  @override
  String get familySelectTitle => 'Select family';

  @override
  String get familyNestBadge => 'Our family nest';

  @override
  String get familySelectQuestion => 'Which family will you care with?';

  @override
  String get familySelectHint => 'Select an approved family to continue.';

  @override
  String get familyEmptyMessage =>
      'No families yet. Create one or enter an invite code.';

  @override
  String get familyPendingTitle => 'Waiting for admin approval';

  @override
  String get familyPendingMessage =>
      'Refresh after approval to select the family.';

  @override
  String get familyRefreshStatus => 'Refresh approval status';

  @override
  String get familyTogetherTitle => 'Caring together';

  @override
  String get familyTogetherMessage =>
      'Family members can check the same pet records together.';

  @override
  String get familyCreateAction => 'Create family';

  @override
  String get familyEnterCodeAction => 'Enter invite code';

  @override
  String get familyNameLabel => 'Family name';

  @override
  String get familyCreateSubmit => 'Create';

  @override
  String get familyNameRequired => 'Enter a family name.';

  @override
  String get familyInviteCodeLabel => 'Invite code';

  @override
  String get familyJoinRequestAction => 'Request to join';

  @override
  String get familyInviteCodeInvalid => 'Enter 6-12 letters or numbers.';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsEmptyMessage => 'No settings info.';

  @override
  String get settingsMyAccount => 'My account';

  @override
  String settingsPetSingle(String name) {
    return 'Registered pet: $name';
  }

  @override
  String settingsPetCount(int count) {
    return '$count registered pets';
  }

  @override
  String get settingsNotificationTitle => 'Smart safety notifications';

  @override
  String get settingsWaterAlertTitle => 'Water bowl analysis alerts';

  @override
  String get settingsWaterAlertMessage => 'Water bowl alerts are coming soon.';

  @override
  String get settingsLitterAlertTitle => 'Litter box anomaly alerts';

  @override
  String get settingsLitterAlertMessage => 'Litter box alerts are coming soon.';

  @override
  String get settingsFamilySyncTitle => 'Family care record sync';

  @override
  String get settingsFamilySyncMessage => 'Check family records in the app.';

  @override
  String get settingsSupportTitle => 'App info & support';

  @override
  String get settingsNoticeTitle => 'Notices & updates';

  @override
  String get settingsFaqTitle => 'FAQ & contact';

  @override
  String get settingsTermsTitle => 'Terms of service';

  @override
  String get settingsComingSoon => 'Coming soon';

  @override
  String get settingsPrivacyTitle => 'Privacy policy';

  @override
  String get settingsVersionTitle => 'App version';

  @override
  String get settingsSignOutAction => 'Sign out';

  @override
  String get settingsSignOutConfirm => 'Sign out on this device?';

  @override
  String get settingsWithdrawHint => 'Delete Hareup account · Coming soon';

  @override
  String get waterPhotoTooLarge => 'Photos must be under 3 MB.';

  @override
  String get photoFetchFailed => 'Could not get the photo.';

  @override
  String get photoReadFailed => 'Could not read the photo.';

  @override
  String get waterServiceUnavailable => 'Photo analysis is unavailable.';

  @override
  String get waterSetupPhotosRequired =>
      'Select the front, back, and top photos of the purifier.';

  @override
  String get waterReadingPhotoRequired => 'Select a purifier photo.';

  @override
  String waterLevelUnknownWith(String reason) {
    return 'Could not check the level. $reason';
  }

  @override
  String get waterSetupTitle => 'Purifier setup';

  @override
  String get waterObserveTitle => 'Level check';

  @override
  String get waterSetupGuideTitle => 'Setup guide';

  @override
  String get waterObserveGuideTitle => 'Level check guide';

  @override
  String get waterSetupGuideMessage =>
      'Estimate the initial level from front, back, and top photos.';

  @override
  String get waterObserveGuideMessage =>
      'Upload one purifier photo to compare with the previous level.';

  @override
  String get waterAngleFront => 'Front';

  @override
  String get waterAngleBack => 'Back';

  @override
  String get waterAngleTop => 'Top';

  @override
  String waterAnglePhoto(String angle) {
    return '$angle photo';
  }

  @override
  String get waterPurifierPhoto => 'Purifier photo';

  @override
  String get waterSetupAnalyzeAction => 'Analyze setup';

  @override
  String get waterAnalyzeAction => 'Analyze level';

  @override
  String get commonNotice => 'Notice';

  @override
  String get analysisResultTitle => 'Analysis result';

  @override
  String waterCurrentLevelReading(String value) {
    return 'Current level: $value% (estimated)';
  }

  @override
  String waterPreviousLevelReading(String value) {
    return 'Previous level: $value% (estimated)';
  }

  @override
  String waterDecreasedSince(String value) {
    return 'Down ${value}pp from before';
  }

  @override
  String waterIncreasedSince(String value) {
    return 'Up ${value}pp from before (possible refill)';
  }

  @override
  String get waterNoChange => 'No change from before';

  @override
  String get waterSavedPending =>
      'Analysis saved. Level estimates appear after accuracy validation.';

  @override
  String get waterEstimateDisclaimer =>
      'Photo analysis is an estimate, not actual intake.';

  @override
  String get navHome => 'Home';

  @override
  String get navWater => 'Water';

  @override
  String get navLitter => 'Litter';

  @override
  String get navCompare => 'Compare';

  @override
  String get navRecords => 'Records';

  @override
  String get homeTargetListError => 'Check the target list and try again.';

  @override
  String get homePickRecordsTarget => 'Select a record target';

  @override
  String get homePickCompareTarget => 'Select a comparison target';

  @override
  String get homePickRecordsHint => 'Select the target whose records to view.';

  @override
  String get homePickCompareHint => 'Select the target to compare.';

  @override
  String get homeNoTargets => 'Register a water bowl or litter box first.';

  @override
  String get homePetError => 'Check the pet list and try again.';

  @override
  String get homeSwitchFamily => 'Switch family';

  @override
  String get homeManageFamily => 'Manage family';

  @override
  String get homeHeadline => 'A day of caring together';

  @override
  String get homeSubheadline => 'Check in on your pets today too.';

  @override
  String get homeLocalPreview =>
      'Dev preview · Data disappears when the app closes.';

  @override
  String get homePetTitle => 'Pets';

  @override
  String get homePetEmpty => 'Register your pet.';

  @override
  String homePetCount(int count) {
    return '$count pets';
  }

  @override
  String get homeWaterManage => 'Manage water bowls';

  @override
  String get homeWaterEmpty => 'Register a water bowl.';

  @override
  String get homeLitterManage => 'Manage litter boxes';

  @override
  String get homeLitterEmpty => 'Register a litter box.';

  @override
  String get homeEstimateNotice =>
      'Photo analysis is estimated; only validated items are shown.';

  @override
  String get analysisPhotoAccessRetry => 'Check photo access and try again.';

  @override
  String get analysisPhotoTooBig10 => 'Photos must be under 10 MB.';

  @override
  String get analysisPhotoCompareRequired => 'Select a photo to compare.';

  @override
  String analysisCompareTitle(String name) {
    return '$name photo comparison';
  }

  @override
  String get analysisWaterObserve => 'Water bowl observation';

  @override
  String get analysisLitterObserve => 'Litter box observation';

  @override
  String analysisBaselineVersion(String photo, int version) {
    return '$photo No. $version';
  }

  @override
  String get analysisPhotoGuideTitle => 'Photo guide';

  @override
  String get analysisWaterGuide =>
      'Photograph the whole purifier from the same position, distance, and angle with enough light.';

  @override
  String get analysisLitterGuide =>
      'Photograph the whole target from the same position, distance, and angle with enough light.';

  @override
  String get analysisRunAction => 'Analyze photo';

  @override
  String get analysisCannotTitle => 'Cannot analyze';

  @override
  String get analysisModelResponseTitle => 'Model response';

  @override
  String get analysisViewModelResponse => 'View model response';

  @override
  String get analysisDisclaimerVet =>
      'Photo analysis is estimated, not a diagnosis. Consult a vet if needed.';

  @override
  String get analysisDecreaseRate => 'Decrease from baseline (estimated)';

  @override
  String get analysisDecreaseVolume => 'Decrease volume (estimated)';

  @override
  String get analysisWaterCaveat =>
      'Refills, evaporation, spills, or shared use may affect this.';

  @override
  String get analysisOriginalEstimate => 'Original estimate';

  @override
  String analysisLitterCounts(int urine, int stool) {
    return 'Urine $urine times · Stool $stool times';
  }

  @override
  String get analysisUncertainTraces =>
      'Overlapping or hidden traces may be inaccurate.';

  @override
  String analysisObservedQuantity(double quantity, String unit) {
    return 'Observed: $quantity $unit (estimated)';
  }

  @override
  String get analysisConfirmedUrine => 'Confirmed urine traces';

  @override
  String get analysisConfirmedStool => 'Confirmed stool traces';

  @override
  String get analysisSelectCat => 'Select the cat';

  @override
  String get analysisCatUnknown => 'Unknown';

  @override
  String get recordsMemoTitle => 'Notes';

  @override
  String get recordsMemoField => 'Notes (optional)';

  @override
  String get recordsMemoHint => 'Write down what you observed.';

  @override
  String get recordsCountInvalid => 'Enter counts of 0 or more.';

  @override
  String get recordsSaveAction => 'Save record';

  @override
  String get recordsSavedBadge => 'Record saved.';

  @override
  String get familyOverviewEmpty => 'Family info not found.';

  @override
  String get familyManageMessage =>
      'Check pet photos and records together with family members.';

  @override
  String get familyCurrentSelected => 'Currently selected family';

  @override
  String familyMemberCount(int count) {
    return '$count family members';
  }

  @override
  String familyMembersHeader(int count) {
    return 'Family members ($count)';
  }

  @override
  String get familyNoMembers => 'No members.';

  @override
  String familyRemoveMemberTooltip(String name) {
    return 'Remove $name';
  }

  @override
  String familyPendingHeader(int count) {
    return 'Pending approvals ($count)';
  }

  @override
  String get familyNoPendingRequests => 'No pending join requests.';

  @override
  String get familyInvitePendingSubtitle =>
      'Waiting for approval after entering an invite code.';

  @override
  String get familyApproveAction => 'Approve';

  @override
  String get familyInviteTitle => 'Invite family';

  @override
  String get familyCreateCodeAction => 'Create invite code';

  @override
  String get familyCreateCodeMessage => 'Issue a code to share with family.';

  @override
  String get familyEnterCodeMessage =>
      'Request to join with a code from another family.';

  @override
  String get familyInviteCodeTitle => 'Family invite code';

  @override
  String get familyDedicatedCodeTitle => 'Invite-only family code';

  @override
  String get familyShareCodeMessage =>
      'Share this code with your caregiving family.';

  @override
  String get familyCodeCopied => 'Invite code copied.';

  @override
  String get familyCopyCodeAction => 'Copy invite code';

  @override
  String get familyJoinGuideTitle => 'How to join';

  @override
  String get familyJoinGuideMessage =>
      'After signing in, family members can request to join with the invite code. They can join once an admin approves.';

  @override
  String get commonClose => 'Close';

  @override
  String get familyJoinRequested =>
      'Join request sent. Please wait for admin approval.';

  @override
  String get familyApproved => 'Approved the join request.';

  @override
  String get familyRemoveConfirm =>
      'This member will lose access to family info.';

  @override
  String get familyRemoveAction => 'Remove';

  @override
  String get familyMemberRemoved => 'Removed the member.';

  @override
  String get commonRegister => 'Register';

  @override
  String get commonDeleteFailed => 'Could not delete.';

  @override
  String get commonRename => 'Rename';

  @override
  String get commonRenameFailed => 'Could not rename.';

  @override
  String get commonPositiveNumber => 'Enter a number greater than 0.';

  @override
  String ordinalVersion(int version) {
    return 'No. $version';
  }

  @override
  String get litterAddAction => 'Add litter box';

  @override
  String get litterEmptyMessage => 'No litter boxes registered.';

  @override
  String get litterRegisterTitle => 'Register litter box';

  @override
  String get litterHealthBadge => 'Excretion health monitoring';

  @override
  String get litterRegisterHint =>
      'Register a clean litter photo and box info.';

  @override
  String get litterPhotoGuide => 'Capture the clean litter and the whole box.';

  @override
  String get litterAutomaticSection => 'Automatic device?';

  @override
  String get litterAutomaticLabel => 'Automatic litter box';

  @override
  String get litterAutomaticBlockedTitle => 'Automatic registration blocked';

  @override
  String get litterAutomaticBlockedMessage =>
      'Automatic litter boxes cannot be registered for analysis.';

  @override
  String get litterBaselineRegisterTitle => 'Register baseline photo';

  @override
  String get litterBaselineRegisterHint =>
      'Register the clean state right after cleaning as the baseline.';

  @override
  String get litterBaselineLabel => 'Litter box baseline photo';

  @override
  String get litterProfileTitle => 'Profile & dimensions';

  @override
  String get litterNameLabel => 'Litter box name';

  @override
  String get litterSharedCats => 'Cats sharing this box';

  @override
  String get litterRegisterCatsFirst => 'Register your cats first.';

  @override
  String get litterDimensionsTitle => 'Detailed dimensions (optional)';

  @override
  String get litterWidthLabel => 'Inner width (cm, optional)';

  @override
  String get litterLengthLabel => 'Inner length (cm, optional)';

  @override
  String get litterHeightLabel => 'Litter height (cm, optional)';

  @override
  String get litterVolumeGuideTitle => 'Observed quantity notice';

  @override
  String get litterVolumeGuideMessage =>
      'Quantity estimates are unverified and unavailable even with dimensions.';

  @override
  String get litterCatsAndPhotoRequired => 'Select cats and a baseline photo.';

  @override
  String get litterRenameTitle => 'Rename litter box';

  @override
  String get litterBaselineChangeFailed =>
      'Could not change the baseline photo.';

  @override
  String get litterDeleteAction => 'Delete litter box';

  @override
  String litterBaselineVersion(int version) {
    return 'Baseline photo No. $version';
  }

  @override
  String get litterNewBaselinePrefix => 'new baseline';

  @override
  String get litterBaselineHistoryTitle => 'Baseline history';

  @override
  String get litterBaselineGuideTitle => 'Baseline photo guide';

  @override
  String get litterBaselineGuideMessage =>
      'Register a new baseline after cleaning or changing litter. Previous baselines are kept.\nAnalysis results are only provided when validated.';

  @override
  String get litterViewRecords => 'View records';

  @override
  String recordsTargetTitle(String name) {
    return '$name records';
  }

  @override
  String get recordsEmptyMessage => 'No saved analysis records.';

  @override
  String get recordsLitterTrendTitle => 'Litter count trend';

  @override
  String get recordsUrineLabel => 'Urine';

  @override
  String get recordsStoolLabel => 'Stool';

  @override
  String get recordsTimelineTitle => 'Health check timeline';

  @override
  String get recordsHistoryTitle => 'Photo analysis records';

  @override
  String get recordsEstimateDisclaimer =>
      'Photo analysis is estimated, not a diagnosis.';

  @override
  String get recordsFilterAll => 'All';

  @override
  String get recordsEmptyFiltered => 'No records of this kind.';

  @override
  String recordsDateLabel(int year, int month, int day) {
    return '$month/$day/$year';
  }

  @override
  String get recordsPhotoLabel => 'Record photo';

  @override
  String get recordsShareCopied => 'Share text copied to the clipboard.';

  @override
  String get recordsShareFailed => 'Could not open the share sheet.';

  @override
  String get recordsRegistrationPhoto => 'Registration photo';

  @override
  String recordsPhotoSelectedAt(String timestamp) {
    return 'Photo selected: $timestamp';
  }

  @override
  String recordsAnalyzedAt(String timestamp) {
    return 'Analyzed: $timestamp';
  }

  @override
  String get recordsOutcomeDisclaimer =>
      'Observations are estimated, not a diagnosis.';

  @override
  String recordsUnavailableWith(String text) {
    return 'Unavailable: $text';
  }

  @override
  String get recordsWaterPercentLabel => 'Water decrease (estimated)';

  @override
  String recordsModelConfidence(double confidence) {
    return 'Model self-reported confidence $confidence% (not real accuracy)';
  }

  @override
  String get recordsWaterVolumeLabel => 'Water decrease volume (estimated)';

  @override
  String get recordsWaterCaveat =>
      'Change relative to the bowl, not individual intake.';

  @override
  String get recordsUserConfirmed => 'Confirmed by you';

  @override
  String recordsObservedQuantity(double quantity, String unit) {
    return 'Observed $quantity $unit (estimated)';
  }

  @override
  String recordsCatWith(String name) {
    return 'Cat: $name';
  }

  @override
  String get recordsCatUnverified => 'Cannot verify';

  @override
  String get recordsShareAction => 'Share record';

  @override
  String get recordsEditAction => 'Edit record';

  @override
  String get recordsGuardianCheckTitle => 'Guardian review';

  @override
  String get recordsGuardianCheckMessage =>
      'The original result is kept; only confirmed values and notes change.';

  @override
  String get recordsConfirmedSection => 'Confirmed observations';

  @override
  String get waterAddAction => 'Add water bowl';

  @override
  String get waterEmptyMessage => 'No water bowls registered.';

  @override
  String get photoPermissionCheck => 'Check photo access permission.';

  @override
  String get waterRegisterTitle => 'Register water bowl';

  @override
  String get waterIntakeBadge => 'Smart intake monitoring';

  @override
  String get waterNewRegisterHeadline => 'Register a new bowl';

  @override
  String get waterRegisterHint => 'Enter purifier photos and basic info.';

  @override
  String get waterPhotoGuide =>
      'Take 3 photos from different angles showing the whole purifier.';

  @override
  String get waterAnglePhotosHint =>
      'Register photos taken from the front, back, and top.';

  @override
  String waterPurifierAnglePhoto(String angle) {
    return '$angle purifier photo';
  }

  @override
  String waterAnglePhotoSelected(String angle) {
    return '$angle photo selected';
  }

  @override
  String get waterInfoTitle => 'Bowl info';

  @override
  String get waterNameLabel => 'Bowl name';

  @override
  String get waterSharedPets => 'Pets sharing this bowl';

  @override
  String get waterRegisterPetsFirst => 'Register your pets first.';

  @override
  String get waterSpecsTitle => 'Optional physical specs';

  @override
  String get waterEmptyWeightLabel => 'Empty bowl weight (g, optional)';

  @override
  String get waterFullVolumeLabel => 'Full water volume (mL, optional)';

  @override
  String get waterFullVolumeHelper => 'Water amount excluding bowl weight';

  @override
  String get waterPhotoNotesLabel => 'Photo notes (optional)';

  @override
  String get waterPhotoNotesHint => 'E.g., the purifier is 70% full';

  @override
  String get waterMeasureCautionTitle => 'Measurement notice';

  @override
  String get waterMeasureCautionMessage =>
      'Volume estimates are unverified and unavailable even with inputs.';

  @override
  String get waterPetsAndPhotosRequired =>
      'Select pets and all front, back, and top photos.';

  @override
  String get waterSetupComplete => 'Purifier setup complete.';

  @override
  String get waterSetupLevelUnknown =>
      'The purifier is registered, but the initial level is unknown. Analyze again.';

  @override
  String waterSetupFailedDetail(String detail) {
    return 'The purifier is registered, but setup failed: $detail';
  }

  @override
  String get waterRegisteredRetryAnalysis =>
      'The purifier is registered. Retry the initial analysis.';

  @override
  String get waterRenameTitle => 'Rename water bowl';

  @override
  String get waterBowlNameLabel => 'Water bowl name';

  @override
  String get waterReregisterPhotos =>
      'Re-register the front, back, and top photos for setup.';

  @override
  String waterInitialLevelUnknown(String reason) {
    return 'Could not check the initial level. $reason';
  }

  @override
  String get waterNewPhotoNotesTitle => 'New purifier photo notes';

  @override
  String get waterNewPhotoNotesHint => 'E.g., 70% full';

  @override
  String get waterSavePhotoAction => 'Save purifier photo';

  @override
  String get waterPhotoChangeFailed => 'Could not change the purifier photo.';

  @override
  String get waterDetailTitle => 'Purifier details';

  @override
  String waterSharedWithPets(int count) {
    return 'Water bowl · Shared with $count pets';
  }

  @override
  String get waterDeleteAction => 'Delete water bowl';

  @override
  String waterPurifierPhotoVersion(int version) {
    return 'Purifier photo No. $version';
  }

  @override
  String waterRecentlyRegistered(String timestamp) {
    return 'Registered $timestamp';
  }

  @override
  String get waterRefillHint =>
      'Register a new photo after refilling or replacing water.';

  @override
  String waterBowlPurifierPhoto(String name) {
    return '$name purifier photo';
  }

  @override
  String get waterPhotoNotesTitle => 'Photo notes';

  @override
  String get waterFirstPhotosTitle => 'First registered photos';

  @override
  String get waterDeviceTitle => 'Device info';

  @override
  String get waterFullVolumeMetric => 'Full water volume';

  @override
  String get waterEmptyDeviceWeight => 'Empty device weight';

  @override
  String get waterPhotoHistoryTitle => 'Purifier photo history';

  @override
  String get waterPhotoHistoryHint => 'Older photos are kept with records.';

  @override
  String get waterCurrentBaseline => 'Current baseline';

  @override
  String get waterOutcomeGuideTitle => 'About observations';

  @override
  String get waterOutcomeGuideMessage =>
      'Analysis estimates change from the baseline; it does not diagnose intake or health.';

  @override
  String get waterReanalyzeAction => 'Reanalyze registration photos';

  @override
  String get waterViewHistoryAction => 'View level history';

  @override
  String get waterViewPastRecords => 'View past analysis records';

  @override
  String get waterTakeNewPhoto => 'Take new photo';

  @override
  String get waterChooseNewPhoto => 'Choose new photo';

  @override
  String get chatUnavailable => 'Health chat is unavailable.';

  @override
  String get chatPhotoSelectFailed => 'Cannot select a photo.';

  @override
  String get chatMentionPets => 'Mention pets';

  @override
  String get chatNoPets => 'No pets registered.';

  @override
  String get commonDone => 'Done';

  @override
  String get chatTitle => 'Pet health chat';

  @override
  String get chatDisclaimer =>
      'AI answers are for reference, not diagnosis. Chats and photos are shared with family.';

  @override
  String get chatLoadFailed => 'Could not load the conversation.';

  @override
  String get chatEmptyPrompt => 'Ask about your pet\'s health.';

  @override
  String get chatGuardianLabel => 'Guardian';

  @override
  String get chatAssistantLabel => 'Health chat';

  @override
  String get chatPhotoLoading => 'Loading photo';

  @override
  String get chatRemovePhoto => 'Remove photo';

  @override
  String get chatAttachPhoto => 'Attach photo';

  @override
  String get chatInputHint => 'Ask about health';

  @override
  String get chatSendAction => 'Send';

  @override
  String get petEditProfile => 'Edit profile';

  @override
  String get petHealthLoadFailed => 'Could not load health records.';

  @override
  String petAgeLine(int age) {
    return 'Age: $age months';
  }

  @override
  String petWeightLine(double weight) {
    return 'Weight: $weight kg';
  }

  @override
  String get petWaterSection => 'Water bowl observations';

  @override
  String get petWaterSectionHint =>
      'Levels of shared bowls. Individual intake is unknown.';

  @override
  String get petNoBowls => 'No linked water bowls.';

  @override
  String get petSharedBowl => 'Shared by multiple pets';

  @override
  String get petLinkedBowl => 'Linked water bowl';

  @override
  String get petLevelHistoryFailed => 'Could not load level records.';

  @override
  String get petLevelRecord => 'Level observation record';

  @override
  String get petTimeUnknown => 'Time unknown';

  @override
  String get petLevelHistoryUnavailable => 'Level records unavailable.';

  @override
  String get petLitterSection => 'Litter box observations';

  @override
  String get petLitterSectionHint =>
      'Only records saved with this pet selected are shown.';

  @override
  String get petNoBoxes => 'No linked litter boxes.';

  @override
  String petLinkedBoxes(String names) {
    return 'Linked litter boxes: $names';
  }

  @override
  String get petNoRecords => 'No observations assigned to this pet.';

  @override
  String petRecordCountsLine(int urine, int stool) {
    return ' · Urine $urine times · Stool $stool times';
  }

  @override
  String get shareHeader => '[Hareup observation record]';

  @override
  String shareWaterPercent(double percent) {
    return 'Water decrease: $percent% (estimated)';
  }

  @override
  String shareWaterVolume(double volume) {
    return 'Water decrease volume: $volume mL (estimated)';
  }

  @override
  String shareConfirmedUrine(int count) {
    return 'Confirmed urine: $count times';
  }

  @override
  String shareConfirmedStool(int count) {
    return 'Confirmed stool: $count times';
  }

  @override
  String shareMemo(String notes) {
    return 'Notes: $notes';
  }
}
