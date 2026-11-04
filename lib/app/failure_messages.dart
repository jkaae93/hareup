import 'package:flutter/widgets.dart';
import 'package:hareup_core/core.dart';

import '../features/photo_analysis/domain/analysis.dart';
import '../l10n/l10n.dart';

/// Resolves the display text for [failure] in the current locale.
///
/// Keyed failures resolve through the application catalog.
/// Default-constructed failures resolve by type. Anything else, such as
/// server-provided text, falls back to the raw message.
String failureDisplayMessage(BuildContext context, AppFailure failure) {
  final l10n = context.l10n;
  final key = failure.messageKey;
  if (key != null) {
    final resolved = failureMessageForKey(l10n, key);
    if (resolved != null) return resolved;
  }
  return switch (failure) {
    UnexpectedFailure(:final message)
        when message == const UnexpectedFailure().message =>
      l10n.failureUnexpected,
    NetworkFailure(:final message)
        when message == const NetworkFailure().message =>
      l10n.failureNetwork,
    SerializationFailure(:final message)
        when message == const SerializationFailure().message =>
      l10n.failureSerialization,
    TimeoutFailure(:final message)
        when message == const TimeoutFailure().message =>
      l10n.failureTimeout,
    CancelledFailure(:final message)
        when message == const CancelledFailure().message =>
      l10n.failureCancelled,
    AuthorizationFailure(:final message)
        when message == const AuthorizationFailure().message =>
      l10n.failureAuthorization,
    NotFoundFailure(:final message)
        when message == const NotFoundFailure().message =>
      l10n.failureNotFound,
    ServerFailure(:final message)
        when message == const ServerFailure().message =>
      l10n.failureServer,
    RequestFailure(:final message)
        when message == const RequestFailure().message =>
      l10n.failureRequest,
    _ => failure.message,
  };
}

/// Resolves the display text for an unavailable analysis outcome.
String analysisReasonDisplayMessage(
  BuildContext context,
  AnalysisUnavailable unavailable,
) {
  final key = unavailable.reasonKey;
  if (key != null) {
    return failureMessageForKey(context.l10n, key) ?? unavailable.reason;
  }
  return unavailable.reason;
}

/// Looks up a [FailureMessageKeys] value in the catalog.
String? failureMessageForKey(
  AppLocalizations l10n,
  String key,
) => switch (key) {
  FailureMessageKeys.authProviderUnavailable => l10n.authProviderUnavailable,
  FailureMessageKeys.authCancelled => l10n.authCancelled,
  FailureMessageKeys.authInvalidEmail => l10n.authInvalidEmail,
  FailureMessageKeys.authEmailInUse => l10n.authEmailInUse,
  FailureMessageKeys.authWeakPassword => l10n.authWeakPassword,
  FailureMessageKeys.authInvalidCredential => l10n.authInvalidCredential,
  FailureMessageKeys.authTooManyRequests => l10n.authTooManyRequests,
  FailureMessageKeys.authNotEnabled => l10n.authNotEnabled,
  FailureMessageKeys.appAuthUnavailable => l10n.appAuthUnavailable,
  FailureMessageKeys.recordsInvalidAnnotations =>
    l10n.recordsInvalidAnnotations,
  FailureMessageKeys.recordsChanged => l10n.recordsChanged,
  FailureMessageKeys.recordsAlreadySaved => l10n.recordsAlreadySaved,
  FailureMessageKeys.waterAlreadyRegistered => l10n.waterAlreadyRegistered,
  FailureMessageKeys.waterHistoryUnavailable => l10n.waterHistoryUnavailable,
  FailureMessageKeys.litterAlreadyRegistered => l10n.litterAlreadyRegistered,
  FailureMessageKeys.settingsLoadFailed => l10n.settingsLoadFailed,
  FailureMessageKeys.settingsOpenLinkFailed => l10n.settingsOpenLinkFailed,
  FailureMessageKeys.familyUnavailable => l10n.familyUnavailable,
  FailureMessageKeys.familyLoadFailed => l10n.familyLoadFailed,
  FailureMessageKeys.familyServerError => l10n.familyServerError,
  FailureMessageKeys.analysisPhotoRequired => l10n.analysisPhotoRequired,
  FailureMessageKeys.analysisPhotoTooLarge => l10n.analysisPhotoTooLarge,
  FailureMessageKeys.analysisBaselineRequired => l10n.analysisBaselineRequired,
  FailureMessageKeys.analysisEachPhotoTooLarge =>
    l10n.analysisEachPhotoTooLarge,
  FailureMessageKeys.analysisUnsupportedType => l10n.analysisUnsupportedType,
  FailureMessageKeys.analysisInvalidCounts => l10n.analysisInvalidCounts,
  FailureMessageKeys.analysisUnreliableWater => l10n.analysisUnreliableWater,
  FailureMessageKeys.analysisConfidenceUnknown =>
    l10n.analysisConfidenceUnknown,
  FailureMessageKeys.analysisUnreliableLitter => l10n.analysisUnreliableLitter,
  FailureMessageKeys.analysisUnknownOutcome => l10n.analysisUnknownOutcome,
  FailureMessageKeys.analysisServiceUnavailable =>
    l10n.analysisServiceUnavailable,
  FailureMessageKeys.storagePhotoNotFound => l10n.storagePhotoNotFound,
  FailureMessageKeys.storageBucketMissing => l10n.storageBucketMissing,
  FailureMessageKeys.chatUnavailable => l10n.chatUnavailable,
  _ => null,
};
