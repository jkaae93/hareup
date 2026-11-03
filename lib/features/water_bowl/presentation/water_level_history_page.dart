import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import '../../photo_analysis/domain/analysis.dart';
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
      return Future.value(const Failure(RequestFailure('수위 기록을 불러올 수 없습니다.')));
    }
    return (service as WaterLevelHistoryService).listWaterLevels(
      groupId: widget.runtime.groupId,
      bowlId: widget.bowlId,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('수위 기록')),
    body: FutureBuilder<Result<List<WaterLevelHistoryItem>>>(
      future: _future,
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return const Center(child: CircularProgressIndicator());
        }
        return switch (snapshot.data!) {
          Failure<List<WaterLevelHistoryItem>>(:final failure) => Center(
            child: Text(failure.message),
          ),
          Success<List<WaterLevelHistoryItem>>(:final value)
              when value.isEmpty =>
            const Center(child: Text('저장된 수위 기록이 없습니다.')),
          Success<List<WaterLevelHistoryItem>>(:final value) => ListView.builder(
            itemCount: value.length,
            itemBuilder: (context, index) {
              final item = value[index];
              final current = item.result.current!;
              final previous = item.result.previous;
              final change = previous == null ? null : previous - current;
              return ListTile(
                title: Text(
                  widget.runtime.validation.waterPercent
                      ? '현재 수위 ${current.toStringAsFixed(1)}% (추정)'
                      : '수위 분석 완료',
                ),
                subtitle: Text(
                  '${item.createdAt?.toLocal().toString().substring(0, 16) ?? ''}${widget.runtime.validation.waterPercent && change != null ? ' · ${change > 0
                            ? '감소'
                            : change < 0
                            ? '증가'
                            : '변화 없음'} ${change.abs().toStringAsFixed(1)}%p' : ''}',
                ),
              );
            },
          ),
        };
      },
    ),
  );
}
