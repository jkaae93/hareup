import 'package:flutter/material.dart';
import 'package:hareup_core/core.dart';
import 'package:share_plus/share_plus.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../domain/record.dart';

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
      appBar: AppBar(title: Text('$targetName 기록')),
      body: HareupContent(
        child: BlocBuilder<RecordsCubit, LoadState<List<ObservationRecord>>>(
          builder: (context, state) => LoadView<List<ObservationRecord>>(
            state: state,
            emptyMessage: '저장된 분석 기록이 없습니다.',
            onRetry: () => context.read<RecordsCubit>().load(),
            builder: (context, records) {
              final ordered = [...records]
                ..sort((a, b) => b.analyzedAt.compareTo(a.analyzedAt));
              return ListView.builder(
                padding: const EdgeInsets.fromLTRB(
                  HareupSpacing.pageMargin,
                  HareupSpacing.small,
                  HareupSpacing.pageMargin,
                  HareupSpacing.large,
                ),
                itemCount: ordered.length,
                itemBuilder: (context, index) {
                  final record = ordered[index];
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
      appBar: AppBar(title: const Text('기록 목록')),
      body: HareupContent(
        child:
            BlocBuilder<_GroupRecordsCubit, LoadState<List<ObservationRecord>>>(
              builder: (context, state) => LoadView<List<ObservationRecord>>(
                state: state,
                emptyMessage: '저장된 분석 기록이 없습니다.',
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
                        '건강 체크 타임라인',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      const HareupGuidance(
                        title: '사진 분석 기록',
                        message: '사진 분석 결과는 추정 정보이며 진단이 아닙니다.',
                      ),
                      const SizedBox(height: HareupSpacing.medium),
                      Wrap(
                        spacing: HareupSpacing.small,
                        children: [
                          FilterChip(
                            label: const Text('전체'),
                            selected: _filter == null,
                            onSelected: (_) => setState(() => _filter = null),
                          ),
                          FilterChip(
                            label: const Text('물그릇'),
                            selected: _filter == AnalysisKind.water,
                            onSelected: (_) =>
                                setState(() => _filter = AnalysisKind.water),
                          ),
                          FilterChip(
                            label: const Text('화장실'),
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
                              ? '저장된 분석 기록이 없습니다.'
                              : '선택한 종류의 기록이 없습니다.',
                        ),
                      for (var i = 0; i < ordered.length; i++) ...[
                        if (i == 0 ||
                            !_sameDay(
                              ordered[i - 1].analyzedAt,
                              ordered[i].analyzedAt,
                            )) ...[
                          const SizedBox(height: HareupSpacing.medium),
                          Text(
                            _dateLabel(ordered[i].analyzedAt),
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

  String _dateLabel(DateTime date) {
    final local = date.toLocal();
    return '${local.year}년 ${local.month}월 ${local.day}일';
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
                  label: '기록 사진',
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
                      WaterOutcome(:final percent) => '물 감소율 $percent% (추정)',
                      LitterOutcome(:final urineCount, :final stoolCount) =>
                        '소변 ${record.correctedUrineCount ?? urineCount}회 · 대변 ${record.correctedStoolCount ?? stoolCount}회',
                      AnalysisUnavailable() => '분석 불가',
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
                    ? '물그릇 사진 관찰'
                    : '화장실 사진 관찰',
              ),
              const SizedBox(height: HareupSpacing.small),
              Text(
                '기준 사진 ${record.request.baseline.version}번째 · ${record.request.baseline.createdAt.toLocal().toString().substring(0, 16)}',
                style: Theme.of(context).textTheme.bodyMedium,
              ),
            ],
          ),
          const SizedBox(height: HareupSpacing.medium),
          if (!record.request.registrationPhoto)
            HareupPhotoComparison(
              before: record.request.baseline.photo,
              after: record.request.photo,
              beforeLabel: '기준 사진 ${record.request.baseline.version}번째',
            )
          else
            HareupPanel(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('등록 사진', style: Theme.of(context).textTheme.titleMedium),
                  const SizedBox(height: HareupSpacing.small),
                  HareupPhotoPreview(
                    bytes: record.request.photo,
                    label: '등록 사진',
                  ),
                ],
              ),
            ),
          Padding(
            padding: const EdgeInsets.symmetric(vertical: HareupSpacing.small),
            child: Text(
              '사진 선택: ${record.request.photoSelectedAt.toLocal().toString().substring(0, 16)}',
              style: Theme.of(context).textTheme.bodySmall,
            ),
          ),
          HareupPanel(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '분석 결과',
                  style: Theme.of(context).textTheme.headlineMedium,
                ),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  '분석 시각: ${record.analyzedAt.toLocal().toString().substring(0, 16)}',
                ),
                const HareupPanel(
                  color: HareupColors.surfaceContainer,
                  child: Text('관찰 결과는 추정 정보이며 진단이 아닙니다.'),
                ),
                if (record.outcome case AnalysisUnavailable(:final reason))
                  Text('분석 불가: $reason'),
                if (record.outcome case WaterOutcome(
                  :final percent,
                  :final volumeMl,
                  :final confidencePercent,
                )) ...[
                  HareupMetric(label: '물 감소율 (추정)', value: '$percent%'),
                  const SizedBox(height: HareupSpacing.small),
                  if (confidencePercent != null)
                    Text('모델 자체 평가 신뢰도 $confidencePercent% (실제 정확도 아님)'),
                  if (volumeMl != null) ...[
                    HareupMetric(label: '물 감소량 (추정)', value: '$volumeMl mL'),
                    const SizedBox(height: HareupSpacing.small),
                  ],
                  const Text('물그릇 기준의 변화이며 개별 반려동물의 음수량은 아닙니다.'),
                ],
                if (record.outcome case LitterOutcome(
                  :final urineCount,
                  :final stoolCount,
                  :final uncertain,
                  :final observedQuantity,
                  :final quantityUnit,
                )) ...[
                  HareupMetric(
                    label: '원래 추정',
                    value: '소변 $urineCount회 · 대변 $stoolCount회',
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  HareupMetric(
                    label: '사용자 확인',
                    value:
                        '소변 ${record.correctedUrineCount ?? urineCount}회 · 대변 ${record.correctedStoolCount ?? stoolCount}회',
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  if (uncertain) const Text('흔적이 겹치거나 가려져 정확하지 않을 수 있습니다.'),
                  if (observedQuantity != null)
                    Text('관찰량 $observedQuantity $quantityUnit (추정)'),
                  Text(
                    record.selectedCatId == null
                        ? '고양이: 미확인'
                        : '고양이: ${record.request.eligibleCats.where((cat) => cat.id == record.selectedCatId).map((cat) => cat.name).firstOrNull ?? '확인 불가'}',
                  ),
                ],
              ],
            ),
          ),
          if (record.notes.isNotEmpty) ...[
            const SizedBox(height: HareupSpacing.medium),
            HareupFormSection(title: '특이사항 메모', children: [Text(record.notes)]),
          ],
          const SizedBox(height: HareupSpacing.large),
          LayoutBuilder(
            builder: (context, constraints) {
              final share = Builder(
                builder: (buttonContext) => OutlinedButton.icon(
                  onPressed: () async {
                    try {
                      final box =
                          buttonContext.findRenderObject() as RenderBox?;
                      await SharePlus.instance.share(
                        ShareParams(
                          text: recordShareText(record),
                          sharePositionOrigin: box == null
                              ? null
                              : box.localToGlobal(Offset.zero) & box.size,
                        ),
                      );
                    } catch (_) {
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('공유 화면을 열지 못했습니다.')),
                        );
                      }
                    }
                  },
                  icon: const Icon(Icons.ios_share),
                  label: const Text('기록 공유하기'),
                ),
              );
              final edit = FilledButton.icon(
                onPressed: _edit,
                icon: const Icon(Icons.edit_outlined),
                label: const Text('기록 수정'),
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
      ).showSnackBar(const SnackBar(content: Text('0 이상의 횟수를 입력해 주세요.')));
      return;
    }
    final updated = widget.record.withAnnotations(
      urineCount: urine,
      stoolCount: stool,
      catId: isLitter ? _catId : null,
      notes: _notes.text,
    );
    if (!validRecordAnnotations(updated)) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(const SnackBar(content: Text('수정한 내용을 확인해 주세요.')));
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
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(failure.message)));
    }
  }

  @override
  Widget build(BuildContext context) => PopScope(
    canPop: !_busy,
    child: HareupFormPage(
      title: const Text('기록 수정'),
      content: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const HareupGuidance(
              title: '보호자 관찰 확인',
              message: '원래 분석 결과는 유지되며 확인한 값과 메모만 수정됩니다.',
            ),
            const SizedBox(height: HareupSpacing.medium),
            HareupFormSection(
              title: '확인한 관찰',
              children: [
                if (widget.record.outcome is LitterOutcome) ...[
                  HareupCountField(
                    controller: _urine,
                    label: '확인한 소변 흔적 수',
                    enabled: !_busy,
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  HareupCountField(
                    controller: _stool,
                    label: '확인한 대변 흔적 수',
                    enabled: !_busy,
                  ),
                  const SizedBox(height: HareupSpacing.medium),
                  Text(
                    '이용 고양이 선택',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Wrap(
                    spacing: HareupSpacing.small,
                    children: [
                      ChoiceChip(
                        label: const Text('미확인'),
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
                  decoration: const InputDecoration(labelText: '특이사항 (선택)'),
                ),
              ],
            ),
          ],
        ),
      ),
      actions: [
        TextButton(
          onPressed: _busy ? null : () => Navigator.pop(context),
          child: const Text('취소'),
        ),
        FilledButton(onPressed: _busy ? null : _save, child: const Text('저장')),
      ],
    ),
  );
}
