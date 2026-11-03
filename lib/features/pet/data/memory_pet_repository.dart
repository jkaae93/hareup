import 'package:hareup_core/core.dart';

import '../domain/pet.dart';

/// Volatile development repository; no data is persisted or shared.
class MemoryPetRepository implements PetRepository {
  final List<Pet> _pets = [];
  @override
  Future<Result<List<Pet>>> list() async =>
      Result.success(List.unmodifiable(_pets));
  @override
  Future<Result<void>> save(Pet pet) async {
    final index = _pets.indexWhere((item) => item.id == pet.id);
    if (index < 0) {
      _pets.add(pet);
    } else {
      _pets[index] = pet;
    }
    return const Result.success(null);
  }

  @override
  Future<Result<void>> delete(String id) async {
    _pets.removeWhere((pet) => pet.id == id);
    return const Result.success(null);
  }
}
