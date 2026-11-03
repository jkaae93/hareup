import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_media/media.dart';
import '../../records/domain/record.dart';
import '../domain/analysis.dart';
import 'analysis_cubit.dart';

class AnalysisPage extends StatelessWidget {
  const AnalysisPage({
    super.key,
    required this.targetId,
    required this.targetName,
    required this.kind,
    required this.baseline,
    required this.photoSource,
    required this.runtime,
    this.cats = const [],
    this.emptyWeightGrams,
    this.fullWaterMl,
    this.widthCm,
    this.lengthCm,
    this.litterHeightCm,
  });
  final String targetId;
  final String targetName;
  final AnalysisKind kind;
  final PhotoBaseline baseline;
  final PhotoSource photoSource;
  final AnalysisRuntime runtime;
  final List<AnalysisCat> cats;
  final double? emptyWeightGrams;
  final double? fullWaterMl;
  final double? widthCm;
  final double? lengthCm;
  final double? litterHeightCm;
  @override
  Widget build(BuildContext context) => BlocProvider(
    create: (_) => AnalysisCubit(
      service: runtime.service,
      validation: runtime.validation,
      records: context.read<RecordsRepository>(),
    ),
    child: _AnalysisView(page: this),
  );
}

class _AnalysisView extends StatefulWidget {
  const _AnalysisView({required this.page});
  final AnalysisPage page;
  @override
  State<_AnalysisView> createState() => _AnalysisViewState();
}

