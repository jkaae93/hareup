import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
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
            if (mounted) _notice('사진은 10MB 이하로 선택해 주세요.');
            break;
          }
          final bytes = await file.readAsBytes();
          if (mounted) setState(() => _photo = bytes);
        case PhotoSelectionFailed(:final reason):
          _notice(
            reason == PhotoFailureReason.permissionDenied
                ? '사진 접근 권한을 확인해 주세요. 사진 없이도 저장할 수 있습니다.'
                : '사진을 가져오지 못했습니다. 다시 시도해 주세요.',
          );
        case PhotoCancelled():
          break;
      }
    } catch (_) {
      if (mounted) _notice('사진을 읽지 못했습니다. 다시 선택해 주세요.');
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
      title: Text(widget.pet == null ? '반려동물 추가' : '반려동물 수정'),
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
                  label: '반려동물 사진',
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
                const Text('선택한 사진은 반려동물 프로필에 표시됩니다.'),
                TextFormField(
                  controller: _name,
                  maxLength: 30,
                  decoration: const InputDecoration(labelText: '이름'),
                  validator: (value) => value == null || value.trim().isEmpty
                      ? '이름을 입력해 주세요.'
                      : null,
                ),
                DropdownButtonFormField<PetSpecies>(
                  initialValue: _species,
                  decoration: const InputDecoration(labelText: '종류'),
                  items: const [
                    DropdownMenuItem(value: PetSpecies.cat, child: Text('고양이')),
                    DropdownMenuItem(value: PetSpecies.dog, child: Text('강아지')),
                  ],
                  onChanged: (value) {
                    if (value != null) setState(() => _species = value);
                  },
                ),
                TextFormField(
                  controller: _age,
                  keyboardType: TextInputType.number,
                  inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                  decoration: const InputDecoration(labelText: '나이 (개월, 선택)'),
                  validator: (value) {
                    if (value == null || value.isEmpty) return null;
                    final age = int.tryParse(value);
                    return age == null || age < 0
                        ? '0 이상의 개월 수를 입력해 주세요.'
                        : null;
                  },
                ),
                DropdownButtonFormField<PetSex?>(
                  initialValue: _sex,
                  decoration: const InputDecoration(labelText: '성별 (선택)'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('미입력')),
                    DropdownMenuItem(value: PetSex.female, child: Text('암컷')),
                    DropdownMenuItem(value: PetSex.male, child: Text('수컷')),
                    DropdownMenuItem(value: PetSex.unknown, child: Text('모름')),
                  ],
                  onChanged: (value) => setState(() => _sex = value),
                ),
                TextFormField(
                  controller: _weight,
                  keyboardType: const TextInputType.numberWithOptions(
                    decimal: true,
                  ),
                  decoration: const InputDecoration(labelText: '체중 (kg, 선택)'),
                  validator: (value) {
                    if (value == null || value.trim().isEmpty) return null;
                    final weight = double.tryParse(value);
                    return weight == null || !weight.isFinite || weight <= 0
                        ? '0보다 큰 체중을 입력해 주세요.'
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
          child: const Text('취소'),
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
                      _notice(failure.message);
                    }
                  },
            child: const Text('저장'),
          ),
        ),
      ],
    );
  }
}
