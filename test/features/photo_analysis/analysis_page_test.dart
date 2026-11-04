import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:hareup/features/photo_analysis/domain/analysis.dart';
import 'package:hareup/features/photo_analysis/data/unavailable_analysis_service.dart';
import 'package:hareup/features/photo_analysis/presentation/analysis_page.dart';
import 'package:hareup/features/records/data/memory_records_repository.dart';
import 'package:hareup/features/records/domain/record.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_media/media.dart';
import 'package:image_picker/image_picker.dart';

final _pixel = base64Decode(
  'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
);

class FakePhotos implements PhotoSource {
  @override
  Future<PhotoSelection> pickFromCamera() => pickFromGallery();
  @override
  Future<PhotoSelection> pickFromGallery() async =>
      PhotoSelected(XFile.fromData(_pixel, name: 'test.png'));
  @override
  Future<PhotoSelection> recoverInterruptedSelection() async =>
      const PhotoCancelled();
}

class ApprovedTestService implements AnalysisService {
  @override
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request) async =>
      const Success(LitterOutcome(urineCount: 2, stoolCount: 1));
}

class ExplainedTestService implements AnalysisService {
  @override
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request) async =>
      const Success(
        AnalysisUnavailable(
          '분석 불확실',
          modelResponse: '{"status":"uncertain","reason":"수면이 보이지 않습니다."}',
        ),
      );
}

void main() {
  testWidgets('shows the unchanged model response on a separate page', (
    tester,
  ) async {
    await tester.pumpWidget(
      RepositoryProvider<RecordsRepository>.value(
        value: MemoryRecordsRepository(),
        child: MaterialApp(
          localizationsDelegates: testLocalizationsDelegates,
          locale: const Locale('ko'),
          supportedLocales: appSupportedLocales,
          home: AnalysisPage(
            targetId: 'bowl',
            targetName: '물그릇',
            kind: AnalysisKind.water,
            baseline: PhotoBaseline(
              version: 1,
              createdAt: DateTime.utc(2026),
              photo: _pixel,
            ),
            photoSource: FakePhotos(),
            runtime: AnalysisRuntime(
              service: ExplainedTestService(),
              groupId: 'family',
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('사진 선택'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('사진 분석'), 200);
    await tester.tap(find.text('사진 분석'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('모델 응답 보기'), 200);
    await tester.tap(find.text('모델 응답 보기'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('모델 응답'), findsOneWidget);
    expect(
      find.text('{"status":"uncertain","reason":"수면이 보이지 않습니다."}'),
      findsOneWidget,
    );
    await tapBackButton(tester);
    await tester.pumpAndSettle();
    expect(find.text('모델 응답'), findsNothing);
  });
  testWidgets('default unavailable service cannot show a result or save', (
    tester,
  ) async {
    final records = MemoryRecordsRepository();
    await tester.pumpWidget(
      RepositoryProvider<RecordsRepository>.value(
        value: records,
        child: MaterialApp(
          theme: testTheme,
          localizationsDelegates: testLocalizationsDelegates,
          locale: const Locale('ko'),
          supportedLocales: appSupportedLocales,
          home: AnalysisPage(
            targetId: 'bowl',
            targetName: '물그릇',
            kind: AnalysisKind.water,
            baseline: PhotoBaseline(
              version: 1,
              createdAt: DateTime.utc(2026),
              photo: _pixel,
            ),
            photoSource: FakePhotos(),
            runtime: const AnalysisRuntime(
              service: UnavailableAnalysisService(),
              groupId: 'local-development',
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('사진 선택'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('사진 분석'), 200);
    await tester.tap(find.text('사진 분석'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('사진 분석 서비스가 아직 준비되지 않았습니다.'),
      200,
    );
    expect(find.text('사진 분석 서비스가 아직 준비되지 않았습니다.'), findsOneWidget);
    expect(find.text('기록 저장'), findsNothing);
    expect(find.textContaining('감소율:'), findsNothing);
    final result = await records.list(
      groupId: 'local-development',
      targetId: 'bowl',
    );
    expect((result as Success<List<ObservationRecord>>).value, isEmpty);
  });
  testWidgets(
    'injected validated service records user-selected cat and edited counts',
    (tester) async {
      final records = MemoryRecordsRepository();
      await tester.pumpWidget(
        RepositoryProvider<RecordsRepository>.value(
          value: records,
          child: MaterialApp(
            theme: testTheme,
            localizationsDelegates: testLocalizationsDelegates,
            locale: const Locale('ko'),
            supportedLocales: appSupportedLocales,
            home: AnalysisPage(
              targetId: 'litter',
              targetName: '화장실',
              kind: AnalysisKind.litter,
              baseline: PhotoBaseline(
                version: 1,
                createdAt: DateTime.utc(2026),
                photo: _pixel,
              ),
              photoSource: FakePhotos(),
              cats: const [AnalysisCat(id: 'cat-1', name: '나비')],
              runtime: AnalysisRuntime(
                service: ApprovedTestService(),
                groupId: 'family-1',
                validation: const AnalysisValidation(litterCounts: true),
              ),
            ),
          ),
        ),
      );
      await tester.tap(find.text('사진 선택'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('사진 분석'), 200);
      await tester.tap(find.text('사진 분석'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, '확인한 소변 흔적 수'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.enterText(
        find.widgetWithText(TextField, '확인한 소변 흔적 수'),
        '3',
      );
      await tester.scrollUntilVisible(
        find.text('미확인'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.ensureVisible(find.widgetWithText(ChoiceChip, '나비'));
      await tester.pumpAndSettle();
      await tester.tap(find.widgetWithText(ChoiceChip, '나비'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.widgetWithText(TextField, '특이사항 (선택)'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.enterText(
        find.widgetWithText(TextField, '특이사항 (선택)'),
        '모래 교체 전 확인',
      );
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('기록 저장'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(ListView),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('기록 저장'));
      await tester.pumpAndSettle();
      final result = await records.list(
        groupId: 'family-1',
        targetId: 'litter',
      );
      final record = (result as Success<List<ObservationRecord>>).value.single;
      expect(record.notes, '모래 교체 전 확인');
      expect(record.selectedCatId, 'cat-1');
      expect(record.correctedUrineCount, 3);
      expect((record.outcome as LitterOutcome).urineCount, 2);
      expect(
        (await records.list(groupId: 'other', targetId: 'litter')
                as Success<List<ObservationRecord>>)
            .value,
        isEmpty,
      );
    },
  );
}
