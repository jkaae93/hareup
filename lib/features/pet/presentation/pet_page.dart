import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../domain/pet.dart';
import 'pet_cubit.dart';
import 'pet_editor.dart';

class PetPage extends StatelessWidget {
  const PetPage({super.key});
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('반려동물 관리')),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(context),
      icon: const Icon(Icons.add),
      label: const Text('반려동물 추가'),
    ),
    body: HareupContent(
      child: BlocBuilder<PetCubit, LoadState<List<Pet>>>(
        builder: (context, state) => LoadView<List<Pet>>(
          state: state,
          emptyMessage: '등록된 반려동물이 없습니다.\n반려동물을 추가해 주세요.',
          onRetry: () => context.read<PetCubit>().load(),
          builder: (context, data) => ListView.builder(
            padding: const EdgeInsets.fromLTRB(
              HareupSpacing.pageMargin,
              HareupSpacing.small,
              HareupSpacing.pageMargin,
              HareupSpacing.floatingActionClearance,
            ),
            itemCount: data.length,
            itemBuilder: (context, index) {
              final pet = data[index];
              return Card(
                child: ListTile(
                  leading: CircleAvatar(
                    foregroundImage: pet.profile.photoBytes == null
                        ? null
                        : MemoryImage(pet.profile.photoBytes!),
                    child: Icon(
                      pet.species == PetSpecies.cat
                          ? Icons.pets
                          : Icons.cruelty_free,
                    ),
                  ),
                  title: Text(pet.name),
                  subtitle: Text(
                    [
                      pet.species == PetSpecies.cat ? '고양이' : '강아지',
                      if (pet.profile.ageMonths case final age?) '$age개월',
                      if (pet.profile.weightKg case final weight?) '$weight kg',
                      if (pet.profile.sex case final sex?)
                        switch (sex) {
                          PetSex.female => '암컷',
                          PetSex.male => '수컷',
                          PetSex.unknown => '성별 모름',
                        },
                    ].join(' · '),
                  ),
                  onTap: () => _edit(context, pet),
                  trailing: IconButton(
                    tooltip: '삭제',
                    icon: const Icon(Icons.delete_outline),
                    onPressed: () => _delete(context, pet),
                  ),
                ),
              );
            },
          ),
        ),
      ),
    ),
  );

  Future<void> _edit(BuildContext context, [Pet? pet]) {
    final cubit = context.read<PetCubit>();
    return Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => BlocProvider.value(
          value: cubit,
          child: PetEditor(pet: pet, photoSource: PhotoPicker()),
        ),
      ),
    );
  }

  Future<void> _delete(BuildContext context, Pet pet) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        title: Text('${pet.name} 삭제'),
        content: const Text('반려동물을 삭제하시겠어요? 연결된 기록의 보관 정책은 아직 정해지지 않았습니다.'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('취소'),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('삭제'),
          ),
        ],
      ),
    );
    if (confirmed == true && context.mounted) {
      final cubit = context.read<PetCubit>();
      final removed = await cubit.remove(pet);
      if (!removed && context.mounted) {
        if (cubit.deleteCommand.state case CommandFailure<void>(
          :final failure,
        )) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(failure.message)));
        }
      }
    }
  }
}
