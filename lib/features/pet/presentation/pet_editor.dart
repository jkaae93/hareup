import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../domain/pet.dart';
import 'pet_cubit.dart';

class PetEditor extends StatefulWidget {
  const PetEditor({super.key, this.pet, required this.photoSource});
  final Pet? pet;
  final PhotoSource photoSource;
  @override
  State<PetEditor> createState() => _PetEditorState();
}

class _PetEditorState extends State<PetEditor> {
  final _form = GlobalKey<FormState>();
  late final TextEditingController _name;
  late final TextEditingController _age;
  late final TextEditingController _weight;
  late PetSpecies _species;
  PetSex? _sex;
  Uint8List? _photo;
  bool _picking = false;

  @override
  void initState() {
    super.initState();
    final pet = widget.pet;
    _name = TextEditingController(text: pet?.name ?? '');
    _age = TextEditingController(
      text: pet?.profile.ageMonths?.toString() ?? '',
    );
    _weight = TextEditingController(
      text: pet?.profile.weightKg?.toString() ?? '',
    );
    _species = pet?.species ?? PetSpecies.cat;
    _sex = pet?.profile.sex;
    _photo = pet?.profile.photoBytes;
  }

  @override
  void dispose() {
    _name.dispose();
    _age.dispose();
    _weight.dispose();
    super.dispose();
  }

  Future<void> _pick(bool camera) async {
    if (_picking) return;
    setState(() => _picking = true);
    try {
      final selection = camera
          ? await widget.photoSource.pickFromCamera()
          : await widget.photoSource.pickFromGallery();
      if (!mounted) return;
      switch (selection) {
        case PhotoSelected(:final file):
          if (await file.length() > 10 * 1024 * 1024) {
            if (mounted) _notice(context.l10n.petPhotoTooLarge);
            break;
          }
          final bytes = await file.readAsBytes();
          if (mounted) setState(() => _photo = bytes);
        case PhotoSelectionFailed(:final reason):
          _notice(
            reason == PhotoFailureReason.permissionDenied
                ? context.l10n.petPhotoPermissionDenied
                : context.l10n.petPhotoUnavailable,
          );
        case PhotoCancelled():
          break;
      }
    } catch (_) {
      if (mounted) _notice(context.l10n.petPhotoReadFailed);
    } finally {
      if (mounted) setState(() => _picking = false);
    }
  }

  void _notice(String text) =>
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(text)));

  @override
  Widget build(BuildContext context) {
    final cubit = context.read<PetCubit>();
    return HareupFormPage(
      title: Text(
        widget.pet == null
            ? context.l10n.petAddAction
            : context.l10n.petEditTitle,
      ),
      content: SizedBox(
        width: 360,
        child: Form(
          key: _form,
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                HareupPhotoPreview(
                  bytes: _photo,
                  label: context.l10n.petPhotoLabel,
                  height: 120,
                  fit: BoxFit.cover,
                ),
                HareupPhotoActions(
                  onCamera: _picking ? null : () => _pick(true),
                  onGallery: _picking ? null : () => _pick(false),
                  onRemove: _photo == null || _picking
                      ? null
                      : () => setState(() => _photo = null),
                ),
                Text(context.l10n.petPhotoHint),
                TextFormField(
                  controller: _name,
                  maxLength: 30,
                  decoration: InputDecoration(
                    labelText: context.l10n.petNameLabel,
                  ),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? context.l10n.petNameRequired
                      : null,
                ),
                DropdownButtonFormField<PetSpecies>(
                  initialValue: _species,
                  decoration: InputDecoration(
                    labelText: context.l10n.petSpeciesLabel,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: PetSpecies.cat,
                      child: Text(context.l10n.petSpeciesCat),
                    ),
                    DropdownMenuItem(
                      value: PetSpecies.dog,
                      child: Text(context.l10n.petSpeciesDog),
                    ),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _species = value);
                  },
                ),
                TextFormField(
                  controller: _age,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: InputDecoration(
                    labelText: context.l10n.petAgeLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final age = int.tryParse(value);
                    return age == null || age < 0
                        ? context.l10n.petAgeInvalid
                        : null;
                  },
                ),
                DropdownButtonFormField<PetSex?>(
                  initialValue: _sex,
                  decoration: InputDecoration(
                    labelText: context.l10n.petSexLabel,
                  ),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(context.l10n.petSexUnspecified),
                    ),
                    DropdownMenuItem(
                      value: PetSex.female,
                      child: Text(context.l10n.petSexFemale),
                    ),
                    DropdownMenuItem(
                      value: PetSex.male,
                      child: Text(context.l10n.petSexMale),
                    ),
                    DropdownMenuItem(
                      value: PetSex.unknown,
                      child: Text(context.l10n.petSexNotKnown),
                    ),
                  ],
                  onChanged: (value) => setState(() => _sex = value),
                ),
                TextFormField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: InputDecoration(
                    labelText: context.l10n.petWeightLabel,
                  ),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final weight = double.tryParse(value);
                    return weight == null || !weight.isFinite || weight <= 0
                        ? context.l10n.petWeightInvalid
                        : null;
                  },
                ),
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
        BlocBuilder<Command1<void, Pet>, CommandState<void>>(
          bloc: cubit.saveCommand,
          builder: (context, state) => FilledButton(
            onPressed: state is CommandRunning<void> || _picking
                ? null
                : () async {
                    if (!_form.currentState!.validate()) return;
                    final saved = await cubit.save(
                      original: widget.pet,
                      name: _name.text,
                      species: _species,
                      profile: PetProfile(
                        ageMonths: int.tryParse(_age.text),
                        sex: _sex,
                        weightKg: double.tryParse(_weight.text),
                        photoBytes: _photo,
                      ),
                    );
                    if (!context.mounted) return;
                    if (saved) {
                      Navigator.pop(context);
                    } else if (cubit.saveCommand.state
                        case CommandFailure<void>(:final failure)) {
                      _notice(failureDisplayMessage(context, failure));
                    }
                  },
            child: Text(context.l10n.commonSave),
          ),
        ),
      ],
    );
  }
}
