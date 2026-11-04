import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_design_system/design_system.dart';

import '../../../l10n/l10n.dart';
import '../../pet/domain/pet.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../records/domain/record.dart';
import '../../records/presentation/widgets/observation_chart.dart';
import '../../water_bowl/domain/water_bowl.dart';
import '../../water_bowl/domain/water_level.dart';

class HealthReportPage extends StatefulWidget {
  const HealthReportPage({
    super.key,
    required this.pets,
    required this.waterRepository,
    required this.recordsRepository,
    required this.runtime,
    required this.onViewRecords,
    required this.onViewTargets,
  });
  final List<Pet> pets;
  final WaterBowlRepository waterRepository;
  final RecordsRepository recordsRepository;
  final AnalysisRuntime runtime;
  final VoidCallback onViewRecords;
  final VoidCallback onViewTargets;
  @override
  State<HealthReportPage> createState() => _HealthReportPageState();
}

class _HealthReportData {
  const _HealthReportData(this.bowls, this.records, this.waterHistory);
  final List<WaterBowl> bowls;
  final List<ObservationRecord> records;
  final Map<String, Result<List<WaterLevelHistoryItem>>> waterHistory;
}

class _HealthReportPageState extends State<HealthReportPage> {
  late Future<_HealthReportData> _future;
  String? _selectedPetId;

  @override
  void initState() {
    super.initState();
    _selectedPetId = widget.pets.firstOrNull?.id;
    _future = _load();
  }

