import 'package:json_annotation/json_annotation.dart';
import '../domain/pet.dart';
part 'pet_dto.g.dart';

/// Photo bytes are deliberately not serialized; durable storage is not wired.
@JsonSerializable(checked: true)
class PetDto {
  const PetDto({
    required this.id,
    required this.name,
    required this.species,
    this.ageMonths,
    this.sex,
    this.weightKg,
  });
  factory PetDto.fromJson(Map<String, dynamic> json) => _$PetDtoFromJson(json);
  factory PetDto.fromDomain(Pet pet) => PetDto(
    id: pet.id,
    name: pet.name,
    species: pet.species,
    ageMonths: pet.profile.ageMonths,
    sex: pet.profile.sex,
    weightKg: pet.profile.weightKg,
  );
  final String id;
  final String name;
  final PetSpecies species;
  final int? ageMonths;
  final PetSex? sex;
  final double? weightKg;
  Map<String, dynamic> toJson() => _$PetDtoToJson(this);
  Pet toDomain() => Pet(
    id: id,
    name: name,
    species: species,
    profile: PetProfile(ageMonths: ageMonths, sex: sex, weightKg: weightKg),
  );
}
