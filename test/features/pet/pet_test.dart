import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup/features/pet/data/memory_pet_repository.dart';
import 'package:hareup/features/pet/data/pet_dto.dart';
import 'package:hareup/features/pet/domain/pet.dart';
import 'package:hareup/features/pet/presentation/pet_cubit.dart';
import 'package:hareup_presentation_core/presentation_core.dart';

void main() {
  test('DTO round trips and rejects invalid JSON', () {
    const pet = Pet(id: '1', name: '나비', species: PetSpecies.cat);
    final restored = PetDto.fromJson(
      PetDto.fromDomain(pet).toJson(),
    ).toDomain();
    expect(restored.name, pet.name);
    expect(restored.species, pet.species);
    expect(
      () => PetDto.fromJson({'id': '1', 'species': 'cat'}),
      throwsA(isA<Exception>()),
    );
  });
  test(
    'profile fields survive JSON round trip and invalid values are rejected',
    () async {
      const pet = Pet(
        id: '1',
        name: '나비',
        species: PetSpecies.cat,
        profile: PetProfile(ageMonths: 18, sex: PetSex.female, weightKg: 4.2),
      );
      final restored = PetDto.fromJson(
        PetDto.fromDomain(pet).toJson(),
      ).toDomain();
      expect(restored.profile.ageMonths, 18);
      expect(restored.profile.sex, PetSex.female);
      expect(restored.profile.weightKg, 4.2);
      final cubit = PetCubit(MemoryPetRepository());
      expect(
        await cubit.save(
          name: '나비',
          species: PetSpecies.cat,
          profile: const PetProfile(weightKg: -1),
        ),
        isFalse,
      );
      expect(
        await cubit.save(
          name: '나비',
          species: PetSpecies.cat,
          profile: const PetProfile(ageMonths: -1),
        ),
        isFalse,
      );
      await cubit.close();
    },
  );
  test('repository failures reach loading and action states', () async {
    final cubit = PetCubit(const FailingPetRepository());
    await cubit.load();
    expect((cubit.state as Failed<List<Pet>>).failure, isA<NetworkFailure>());
    expect(await cubit.save(name: '나비', species: PetSpecies.cat), isFalse);
    expect(
      (cubit.saveCommand.state as CommandFailure<void>).failure,
      isA<NetworkFailure>(),
    );
    expect(
      await cubit.remove(
        const Pet(id: '1', name: '나비', species: PetSpecies.cat),
      ),
      isFalse,
    );
    expect(
      (cubit.deleteCommand.state as CommandFailure<void>).failure,
      isA<NetworkFailure>(),
    );
    await cubit.close();
  });
  test('pet cubit validates, updates and removes pets', () async {
    final cubit = PetCubit(MemoryPetRepository());
    await cubit.load();
    expect(cubit.state, isA<Empty<List<Pet>>>());
    expect(await cubit.save(name: '  ', species: PetSpecies.cat), false);
    expect(await cubit.save(name: ' 나비 ', species: PetSpecies.cat), true);
    final pet = (cubit.state as Loaded<List<Pet>>).data.single;
    expect(pet.name, '나비');
    await cubit.save(original: pet, name: '두부', species: PetSpecies.dog);
    expect((cubit.state as Loaded<List<Pet>>).data.single.name, '두부');
    await cubit.remove(pet);
    expect(cubit.state, isA<Empty<List<Pet>>>());
    await cubit.close();
  });
}

class FailingPetRepository implements PetRepository {
  const FailingPetRepository();

  @override
  Future<Result<List<Pet>>> list() async =>
      const Result.failure(NetworkFailure());

  @override
  Future<Result<void>> save(Pet pet) async =>
      const Result.failure(NetworkFailure());

  @override
  Future<Result<void>> delete(String id) async =>
      const Result.failure(NetworkFailure());
}
