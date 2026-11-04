import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:hareup_core/core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../domain/record.dart';
import 'widgets/observation_chart.dart';

class RecordsCubit extends LoadCubit<List<ObservationRecord>> {
  RecordsCubit(this.repository, this.groupId, this.targetId);
  final RecordsRepository repository;
  final String groupId;
  final String targetId;
  Future<void> load() => loadResult(
    () => repository.list(groupId: groupId, targetId: targetId),
    isEmpty: (items) => items.isEmpty,
  );
}

class RecordsPage extends StatelessWidget {
  const RecordsPage({
    super.key,
    required this.groupId,
    required this.targetId,
    required this.targetName,
  });
  final String groupId;
  final String targetId;
  final String targetName;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        RecordsCubit(context.read<RecordsRepository>(), groupId, targetId)
          ..load(),
    child: Scaffold(
      appBar: AppBar(title: Text(context.l10n.recordsTargetTitle(targetName))),
      body: HareupContent(
        child: BlocBuilder<RecordsCubit, LoadState<List<ObservationRecord>>>(
          builder: (context, state) => LoadView<List<ObservationRecord>>(
            state: state,
            emptyMessage: context.l10n.recordsEmptyMessage,
            onRetry: () => context.read<RecordsCubit>().load(),
            builder: (context, records) {
              final ordered = [...records]
                ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
              final litterRecords = ordered
                  .where((record) => record.outcome is LitterOutcome)
                  .toList()
                  .reversed
                  .toList();
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  HareupSpacing.pageMargin,
                  HareupSpacing.small,
                  HareupSpacing.pageMargin,
                  HareupSpacing.large,
                ),
                itemCount: ordered.length + (litterRecords.isEmpty ? 0 : 1),
                itemBuilder: (context, index) {
                  if (litterRecords.isNotEmpty && index == 0) {
                    return ObservationChart(
                      title: context.l10n.recordsLitterTrendTitle,
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
                    );
                  }
                  final record =
                      ordered[index - (litterRecords.isEmpty ? 0 : 1)];
                  return _RecordCard(
                    record: record,
                    repository: context.read<RecordsRepository>(),
                    onReturn: () => context.read<RecordsCubit>().load(),
                  );
                },
              );
            },
          ),
        ),
      ),
    ),
  );
}

class GroupRecordsPage extends StatefulWidget {
  const GroupRecordsPage({
    super.key,
    required this.repository,
    required this.groupId,
  });
  final RecordsRepository repository;
  final String groupId;
  @override
  State<GroupRecordsPage> createState() => _GroupRecordsPageState();
}

