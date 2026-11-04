import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup/features/litter_box/data/memory_litter_box_repository.dart';
import 'package:hareup/features/litter_box/domain/litter_box.dart';
import 'package:hareup/features/pet/domain/pet.dart';
import 'package:hareup/features/pet/presentation/pet_detail_page.dart';
import 'package:hareup/features/photo_analysis/domain/analysis.dart';
import 'package:hareup/features/records/data/memory_records_repository.dart';
import 'package:hareup/features/records/domain/record.dart';
import 'package:hareup/features/water_bowl/data/memory_water_bowl_repository.dart';
import 'package:hareup/features/water_bowl/domain/water_bowl.dart';
import 'package:hareup/features/water_bowl/domain/water_level.dart';
import 'package:hareup/l10n/l10n.dart';
import 'package:hareup_design_system/design_system.dart';

class FakeHistory implements AnalysisService, WaterLevelHistoryService {
  @override
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request) async =>
      const Success(AnalysisUnavailable(''));
  @override
  Future<Result<List<WaterLevelHistoryItem>>> listWaterLevels({
    required String groupId,
    required String bowlId,
  }) async => Success([
    WaterLevelHistoryItem(
      result: const WaterLevelResult(status: 'ok', current: 42),
      createdAt: DateTime.utc(2026),
      setup: false,
    ),
  ]);
}

void main() {
  testWidgets('pet health page shows English labels when English is selected', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          DesignLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: PetDetailPage(
          pet: const Pet(id: 'cat', name: 'Nabi', species: PetSpecies.cat),
          waterRepository: MemoryWaterBowlRepository(),
          litterRepository: MemoryLitterBoxRepository(),
          recordsRepository: MemoryRecordsRepository(),
          runtime: AnalysisRuntime(service: FakeHistory(), groupId: 'g'),
          onEdit: () {},
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Water bowl observations'), findsOneWidget);
    expect(find.text('No linked water bowls.'), findsOneWidget);
  });
  testWidgets(
    'shows shared water as shared and only litter records explicitly attributed to pet',
    (tester) async {
      final water = MemoryWaterBowlRepository();
      final litter = MemoryLitterBoxRepository();
      final records = MemoryRecordsRepository();
      final now = DateTime.utc(2026);
      final photo = Uint8List.fromList([1]);
      final baseline = PhotoBaseline(version: 1, createdAt: now, photo: photo);
      await water.create(
        WaterBowl(
          id: 'w',
          name: '공용 정수기',
          petIds: ['cat', 'other'],
          baselines: [baseline],
        ),
      );
      await litter.create(
        LitterBox(
          id: 'l',
          name: '공용 화장실',
          catIds: ['cat', 'other'],
          baselines: [baseline],
        ),
      );
      ObservationRecord record(String id, String? selected) =>
          ObservationRecord(
            request: AnalysisRequest(
              id: id,
              groupId: 'g',
              targetId: 'l',
              targetName: id,
              kind: AnalysisKind.litter,
              baseline: baseline,
              photo: photo,
              photoSelectedAt: now,
              eligibleCats: const [
                AnalysisCat(id: 'cat', name: '나비'),
                AnalysisCat(id: 'other', name: '보리'),
              ],
            ),
            outcome: const LitterOutcome(urineCount: 2, stoolCount: 1),
            analyzedAt: now,
            selectedCatId: selected,
          );
      await records.save(record('나비 기록', 'cat'));
      await records.save(record('미확인 기록', null));
      await records.save(record('보리 기록', 'other'));
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            DesignLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: PetDetailPage(
            pet: const Pet(id: 'cat', name: '나비', species: PetSpecies.cat),
            waterRepository: water,
            litterRepository: litter,
            recordsRepository: records,
            runtime: AnalysisRuntime(
              service: FakeHistory(),
              groupId: 'g',
              validation: const AnalysisValidation(
                waterPercent: true,
                litterCounts: true,
              ),
            ),
            onEdit: () {},
          ),
        ),
      );
      await tester.pumpAndSettle();
      expect(
        find.text('함께 사용하는 물그릇의 수위입니다. 개별 음수량은 알 수 없습니다.'),
        findsOneWidget,
      );
      expect(find.text('현재 수위 42.0% (추정)'), findsOneWidget);
      await tester.scrollUntilVisible(find.text('나비 기록'), 200);
      expect(find.text('나비 기록'), findsOneWidget);
      expect(find.text('미확인 기록'), findsNothing);
      expect(find.text('보리 기록'), findsNothing);
    },
  );
}
