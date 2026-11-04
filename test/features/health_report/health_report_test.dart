import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup/features/health_report/presentation/health_report_page.dart';
import 'package:hareup/features/pet/domain/pet.dart';
import 'package:hareup/features/photo_analysis/domain/analysis.dart';
import 'package:hareup/features/records/data/memory_records_repository.dart';
import 'package:hareup/features/records/domain/record.dart';
import 'package:hareup/features/records/presentation/widgets/observation_chart.dart';
import 'package:hareup/features/water_bowl/data/memory_water_bowl_repository.dart';
import 'package:hareup/features/water_bowl/domain/water_bowl.dart';
import 'package:hareup/features/water_bowl/domain/water_level.dart';
import 'package:hareup/l10n/l10n.dart';
import 'package:hareup_design_system/design_system.dart';

class History implements AnalysisService, WaterLevelHistoryService {
  @override
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request) async =>
      const Success(AnalysisUnavailable(''));
  @override
  Future<Result<List<WaterLevelHistoryItem>>> listWaterLevels({
    required String groupId,
    required String bowlId,
  }) async => Success([
    WaterLevelHistoryItem(
      result: const WaterLevelResult(status: 'ok', current: 30),
      createdAt: DateTime.utc(2026, 1, 2),
      setup: false,
    ),
    WaterLevelHistoryItem(
      result: const WaterLevelResult(status: 'ok', current: 80),
      createdAt: DateTime.utc(2026, 1, 1),
      setup: false,
    ),
  ]);
}

void main() {
  testWidgets(
    'report separates shared bowl levels and pet-attributed litter records',
    (tester) async {
      final water = MemoryWaterBowlRepository();
      final records = MemoryRecordsRepository();
      final photo = Uint8List.fromList([1]);
      final time = DateTime.utc(2026);
      final baseline = PhotoBaseline(version: 1, createdAt: time, photo: photo);
      await water.create(
        WaterBowl(
          id: 'bowl',
          name: '공용 물그릇',
          petIds: ['a', 'b'],
          baselines: [baseline],
        ),
      );
      Future<void> save(String id, String? catId, int count) => records.save(
        ObservationRecord(
          request: AnalysisRequest(
            id: id,
            groupId: 'g',
            targetId: 'l',
            targetName: '화장실',
            kind: AnalysisKind.litter,
            baseline: baseline,
            photo: photo,
            photoSelectedAt: time,
          ),
          outcome: LitterOutcome(urineCount: count, stoolCount: 1),
          analyzedAt: time,
          selectedCatId: catId,
        ),
      );
      await save('a-record', 'a', 2);
      await save('b-record', 'b', 7);
      await save('unknown', null, 9);
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            DesignLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: HealthReportPage(
            pets: const [
              Pet(id: 'a', name: '나비', species: PetSpecies.cat),
              Pet(id: 'b', name: '보리', species: PetSpecies.cat),
            ],
            waterRepository: water,
            recordsRepository: records,
            runtime: AnalysisRuntime(
              service: History(),
              groupId: 'g',
              validation: const AnalysisValidation(
                waterPercent: true,
                litterCounts: true,
              ),
            ),
            onViewRecords: () {},
            onViewTargets: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('반려동물별 음수량은 아직 측정할 수 없어 그래프를 제공하지 않습니다.'),
        findsOneWidget,
      );
      expect(find.text('공용 물그릇 · 함께 사용하는 물그릇'), findsOneWidget);
      final waterChart = tester.widget<ObservationChart>(
        find.byWidgetPredicate(
          (widget) => widget is ObservationChart && widget.unit == '%',
        ),
      );
      expect(waterChart.points.map((point) => point.values.single), [80, 30]);
      final vertical = find
          .descendant(
            of: find.byType(HealthReportPage),
            matching: find.byType(Scrollable),
          )
          .first;
      await tester.scrollUntilVisible(
        find.text('배변 횟수 추이'),
        250,
        scrollable: vertical,
      );
      final first = tester.widget<ObservationChart>(
        find.byWidgetPredicate(
          (widget) => widget is ObservationChart && widget.unit == '회',
        ),
      );
      expect(first.points.map((point) => point.values), [
        [2.0, 1.0],
      ]);
      await tester.scrollUntilVisible(
        find.text('보리'),
        -250,
        scrollable: vertical,
      );
      await tester.tap(find.text('보리'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(
        find.text('배변 횟수 추이'),
        250,
        scrollable: vertical,
      );
      final second = tester.widget<ObservationChart>(
        find.byWidgetPredicate(
          (widget) => widget is ObservationChart && widget.unit == '회',
        ),
      );
      expect(second.points.map((point) => point.values), [
        [7.0, 1.0],
      ]);
    },
  );

  testWidgets('does not display unvalidated water or litter values', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('ko'),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          DesignLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: HealthReportPage(
          pets: const [Pet(id: 'a', name: '나비', species: PetSpecies.cat)],
          waterRepository: MemoryWaterBowlRepository(),
          recordsRepository: MemoryRecordsRepository(),
          runtime: AnalysisRuntime(service: History(), groupId: 'g'),
          onViewRecords: () {},
          onViewTargets: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.text('배변 흔적 횟수는 정확도 검증 후 표시됩니다.'),
      250,
    );
    expect(find.byType(ObservationChart), findsNothing);
  });
}
