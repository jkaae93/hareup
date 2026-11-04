import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_core/core.dart';
import '../../shared_data/target_widgets.dart';
import '../../shared_data/selection_management_page.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../records/domain/record.dart';
import '../../records/presentation/records_page.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../domain/water_bowl.dart';
import '../domain/water_level.dart';
import 'water_level_page.dart';
import 'water_level_history_page.dart';
import 'water_bowl_cubit.dart';

Future<void> showWaterBowlDetail(
  BuildContext context,
  WaterBowl bowl,
  PhotoSource photoSource,
) {
  final cubit = context.read<WaterBowlCubit>();
  final analysisRuntime = context.read<AnalysisRuntime>();
  final recordsRepository = context.read<RecordsRepository>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => _WaterBowlDetailPage(
        bowl: bowl,
        cubit: cubit,
        photoSource: photoSource,
        analysisRuntime: analysisRuntime,
        recordsRepository: recordsRepository,
      ),
    ),
  );
}

class WaterBowlPage extends StatelessWidget {
  const WaterBowlPage({
    super.key,
    required this.pets,
    required this.photoSource,
    required this.analysisRuntime,
    required this.recordsRepository,
    this.selectionMode = false,
  });
  final bool selectionMode;
  final List<BowlPetOption> pets;
  final PhotoSource photoSource;
  final AnalysisRuntime analysisRuntime;
  final RecordsRepository recordsRepository;

