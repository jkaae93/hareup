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

/// Localized labels for [recordShareText], built at the presentation
/// boundary so domain code stays locale-free.
class RecordShareStrings {
  const RecordShareStrings({
    required this.header,
    required this.analyzedAt,
    required this.waterPercent,
    required this.waterVolume,
    required this.confirmedUrine,
    required this.confirmedStool,
    required this.unavailable,
    required this.memo,
    required this.disclaimer,
  });

  final String header;
  final String Function(String timestamp) analyzedAt;
  final String Function(double percent) waterPercent;
  final String Function(double volumeMl) waterVolume;
  final String Function(int count) confirmedUrine;
  final String Function(int count) confirmedStool;
  final String Function(AnalysisUnavailable unavailable) unavailable;
  final String Function(String notes) memo;
  final String disclaimer;

  /// Korean labels preserving the historical share format.
  factory RecordShareStrings.korean() => RecordShareStrings(
    header: '[하릅 관찰 기록]',
    analyzedAt: (timestamp) => '분석 시각: $timestamp',
    waterPercent: (percent) => '물 감소율: $percent% (추정)',
    waterVolume: (volumeMl) => '물 감소량: $volumeMl mL (추정)',
    confirmedUrine: (count) => '확인한 소변: $count회',
    confirmedStool: (count) => '확인한 대변: $count회',
    unavailable: (unavailable) => '분석 불가: ${unavailable.reason}',
    memo: (notes) => '메모: $notes',
    disclaimer: '사진 분석 결과는 추정 정보이며 진단이 아닙니다.',
  );
}

/// Human-readable summary for an explicitly initiated share action.
String recordShareText(ObservationRecord record, RecordShareStrings strings) {
  final outcome = switch (record.outcome) {
    WaterOutcome(:final percent, :final volumeMl) =>
      '${strings.waterPercent(percent)}${volumeMl == null ? '' : '\n${strings.waterVolume(volumeMl)}'}',
    LitterOutcome(:final urineCount, :final stoolCount) =>
      '${strings.confirmedUrine(record.correctedUrineCount ?? urineCount)}\n${strings.confirmedStool(record.correctedStoolCount ?? stoolCount)}',
    final AnalysisUnavailable unavailable => strings.unavailable(unavailable),
  };
  final timestamp = record.analyzedAt.toLocal().toString().substring(0, 16);
  return '${strings.header}\n${record.request.targetName}\n${strings.analyzedAt(timestamp)}\n$outcome${record.notes.isEmpty ? '' : '\n${strings.memo(record.notes)}'}\n${strings.disclaimer}';
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