class _AnalysisViewState extends State<_AnalysisView> {
  Uint8List? _photo;
  bool _picking = false;
  int _sequence = 0;
  DateTime? _selectedAt;
  AnalysisRequest? _pendingRequest;
  String? _selectedCatId;
  final _urine = TextEditingController();
  final _stool = TextEditingController();
  final _notes = TextEditingController();
  @override
  void dispose() {
    _urine.dispose();
    _stool.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pick(bool camera) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final selection = camera
          ? await widget.page.photoSource.pickFromCamera()
          : await widget.page.photoSource.pickFromGallery();
      if (!mounted) return;
      if (selection is PhotoSelectionFailed) {
        _message('사진 접근을 확인하고 다시 시도해 주세요.');
        return;
      }
      if (selection is! PhotoSelected) return;
      if (await selection.file.length() > 10 * 1024 * 1024) {
        if (mounted) _message('사진은 10MB 이하여야 합니다.');
        return;
      }
      final bytes = await selection.file.readAsBytes();
      if (mounted) {
        setState(() {
          _photo = bytes;
          _selectedAt = DateTime.now().toUtc();
          _pendingRequest = null;
        });
      }
    } catch (_) {
      if (mounted) _message('사진을 읽지 못했습니다.');
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  void _analyze() {
    if (_photo == null || _photo!.isEmpty) {
      _message('비교할 사진을 선택해 주세요.');
      return;
    }
    final page = widget.page;
    final now = DateTime.now().toUtc();
    final request = _pendingRequest ??= AnalysisRequest(
      id: '${now.microsecondsSinceEpoch}-${_sequence++}',
      groupId: page.runtime.groupId,
      targetId: page.targetId,
      targetName: page.targetName,
      kind: page.kind,
      baseline: page.baseline,
      photo: _photo!,
      photoSelectedAt: _selectedAt!,
      eligibleCats: page.cats,
      emptyWeightGrams: page.emptyWeightGrams,
      fullWaterMl: page.fullWaterMl,
      widthCm: page.widthCm,
      lengthCm: page.lengthCm,
      litterHeightCm: page.litterHeightCm,
    );
    context.read<AnalysisCubit>().analyze(request);
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text('${widget.page.targetName} 사진 비교')),
    body: HareupContent(
      child: BlocConsumer<AnalysisCubit, AnalysisState>(
        listener: (context, state) {
          final outcome = state.outcome;
          if (state.stage == AnalysisStage.review && outcome is LitterOutcome) {
            if (_urine.text.isEmpty) _urine.text = '${outcome.urineCount}';
            if (_stool.text.isEmpty) _stool.text = '${outcome.stoolCount}';
          }
        },
        builder: (context, state) {
          final mayPick =
              state.stage == AnalysisStage.ready ||
              state.stage == AnalysisStage.failed ||
              state.stage == AnalysisStage.unavailable;
          final busy =
              _picking ||
              state.stage == AnalysisStage.analyzing ||
              state.stage == AnalysisStage.saving;
          return ListView(
            padding: const EdgeInsets.symmetric(
              horizontal: HareupSpacing.pageMargin,
              vertical: HareupSpacing.medium,
            ),
            children: [
              HareupFormSection(
                title: widget.page.targetName,
                description: widget.page.kind == AnalysisKind.water
                    ? '물그릇 사진 관찰'
                    : '화장실 사진 관찰',
                children: [
                  Text(
                    '${widget.page.kind == AnalysisKind.water ? '정수기 사진' : '기준 사진'} ${widget.page.baseline.version}번째 · ${widget.page.baseline.createdAt.toLocal().toString().substring(0, 16)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: HareupSpacing.medium),
              HareupPhotoComparison(
                before: widget.page.baseline.photo,
                after: _photo,
                beforeLabel:
                    '${widget.page.kind == AnalysisKind.water ? '정수기 사진' : '기준 사진'} ${widget.page.baseline.version}번째',
              ),
              HareupPhotoActions(
                onCamera: busy || !mayPick ? null : () => _pick(true),
                onGallery: busy || !mayPick ? null : () => _pick(false),
              ),
              const SizedBox(height: HareupSpacing.medium),
              HareupGuidance(
                title: '사진 촬영 가이드',
                message: widget.page.kind == AnalysisKind.water
                    ? '등록한 정수기 사진과 같은 위치·거리·각도와 충분한 조명에서 정수기 전체가 보이도록 촬영하세요.'
                    : '기준 사진과 같은 위치·거리·각도와 충분한 조명에서 대상 전체가 보이도록 촬영하세요.',
                icon: Icons.center_focus_strong,
              ),
              const SizedBox(height: HareupSpacing.medium),
              if (state.stage == AnalysisStage.ready ||
                  state.stage == AnalysisStage.failed ||
                  state.stage == AnalysisStage.unavailable)
                FilledButton(
                  onPressed: busy ? null : _analyze,
                  child: const Text('사진 분석'),
                ),
              if (state.stage == AnalysisStage.analyzing ||
                  state.stage == AnalysisStage.saving)
                const Padding(
                  padding: EdgeInsets.all(HareupSpacing.medium),
                  child: HareupLoading(),
                ),
              if (state.failure case final failure?)
                HareupStatusBadge(
                  label: failure.message,
                  status: HareupStatus.error,
                ),
              if (state.outcome case AnalysisUnavailable(:final reason))
                HareupGuidance(
                  title: '분석할 수 없습니다',
                  message: reason,
                  icon: Icons.info_outline,
                ),
              if (state.modelResponse case final response?
                  when response.isNotEmpty)
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) =>
                          HareupTextDisplayPage(title: '모델 응답', text: response),
                    ),
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: const Text('모델 응답 보기'),
                ),
              if (state.stage == AnalysisStage.review ||
                  state.stage == AnalysisStage.saving ||
                  state.stage == AnalysisStage.saved) ...[
                HareupPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        '분석 결과',
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      const HareupPanel(
                        color: HareupColors.surfaceContainer,
                        child: Text(
                          '사진 분석 결과는 추정 정보이며 진단이 아닙니다. 필요한 경우 수의사와 상담하세요.',
                        ),
                      ),
                      if (state.outcome case WaterOutcome(
                        :final percent,
                        :final volumeMl,
                      )) ...[
                        const SizedBox(height: HareupSpacing.medium),
                        HareupMetric(
                          label: '기준 대비 감소율 (추정)',
                          value: '$percent%',
                        ),
                        if (volumeMl != null) ...[
                          const SizedBox(height: HareupSpacing.small),
                          HareupMetric(
                            label: '감소량 (추정)',
                            value: '$volumeMl mL',
                          ),
                        ],
                        const SizedBox(height: HareupSpacing.small),
                        const Text('보충, 증발, 쏟음 또는 공동 사용의 영향을 받을 수 있습니다.'),
                      ],
                      if (state.outcome case LitterOutcome(
                        :final urineCount,
                        :final stoolCount,
                        :final uncertain,
                        :final observedQuantity,
                        :final quantityUnit,
                      )) ...[
                        const SizedBox(height: HareupSpacing.medium),
                        HareupMetric(
                          label: '원래 추정',
                          value: '소변 $urineCount회 · 대변 $stoolCount회',
                        ),
                        const SizedBox(height: HareupSpacing.medium),
                        if (uncertain)
                          const Text('흔적이 겹치거나 가려져 정확하지 않을 수 있습니다.'),
                        if (observedQuantity != null)
                          Text('관찰량: $observedQuantity $quantityUnit (추정)'),
                        HareupCountField(
                          controller: _urine,
                          enabled: state.stage == AnalysisStage.review,
                          label: '확인한 소변 흔적 수',
                        ),
                        const SizedBox(height: HareupSpacing.small),
                        HareupCountField(
                          controller: _stool,
                          enabled: state.stage == AnalysisStage.review,
                          label: '확인한 대변 흔적 수',
                        ),
                        const SizedBox(height: HareupSpacing.medium),
                        Text(
                          '이용 고양이 선택',
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: HareupSpacing.small),
                        Wrap(
                          spacing: HareupSpacing.small,
                          runSpacing: HareupSpacing.small,
                          children: [
                            ChoiceChip(
                              label: const Text('미확인'),
                              avatar: const Icon(Icons.help_outline),
                              selected: _selectedCatId == null,
                              onSelected: state.stage == AnalysisStage.review
                                  ? (_) => setState(() => _selectedCatId = null)
                                  : null,
                            ),
                            for (final cat in widget.page.cats)
                              ChoiceChip(
                                label: Text(cat.name),
                                avatar: const Icon(Icons.pets),
                                selected: _selectedCatId == cat.id,
                                onSelected: state.stage == AnalysisStage.review
                                    ? (_) => setState(
                                        () => _selectedCatId = cat.id,
                                      )
                                    : null,
                              ),
                          ],
                        ),
                      ],
                      const SizedBox(height: HareupSpacing.medium),
                      Text(
                        '특이사항 메모',
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      TextField(
                        controller: _notes,
                        enabled: state.stage == AnalysisStage.review,
                        minLines: 2,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: const InputDecoration(
                          labelText: '특이사항 (선택)',
                          hintText: '관찰한 내용을 기록해 주세요.',
                        ),
                      ),
                      const SizedBox(height: HareupSpacing.medium),
                      if (state.stage == AnalysisStage.review)
                        FilledButton(
                          onPressed: () {
                            final isLitter = state.outcome is LitterOutcome;
                            final urine = isLitter
                                ? int.tryParse(_urine.text)
                                : null;
                            final stool = isLitter
                                ? int.tryParse(_stool.text)
                                : null;
                            if (isLitter &&
                                (urine == null ||
                                    stool == null ||
                                    urine < 0 ||
                                    stool < 0)) {
                              _message('0 이상의 횟수를 입력해 주세요.');
                              return;
                            }
                            context.read<AnalysisCubit>().save(
                              urineCount: urine,
                              stoolCount: stool,
                              selectedCatId: isLitter ? _selectedCatId : null,
                              notes: _notes.text,
                            );
                          },
                          child: const Text('기록 저장'),
                        ),
                      if (state.stage == AnalysisStage.saved)
                        const HareupStatusBadge(
                          label: '기록을 저장했습니다.',
                          status: HareupStatus.success,
                        ),
                    ],
                  ),
                ),
              ],
            ],
          );
        },
      ),
    ),
  );
}