class _GroupRecordsPageState extends State<GroupRecordsPage> {
  AnalysisKind? _filter;

  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) =>
        _GroupRecordsCubit(widget.repository, widget.groupId)..load(),
    child: Scaffold(
      appBar: AppBar(title: Text(context.l10n.navRecords)),
      body: HareupContent(
        child:
            BlocBuilder<_GroupRecordsCubit, LoadState<List<ObservationRecord>>>(
              builder: (context, state) => LoadView<List<ObservationRecord>>(
                state: state,
                emptyMessage: context.l10n.recordsEmptyMessage,
                onRetry: () => context.read<_GroupRecordsCubit>().load(),
                builder: (context, records) {
                  final ordered =
                      records
                          .where(
                            (record) =>
                                _filter == null ||
                                record.request.kind == _filter,
                          )
                          .toList()
                        ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
                  return ListView(
                    padding: const EdgeInsets.symmetric(
                      horizontal: HareupSpacing.pageMargin,
                      vertical: HareupSpacing.medium,
                    ),
                    children: [
                      Text(
                        context.l10n.recordsTimelineTitle,
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      HareupGuidance(
                        title: context.l10n.recordsHistoryTitle,
                        message: context.l10n.recordsEstimateDisclaimer,
                      ),
                      const SizedBox(height: HareupSpacing.medium),
                      Wrap(
                        spacing: HareupSpacing.small,
                        children: [
                          FilterChip(
                            label: Text(context.l10n.recordsFilterAll),
                            selected: _filter == null,
                            onSelected: (_) => setState(() => _filter = null),
                          ),
                          FilterChip(
                            label: Text(context.l10n.navWater),
                            selected: _filter == AnalysisKind.water,
                            onSelected: (_) =>
                                setState(() => _filter = AnalysisKind.water),
                          ),
                          FilterChip(
                            label: Text(context.l10n.navLitter),
                            selected: _filter == AnalysisKind.litter,
                            onSelected: (_) =>
                                setState(() => _filter = AnalysisKind.litter),
                          ),
                        ],
                      ),
                      const SizedBox(height: HareupSpacing.medium),
                      if (ordered.isEmpty)
                        EmptyNotice(
                          message: records.isEmpty
                              ? context.l10n.recordsEmptyMessage
                              : context.l10n.recordsEmptyFiltered,
                        ),
                      for (var i = 0; i < ordered.length; i++) ...[
                        if (i == 0 ||
                            !_sameDay(
                              ordered[i - 1].analyzedAt,
                              ordered[i].analyzedAt,
                            )) ...[
                          const SizedBox(height: HareupSpacing.medium),
                          Text(
                            _dateLabel(context, ordered[i].analyzedAt),
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: HareupSpacing.small),
                        ],
                        _RecordCard(
                          record: ordered[i],
                          repository: widget.repository,
                          onReturn: () =>
                              context.read<_GroupRecordsCubit>().load(),
                        ),
                      ],
                    ],
                  );
                },
              ),
            ),
      ),
    ),
  );

  bool _sameDay(DateTime a, DateTime b) {
    final x = a.toLocal();
    final y = b.toLocal();
    return x.year == y.year && x.month == y.month && x.day == y.day;
  }

  String _dateLabel(BuildContext context, DateTime date) {
    final local = date.toLocal();
    return context.l10n.recordsDateLabel(local.year, local.month, local.day);
  }
}

class _GroupRecordsCubit extends LoadCubit<List<ObservationRecord>> {
  _GroupRecordsCubit(this.repository, this.groupId);
  final RecordsRepository repository;
  final String groupId;
  Future<void> load() => loadResult(
    () => repository.listAll(groupId: groupId),
    isEmpty: (_) => false,
  );
}

class _RecordCard extends StatelessWidget {
  const _RecordCard({
    required this.record,
    required this.repository,
    required this.onReturn,
  });
  final ObservationRecord record;
  final RecordsRepository repository;
  final VoidCallback onReturn;
  @override
  Widget build(BuildContext context) {
    return Card(
      clipBehavior: Clip.antiAlias,
      child: InkWell(
        onTap: () async {
          await Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) =>
                  RecordDetailPage(record: record, repository: repository),
            ),
          );
          if (context.mounted) onReturn();
        },
        child: Padding(
          padding: const EdgeInsets.all(HareupSpacing.medium),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                width: 88,
                child: HareupPhotoPreview(
                  bytes: record.request.photo,
                  label: context.l10n.recordsPhotoLabel,
                  height: 88,
                  fit: BoxFit.cover,
                ),
              ),
              const SizedBox(width: HareupSpacing.medium),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      record.analyzedAt.toLocal().toString().substring(0, 16),
                      style: Theme.of(context).textTheme.labelMedium,
                    ),
                    const SizedBox(height: HareupSpacing.extraSmall),
                    Text(
                      record.request.targetName,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    Text(switch (record.outcome) {
                      WaterOutcome(:final percent) =>
                        context.l10n.recordsWaterSummary(percent),
                      LitterOutcome(:final urineCount, :final stoolCount) =>
                        context.l10n.analysisLitterCounts(
                          record.correctedUrineCount ?? urineCount,
                          record.correctedStoolCount ?? stoolCount,
                        ),
                      AnalysisUnavailable() =>
                        context.l10n.recordsUnavailableShort,
                    }, style: Theme.of(context).textTheme.bodyMedium),
                  ],
                ),
              ),
              const Icon(Icons.chevron_right),
            ],
          ),
        ),
      ),
    );
  }
}