  @override
  Widget build(BuildContext context) {
    if (selectionMode) {
      final cubit = context.read<WaterBowlCubit>();
      return SelectionManagementPage<WaterBowl>(
        title: context.l10n.homeWaterManage,
        emptyMessage: context.l10n.waterEmptyMessage,
        addLabel: context.l10n.waterAddAction,
        confirmMessage: context.l10n.targetDeleteMessage,
        cubit: cubit,
        idOf: (bowl) => bowl.id,
        nameOf: (bowl) => bowl.name,
        iconOf: (_) => Icons.water_drop_outlined,
        onAdd: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: _BowlForm(
                pets: pets,
                photoSource: photoSource,
                analysisRuntime: analysisRuntime,
                recordsRepository: recordsRepository,
              ),
            ),
          ),
        ),
        onRetry: cubit.load,
        onDelete: (bowl) => cubit.remove(bowl.id),
        failureMessage: () => switch (cubit.deleteCommand.state) {
          CommandFailure<void>(:final failure) => failureDisplayMessage(
            context,
            failure,
          ),
          _ => context.l10n.commonDeleteFailed,
        },
      );
    }
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.homeWaterManage)),
      bottomNavigationBar: Builder(
        builder: (context) {
          final cubit = context.read<WaterBowlCubit>();
          return ManagementBottomButton(
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (_) => BlocProvider.value(
                  value: cubit,
                  child: _BowlForm(
                    pets: pets,
                    photoSource: photoSource,
                    analysisRuntime: analysisRuntime,
                    recordsRepository: recordsRepository,
                  ),
                ),
              ),
            ),
            label: context.l10n.waterAddAction,
            icon: Icons.add,
          );
        },
      ),
      body: HareupContent(
        child: BlocBuilder<WaterBowlCubit, LoadState<List<WaterBowl>>>(
          builder: (context, state) => LoadView<List<WaterBowl>>(
            state: state,
            emptyMessage: context.l10n.waterEmptyMessage,
            onRetry: () => context.read<WaterBowlCubit>().load(),
            builder: (context, bowls) => GridView.builder(
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2,
                childAspectRatio: 1.5,
              ),
              padding: const EdgeInsets.fromLTRB(
                HareupSpacing.pageMargin,
                HareupSpacing.small,
                HareupSpacing.pageMargin,
                HareupSpacing.floatingActionClearance,
              ),
              itemCount: bowls.length,
              itemBuilder: (context, index) {
                final bowl = bowls[index];
                return TargetGridTile(
                  name: bowl.name,
                  icon: Icons.water_drop_outlined,
                  onTap: () => Navigator.of(context).push(
                    MaterialPageRoute<void>(
                      builder: (_) => _WaterBowlDetailPage(
                        bowl: bowl,
                        cubit: context.read<WaterBowlCubit>(),
                        photoSource: photoSource,
                        analysisRuntime: analysisRuntime,
                        recordsRepository: recordsRepository,
                      ),
                    ),
                  ),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _BowlForm extends StatefulWidget {
  const _BowlForm({
    required this.pets,
    required this.photoSource,
    required this.analysisRuntime,
    required this.recordsRepository,
  });
  final List<BowlPetOption> pets;
  final PhotoSource photoSource;
  final AnalysisRuntime analysisRuntime;
  final RecordsRepository recordsRepository;
  @override
  State<_BowlForm> createState() => _BowlFormState();
}

class _BowlFormState extends State<_BowlForm> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _weight = TextEditingController();
  final _capacity = TextEditingController();
  final _notes = TextEditingController();
  final _selected = <String>{};
  final _photos = <String, Uint8List>{};
  static const _photoAngleKeys = ['front', 'back', 'top'];
  bool _picking = false;
  bool _submitting = false;

  String _angleLabel(BuildContext context, String angle) => switch (angle) {
    'front' => context.l10n.waterAngleFront,
    'back' => context.l10n.waterAngleBack,
    _ => context.l10n.waterAngleTop,
  };

  @override
  void dispose() {
    _name.dispose();
    _weight.dispose();
    _capacity.dispose();
    _notes.dispose();
    super.dispose();
  }

  Future<void> _pick(String angle, bool camera) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final result = camera
          ? await widget.photoSource.pickFromCamera()
          : await widget.photoSource.pickFromGallery();
      if (!mounted) return;
      switch (result) {
        case PhotoSelected(:final file):
          if (await file.length() > 3 * 1024 * 1024) {
            if (mounted) _message(context.l10n.waterPhotoTooLarge);
            break;
          }
          final bytes = await file.readAsBytes();
          if (mounted) setState(() => _photos[angle] = bytes);
        case PhotoSelectionFailed(:final reason):
          _message(
            reason == PhotoFailureReason.permissionDenied
                ? context.l10n.photoPermissionCheck
                : context.l10n.photoFetchFailed,
          );
        case PhotoCancelled():
          break;
      }
    } catch (_) {
      if (mounted) _message(context.l10n.photoReadFailed);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _message(String message) => ScaffoldMessenger.of(
    context,
  ).showSnackBar(SnackBar(content: Text(message)));
  String? _positive(String? input) {
    if (input == null || input.trim().isEmpty) return null;
    final value = double.tryParse(input);
    return value == null || !value.isFinite || value <= 0
        ? context.l10n.commonPositiveNumber
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<WaterBowlCubit>();
    return PopScope(
      canPop: !_submitting,
      child: HareupFormPage(
        title: Text(context.l10n.waterRegisterTitle),
        content: SizedBox(
          width: 380,
          child: Form(
            key: _form,
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  HareupStatusBadge(label: context.l10n.waterIntakeBadge),
                  const SizedBox(height: HareupSpacing.small),
                  Text(
                    context.l10n.waterNewRegisterHeadline,
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: HareupSpacing.small),
                  Text(context.l10n.waterRegisterHint),
                  const SizedBox(height: HareupSpacing.large),
                  HareupGuidance(
                    title: context.l10n.analysisPhotoGuideTitle,
                    message: context.l10n.waterPhotoGuide,
                    icon: Icons.camera_alt_outlined,
                  ),
                  const SizedBox(height: HareupSpacing.medium),
                  HareupFormSection(
                    title: context.l10n.waterPurifierPhoto,
                    description: context.l10n.waterAnglePhotosHint,
                    children: [
                      for (final angle in _photoAngleKeys) ...[
                        Text(
                          context.l10n.waterAnglePhoto(
                            _angleLabel(context, angle),
                          ),
                          style: Theme.of(context).textTheme.titleMedium,
                        ),
                        HareupPhotoPreview(
                          bytes: _photos[angle],
                          label: context.l10n.waterPurifierAnglePhoto(
                            _angleLabel(context, angle),
                          ),
                          height: 160,
                        ),
                        if (_photos.containsKey(angle))
                          Text(
                            context.l10n.waterAnglePhotoSelected(
                              _angleLabel(context, angle),
                            ),
                          ),
                        HareupPhotoActions(
                          prefix: context.l10n.waterAnglePhoto(
                            _angleLabel(context, angle),
                          ),
                          onCamera: _picking ? null : () => _pick(angle, true),
                          onGallery: _picking
                              ? null
                              : () => _pick(angle, false),
                        ),
                        const SizedBox(height: HareupSpacing.medium),
                      ],
                    ],
                  ),
                  const SizedBox(height: HareupSpacing.medium),
                  HareupFormSection(
                    title: context.l10n.waterInfoTitle,
                    children: [
                      TextFormField(
                        controller: _name,
                        maxLength: 30,
                        decoration: InputDecoration(
                          labelText: context.l10n.waterNameLabel,
                        ),
                        validator: (value) =>
                            value == null || value.trim().isEmpty
                            ? context.l10n.petNameRequired
                            : null,
                      ),
                      const SizedBox(height: HareupSpacing.medium),
                      Text(
                        context.l10n.waterSharedPets,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      if (widget.pets.isEmpty)
                        Text(context.l10n.waterRegisterPetsFirst),
                      for (final pet in widget.pets)
                        CheckboxListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: HareupSpacing.small,
                          ),
                          tileColor: HareupColors.neutral100,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          title: Text(pet.name),
                          value: _selected.contains(pet.id),
                          onChanged: (value) => setState(() {
                            if (value == true) {
                              _selected.add(pet.id);
                            } else {
                              _selected.remove(pet.id);
                            }
                          }),
                        ),
                      const SizedBox(height: HareupSpacing.medium),
                      Text(
                        context.l10n.waterSpecsTitle,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      TextFormField(
                        controller: _weight,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.waterEmptyWeightLabel,
                        ),
                        validator: _positive,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                      TextFormField(
                        controller: _capacity,
                        keyboardType: const TextInputType.numberWithOptions(
                          decimal: true,
                        ),
                        decoration: InputDecoration(
                          labelText: context.l10n.waterFullVolumeLabel,
                          helperText: context.l10n.waterFullVolumeHelper,
                        ),
                        validator: _positive,
                      ),
                      const SizedBox(height: HareupSpacing.medium),
                      TextFormField(
                        controller: _notes,
                        maxLength: 500,
                        minLines: 2,
                        maxLines: 4,
                        decoration: InputDecoration(
                          labelText: context.l10n.waterPhotoNotesLabel,
                          hintText: context.l10n.waterPhotoNotesHint,
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: HareupSpacing.medium),
                  HareupGuidance(
                    title: context.l10n.waterMeasureCautionTitle,
                    message: context.l10n.waterMeasureCautionMessage,
                    icon: Icons.warning_amber_outlined,
                  ),
                  const SizedBox(height: HareupSpacing.large),
                ],
              ),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: _submitting ? null : () => Navigator.pop(context),
            child: Text(context.dsL10n.cancelAction),
          ),
          BlocBuilder<Command1<void, WaterBowl>, CommandState<void>>(
            bloc: cubit.createCommand,
            builder: (_, state) => FilledButton(
              onPressed:
                  _picking || _submitting || state is CommandRunning<void>
                  ? null
                  : () async {
                      if (!_form.currentState!.validate()) return;
                      if (_selected.isEmpty ||
                          _photoAngleKeys.any(
                            (key) => _photos[key]?.isNotEmpty != true,
                          )) {
                        _message(context.l10n.waterPetsAndPhotosRequired);
                        return;
                      }
                      setState(() => _submitting = true);
                      final saved = await cubit.create(
                        name: _name.text,
                        petIds: _selected.toList(),
                        photo: _photos['front']!,
                        registrationPhotos: _photos,
                        emptyWeightGrams: double.tryParse(_weight.text),
                        fullWaterMl: double.tryParse(_capacity.text),
                        notes: _notes.text,
                      );
                      if (!context.mounted) return;
                      if (saved) {
                        final service = widget.analysisRuntime.service;
                        String message;
                        if (service is WaterLevelService) {
                          final result = await (service as WaterLevelService)
                              .observeWaterLevel(
                                groupId: widget.analysisRuntime.groupId,
                                bowlId: cubit.lastCreated!.id,
                                requestId:
                                    'setup-${DateTime.now().microsecondsSinceEpoch}',
                                setup: true,
                                photos: _photos,
                              );
                          if (!context.mounted) return;
                          message = switch (result) {
                            Success<WaterLevelResult>(:final value)
                                when value.status == 'ok' =>
                              context.l10n.waterSetupComplete,
                            Success<WaterLevelResult>() =>
                              context.l10n.waterSetupLevelUnknown,
                            Failure<WaterLevelResult>(:final failure) =>
                              context.l10n.waterSetupFailedDetail(
                                failureDisplayMessage(context, failure),
                              ),
                          };
                        } else {
                          message = context.l10n.waterRegisteredRetryAnalysis;
                        }
                        if (!context.mounted) return;
                        await cubit.load();
                        if (!context.mounted) return;
                        _message(message);
                        setState(() => _submitting = false);
                        Navigator.pop(context);
                      } else {
                        setState(() => _submitting = false);
                        if (cubit.createCommand.state case CommandFailure<void>(
                          :final failure,
                        )) {
                          _message(failureDisplayMessage(context, failure));
                        }
                      }
                    },
              child: Text(context.l10n.commonRegister),
            ),
          ),
        ],
      ),
    );
  }
}

class _WaterBowlDetailPage extends StatefulWidget {
  const _WaterBowlDetailPage({
    required this.bowl,
    required this.cubit,
    required this.photoSource,
    required this.analysisRuntime,
    required this.recordsRepository,
  });
  final WaterBowl bowl;
  final WaterBowlCubit cubit;
  final PhotoSource photoSource;
  final AnalysisRuntime analysisRuntime;
  final RecordsRepository recordsRepository;
  @override
  State<_WaterBowlDetailPage> createState() => _WaterBowlDetailPageState();
}

class _WaterBowlDetailPageState extends State<_WaterBowlDetailPage> {
  bool _busy = false;
  late String _name = widget.bowl.name;

  Future<void> _delete() async {
    final confirmed = await confirmTargetDeletion(context, _name);
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    final removed = await widget.cubit.remove(widget.bowl.id);
    if (!mounted) return;
    if (removed) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
      final message = switch (widget.cubit.deleteCommand.state) {
        CommandFailure<void>(:final failure) => failureDisplayMessage(
          context,
          failure,
        ),
        _ => context.l10n.commonDeleteFailed,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _rename() async {
    final name = await Navigator.of(context).push<String>(
      MaterialPageRoute(
        builder: (_) => HareupTextEntryPage(
          title: context.l10n.waterRenameTitle,
          label: context.l10n.waterBowlNameLabel,
          submitLabel: context.l10n.commonSave,
          initialValue: _name,
          maxLength: 30,
          validate: (value) =>
              value.isEmpty ? context.l10n.petNameRequired : null,
        ),
      ),
    );
    if (!mounted || name == null || name == _name) return;
    setState(() => _busy = true);
    final saved = await widget.cubit.rename(widget.bowl.id, name);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (saved) _name = name;
    });
    if (!saved) {
      final message = switch (widget.cubit.renameCommand.state) {
        CommandFailure<void>(:final failure) => failureDisplayMessage(
          context,
          failure,
        ),
        _ => context.l10n.commonRenameFailed,
      };
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text(message)));
    }
  }

  Future<void> _reanalyze() async {
    if (_busy) return;
    final service = widget.analysisRuntime.service;
    if (service is! WaterLevelService ||
        ![
          'front',
          'back',
          'top',
        ].every((key) => widget.bowl.registrationPhotos.containsKey(key))) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(context.l10n.waterReregisterPhotos)),
      );
      return;
    }
    setState(() => _busy = true);
    final result = await (service as WaterLevelService).observeWaterLevel(
      groupId: widget.analysisRuntime.groupId,
      bowlId: widget.bowl.id,
      requestId: 'setup-${DateTime.now().microsecondsSinceEpoch}',
      setup: true,
      photos: widget.bowl.registrationPhotos,
    );
    if (!mounted) return;
    setState(() => _busy = false);
    final message = switch (result) {
      Success<WaterLevelResult>(:final value) when value.status == 'ok' =>
        context.l10n.waterSetupComplete,
      Success<WaterLevelResult>(:final value) =>
        context.l10n.waterInitialLevelUnknown(value.reason),
      Failure<WaterLevelResult>(:final failure) => failureDisplayMessage(
        context,
        failure,
      ),
    };
    await widget.cubit.load();
    if (!mounted) return;
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  Future<void> _replace(bool camera) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final selected = camera
          ? await widget.photoSource.pickFromCamera()
          : await widget.photoSource.pickFromGallery();
      if (!mounted) return;
      if (selected is PhotoSelectionFailed) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.analysisPhotoAccessRetry)),
        );
        return;
      }
      if (selected is! PhotoSelected) return;
      if (await selected.file.length() > 10 * 1024 * 1024) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(context.l10n.analysisPhotoTooBig10)),
          );
        }
        return;
      }
      final photo = await selected.file.readAsBytes();
      if (!mounted) return;
      final notes = await Navigator.of(context).push<String>(
        MaterialPageRoute<String>(
          builder: (_) => HareupTextEntryPage(
            title: context.l10n.waterNewPhotoNotesTitle,
            label: context.l10n.waterPhotoNotesLabel,
            hint: context.l10n.waterNewPhotoNotesHint,
            maxLength: 500,
            minLines: 2,
            maxLines: 4,
            submitLabel: context.l10n.waterSavePhotoAction,
          ),
        ),
      );
      if (!mounted || notes == null) return;
      final saved = await widget.cubit.changeBaseline(
        widget.bowl.id,
        photo,
        notes: notes,
      );
      if (!mounted) return;
      if (saved) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.waterPhotoChangeFailed)),
        );
      }
    } catch (_) {
      if (mounted) {
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(SnackBar(content: Text(context.l10n.photoReadFailed)));
      }
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final original = widget.bowl;
    final bowl = WaterBowl(
      id: original.id,
      name: _name,
      petIds: original.petIds,
      baselines: original.baselines,
      registrationPhotos: original.registrationPhotos,
      emptyWeightGrams: original.emptyWeightGrams,
      fullWaterMl: original.fullWaterMl,
      levelProfile: original.levelProfile,
    );
    final baseline = bowl.currentBaseline;
    return Scaffold(
      appBar: AppBar(title: Text(context.l10n.waterDetailTitle)),
      body: HareupContent(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(
            HareupSpacing.pageMargin,
            HareupSpacing.medium,
            HareupSpacing.pageMargin,
            HareupSpacing.floatingActionClearance,
          ),
          children: [
            HareupFormSection(
              title: _name,
              description: context.l10n.waterSharedWithPets(bowl.petIds.length),
              children: [
                OutlinedButton.icon(
                  onPressed: _busy ? null : _rename,
                  icon: const Icon(Icons.edit_outlined),
                  label: Text(context.l10n.commonRename),
                ),
                TextButton.icon(
                  onPressed: _busy ? null : _delete,
                  icon: const Icon(Icons.delete_outline),
                  label: Text(context.l10n.waterDeleteAction),
                ),
                HareupStatusBadge(
                  label: context.l10n.waterPurifierPhotoVersion(
                    baseline.version,
                  ),
                ),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  context.l10n.waterRecentlyRegistered(
                    baseline.createdAt.toLocal().toString().substring(0, 16),
                  ),
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
              ],
            ),
            const SizedBox(height: HareupSpacing.medium),
            HareupFormSection(
              title: context.l10n.waterPurifierPhoto,
              description: context.l10n.waterRefillHint,
              children: [
                HareupPhotoPreview(
                  bytes: baseline.photo,
                  label: context.l10n.waterBowlPurifierPhoto(bowl.name),
                  height: 220,
                  fit: BoxFit.contain,
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupPhotoActions(
                  prefix: context.l10n.litterNewBaselinePrefix,
                  onCamera: _busy ? null : () => _replace(true),
                  onGallery: _busy ? null : () => _replace(false),
                ),
                if (baseline.notes.isNotEmpty) ...[
                  const SizedBox(height: HareupSpacing.small),
                  HareupGuidance(
                    title: context.l10n.waterPhotoNotesTitle,
                    message: baseline.notes,
                  ),
                ],
              ],
            ),
            const SizedBox(height: HareupSpacing.medium),
            if (bowl.registrationPhotos.isNotEmpty) ...[
              HareupFormSection(
                title: context.l10n.waterFirstPhotosTitle,
                children: [
                  for (final angle in const ['front', 'back', 'top'])
                    if (bowl.registrationPhotos[angle] case final photo?) ...[
                      Text(
                        context.l10n.waterAnglePhoto(
                          _registrationAngleLabel(context, angle),
                        ),
                      ),
                      HareupPhotoPreview(
                        bytes: photo,
                        label: context.l10n.waterPurifierAnglePhoto(
                          _registrationAngleLabel(context, angle),
                        ),
                        height: 160,
                      ),
                      const SizedBox(height: HareupSpacing.small),
                    ],
                ],
              ),
              const SizedBox(height: HareupSpacing.medium),
            ],
            HareupFormSection(
              title: context.l10n.waterDeviceTitle,
              children: [
                HareupMetric(
                  label: context.l10n.waterFullVolumeMetric,
                  value: bowl.fullWaterMl == null
                      ? context.l10n.petSexUnspecified
                      : '${_formatNumber(bowl.fullWaterMl!)} mL',
                ),
                const SizedBox(height: HareupSpacing.small),
                HareupMetric(
                  label: context.l10n.waterEmptyDeviceWeight,
                  value: bowl.emptyWeightGrams == null
                      ? context.l10n.petSexUnspecified
                      : '${_formatNumber(bowl.emptyWeightGrams!)} g',
                ),
              ],
            ),
            const SizedBox(height: HareupSpacing.medium),
            HareupFormSection(
              title: context.l10n.waterPhotoHistoryTitle,
              description: context.l10n.waterPhotoHistoryHint,
              children: [
                for (final item in bowl.baselines.reversed)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: CircleAvatar(
                      backgroundColor: HareupColors.primaryContainer,
                      child: Text('${item.version}'),
                    ),
                    title: Text(
                      context.l10n.waterPurifierPhotoVersion(item.version),
                    ),
                    subtitle: Text(
                      item.createdAt.toLocal().toString().substring(0, 16),
                    ),
                    trailing: item.version == baseline.version
                        ? HareupStatusBadge(
                            label: context.l10n.waterCurrentBaseline,
                          )
                        : null,
                  ),
              ],
            ),
            const SizedBox(height: HareupSpacing.medium),
            HareupGuidance(
              title: context.l10n.waterOutcomeGuideTitle,
              message: context.l10n.waterOutcomeGuideMessage,
            ),
            const SizedBox(height: HareupSpacing.medium),
            if (bowl.levelProfile == null) ...[
              OutlinedButton.icon(
                onPressed: _busy ? null : _reanalyze,
                icon: const Icon(Icons.refresh),
                label: Text(context.l10n.waterReanalyzeAction),
              ),
              const SizedBox(height: HareupSpacing.small),
            ],
            TextButton(
              onPressed: _busy
                  ? null
                  : () => Navigator.of(context).push(
                      MaterialPageRoute<void>(
                        builder: (_) =>
                            RepositoryProvider<RecordsRepository>.value(
                              value: widget.recordsRepository,
                              child: RecordsPage(
                                groupId: widget.analysisRuntime.groupId,
                                targetId: bowl.id,
                                targetName: bowl.name,
                              ),
                            ),
                      ),
                    ),
              child: Text(context.l10n.waterViewPastRecords),
            ),
            const SizedBox(height: HareupSpacing.large),
          ],
        ),
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(
            HareupSpacing.pageMargin,
            HareupSpacing.small,
            HareupSpacing.pageMargin,
            HareupSpacing.small,
          ),
          child: Row(
            children: [
              Expanded(
                child: OutlinedButton(
                  onPressed: _busy
                      ? null
                      : () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute<void>(
                              builder: (_) => WaterLevelPage(
                                bowl: bowl,
                                photoSource: widget.photoSource,
                                runtime: widget.analysisRuntime,
                              ),
                            ),
                          );
                          await widget.cubit.load();
                          if (context.mounted) Navigator.pop(context);
                        },
                  child: Text(context.l10n.waterObserveTitle),
                ),
              ),
              const SizedBox(width: HareupSpacing.small),
              Expanded(
                child: FilledButton(
                  onPressed: _busy
                      ? null
                      : () => Navigator.of(context).push(
                          MaterialPageRoute<void>(
                            builder: (_) => WaterLevelHistoryPage(
                              runtime: widget.analysisRuntime,
                              bowlId: bowl.id,
                            ),
                          ),
                        ),
                  child: Text(context.l10n.waterViewHistoryAction),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  String _formatNumber(double value) =>
      value == value.roundToDouble() ? value.toStringAsFixed(0) : '$value';

  String _registrationAngleLabel(BuildContext context, String angle) =>
      switch (angle) {
        'front' => context.l10n.waterAngleFront,
        'back' => context.l10n.waterAngleBack,
        _ => context.l10n.waterAngleTop,
      };
}
