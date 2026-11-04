import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import '../../../l10n/l10n.dart';
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
  Widget build(BuildContext context) =>
      FutureBuilder<Result<List<ObservationRecord>>>(
        future: _future,
        builder: (context, snapshot) {
          final textTheme = Theme.of(context).textTheme;
          final statusStyle = textTheme.bodySmall?.copyWith(
            color: Theme.of(context).colorScheme.onSurfaceVariant,
          );
          if (snapshot.connectionState != ConnectionState.done) {
            return Text(context.l10n.recordsChecking, style: statusStyle);
          }
          if (snapshot.hasError ||
              snapshot.data is! Success<List<ObservationRecord>>) {
            return Text(context.l10n.recordsLoadFailed, style: statusStyle);
          }
          final records = (snapshot.data! as Success<List<ObservationRecord>>)
              .value
              .where(
                (r) =>
                    r.request.groupId == widget.groupId &&
                    r.request.targetId == widget.targetId &&
                    r.request.kind == widget.kind,
              )
              .toList();
          if (records.isEmpty) {
            return Text(context.l10n.recordsEmpty, style: statusStyle);
          }
          records.sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
          final record = records.first;
          final summary = switch (record.outcome) {
            WaterOutcome(:final percent) => context.l10n.recordsWaterSummary(
              percent,
            ),
            LitterOutcome(:final urineCount, :final stoolCount) =>
              context.l10n.recordsLitterSummary(
                record.correctedUrineCount ?? urineCount,
                record.correctedStoolCount ?? stoolCount,
              ),
            AnalysisUnavailable() => context.l10n.recordsUnavailableShort,
          };
          return Text(
            context.l10n.recordsRecentWith(summary),
            style: textTheme.bodyMedium,
          );
        },
      );
}
