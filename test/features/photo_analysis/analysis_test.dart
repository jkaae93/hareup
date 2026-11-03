import 'dart:typed_data';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/features/photo_analysis/data/unavailable_analysis_service.dart';
import 'package:hareup/features/photo_analysis/domain/analysis.dart';
import 'package:hareup/features/photo_analysis/presentation/analysis_cubit.dart';
import 'package:hareup/features/records/data/memory_records_repository.dart';
import 'package:hareup/features/records/domain/record.dart';
import 'package:hareup_core/core.dart';

class FakeAnalysis implements AnalysisService {
  FakeAnalysis(this.outcome);
  final AnalysisOutcome outcome;
  int calls = 0;
  @override
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request) async {
    calls++;
    return Success(outcome);
  }
}

AnalysisRequest request({
  AnalysisKind kind = AnalysisKind.water,
  String id = 'one',
  String group = 'family',
  Uint8List? baseline,
  Uint8List? photo,
  double? fullMl,
  double? weight,
  double? width,
  double? length,
  double? height,
  bool registrationPhoto = false,
}) => AnalysisRequest(
  id: id,
  groupId: group,
  targetId: 'target',
  targetName: '물그릇',
  kind: kind,
  baseline: PhotoBaseline(
    version: 1,
    createdAt: DateTime.utc(2026),
    photo: baseline ?? Uint8List.fromList([1]),
  ),
  photo: photo ?? Uint8List.fromList([2]),
  photoSelectedAt: DateTime.utc(2026, 1, 2),
  registrationPhoto: registrationPhoto,
  fullWaterMl: fullMl,
  emptyWeightGrams: weight,
  widthCm: width,
  lengthCm: length,
  litterHeightCm: height,
);

void main() {
  test('registration estimate keeps valid subjective confidence', () {
    final input = request(registrationPhoto: true, fullMl: 500);
    final result =
        gateAnalysis(
              input,
              const WaterOutcome(percent: 30, confidencePercent: 40),
              const AnalysisValidation(),
            )
            as WaterOutcome;
    expect(result.percent, 30);
    expect(result.confidencePercent, 40);
    expect(
      gateAnalysis(
        input,
        const WaterOutcome(percent: 30, confidencePercent: 101),
        const AnalysisValidation(),
      ),
      isA<AnalysisUnavailable>(),
    );
    expect(
      gateAnalysis(
        input,
        const WaterOutcome(percent: 30),
        const AnalysisValidation(),
      ),
      isA<AnalysisUnavailable>(),
    );
  });
  test(
    'blocks invalid or unvalidated results and only permits validated quantities with complete inputs',
    () {
      final water = request();
      const result = WaterOutcome(percent: 25, volumeMl: 100);
      expect(
        gateAnalysis(water, result, const AnalysisValidation()),
        isA<AnalysisUnavailable>(),
      );
      final percentOnly =
          gateAnalysis(
                water,
                result,
                const AnalysisValidation(waterPercent: true, waterVolume: true),
              )
              as WaterOutcome;
      expect(percentOnly.percent, 25);
      expect(percentOnly.volumeMl, isNull);
      final valid =
          gateAnalysis(
                request(fullMl: 500, weight: 100),
                result,
                const AnalysisValidation(waterPercent: true, waterVolume: true),
              )
              as WaterOutcome;
      expect(valid.volumeMl, 100);
      expect(
        gateAnalysis(
          water,
          const WaterOutcome(percent: 101),
          const AnalysisValidation(waterPercent: true),
        ),
        isA<AnalysisUnavailable>(),
      );
      final litter = request(kind: AnalysisKind.litter, width: 40, length: 50);
      final litterResult =
          gateAnalysis(
                litter,
                const LitterOutcome(
                  urineCount: 2,
                  stoolCount: 1,
                  observedQuantity: 3,
                  quantityUnit: 'unit',
                ),
                const AnalysisValidation(
                  litterCounts: true,
                  litterVolume: true,
                ),
              )
              as LitterOutcome;
      expect(litterResult.observedQuantity, isNull);
    },
  );
  test('requires photos and never saves unavailable result', () async {
    final service = FakeAnalysis(const WaterOutcome(percent: 10));
    final records = MemoryRecordsRepository();
    final cubit = AnalysisCubit(service: service, records: records);
    await cubit.analyze(request(photo: Uint8List(0)));
    expect(cubit.state.stage, AnalysisStage.failed);
    expect(service.calls, 0);
    await cubit.analyze(request());
    expect(cubit.state.stage, AnalysisStage.unavailable);
    await cubit.save();
    expect(
      (await records.list(groupId: 'family', targetId: 'target')
              as Success<List<ObservationRecord>>)
          .value,
      isEmpty,
    );
    await cubit.close();
  });
  test(
    'preserves original and corrected counts, idempotently saves and isolates groups',
    () async {
      final records = MemoryRecordsRepository();
      final cubit = AnalysisCubit(
        service: FakeAnalysis(
          const LitterOutcome(urineCount: 2, stoolCount: 1, uncertain: true),
        ),
        records: records,
        validation: const AnalysisValidation(litterCounts: true),
      );
      await cubit.analyze(request(kind: AnalysisKind.litter));
      expect(cubit.state.stage, AnalysisStage.review);
      await cubit.save(urineCount: -1, stoolCount: 1);
      expect(cubit.state.stage, AnalysisStage.review);
      await cubit.save(urineCount: 3, stoolCount: 1);
      expect(cubit.state.stage, AnalysisStage.saved);
      final items =
          (await records.list(groupId: 'family', targetId: 'target')
                  as Success<List<ObservationRecord>>)
              .value;
      expect((items.single.outcome as LitterOutcome).urineCount, 2);
      expect(items.single.correctedUrineCount, 3);
      expect(items.single.selectedCatId, isNull);
      expect(await records.save(items.single), isA<Success<void>>());
      expect(
        (await records.list(groupId: 'other', targetId: 'target')
                as Success<List<ObservationRecord>>)
            .value,
        isEmpty,
      );
      expect(
        (await records.list(groupId: 'family', targetId: 'target')
                as Success<List<ObservationRecord>>)
            .value
            .length,
        1,
      );
      await cubit.close();
    },
  );
  test('default service reports unavailable', () async {
    final response = await const UnavailableAnalysisService().analyze(
      request(),
    );
    expect(
      (response as Success<AnalysisOutcome>).value,
      isA<AnalysisUnavailable>(),
    );
  });
}
