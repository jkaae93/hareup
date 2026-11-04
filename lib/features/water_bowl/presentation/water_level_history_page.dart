import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_design_system/design_system.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../records/presentation/widgets/observation_chart.dart';
import '../domain/water_level.dart';

class WaterLevelHistoryPage extends StatefulWidget {
  const WaterLevelHistoryPage({
    super.key,
    required this.runtime,
    required this.bowlId,
  });
  final AnalysisRuntime runtime;
  final String bowlId;
  @override
  State<WaterLevelHistoryPage> createState() => _WaterLevelHistoryPageState();
}

class _WaterLevelHistoryPageState extends State<WaterLevelHistoryPage> {
  late Future<Result<List<WaterLevelHistoryItem>>> _future;
  @override
  void initState() {
    super.initState();
    _future = _load();
  }

  Future<Result<List<WaterLevelHistoryItem>>> _load() {
    final service = widget.runtime.service;
    if (service is! WaterLevelHistoryService) {
      return Future.value(
        const Failure(
          RequestFailure(
            '수위 기록을 불러올 수 없습니다.',
            FailureMessageKeys.waterHistoryUnavailable,
          ),
        ),
      );
    }
    return (service as WaterLevelHistoryService).listWaterLevels(
      groupId: widget.runtime.groupId,
      bowlId: widget.bowlId,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.waterHistoryTitle)),
    body: HareupContent(
      child: FutureBuilder<Result<List<WaterLevelHistoryItem>>>(
        future: _future,
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const HareupLoading();
          }
          return switch (snapshot.data!) {
            Failure<List<WaterLevelHistoryItem>>(:final failure) => Center(
              child: Text(failureDisplayMessage(context, failure)),
            ),
            Success<List<WaterLevelHistoryItem>>(:final value)
                when value.isEmpty =>
              Center(child: Text(context.l10n.waterHistoryEmpty)),
            Success<List<WaterLevelHistoryItem>>(:final value) =>
              ListView.builder(
                padding: const EdgeInsets.symmetric(
                  horizontal: HareupSpacing.pageMargin,
                  vertical: HareupSpacing.medium,
                ),
                itemCount: value.length + 1,
                itemBuilder: (context, index) {
                  if (index == 0) {
                    final points =
                        value
                            .where(
                              (item) =>
                                  item.createdAt != null &&
                                  item.result.current != null &&
                                  item.result.current!.isFinite &&
                                  item.result.current! >= 0 &&
                                  item.result.current! <= 100,
                            )
                            .toList()
                          ..sort(
                            (a, b) => a.createdAt!.compareTo(b.createdAt!),
                          );
                    if (!widget.runtime.validation.waterPercent) {
                      return HareupGuidance(
                        title: context.l10n.waterTrendTitle,
                        message: context.l10n.waterTrendPending,
                      );
                    }
                    if (points.isEmpty) {
                      return HareupGuidance(
                        title: context.l10n.waterTrendTitle,
                        message: context.l10n.waterTrendNoData,
                      );
                    }
                    return ObservationChart(
                      title: context.l10n.waterTrendTitle,
                      labels: [context.l10n.waterCurrentLevelEstimated],
                      unit: '%',
                      maximum: 100,
                      points: [
                        for (final item in points)
                          ObservationChartPoint(
                            time: item.createdAt!.toLocal(),
                            values: [item.result.current!],
                          ),
                      ],
                    );
                  }
                  final item = value[index - 1];
                  final current = item.result.current;
                  final previous = item.result.previous;
                  final change = previous == null || current == null
                      ? null
                      : previous - current;
                  final changeLabel = change == null
                      ? null
                      : change > 0
                      ? context.l10n.waterChangeDecrease
                      : change < 0
                      ? context.l10n.waterChangeIncrease
                      : context.l10n.waterChangeNone;
                  return HareupCard(
                    title:
                        widget.runtime.validation.waterPercent &&
                            current != null
                        ? context.l10n.waterCurrentLevelValue(
                            current.toStringAsFixed(1),
                          )
                        : context.l10n.waterAnalysisDone,
                    subtitle:
                        '${item.createdAt?.toLocal().toString().substring(0, 16) ?? ''}${widget.runtime.validation.waterPercent && change != null && changeLabel != null ? context.l10n.waterChangeWith(changeLabel, change.abs().toStringAsFixed(1)) : ''}',
                  );
                },
              ),
          };
        },
      ),
    ),
  );
}
