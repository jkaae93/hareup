import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_media/media.dart';
import '../../shared_data/target_widgets.dart';
import '../../shared_data/selection_management_page.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../photo_analysis/presentation/analysis_page.dart';
import '../../records/presentation/records_page.dart';
import '../../records/domain/record.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../domain/litter_box.dart';
import 'litter_box_cubit.dart';

Future<void> showLitterBoxDetail(
  BuildContext context,
  LitterBox box,
  PhotoSource photoSource,
  List<CatOption> cats,
) {
  final cubit = context.read<LitterBoxCubit>();
  final runtime = context.read<AnalysisRuntime>();
  final records = context.read<RecordsRepository>();
  return Navigator.of(context).push(
    MaterialPageRoute<void>(
      builder: (_) => MultiRepositoryProvider(
        providers: [
          RepositoryProvider<AnalysisRuntime>.value(value: runtime),
          RepositoryProvider<RecordsRepository>.value(value: records),
        ],
        child: BlocProvider.value(
          value: cubit,
          child: _LitterBaselineDialog(
            box: box,
            source: photoSource,
            cats: cats.where((cat) => box.catIds.contains(cat.id)).toList(),
          ),
        ),
      ),
    ),
  );
}

class LitterBoxPage extends StatelessWidget {
  const LitterBoxPage({
    super.key,
    required this.cats,
    required this.photoSource,
    this.selectionMode = false,
  });
  final bool selectionMode;
  final List<CatOption> cats;
  final PhotoSource photoSource;
  @override
  Widget build(BuildContext context) {
    if (selectionMode) {
      final cubit = context.read<LitterBoxCubit>();
      return SelectionManagementPage<LitterBox>(
        title: context.l10n.homeLitterManage,
        emptyMessage: context.l10n.litterEmptyMessage,
        addLabel: context.l10n.litterAddAction,
        confirmMessage: context.l10n.targetDeleteMessage,
        cubit: cubit,
        idOf: (box) => box.id,
        nameOf: (box) => box.name,
        iconOf: (_) => Icons.cleaning_services_outlined,
        onAdd: () => Navigator.of(context).push(
          MaterialPageRoute<void>(
            builder: (_) => BlocProvider.value(
              value: cubit,
              child: _LitterEditor(cats: cats, source: photoSource),
            ),
          ),
        ),
        onRetry: cubit.load,
        onDelete: (box) => cubit.remove(box.id),
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
      appBar: AppBar(title: Text(context.l10n.homeLitterManage)),
      bottomNavigationBar: ManagementBottomButton(
        icon: Icons.add,
        label: context.l10n.litterAddAction,
        onPressed: () {
          final cubit = context.read<LitterBoxCubit>();
          Navigator.of(context).push(
            MaterialPageRoute<void>(
              builder: (_) => BlocProvider.value(
                value: cubit,
                child: _LitterEditor(cats: cats, source: photoSource),
              ),
            ),
          );
        },
      ),
      body: HareupContent(
        child: BlocBuilder<LitterBoxCubit, LoadState<List<LitterBox>>>(
          builder: (context, state) => LoadView<List<LitterBox>>(
            state: state,
            emptyMessage: context.l10n.litterEmptyMessage,
            onRetry: () => context.read<LitterBoxCubit>().load(),
            builder: (context, boxes) => GridView.builder(
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
              itemCount: boxes.length,
              itemBuilder: (context, index) {
                final box = boxes[index];
                return TargetGridTile(
                  name: box.name,
                  icon: Icons.cleaning_services_outlined,
                  onTap: () =>
                      showLitterBoxDetail(context, box, photoSource, cats),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class _LitterEditor extends StatefulWidget {
  const _LitterEditor({required this.cats, required this.source});
  final List<CatOption> cats;
  final PhotoSource source;
  @override
  State<_LitterEditor> createState() => _LitterEditorState();
}

class _LitterEditorState extends State<_LitterEditor> {
  final _form = GlobalKey<FormState>();
  final _name = TextEditingController();
  final _width = TextEditingController();
  final _length = TextEditingController();
  final _height = TextEditingController();
  final _selected = <String>{};
  Uint8List? _photo;
  bool _automatic = false;
  bool _picking = false;
  @override
  void dispose() {
    _name.dispose();
    _width.dispose();
    _length.dispose();
    _height.dispose();
    super.dispose();
  }

  void _message(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));
  Future<void> _pick(bool camera) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final selected = camera
          ? await widget.source.pickFromCamera()
          : await widget.source.pickFromGallery();
      if (!mounted) return;
      if (selected is PhotoSelectionFailed) {
        _message(context.l10n.analysisPhotoAccessRetry);
        return;
      }
      if (selected is! PhotoSelected) return;
      if (await selected.file.length() > 10 * 1024 * 1024) {
        if (mounted) _message(context.l10n.analysisPhotoTooBig10);
        return;
      }
      final bytes = await selected.file.readAsBytes();
      if (mounted) setState(() => _photo = bytes);
    } catch (_) {
      if (mounted) _message(context.l10n.photoReadFailed);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  String? _positive(String? value) {
    if (value == null || value.trim().isEmpty) return null;
    final number = double.tryParse(value);
    return number == null || !number.isFinite || number <= 0
        ? context.l10n.commonPositiveNumber
        : null;
  }

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<LitterBoxCubit>();
    return HareupFormPage(
      title: Text(context.l10n.litterRegisterTitle),
      content: SizedBox(
        width: 380,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                HareupStatusBadge(label: context.l10n.litterHealthBadge),
                const SizedBox(height: HareupSpacing.small),
                Text(
                  context.l10n.litterRegisterTitle,
                  style: Theme.of(context).textTheme.headlineSmall,
                ),
                const SizedBox(height: HareupSpacing.small),
                Text(context.l10n.litterRegisterHint),
                const SizedBox(height: HareupSpacing.large),
                HareupGuidance(
                  title: context.l10n.analysisPhotoGuideTitle,
                  message: context.l10n.litterPhotoGuide,
                  icon: Icons.center_focus_strong,
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupFormSection(
                  title: context.l10n.litterAutomaticSection,
                  children: [
                    SwitchListTile(
                      contentPadding: EdgeInsets.zero,
                      title: Text(context.l10n.litterAutomaticLabel),
                      value: _automatic,
                      onChanged: (value) => setState(() => _automatic = value),
                    ),
                    if (_automatic)
                      HareupGuidance(
                        title: context.l10n.litterAutomaticBlockedTitle,
                        message: context.l10n.litterAutomaticBlockedMessage,
                        icon: Icons.error_outline,
                        warning: true,
                      ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupFormSection(
                  title: context.l10n.litterBaselineRegisterTitle,
                  description: context.l10n.litterBaselineRegisterHint,
                  children: [
                    HareupPhotoPreview(
                      bytes: _photo,
                      label: context.l10n.litterBaselineLabel,
                      height: 220,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    HareupPhotoActions(
                      prefix: context.dsL10n.photoBeforeDefault,
                      onCamera: _picking ? null : () => _pick(true),
                      onGallery: _picking ? null : () => _pick(false),
                    ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupFormSection(
                  title: context.l10n.litterProfileTitle,
                  children: [
                    TextFormField(
                      controller: _name,
                      maxLength: 30,
                      decoration: InputDecoration(
                        labelText: context.l10n.litterNameLabel,
                      ),
                      validator: (value) =>
                          value == null || value.trim().isEmpty
                          ? context.l10n.petNameRequired
                          : null,
                    ),
                    const SizedBox(height: HareupSpacing.medium),
                    Text(
                      context.l10n.litterSharedCats,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    if (widget.cats.isEmpty)
                      Text(context.l10n.litterRegisterCatsFirst),
                    for (final cat in widget.cats)
                      CheckboxListTile(
                        contentPadding: const EdgeInsets.symmetric(
                          horizontal: HareupSpacing.small,
                        ),
                        tileColor: HareupColors.neutral100,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(12),
                        ),
                        title: Text(cat.name),
                        value: _selected.contains(cat.id),
                        onChanged: (value) => setState(() {
                          if (value == true) {
                            _selected.add(cat.id);
                          } else {
                            _selected.remove(cat.id);
                          }
                        }),
                      ),
                    const SizedBox(height: HareupSpacing.medium),
                    Text(
                      context.l10n.litterDimensionsTitle,
                      style: Theme.of(context).textTheme.titleMedium,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    TextFormField(
                      controller: _width,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.l10n.litterWidthLabel,
                      ),
                      validator: _positive,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    TextFormField(
                      controller: _length,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.l10n.litterLengthLabel,
                      ),
                      validator: _positive,
                    ),
                    const SizedBox(height: HareupSpacing.small),
                    TextFormField(
                      controller: _height,
                      keyboardType: const TextInputType.numberWithOptions(
                        decimal: true,
                      ),
                      decoration: InputDecoration(
                        labelText: context.l10n.litterHeightLabel,
                      ),
                      validator: _positive,
                    ),
                  ],
                ),
                const SizedBox(height: HareupSpacing.medium),
                HareupGuidance(
                  title: context.l10n.litterVolumeGuideTitle,
                  message: context.l10n.litterVolumeGuideMessage,
                  icon: Icons.lightbulb_outline,
                ),
                const SizedBox(height: HareupSpacing.large),
              ],
            ),
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(context.dsL10n.cancelAction),
        ),
        BlocBuilder<Command1<void, LitterBox>, CommandState<void>>(
          bloc: cubit.createCommand,
          builder: (_, state) => FilledButton(
            onPressed: _picking || _automatic || state is CommandRunning<void>
                ? null
                : () async {
                    if (!_form.currentState!.validate()) return;
                    if (_selected.isEmpty ||
                        _photo == null ||
                        _photo!.isEmpty) {
                      _message(context.l10n.litterCatsAndPhotoRequired);
                      return;
                    }
                    final saved = await cubit.create(
                      name: _name.text,
                      catIds: _selected.toList(),
                      photo: _photo!,
                      isAutomatic: _automatic,
                      widthCm: double.tryParse(_width.text),
                      lengthCm: double.tryParse(_length.text),
                      litterHeightCm: double.tryParse(_height.text),
                    );
                    if (!context.mounted) return;
                    if (saved) {
                      Navigator.pop(context);
                    } else if (cubit.createCommand.state
                        case CommandFailure<void>(:final failure)) {
                      _message(failureDisplayMessage(context, failure));
                    }
                  },
            child: Text(context.l10n.commonRegister),
          ),
        ),
      ],
    );
  }
}

class _LitterBaselineDialog extends StatefulWidget {
  const _LitterBaselineDialog({
    required this.box,
    required this.source,
    required this.cats,
  });
  final LitterBox box;
  final PhotoSource source;
  final List<CatOption> cats;
  @override
  State<_LitterBaselineDialog> createState() => _LitterBaselineDialogState();
}

class _LitterBaselineDialogState extends State<_LitterBaselineDialog> {
  bool _busy = false;
  late String _name = widget.box.name;

  Future<void> _delete() async {
    final confirmed = await confirmTargetDeletion(context, _name);
    if (!confirmed || !mounted) return;
    setState(() => _busy = true);
    final cubit = context.read<LitterBoxCubit>();
    final removed = await cubit.remove(widget.box.id);
    if (!mounted) return;
    if (removed) {
      Navigator.pop(context);
    } else {
      setState(() => _busy = false);
      final message = switch (cubit.deleteCommand.state) {
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
          title: context.l10n.litterRenameTitle,
          label: context.l10n.litterNameLabel,
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
    final cubit = context.read<LitterBoxCubit>();
    final saved = await cubit.rename(widget.box.id, name);
    if (!mounted) return;
    setState(() {
      _busy = false;
      if (saved) _name = name;
    });
    if (!saved) {
      final message = switch (cubit.renameCommand.state) {
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

  Future<void> _replace(bool camera) async {
    if (_busy) return;
    setState(() => _busy = true);
    try {
      final selected = camera
          ? await widget.source.pickFromCamera()
          : await widget.source.pickFromGallery();
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
      final bytes = await selected.file.readAsBytes();
      if (!mounted) return;
      final saved = await context.read<LitterBoxCubit>().changeBaseline(
        widget.box.id,
        bytes,
      );
      if (!mounted) return;
      if (saved) {
        Navigator.pop(context);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(context.l10n.litterBaselineChangeFailed)),
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
  Widget build(BuildContext context) => HareupFormPage(
    title: Text(_name),
    appBarActions: [
      IconButton(
        tooltip: context.l10n.commonRename,
        onPressed: _busy ? null : _rename,
        icon: const Icon(Icons.edit_outlined),
      ),
      IconButton(
        tooltip: context.l10n.litterDeleteAction,
        onPressed: _busy ? null : _delete,
        icon: const Icon(Icons.delete_outline),
      ),
    ],
    content: SingleChildScrollView(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          HareupFormSection(
            title: context.dsL10n.photoBeforeDefault,
            children: [
              HareupPhotoPreview(
                bytes: widget.box.currentBaseline.photo,
                label: context.l10n.litterBaselineLabel,
                height: 120,
                fit: BoxFit.cover,
              ),
              const SizedBox(height: HareupSpacing.medium),
              HareupPhotoActions(
                prefix: context.l10n.litterNewBaselinePrefix,
                onCamera: _busy ? null : () => _replace(true),
                onGallery: _busy ? null : () => _replace(false),
              ),
            ],
          ),
          const SizedBox(height: HareupSpacing.medium),
          HareupFormSection(
            title: context.l10n.litterBaselineHistoryTitle,
            children: [
              for (final baseline in widget.box.baselines.reversed)
                Text(
                  '${context.l10n.ordinalVersion(baseline.version)} · ${baseline.createdAt.toLocal().toString().substring(0, 16)}',
                ),
            ],
          ),
          const SizedBox(height: HareupSpacing.medium),
          HareupGuidance(
            title: context.l10n.litterBaselineGuideTitle,
            message: context.l10n.litterBaselineGuideMessage,
          ),
          const SizedBox(height: HareupSpacing.medium),
        ],
      ),
    ),
    equalActionWidths: true,
    actions: [
      OutlinedButton(
        onPressed: _busy
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RepositoryProvider<RecordsRepository>.value(
                    value: context.read<RecordsRepository>(),
                    child: AnalysisPage(
                      targetId: widget.box.id,
                      targetName: _name,
                      kind: AnalysisKind.litter,
                      baseline: widget.box.currentBaseline,
                      photoSource: widget.source,
                      runtime: context.read<AnalysisRuntime>(),
                      cats: [
                        for (final cat in widget.cats)
                          AnalysisCat(id: cat.id, name: cat.name),
                      ],
                      widthCm: widget.box.widthCm,
                      lengthCm: widget.box.lengthCm,
                      litterHeightCm: widget.box.litterHeightCm,
                    ),
                  ),
                ),
              ),
        child: Text(context.l10n.navCompare),
      ),
      FilledButton(
        onPressed: _busy
            ? null
            : () => Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (_) => RepositoryProvider<RecordsRepository>.value(
                    value: context.read<RecordsRepository>(),
                    child: RecordsPage(
                      groupId: context.read<AnalysisRuntime>().groupId,
                      targetId: widget.box.id,
                      targetName: _name,
                    ),
                  ),
                ),
              ),
        child: Text(context.l10n.litterViewRecords),
      ),
    ],
  );
}
