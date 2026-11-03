import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../domain/record.dart';

/// Displays a single latest record without summing overlapping observations.
class RecentRecordSummary extends StatefulWidget {
  const RecentRecordSummary({
    super.key,
    required this.repository,
    required this.groupId,
    required this.targetId,
    required this.kind,
  });
  final RecordsRepository repository;
  final String groupId;
  final String targetId;
  final AnalysisKind kind;
  @override
  State<RecentRecordSummary> createState() => _RecentRecordSummaryState();
}

class _RecentRecordSummaryState extends State<RecentRecordSummary> {
  late Future<Result<List<ObservationRecord>>> _future;
  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void didUpdateWidget(RecentRecordSummary oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.repository != widget.repository ||
        oldWidget.groupId != widget.groupId ||
        oldWidget.targetId != widget.targetId ||
        oldWidget.kind != widget.kind) {
      _load();
    }
  }

  void _load() {
    _future = widget.repository.list(
      groupId: widget.groupId,
      targetId: widget.targetId,
    );
  }

  @override
  Widget build(
    BuildContext context,
  ) => FutureBuilder<Result<List<ObservationRecord>>>(
    future: _future,
    builder: (context, snapshot) {
      if (snapshot.connectionState != ConnectionState.done) {
        return const Text('기록 확인 중');
      }
      if (snapshot.hasError ||
          snapshot.data is! Success<List<ObservationRecord>>) {
        return const Text('기록을 불러오지 못했습니다.');
      }
      final records = (snapshot.data! as Success<List<ObservationRecord>>).value
          .where(
            (r) =>
                r.request.groupId == widget.groupId &&
                r.request.targetId == widget.targetId &&
                r.request.kind == widget.kind,
          )
          .toList();
      if (records.isEmpty) return const Text('분석 기록 없음');
      records.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
      final record = records.first;
      final summary = switch (record.outcome) {
        WaterOutcome(:final percent) => '물 감소율 $percent% (추정)',
        LitterOutcome(:final urineCount, :final stoolCount) =>
          '소변 ${record.correctedUrineCount ?? urineCount}회 · 대변 ${record.correctedStoolCount ?? stoolCount}회 (추정)',
        AnalysisUnavailable() => '분석 불가',
      };
      return Text('최근 기록 · $summary');
    },
  );
}