class RecordDetailPage extends StatefulWidget {
  const RecordDetailPage({
    super.key,
    required this.record,
    required this.repository,
  });
  final ObservationRecord record;
  final RecordsRepository repository;
  @override
  State<RecordDetailPage> createState() => _RecordDetailPageState();
}

class _RecordDetailPageState extends State<RecordDetailPage> {
  late ObservationRecord record = widget.record;

  Future<void> _edit() async {
    final updated = await Navigator.of(context).push<ObservationRecord>(
      MaterialPageRoute(
        builder: (_) =>
            _RecordEditPage(record: record, repository: widget.repository),
      ),
    );
    if (updated != null && mounted) setState(() => record = updated);
  }

  String _shareText(BuildContext context) {
    final l10n = context.l10n;
    return recordShareText(
      record,
      RecordShareStrings(
        header: l10n.shareHeader,
        analyzedAt: l10n.recordsAnalyzedAt,
        waterPercent: l10n.shareWaterPercent,
        waterVolume: l10n.shareWaterVolume,
        confirmedUrine: l10n.shareConfirmedUrine,
        confirmedStool: l10n.shareConfirmedStool,
        unavailable: (unavailable) => l10n.recordsUnavailableWith(
          analysisReasonDisplayMessage(context, unavailable),
        ),
        memo: l10n.shareMemo,
        disclaimer: l10n.recordsEstimateDisclaimer,
      ),
    );
  }

