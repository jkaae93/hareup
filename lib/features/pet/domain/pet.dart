import 'dart:typed_data';
import 'package:hareup_core/core.dart';

enum PetSpecies { cat, dog }

enum PetSex { female, male, unknown }

class PetProfile {
  const PetProfile({this.ageMonths, this.sex, this.weightKg, this.photoBytes});
  final int? ageMonths;
  final PetSex? sex;
  final double? weightKg;

  /// Temporary in-memory preview only; a durable photo needs a storage contract.
  final Uint8List? photoBytes;
}

class Pet {
  const Pet({
    required this.id,
    required this.name,
    required this.species,
    this.profile = const PetProfile(),
  });
  final String id;
  final String name;
  final PetSpecies species;
  final PetProfile profile;
}

abstract interface class PetRepository {
  Future<Result<List<Pet>>> list();
  Future<Result<void>> save(Pet pet);
  Future<Result<void>> delete(String id);
}
