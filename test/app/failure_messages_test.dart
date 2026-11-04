import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/app/failure_messages.dart';
import 'package:hareup_core/core.dart';

import '../test_support.dart';

/// Every stable failure key must resolve in both locales.
const _allKeys = [
  FailureMessageKeys.authProviderUnavailable,
  FailureMessageKeys.authCancelled,
  FailureMessageKeys.authInvalidEmail,
  FailureMessageKeys.authEmailInUse,
  FailureMessageKeys.authWeakPassword,
  FailureMessageKeys.authInvalidCredential,
  FailureMessageKeys.authTooManyRequests,
  FailureMessageKeys.authNotEnabled,
  FailureMessageKeys.appAuthUnavailable,
  FailureMessageKeys.recordsInvalidAnnotations,
  FailureMessageKeys.recordsChanged,
  FailureMessageKeys.recordsAlreadySaved,
  FailureMessageKeys.waterAlreadyRegistered,
  FailureMessageKeys.waterHistoryUnavailable,
  FailureMessageKeys.litterAlreadyRegistered,
  FailureMessageKeys.settingsLoadFailed,
  FailureMessageKeys.settingsOpenLinkFailed,
  FailureMessageKeys.familyUnavailable,
  FailureMessageKeys.familyLoadFailed,
  FailureMessageKeys.familyServerError,
  FailureMessageKeys.analysisPhotoRequired,
  FailureMessageKeys.analysisPhotoTooLarge,
  FailureMessageKeys.analysisBaselineRequired,
  FailureMessageKeys.analysisEachPhotoTooLarge,
  FailureMessageKeys.analysisUnsupportedType,
  FailureMessageKeys.analysisInvalidCounts,
  FailureMessageKeys.analysisUnreliableWater,
  FailureMessageKeys.analysisConfidenceUnknown,
  FailureMessageKeys.analysisUnreliableLitter,
  FailureMessageKeys.analysisUnknownOutcome,
  FailureMessageKeys.analysisServiceUnavailable,
  FailureMessageKeys.storagePhotoNotFound,
  FailureMessageKeys.storageBucketMissing,
  FailureMessageKeys.chatUnavailable,
];

void main() {
  test('every failure key resolves in both locales', () {
    for (final locale in [const Locale('ko'), const Locale('en')]) {
      final l10n = lookupAppLocalizations(locale);
      for (final key in _allKeys) {
        final resolved = failureMessageForKey(l10n, key);
        expect(resolved, isNotNull, reason: '$key in $locale');
        expect(resolved, isNotEmpty, reason: '$key in $locale');
      }
    }
  });

  test('unknown keys fall back to null', () {
    expect(
      failureMessageForKey(lookupAppLocalizations(const Locale('en')), 'nope'),
      isNull,
    );
  });

  testWidgets('keyed failures render in the widget locale', (tester) async {
    Future<String> rendered(Locale locale, AppFailure failure) async {
      var text = '';
      await tester.pumpWidget(
        MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          supportedLocales: appSupportedLocales,
          locale: locale,
          home: Builder(
            builder: (context) {
              text = failureDisplayMessage(context, failure);
              return const SizedBox();
            },
          ),
        ),
      );
      return text;
    }

    const failure = RequestFailure(
      '이메일 또는 비밀번호를 확인해 주세요.',
      FailureMessageKeys.authInvalidCredential,
    );
    expect(
      await rendered(const Locale('ko'), failure),
      '이메일 또는 비밀번호를 확인해 주세요.',
    );
    expect(
      await rendered(const Locale('en'), failure),
      'Check your email or password.',
    );
    expect(
      await rendered(const Locale('en'), const NetworkFailure()),
      'Check your network connection.',
    );
    expect(
      await rendered(const Locale('en'), const ServerFailure('server says hi')),
      'server says hi',
    );
  });
}
