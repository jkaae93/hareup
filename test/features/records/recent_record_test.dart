import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:hareup/features/photo_analysis/domain/analysis.dart';
import 'package:hareup/features/records/domain/record.dart';
import 'package:hareup/features/records/presentation/recent_record_summary.dart';
import 'package:hareup_core/core.dart';

class FakeRecords implements RecordsRepository {
  FakeRecords(this.result);
  final Result<List<ObservationRecord>> result;
  @override
  Future<Result<List<ObservationRecord>>> listAll({
    required String groupId,
  }) async => result;
  @override
  Future<Result<List<ObservationRecord>>> list({
    required String groupId,
    required String targetId,
  }) async => result;
  @override
  Future<Result<void>> updateAnnotations({
    required ObservationRecord original,
    required ObservationRecord updated,
  }) async => const Success(null);
  @override
  Future<Result<void>> save(ObservationRecord record) async =>
      const Success(null);
}

ObservationRecord record({
  required String group,
  required String target,
  required int day,
  required double percent,
}) => ObservationRecord(
  request: AnalysisRequest(
    id: '$group-$day',
    groupId: group,
    targetId: target,
    targetName: '그릇',
    kind: AnalysisKind.water,
    baseline: PhotoBaseline(
      version: 1,
      createdAt: DateTime.utc(2026),
      photo: Uint8List.fromList([1]),
    ),
    photo: Uint8List.fromList([2]),
    photoSelectedAt: DateTime.utc(2026, 1, day),
  ),
  outcome: WaterOutcome(percent: percent),
  analyzedAt: DateTime.utc(2026, 1, day),
);
void main() {
  testWidgets(
    'shows latest matching observation, including zero, without adding other groups or photos',
    (tester) async {
      final repo = FakeRecords(
        Success([
          record(group: 'a', target: 'bowl', day: 1, percent: 30),
          record(group: 'a', target: 'bowl', day: 2, percent: 0),
          record(group: 'other', target: 'bowl', day: 3, percent: 90),
        ]),
      );
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          localizationsDelegates: testLocalizationsDelegates,
          locale: const Locale('ko'),
          supportedLocales: appSupportedLocales,
          home: Scaffold(
            body: RecentRecordSummary(
              repository: repo,
              groupId: 'a',
              targetId: 'bowl',
              kind: AnalysisKind.water,
            ),
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('최근 기록 · 물 감소율 0.0% (추정)'), findsOneWidget);
      expect(find.textContaining('90'), findsNothing);
      expect(find.textContaining('30'), findsNothing);
    },
  );
  testWidgets('distinguishes an empty list from a retrieval failure', (
    tester,
  ) async {
    Widget view(RecordsRepository repo) => MaterialApp(
      theme: testTheme,
      localizationsDelegates: testLocalizationsDelegates,
      locale: const Locale('ko'),
      supportedLocales: appSupportedLocales,
      home: Scaffold(
        body: RecentRecordSummary(
          repository: repo,
          groupId: 'a',
          targetId: 'bowl',
          kind: AnalysisKind.water,
        ),
      ),
    );
    await tester.pumpWidget(view(FakeRecords(const Success([]))));
    await tester.pumpAndSettle();
    expect(find.text('분석 기록 없음'), findsOneWidget);
    await tester.pumpWidget(view(FakeRecords(const Failure(NetworkFailure()))));
    await tester.pumpAndSettle();
    expect(find.text('기록을 불러오지 못했습니다.'), findsOneWidget);
  });
}
