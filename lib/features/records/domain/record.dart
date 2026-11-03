import 'package:hareup_core/core.dart';
import '../../photo_analysis/domain/analysis.dart';

class ObservationRecord {
  const ObservationRecord({
    required this.request,
    required this.outcome,
    required this.analyzedAt,
    this.correctedUrineCount,
    this.correctedStoolCount,
    this.selectedCatId,
    this.notes = '',
  });
  final AnalysisRequest request;
  final AnalysisOutcome outcome;
  final DateTime analyzedAt;
  final int? correctedUrineCount;
  final int? correctedStoolCount;
  final String? selectedCatId;
  final String notes;

  ObservationRecord withAnnotations({
    int? urineCount,
    int? stoolCount,
    String? catId,
    required String notes,
  }) => ObservationRecord(
    request: request,
    outcome: outcome,
    analyzedAt: analyzedAt,
    correctedUrineCount: urineCount,
    correctedStoolCount: stoolCount,
    selectedCatId: catId,
    notes: notes.trim(),
  );
}

/// Whether user annotations are valid for the immutable model outcome.
bool validRecordAnnotations(ObservationRecord record) {
  if (record.notes.length > 500) return false;
  if (record.outcome is LitterOutcome) {
    return (record.correctedUrineCount == null ||
            record.correctedUrineCount! >= 0) &&
        (record.correctedStoolCount == null ||
            record.correctedStoolCount! >= 0) &&
        (record.selectedCatId == null ||
            record.request.eligibleCats.any(
              (cat) => cat.id == record.selectedCatId,
            ));
  }
  return record.correctedUrineCount == null &&
      record.correctedStoolCount == null &&
      record.selectedCatId == null;
}

bool sameRecordAnnotations(ObservationRecord a, ObservationRecord b) =>
    a.correctedUrineCount == b.correctedUrineCount &&
    a.correctedStoolCount == b.correctedStoolCount &&
    a.selectedCatId == b.selectedCatId &&
    a.notes == b.notes;

/// Human-readable summary for an explicitly initiated share action.
String recordShareText(ObservationRecord record) {
  final outcome = switch (record.outcome) {
    WaterOutcome(:final percent, :final volumeMl) =>
      '물 감소율: $percent% (추정)${volumeMl == null ? '' : '\n물 감소량: $volumeMl mL (추정)'}',
    LitterOutcome(:final urineCount, :final stoolCount) =>
      '확인한 소변: ${record.correctedUrineCount ?? urineCount}회\n확인한 대변: ${record.correctedStoolCount ?? stoolCount}회',
    AnalysisUnavailable(:final reason) => '분석 불가: $reason',
  };
  final timestamp = record.analyzedAt.toLocal().toString().substring(0, 16);
  return '[하릅 관찰 기록]\n${record.request.targetName}\n분석 시각: $timestamp\n$outcome${record.notes.isEmpty ? '' : '\n메모: ${record.notes}'}\n사진 분석 결과는 추정 정보이며 진단이 아닙니다.';
}

abstract interface class RecordsRepository {
  Future<Result<List<ObservationRecord>>> listAll({required String groupId});

  Future<Result<List<ObservationRecord>>> list({
    required String groupId,
    required String targetId,
  });

  /// Updates only annotations if the stored version still matches [original].
  Future<Result<void>> updateAnnotations({
    required ObservationRecord original,
    required ObservationRecord updated,
  });

  /// Must be idempotent for the same analysis request ID within a group.
  Future<Result<void>> save(ObservationRecord record);
}