  Future<void> _share(BuildContext buttonContext) async {
    final box = buttonContext.findRenderObject() as RenderBox?;
    final text = _shareText(context);
    try {
      await SharePlus.instance.share(
        ShareParams(
          text: text,
          sharePositionOrigin: box == null
              ? null
              : box.localToGlobal(Offset.zero) & box.size,
        ),
      );
    } catch (_) {
      // Browsers without the Web Share API fall back to the clipboard.
      if (kIsWeb) {
        try {
          await Clipboard.setData(ClipboardData(text: text));
          if (mounted) {
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text(context.l10n.recordsShareCopied)),
            );
          }
          return;
        } catch (_) {
          // Fall through to the generic failure notice below.
        }
      }
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.recordsShareFailed)),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(record.request.targetName)),
    body: HareupContent(
      child: ListView(
        padding: const EdgeInsets.symmetric(
          horizontal: HareupSpacing.pageMargin,
          vertical: HareupSpacing.medium,
        ),
        children: [
          HareupFormSection(
            title: record.request.targetName,
            children: [
              HareupStatusBadge(
                label: record.request.kind == AnalysisKind.water
                    ? context.l10n.analysisWaterObserve
                    : context.l10n.analysisLitterObserve,
              ),
              const SizedBox(height: HareupSpacing.small),
              Text(
                '${context.l10n.litterBaselineVersion(record.request.baseline.version)} · ${record.request.baseline.createdAt.toLocal().toString().substring(0, 16)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: HareupSpacing.medium),
          if (!record.request.registrationPhoto)
            HareupPhotoComparison(
              before: record.request.baseline.photo,
              after: record.request.photo,
              beforeLabel: context.l10n.litterBaselineVersion(
                record.request.baseline.version,
              ),
            )
          else
            HareupPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    context.l10n.recordsRegistrationPhoto,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  HareupPhotoPreview(
                    bytes: record.request.photo,
                    label: context.l10n.recordsRegistrationPhoto,
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: HareupSpacing.small),
            child: Text(
              context.l10n.recordsPhotoSelectedAt(
                record.request.photoSelectedAt.toLocal().toString().substring(
                  0,
                  16,
                ),
              ),
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          HareupPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  context.l10n.analysisResultTitle,
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  context.l10n.recordsAnalyzedAt(
                    record.analyzedAt.toLocal().toString().substring(0, 16),
                  ),
                ),
                HareupPanel(
                  color: HareupColors.surfaceContainer,
                  child: Text(context.l10n.recordsOutcomeDisclaimer),
                ),
                if (record.outcome case final AnalysisUnavailable unavailable)
                  Text(
                    context.l10n.recordsUnavailableWith(
                      analysisReasonDisplayMessage(context, unavailable),
                    ),
                  ),
                if (record.outcome case WaterOutcome(
                  :final percent,
                  :final volumeMl,
                  :final confidencePercent,
                )) ...[
                  HareupMetric(
                    label: context.l10n.recordsWaterPercentLabel,
                    value: '$percent%',
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  if (confidencePercent != null)
                    Text(
                      context.l10n.recordsModelConfidence(confidencePercent),
                    ),
                  if (volumeMl != null) ...[
                    HareupMetric(
                      label: context.l10n.recordsWaterVolumeLabel,
                      value: '$volumeMl mL',
                    ),
                    const SizedBox(height: HareupSpacing.small),
                  ],
                  Text(context.l10n.recordsWaterCaveat),
                ],
                if (record.outcome case LitterOutcome(
                  :final urineCount,
                  :final stoolCount,
                  :final uncertain,
                  :final observedQuantity,
                  :final quantityUnit,
                )) ...[
                  HareupMetric(
                    label: context.l10n.analysisOriginalEstimate,
                    value: context.l10n.analysisLitterCounts(
                      urineCount,
                      stoolCount,
                    ),
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  HareupMetric(
                    label: context.l10n.recordsUserConfirmed,
                    value: context.l10n.analysisLitterCounts(
                      record.correctedUrineCount ?? urineCount,
                      record.correctedStoolCount ?? stoolCount,
                    ),
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  if (uncertain) Text(context.l10n.analysisUncertainTraces),
                  if (observedQuantity != null)
                    Text(
                      context.l10n.recordsObservedQuantity(
                        observedQuantity,
                        quantityUnit ?? '',
                      ),
                    ),
                  Text(
                    context.l10n.recordsCatWith(
                      record.selectedCatId == null
                          ? context.l10n.analysisCatUnknown
                          : record.request.eligibleCats
                                    .where(
                                      (cat) => cat.id == record.selectedCatId,
                                    )
                                    .map((cat) => cat.name)
                                    .firstOrNull ??
                                context.l10n.recordsCatUnverified,
                    ),
                  ),
                ],
              ],
            ),
          ),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: HareupSpacing.medium),
            HareupFormSection(
              title: context.l10n.recordsMemoTitle,
              children: [Text(record.notes)],
            ),
          ],
          const SizedBox(height: HareupSpacing.large),
          LayoutBuilder(
            builder: (context, constraints) {
              final share = Builder(
                builder: (buttonContext) => OutlinedButton.icon(
                  onPressed: () => _share(buttonContext),
                  icon: const Icon(Icons.ios_share),
                  label: Text(context.l10n.recordsShareAction),
                ),
              );
              final edit = FilledButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined),
                label: Text(context.l10n.recordsEditAction),
              );
              if (constraints.maxWidth < 300 ||
                  MediaQuery.textScalerOf(context).scale(1) > 1.2) {
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    share,
                    const SizedBox(height: HareupSpacing.small),
                    edit,
                  ],
                );
              }
              return Row(
                children: [
                  Expanded(child: share),
                  const SizedBox(width: HareupSpacing.small),
                  Expanded(child: edit),
                ],
              );
            },
          ),
        ],
      ),
    ),
  );
}

class _RecordEditPage extends StatefulWidget {
  const _RecordEditPage({required this.record, required this.repository});
  final ObservationRecord record;
  final RecordsRepository repository;
  @override
  State<_RecordEditPage> createState() => _RecordEditPageState();
}

