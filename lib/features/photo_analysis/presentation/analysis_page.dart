import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_media/media.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
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
        _message(context.l10n.analysisPhotoAccessRetry);
        return;
      }
      if (selection is! PhotoSelected) return;
      if (await selection.file.length() > 10 * 1024 * 1024) {
        if (mounted) _message(context.l10n.analysisPhotoTooBig10);
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
      if (mounted) _message(context.l10n.photoReadFailed);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  String _baselinePhotoWord(BuildContext context) =>
      widget.page.kind == AnalysisKind.water
      ? context.l10n.waterPurifierPhoto
      : context.dsL10n.photoBeforeDefault;
  void _analyze() {
    if (_photo == null || _photo!.isEmpty) {
      _message(context.l10n.analysisPhotoCompareRequired);
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
    appBar: AppBar(
      title: Text(context.l10n.analysisCompareTitle(widget.page.targetName)),
    ),
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
                    ? context.l10n.analysisWaterObserve
                    : context.l10n.analysisLitterObserve,
                children: [
                  Text(
                    '${context.l10n.analysisBaselineVersion(_baselinePhotoWord(context), widget.page.baseline.version)} · ${widget.page.baseline.createdAt.toLocal().toString().substring(0, 16)}',
                    style: Theme.of(context).textTheme.bodyMedium,
                  ),
                ],
              ),
              const SizedBox(height: HareupSpacing.medium),
              HareupPhotoComparison(
                before: widget.page.baseline.photo,
                after: _photo,
                beforeLabel: context.l10n.analysisBaselineVersion(
                  _baselinePhotoWord(context),
                  widget.page.baseline.version,
                ),
              ),
              HareupPhotoActions(
                onCamera: busy || !mayPick ? null : () => _pick(true),
                onGallery: busy || !mayPick ? null : () => _pick(false),
              ),
              const SizedBox(height: HareupSpacing.medium),
              HareupGuidance(
                title: context.l10n.analysisPhotoGuideTitle,
                message: widget.page.kind == AnalysisKind.water
                    ? context.l10n.analysisWaterGuide
                    : context.l10n.analysisLitterGuide,
                icon: Icons.center_focus_strong,
              ),
              const SizedBox(height: HareupSpacing.medium),
              if (state.stage == AnalysisStage.ready ||
                  state.stage == AnalysisStage.failed ||
                  state.stage == AnalysisStage.unavailable)
                FilledButton(
                  onPressed: busy ? null : _analyze,
                  child: Text(context.l10n.analysisRunAction),
                ),
              if (state.stage == AnalysisStage.analyzing ||
                  state.stage == AnalysisStage.saving)
                const Padding(
                  padding: EdgeInsets.all(HareupSpacing.medium),
                  child: HareupLoading(),
                ),
              if (state.failure case final failure?)
                HareupStatusBadge(
                  label: failureDisplayMessage(context, failure),
                  status: HareupStatus.error,
                ),
              if (state.outcome case final AnalysisUnavailable unavailable)
                HareupGuidance(
                  title: context.l10n.analysisCannotTitle,
                  message: analysisReasonDisplayMessage(context, unavailable),
                  icon: Icons.info_outline,
                ),
              if (state.modelResponse case final response?
                  when response.isNotEmpty)
                TextButton.icon(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => HareupTextDisplayPage(
                        title: context.l10n.analysisModelResponseTitle,
                        text: response,
                      ),
                    ),
                  ),
                  icon: const Icon(Icons.description_outlined),
                  label: Text(context.l10n.analysisViewModelResponse),
                ),
              if (state.stage == AnalysisStage.review ||
                  state.stage == AnalysisStage.saving ||
                  state.stage == AnalysisStage.saved) ...[
                HareupPanel(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Text(
                        context.l10n.analysisResultTitle,
                        style: Theme.of(context).textTheme.headlineMedium,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      HareupPanel(
                        color: HareupColors.surfaceContainer,
                        child: Text(context.l10n.analysisDisclaimerVet),
                      ),
                      if (state.outcome case WaterOutcome(
                        :final percent,
                        :final volumeMl,
                      )) ...[
                        const SizedBox(height: HareupSpacing.medium),
                        HareupMetric(
                          label: context.l10n.analysisDecreaseRate,
                          value: '$percent%',
                        ),
                        if (volumeMl != null) ...[
                          const SizedBox(height: HareupSpacing.small),
                          HareupMetric(
                            label: context.l10n.analysisDecreaseVolume,
                            value: '$volumeMl mL',
                          ),
                        ],
                        const SizedBox(height: HareupSpacing.small),
                        Text(context.l10n.analysisWaterCaveat),
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
                          label: context.l10n.analysisOriginalEstimate,
                          value: context.l10n.analysisLitterCounts(
                            urineCount,
                            stoolCount,
                          ),
                        ),
                        const SizedBox(height: HareupSpacing.medium),
                        if (uncertain)
                          Text(context.l10n.analysisUncertainTraces),
                        if (observedQuantity != null)
                          Text(
                            context.l10n.analysisObservedQuantity(
                              observedQuantity,
                              quantityUnit ?? '',
                            ),
                          ),
                        HareupCountField(
                          controller: _urine,
                          enabled: state.stage == AnalysisStage.review,
                          label: context.l10n.analysisConfirmedUrine,
                        ),
                        const SizedBox(height: HareupSpacing.small),
                        HareupCountField(
                          controller: _stool,
                          enabled: state.stage == AnalysisStage.review,
                          label: context.l10n.analysisConfirmedStool,
                        ),
                        const SizedBox(height: HareupSpacing.medium),
                        Text(
                          context.l10n.analysisSelectCat,
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        const SizedBox(height: HareupSpacing.small),
                        Wrap(
                          spacing: HareupSpacing.small,
                          runSpacing: HareupSpacing.small,
                          children: [
                            ChoiceChip(
                              label: Text(context.l10n.analysisCatUnknown),
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
                        context.l10n.recordsMemoTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      TextField(
                        controller: _notes,
                        enabled: state.stage == AnalysisStage.review,
                        minLines: 2,
                        maxLines: 4,
                        maxLength: 500,
                        decoration: InputDecoration(
                          labelText: context.l10n.recordsMemoField,
                          hintText: context.l10n.recordsMemoHint,
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
                              _message(context.l10n.recordsCountInvalid);
                              return;
                            }
                            context.read<AnalysisCubit>().save(
                              urineCount: urine,
                              stoolCount: stool,
                              selectedCatId: isLitter ? _selectedCatId : null,
                              notes: _notes.text,
                            );
                          },
                          child: Text(context.l10n.recordsSaveAction),
                        ),
                      if (state.stage == AnalysisStage.saved)
                        HareupStatusBadge(
                          label: context.l10n.recordsSavedBadge,
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
