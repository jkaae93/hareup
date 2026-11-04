import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../../app/failure_messages.dart';
import '../../../l10n/l10n.dart';
import '../domain/pet.dart';
import 'pet_cubit.dart';
import 'pet_editor.dart';
import 'pet_detail_page.dart';
import '../../water_bowl/domain/water_bowl.dart';
import '../../litter_box/domain/litter_box.dart';
import '../../photo_analysis/domain/analysis.dart';
import '../../records/domain/record.dart';

class PetPage extends StatelessWidget {
  const PetPage({
    super.key,
    required this.waterRepository,
    required this.litterRepository,
    required this.recordsRepository,
    required this.runtime,
  });
  final WaterBowlRepository waterRepository;
  final LitterBoxRepository litterRepository;
  final RecordsRepository recordsRepository;
  final AnalysisRuntime runtime;
  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: Text(context.l10n.petManageTitle)),
    floatingActionButton: FloatingActionButton.extended(
      onPressed: () => _edit(context),
      icon: const Icon(Icons.add),
      label: Text(context.l10n.petAddAction),
    ),
    body: HareupContent(
      child: BlocBuilder<PetCubit, LoadState<List<Pet>>>(
        builder: (context, state) => LoadView<List<Pet>>(
          state: state,
          emptyMessage: context.l10n.petEmptyMessage,
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
              return HareupCard(
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
                title: pet.name,
                subtitle: [
                  pet.species == PetSpecies.cat
                      ? context.l10n.petSpeciesCat
                      : context.l10n.petSpeciesDog,
                  if (pet.profile.ageMonths case final age?)
                    context.l10n.petAgeMonths(age),
                  if (pet.profile.weightKg case final weight?) '$weight kg',
                  if (pet.profile.sex case final sex?)
                    switch (sex) {
                      PetSex.female => context.l10n.petSexFemale,
                      PetSex.male => context.l10n.petSexMale,
                      PetSex.unknown => context.l10n.petSexUnknown,
                    },
                ].join(' · '),
                onTap: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PetDetailPage(
                      pet: pet,
                      waterRepository: waterRepository,
                      litterRepository: litterRepository,
                      recordsRepository: recordsRepository,
                      runtime: runtime,
                      onEdit: () {
                        Navigator.of(context).pop();
                        _edit(context, pet);
                      },
                    ),
                  ),
                ),
                trailing: IconButton(
                  tooltip: context.l10n.commonDelete,
                  icon: const Icon(Icons.delete_outline),
                  onPressed: () => _delete(context, pet),
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
        title: Text(context.l10n.targetDeleteTitle(pet.name)),
        content: Text(context.l10n.petDeleteMessage),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: Text(dialogContext.dsL10n.cancelAction),
          ),
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, true),
            child: Text(context.l10n.commonDelete),
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
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(failureDisplayMessage(context, failure))),
          );
        }
      }
    }
  }
}
