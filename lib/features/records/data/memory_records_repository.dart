import 'dart:typed_data';
import 'package:hareup_core/core.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../domain/record.dart';

class MemoryRecordsRepository implements RecordsRepository {
  final _items = <(String, String), ObservationRecord>{};
  @override
  Future<Result<List<ObservationRecord>>> listAll({
    required String groupId,
  }) async => Success(
    List.unmodifiable(
      _items.values.where((record) => record.request.groupId == groupId),
    ),
  );
  @override
  Future<Result<List<ObservationRecord>>> list({
    required String groupId,
    required String targetId,
  }) async => Success(
    List.unmodifiable(
      _items.values.where(
        (r) => r.request.groupId == groupId && r.request.targetId == targetId,
      ),
    ),
  );
  @override
  Future<Result<void>> updateAnnotations({
    required ObservationRecord original,
    required ObservationRecord updated,
  }) async {
    if (original.request.groupId != updated.request.groupId ||
        original.request.id != updated.request.id ||
        !validRecordAnnotations(
          original.withAnnotations(
            urineCount: updated.correctedUrineCount,
            stoolCount: updated.correctedStoolCount,
            catId: updated.selectedCatId,
            notes: updated.notes,
          ),
        )) {
      return const Failure(
        RequestFailure(
          '수정한 내용을 확인해 주세요.',
          FailureMessageKeys.recordsInvalidAnnotations,
        ),
      );
    }
    final key = (original.request.groupId, original.request.id);
    final current = _items[key];
    if (current == null) return const Failure(NotFoundFailure());
    if (!sameRecordAnnotations(current, original)) {
      return const Failure(
        RequestFailure(
          '기록이 변경되었습니다. 다시 불러온 후 수정해 주세요.',
          FailureMessageKeys.recordsChanged,
        ),
      );
    }
    _items[key] = current.withAnnotations(
      urineCount: updated.correctedUrineCount,
      stoolCount: updated.correctedStoolCount,
      catId: updated.selectedCatId,
      notes: updated.notes,
    );
    return const Success(null);
  }

  @override
  Future<Result<void>> save(ObservationRecord record) async {
    final key = (record.request.groupId, record.request.id);
    final existing = _items[key];
    if (existing != null) {
      return _same(existing, record)
          ? const Success(null)
          : const Failure(
              RequestFailure(
                '이미 저장된 분석입니다.',
                FailureMessageKeys.recordsAlreadySaved,
              ),
            );
    }
    _items[key] = record;
    return const Success(null);
  }

  bool _same(ObservationRecord a, ObservationRecord b) {
    final x = a.request;
    final y = b.request;
    return x.targetId == y.targetId &&
        x.targetName == y.targetName &&
        _sameCats(x.eligibleCats, y.eligibleCats) &&
        x.kind == y.kind &&
        x.registrationPhoto == y.registrationPhoto &&
        x.baseline.version == y.baseline.version &&
        x.baseline.notes == y.baseline.notes &&
        x.baseline.createdAt == y.baseline.createdAt &&
        _sameBytes(x.baseline.photo, y.baseline.photo) &&
        _sameBytes(x.photo, y.photo) &&
        x.photoSelectedAt == y.photoSelectedAt &&
        x.emptyWeightGrams == y.emptyWeightGrams &&
        x.fullWaterMl == y.fullWaterMl &&
        x.widthCm == y.widthCm &&
        x.lengthCm == y.lengthCm &&
        x.litterHeightCm == y.litterHeightCm &&
        a.analyzedAt == b.analyzedAt &&
        a.correctedUrineCount == b.correctedUrineCount &&
        a.correctedStoolCount == b.correctedStoolCount &&
        a.selectedCatId == b.selectedCatId &&
        a.notes == b.notes &&
        _sameOutcome(a.outcome, b.outcome);
  }

  bool _sameCats(List<AnalysisCat> a, List<AnalysisCat> b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i].id != b[i].id || a[i].name != b[i].name) return false;
    }
    return true;
  }

  bool _sameBytes(Uint8List a, Uint8List b) {
    if (a.length != b.length) return false;
    for (var i = 0; i < a.length; i++) {
      if (a[i] != b[i]) return false;
    }
    return true;
  }

  bool _sameOutcome(AnalysisOutcome a, AnalysisOutcome b) => switch ((a, b)) {
    (WaterOutcome x, WaterOutcome y) =>
      x.percent == y.percent &&
          x.volumeMl == y.volumeMl &&
          x.confidencePercent == y.confidencePercent,
    (LitterOutcome x, LitterOutcome y) =>
      x.urineCount == y.urineCount &&
          x.stoolCount == y.stoolCount &&
          x.observedQuantity == y.observedQuantity &&
          x.quantityUnit == y.quantityUnit &&
          x.uncertain == y.uncertain,
    (AnalysisUnavailable x, AnalysisUnavailable y) => x.reason == y.reason,
    _ => false,
  };
}
