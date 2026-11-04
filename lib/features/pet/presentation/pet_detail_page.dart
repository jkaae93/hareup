import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_design_system/design_system.dart';
import '../../../l10n/l10n.dart';
import '../../litter_box/domain/litter_box.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../records/domain/record.dart';
import '../../water_bowl/domain/water_bowl.dart';
import '../../water_bowl/domain/water_level.dart';
import '../domain/pet.dart';

class PetDetailPage extends StatefulWidget {
  const PetDetailPage({
    super.key,
    required this.pet,
    required this.waterRepository,
    required this.litterRepository,
    required this.recordsRepository,
    required this.runtime,
    required this.onEdit,
  });
  final Pet pet;
  final WaterBowlRepository waterRepository;
  final LitterBoxRepository litterRepository;
  final RecordsRepository recordsRepository;
  final AnalysisRuntime runtime;
  final VoidCallback onEdit;
  @override
  State<PetDetailPage> createState() => _PetDetailPageState();
}

class _PetHealthData {
  const _PetHealthData(this.bowls, this.boxes, this.records, this.waterHistory);
  final List<WaterBowl> bowls;
  final List<LitterBox> boxes;
  final List<ObservationRecord> records;
  final Map<String, Result<List<WaterLevelHistoryItem>>> waterHistory;
}

class _PetDetailPageState extends State<PetDetailPage> {
  late Future<_PetHealthData> _data;
  @override
  void initState() {
    super.initState();
    _data = _load();
  }

  Future<_PetHealthData> _load() async {
    final results = await Future.wait<Object>([
      widget.waterRepository.list(),
      widget.litterRepository.list(),
      widget.recordsRepository.listAll(groupId: widget.runtime.groupId),
    ]);
    final water = results[0] as Result<List<WaterBowl>>;
    final litter = results[1] as Result<List<LitterBox>>;
    final records = results[2] as Result<List<ObservationRecord>>;
    if (water is! Success<List<WaterBowl>> ||
        litter is! Success<List<LitterBox>> ||
        records is! Success<List<ObservationRecord>>) {
      throw StateError('Failed to load health records');
    }
    final bowls = water.value
        .where((bowl) => bowl.petIds.contains(widget.pet.id))
        .toList();
    final boxes = litter.value
        .where((box) => box.catIds.contains(widget.pet.id))
        .toList();
    final confirmed =
        records.value
            .where(
              (record) =>
                  record.outcome is LitterOutcome &&
                  record.selectedCatId == widget.pet.id,
            )
            .toList()
          ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
    final histories = <String, Result<List<WaterLevelHistoryItem>>>{};
    final service = widget.runtime.service;
    if (service is WaterLevelHistoryService) {
      await Future.wait(
        bowls.map((bowl) async {
          histories[bowl.id] = await (service as WaterLevelHistoryService)
              .listWaterLevels(
                groupId: widget.runtime.groupId,
                bowlId: bowl.id,
              );
        }),
      );
    }
    return _PetHealthData(bowls, boxes, confirmed, histories);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(
      title: Text(widget.pet.name),
      actions: [
        IconButton(
          tooltip: context.l10n.petEditProfile,
          onPressed: widget.onEdit,
          icon: const Icon(Icons.edit_outlined),
        ),
      ],
    ),
    body: HareupContent(
      child: FutureBuilder<_PetHealthData>(
        future: _data,
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(context.l10n.petHealthLoadFailed),
                  TextButton(
                    onPressed: () => setState(() => _data = _load()),
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
          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              HareupFormSection(
                title: widget.pet.name,
                description: widget.pet.species == PetSpecies.cat
                    ? context.l10n.petSpeciesCat
                    : context.l10n.petSpeciesDog,
                children: [
                  if (widget.pet.profile.ageMonths case final age?)
                    Text(context.l10n.petAgeLine(age)),
                  if (widget.pet.profile.weightKg case final weight?)
                    Text(context.l10n.petWeightLine(weight)),
                ],
              ),
              const SizedBox(height: 16),
              Text(
                context.l10n.petWaterSection,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(context.l10n.petWaterSectionHint),
              if (data.bowls.isEmpty)
                ListTile(title: Text(context.l10n.petNoBowls)),
              for (final bowl in data.bowls) ...[
                ListTile(
                  title: Text(bowl.name),
                  subtitle: Text(
                    bowl.petIds.length > 1
                        ? context.l10n.petSharedBowl
                        : context.l10n.petLinkedBowl,
                  ),
                ),
                if (data.waterHistory[bowl.id]
                    case Failure<List<WaterLevelHistoryItem>>())
                  ListTile(title: Text(context.l10n.petLevelHistoryFailed))
                else if (data.waterHistory[bowl.id]
                    case Success<List<WaterLevelHistoryItem>>(:final value))
                  if (value.isEmpty)
                    ListTile(title: Text(context.l10n.waterHistoryEmpty))
                  else
                    for (final item in value.take(10))
                      ListTile(
                        title: Text(
                          widget.runtime.validation.waterPercent &&
                                  item.result.current != null
                              ? context.l10n.waterCurrentLevelValue(
                                  item.result.current!.toStringAsFixed(1),
                                )
                              : context.l10n.petLevelRecord,
                        ),
                        subtitle: Text(
                          item.createdAt?.toLocal().toString().substring(
                                0,
                                16,
                              ) ??
                              context.l10n.petTimeUnknown,
                        ),
                      )
                else
                  ListTile(
                    title: Text(context.l10n.petLevelHistoryUnavailable),
                  ),
              ],
              const SizedBox(height: 16),
              Text(
                context.l10n.petLitterSection,
                style: const TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Text(context.l10n.petLitterSectionHint),
              if (data.boxes.isEmpty)
                ListTile(title: Text(context.l10n.petNoBoxes))
              else
                Text(
                  context.l10n.petLinkedBoxes(
                    data.boxes.map((box) => box.name).join(', '),
                  ),
                ),
              if (data.records.isEmpty)
                ListTile(title: Text(context.l10n.petNoRecords)),
              for (final record in data.records.take(30))
                ListTile(
                  title: Text(record.request.targetName),
                  subtitle: Text(
                    '${record.analyzedAt.toLocal().toString().substring(0, 16)}${widget.runtime.validation.litterCounts ? context.l10n.petRecordCountsLine(record.correctedUrineCount ?? (record.outcome as LitterOutcome).urineCount, record.correctedStoolCount ?? (record.outcome as LitterOutcome).stoolCount) : ''}',
                  ),
                ),
            ],
          );
        },
      ),
    ),
  );
}
