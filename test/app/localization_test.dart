import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/app/app.dart';
import 'package:hareup/features/auth/domain/auth_repository.dart';
import 'package:hareup/features/photo_analysis/domain/analysis.dart';
import 'package:hareup/features/records/domain/record.dart';
import 'package:hareup/l10n/l10n.dart';
import 'package:hareup_core/core.dart';

import '../test_support.dart';

class _SignedOutAuth implements AuthRepository {
  const _SignedOutAuth();

  @override
  List<AuthProviderOption> get providers => const [];

  @override
  Stream<AuthSession?> observeSession() => Stream.value(null);

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async => const Success(null);

  @override
  Future<Result<void>> signInWithProvider(String providerId) async =>
      const Success(null);

  @override
  Future<Result<void>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => const Success(null);

  @override
  Future<Result<void>> signOut() async => const Success(null);
}

ObservationRecord _sample() {
  final photo = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
  );
  final date = DateTime.utc(2026, 1, 2);
  return ObservationRecord(
    request: AnalysisRequest(
      id: 'target',
      groupId: 'family',
      targetId: 'target',
      targetName: '관찰 대상',
      kind: AnalysisKind.litter,
      baseline: PhotoBaseline(version: 1, createdAt: date, photo: photo),
      photo: photo,
      photoSelectedAt: date,
    ),
    outcome: const LitterOutcome(urineCount: 1, stoolCount: 2),
    analyzedAt: date,
  ).withAnnotations(urineCount: 3, stoolCount: 2, notes: '확인 메모');
}

void main() {
  for (final entry in {
    const Locale('ko'): ['로그인', '이메일'],
    const Locale('en'): ['Sign in', 'Email'],
  }.entries) {
    testWidgets('sign-in form renders in ${entry.key}', (tester) async {
      await tester.pumpWidget(
        HareupApp(
          authRepository: const _SignedOutAuth(),
          initialLocale: entry.key,
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text(entry.value[0]), findsOneWidget);
      expect(find.text(entry.value[1]), findsOneWidget);
    });
  }

  test('share text renders in English', () {
    final l10n = lookupAppLocalizations(const Locale('en'));
    final text = recordShareText(
      _sample(),
      RecordShareStrings(
        header: l10n.shareHeader,
        analyzedAt: l10n.recordsAnalyzedAt,
        waterPercent: l10n.shareWaterPercent,
        waterVolume: l10n.shareWaterVolume,
        confirmedUrine: l10n.shareConfirmedUrine,
        confirmedStool: l10n.shareConfirmedStool,
        unavailable: (unavailable) =>
            l10n.recordsUnavailableWith(unavailable.reason),
        memo: l10n.shareMemo,
        disclaimer: l10n.recordsEstimateDisclaimer,
      ),
    );
    expect(text, contains('[Hareup observation record]'));
    expect(text, contains('Confirmed urine: 3 times'));
    expect(text, contains('Confirmed stool: 2 times'));
    expect(text, contains('Notes: 확인 메모'));
    expect(text, contains('not a diagnosis'));
    expect(text, isNot(contains('확인한 소변')));
  });
}
