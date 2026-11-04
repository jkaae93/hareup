import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup/features/photo_analysis/domain/analysis.dart';
import 'package:hareup/features/records/data/memory_records_repository.dart';
import 'package:hareup/features/records/domain/record.dart';
import 'package:hareup/features/records/presentation/records_page.dart';
import '../../test_support.dart';

ObservationRecord sample(String id, String group, AnalysisKind kind, int day) {
  final photo = base64Decode(
    'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
  );
  final date = DateTime.utc(2026, 1, day);
  return ObservationRecord(
    request: AnalysisRequest(
      id: id,
      groupId: group,
      targetId: id,
      targetName: id,
      kind: kind,
      baseline: PhotoBaseline(version: 1, createdAt: date, photo: photo),
      photo: photo,
      photoSelectedAt: date,
    ),
    outcome: kind == AnalysisKind.water
        ? const WaterOutcome(percent: 20)
        : const LitterOutcome(urineCount: 1, stoolCount: 2),
    analyzedAt: date,
  );
}

void main() {
  test('share text describes the observation without internal identifiers', () {
    final record = sample(
      '관찰 대상',
      'private-family-id',
      AnalysisKind.litter,
      1,
    ).withAnnotations(urineCount: 3, stoolCount: 2, notes: '확인 메모');
    final text = recordShareText(record, RecordShareStrings.korean());
    expect(text, contains('관찰 대상'));
    expect(text, contains('확인한 소변: 3회'));
    expect(text, contains('확인 메모'));
    expect(text, contains('진단이 아닙니다'));
    expect(text, isNot(contains('private-family-id')));
  });

  testWidgets(
    'group timeline keeps groups separate, sorts, filters and opens a record',
    (tester) async {
      final repository = MemoryRecordsRepository();
      await repository.save(sample('물 기록', 'family', AnalysisKind.water, 1));
      await repository.save(sample('화장실 기록', 'family', AnalysisKind.litter, 2));
      await repository.save(sample('다른 가족', 'other', AnalysisKind.water, 3));
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          localizationsDelegates: testLocalizationsDelegates,
          locale: const Locale('ko'),
          supportedLocales: appSupportedLocales,
          home: GroupRecordsPage(repository: repository, groupId: 'family'),
        ),
      );
      await tester.pumpAndSettle();
      expect(find.text('다른 가족'), findsNothing);
      expect(find.text('물 기록'), findsOneWidget);
      expect(find.text('화장실 기록'), findsOneWidget);
      expect(
        tester.getTopLeft(find.text('화장실 기록')).dy,
        lessThan(tester.getTopLeft(find.text('물 기록')).dy),
      );
      await tester.tap(find.text('물그릇'));
      await tester.pumpAndSettle();
      expect(find.text('물 기록'), findsOneWidget);
      expect(find.text('화장실 기록'), findsNothing);
      await tester.tap(find.text('물 기록'));
      await tester.pumpAndSettle();
      expect(find.byType(RecordDetailPage), findsOneWidget);
    },
  );
  test(
    'annotation updates keep the original outcome and reject stale writes',
    () async {
      final repo = MemoryRecordsRepository();
      final original = sample('기록', 'family', AnalysisKind.litter, 1);
      await repo.save(original);
      final first = original.withAnnotations(
        urineCount: 3,
        stoolCount: 2,
        notes: '확인',
      );
      expect(
        await repo.updateAnnotations(original: original, updated: first),
        isA<Success<void>>(),
      );
      final conflict = original.withAnnotations(
        urineCount: 4,
        stoolCount: 2,
        notes: '다른 수정',
      );
      expect(
        await repo.updateAnnotations(original: original, updated: conflict),
        isA<Failure<void>>(),
      );
      final saved =
          (await repo.listAll(groupId: 'family')
                  as Success<List<ObservationRecord>>)
              .value
              .single;
      expect(saved.notes, '확인');
      expect(saved.correctedUrineCount, 3);
      expect((saved.outcome as LitterOutcome).urineCount, 1);
      expect(
        (await repo.listAll(groupId: 'other')
                as Success<List<ObservationRecord>>)
            .value,
        isEmpty,
      );
    },
  );

  testWidgets(
    'record annotations can be edited on a separate page and reloaded',
    (tester) async {
      final repo = MemoryRecordsRepository();
      await repo.save(sample('화장실 기록', 'family', AnalysisKind.litter, 1));
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          localizationsDelegates: testLocalizationsDelegates,
          locale: const Locale('ko'),
          supportedLocales: appSupportedLocales,
          home: GroupRecordsPage(repository: repo, groupId: 'family'),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('화장실 기록'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('기록 수정'), 250);
      await tester.tap(find.text('기록 수정'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextField, '확인한 소변 흔적 수'),
        '4',
      );
      await tester.ensureVisible(find.widgetWithText(TextField, '특이사항 (선택)'));
      await tester.enterText(
        find.widgetWithText(TextField, '특이사항 (선택)'),
        '모래 교체',
      );
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.tap(find.text('저장'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('모래 교체'), 250);
      expect(find.text('모래 교체'), findsOneWidget);
      final saved =
          (await repo.listAll(groupId: 'family')
                  as Success<List<ObservationRecord>>)
              .value
              .single;
      expect(saved.correctedUrineCount, 4);
      expect((saved.outcome as LitterOutcome).urineCount, 1);
      await tapBackButton(tester);
      await tester.pumpAndSettle();
      expect(find.textContaining('소변 4회'), findsOneWidget);
    },
  );
}