  @override
  void didUpdateWidget(covariant HealthReportPage oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.pets.any((pet) => pet.id == _selectedPetId)) {
      _selectedPetId = widget.pets.firstOrNull?.id;
    }
  }

  Future<_HealthReportData> _load() async {
    final results = await Future.wait<Object>([
      widget.waterRepository.list(),
      widget.recordsRepository.listAll(groupId: widget.runtime.groupId),
    ]);
    final bowls = results[0] as Result<List<WaterBowl>>;
    final records = results[1] as Result<List<ObservationRecord>>;
    if (bowls is! Success<List<WaterBowl>> ||
        records is! Success<List<ObservationRecord>>) {
      throw StateError('Could not load report');
    }
    final histories = <String, Result<List<WaterLevelHistoryItem>>>{};
    final service = widget.runtime.service;
    if (service is WaterLevelHistoryService &&
        widget.runtime.validation.waterPercent) {
      await Future.wait(
        bowls.value.map((bowl) async {
          histories[bowl.id] = await (service as WaterLevelHistoryService)
              .listWaterLevels(
                groupId: widget.runtime.groupId,
                bowlId: bowl.id,
              );
        }),
      );
    }
    return _HealthReportData(bowls.value, records.value, histories);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(context.l10n.navHealthReport),
      actions: [
        IconButton(
          tooltip: context.l10n.navRecords,
          onPressed: widget.onViewRecords,
          icon: const Icon(Icons.history),
        ),
      ],
    ),
    body: widget.pets.isEmpty
        ? Center(child: Text(context.l10n.reportNoPets))
        : HareupContent(
            child: FutureBuilder<_HealthReportData>(
              future: _future,
              builder: (context, snapshot) {
                if (snapshot.hasError) {
                  return Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(context.l10n.reportLoadFailed),
                        TextButton(
                          onPressed: () => setState(() => _future = _load()),
                          child: Text(context.dsL10n.retryAction),
                        ),
                      ],
                    ),
                  );
                }
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }
                final data = snapshot.data!;
                final bowls = data.bowls
                    .where((bowl) => bowl.petIds.contains(_selectedPetId))
                    .toList();
                final litterRecords =
                    data.records
                        .where(
                          (record) =>
                              record.selectedCatId == _selectedPetId &&
                              record.outcome is LitterOutcome,
                        )
                        .toList()
                      ..sort((a, b) => a.analyzedAt.compareTo(b.analyzedAt));
                final quantityRecords = litterRecords.where((record) {
                  final outcome = record.outcome as LitterOutcome;
                  final value = outcome.observedQuantity;
                  return !outcome.uncertain &&
                      value != null &&
                      value.isFinite &&
                      value >= 0 &&
                      outcome.quantityUnit != null &&
                      outcome.quantityUnit!.trim().isNotEmpty;
                }).toList();
                final quantitiesByUnit = <String, List<ObservationRecord>>{};
                for (final record in quantityRecords) {
                  final unit = (record.outcome as LitterOutcome).quantityUnit!
                      .trim();
                  (quantitiesByUnit[unit] ??= []).add(record);
                }
                return ListView(
                  padding: const EdgeInsets.all(HareupSpacing.pageMargin),
                  children: [
                    Text(
                      context.l10n.reportPetSelect,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    Wrap(
                      spacing: HareupSpacing.small,
                      children: [
                        for (final pet in widget.pets)
                          ChoiceChip(
                            label: Text(pet.name),
                            selected: pet.id == _selectedPetId,
                            onSelected: (_) =>
                                setState(() => _selectedPetId = pet.id),
                          ),
                      ],
                    ),
                    const SizedBox(height: HareupSpacing.medium),
                    HareupFormSection(
                      title: context.l10n.reportWaterIntakeTitle,
                      description: context.l10n.reportWaterIntakeUnavailable,
                      children: [Text(context.l10n.reportWaterContext)],
                    ),
                    const SizedBox(height: HareupSpacing.medium),
                    if (bowls.isEmpty)
                      HareupGuidance(
                        title: context.l10n.reportWaterLevelTitle,
                        message: context.l10n.petNoBowls,
                      )
                    else if (!widget.runtime.validation.waterPercent)
                      HareupGuidance(
                        title: context.l10n.reportWaterLevelTitle,
                        message: context.l10n.reportWaterUnverified,
                      )
                    else
                      for (final bowl in bowls) ...[
                        Text(
                          bowl.petIds.length > 1
                              ? context.l10n.reportSharedBowl(bowl.name)
                              : bowl.name,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        if (data.waterHistory[bowl.id]
                            case Failure<List<WaterLevelHistoryItem>>())
                          HareupGuidance(
                            title: context.l10n.reportWaterLevelTitle,
                            message: context.l10n.petLevelHistoryFailed,
                          )
                        else if (data.waterHistory[bowl.id]
                            case Success<List<WaterLevelHistoryItem>>(
                              :final value,
                            ))
                          if (value
                              .where(
                                (item) =>
                                    item.createdAt != null &&
                                    item.result.current != null &&
                                    item.result.current!.isFinite &&
                                    item.result.current! >= 0 &&
                                    item.result.current! <= 100,
                              )
                              .isEmpty)
                            HareupGuidance(
                              title: context.l10n.reportWaterLevelTitle,
                              message: context.l10n.waterHistoryEmpty,
                            )
                          else
                            ObservationChart(
                              title: context.l10n.reportWaterLevelTitle,
                              labels: [context.l10n.reportWaterLevelLabel],
                              unit: '%',
                              maximum: 100,
                              points: [
                                for (final item
                                    in (value
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
                                        (a, b) => a.createdAt!.compareTo(
                                          b.createdAt!,
                                        ),
                                      )))
                                  ObservationChartPoint(
                                    time: item.createdAt!.toLocal(),
                                    values: [item.result.current!],
                                  ),
                              ],
                            )
                        else
                          HareupGuidance(
                            title: context.l10n.reportWaterLevelTitle,
                            message: context.l10n.petLevelHistoryUnavailable,
                          ),
                        const SizedBox(height: HareupSpacing.medium),
                      ],
                    HareupFormSection(
                      title: context.l10n.reportLitterAmountTitle,
                      description: context.l10n.reportLitterAttribution,
                      children: [
                        if (!widget.runtime.validation.litterVolume ||
                            quantitiesByUnit.isEmpty)
                          Text(context.l10n.reportLitterAmountUnavailable),
                      ],
                    ),
                    if (widget.runtime.validation.litterVolume)
                      for (final entry in quantitiesByUnit.entries) ...[
                        const SizedBox(height: HareupSpacing.medium),
                        ObservationChart(
                          title: context.l10n.reportLitterAmountTitle,
                          labels: [context.l10n.reportLitterAmountLabel],
                          unit: entry.key,
                          points: [
                            for (final record in entry.value)
                              ObservationChartPoint(
                                time: record.analyzedAt.toLocal(),
                                values: [
                                  (record.outcome as LitterOutcome)
                                      .observedQuantity!,
                                ],
                              ),
                          ],
                        ),
                      ],
                    const SizedBox(height: HareupSpacing.medium),
                    if (!widget.runtime.validation.litterCounts)
                      HareupGuidance(
                        title: context.l10n.reportLitterCountTitle,
                        message: context.l10n.reportLitterCountsUnverified,
                      )
                    else if (litterRecords.isEmpty)
                      HareupGuidance(
                        title: context.l10n.reportLitterCountTitle,
                        message: context.l10n.petNoRecords,
                      )
                    else
                      ObservationChart(
                        title: context.l10n.reportLitterCountTitle,
                        labels: [
                          context.l10n.recordsUrineLabel,
                          context.l10n.recordsStoolLabel,
                        ],
                        unit: context.l10n.recordsCountUnit,
                        points: [
                          for (final record in litterRecords)
                            ObservationChartPoint(
                              time: record.analyzedAt.toLocal(),
                              values: [
                                (record.correctedUrineCount ??
                                        (record.outcome as LitterOutcome)
                                            .urineCount)
                                    .toDouble(),
                                (record.correctedStoolCount ??
                                        (record.outcome as LitterOutcome)
                                            .stoolCount)
                                    .toDouble(),
                              ],
                            ),
                        ],
                      ),
                    const SizedBox(height: HareupSpacing.medium),
                    OutlinedButton.icon(
                      onPressed: widget.onViewTargets,
                      icon: const Icon(Icons.list_alt_outlined),
                      label: Text(context.l10n.homePickRecordsTarget),
                    ),
                  ],
                );
              },
            ),
          ),
  );
}
