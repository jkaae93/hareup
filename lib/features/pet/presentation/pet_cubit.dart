import 'package:hareup_presentation_core/presentation_core.dart';

import '../domain/pet.dart';

class PetCubit extends LoadCubit<List<Pet>> {
  PetCubit(this.repository) {
    saveCommand = Command1<void, Pet>(repository.save);
    deleteCommand = Command1<void, String>(repository.delete);
  }

  final PetRepository repository;
  late final Command1<void, Pet> saveCommand;
  late final Command1<void, String> deleteCommand;
  int _sequence = 0;

  Future<void> load() =>
      loadResult(repository.list, isEmpty: (pets) => pets.isEmpty);

  Future<bool> save({
    Pet? original,
    required String name,
    required PetSpecies species,
    PetProfile? profile,
  }) async {
    final trimmed = name.trim();
    final nextProfile = profile ?? original?.profile ?? const PetProfile();
    if (trimmed.isEmpty ||
        (nextProfile.ageMonths != null && nextProfile.ageMonths! < 0) ||
        (nextProfile.weightKg != null &&
            (!nextProfile.weightKg!.isFinite || nextProfile.weightKg! <= 0)) ||
        saveCommand.state is CommandRunning<void>) {
      return false;
    }
    await saveCommand.execute(
      Pet(
        id:
            original?.id ??
            '${DateTime.now().microsecondsSinceEpoch}-${_sequence++}',
        name: trimmed,
        species: species,
        profile: nextProfile,
      ),
    );
    if (isClosed || saveCommand.state is! CommandSuccess<void>) return false;
    await load();
    return true;
  }

  Future<bool> remove(Pet pet) async {
    if (deleteCommand.state is CommandRunning<void>) return false;
    await deleteCommand.execute(pet.id);
    if (isClosed || deleteCommand.state is! CommandSuccess<void>) return false;
    await load();
    return true;
  }

  @override
  Future<void> close() async {
    await Future.wait([saveCommand.close(), deleteCommand.close()]);
    await super.close();
  }
}