class _RecordEditPageState extends State<_RecordEditPage> {
  late final TextEditingController _urine;
  late final TextEditingController _stool;
  late final TextEditingController _notes;
  String? _catId;
  bool _busy = false;

  @override
  void initState() {
    super.initState();
    final record = widget.record;
    final outcome = record.outcome;
    _urine = TextEditingController(
      text: outcome is LitterOutcome
          ? '${record.correctedUrineCount ?? outcome.urineCount}'
          : '',
    );
    _stool = TextEditingController(
      text: outcome is LitterOutcome
          ? '${record.correctedStoolCount ?? outcome.stoolCount}'
          : '',
    );
    _notes = TextEditingController(text: record.notes);
    _catId = record.selectedCatId;
  }

  @override
  void dispose() {
    _urine.dispose();
    _stool.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (_busy) return;
    final isLitter = widget.record.outcome is LitterOutcome;
    final urine = isLitter ? int.tryParse(_urine.text) : null;
    final stool = isLitter ? int.tryParse(_stool.text) : null;
    if (isLitter &&
        (urine == null || stool == null || urine < 0 || stool < 0)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(context.l10n.recordsCountInvalid)));
      return;
    }
    final updated = widget.record.withAnnotations(
      urineCount: urine,
      stoolCount: stool,
      catId: isLitter ? _catId : null,
      notes: _notes.text,
    );
    if (!validRecordAnnotations(updated)) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.recordsInvalidAnnotations)),
      );
      return;
    }
    setState(() => _busy = true);
    Result<void> result;
    try {
      result = await widget.repository.updateAnnotations(
        original: widget.record,
        updated: updated,
      );
    } catch (_) {
      result = const Failure(UnexpectedFailure());
    }
    if (!mounted) return;
    setState(() => _busy = false);
    switch (result) {
      case Success<void>():
        Navigator.pop(context, updated);
      case Failure<void>(:final failure):
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(failureDisplayMessage(context, failure))),
        );
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: HareupFormPage(
      title: Text(context.l10n.recordsEditAction),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            HareupGuidance(
              title: context.l10n.recordsGuardianCheckTitle,
              message: context.l10n.recordsGuardianCheckMessage,
            ),
            const SizedBox(height: HareupSpacing.medium),
            HareupFormSection(
              title: context.l10n.recordsConfirmedSection,
              children: [
                if (widget.record.outcome is LitterOutcome) ...[
                  HareupCountField(
                    controller: _urine,
                    label: context.l10n.analysisConfirmedUrine,
                    enabled: !_busy,
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  HareupCountField(
                    controller: _stool,
                    label: context.l10n.analysisConfirmedStool,
                    enabled: !_busy,
                  ),
                  const SizedBox(height: HareupSpacing.medium),
                  Text(
                    context.l10n.analysisSelectCat,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: HareupSpacing.small,
                    children: [
                      ChoiceChip(
                        label: Text(context.l10n.analysisCatUnknown),
                        selected: _catId == null,
                        onSelected: _busy
                            ? null
                            : (_) => setState(() => _catId = null),
                      ),
                      for (final cat in widget.record.request.eligibleCats)
                        ChoiceChip(
                          label: Text(cat.name),
                          selected: _catId == cat.id,
                          onSelected: _busy
                              ? null
                              : (_) => setState(() => _catId = cat.id),
                        ),
                    ],
                  ),
                  const SizedBox(height: HareupSpacing.medium),
                ],
                TextField(
                  controller: _notes,
                  enabled: !_busy,
                  minLines: 2,
                  maxLines: 4,
                  maxLength: 500,
                  decoration: InputDecoration(
                    labelText: context.l10n.recordsMemoField,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: Text(context.dsL10n.cancelAction),
        ),
        FilledButton(
          onPressed: _busy ? null : _save,
          child: Text(context.l10n.commonSave),
        ),
      ],
    ),
  );
}
