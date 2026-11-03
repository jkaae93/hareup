// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'pet_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

PetDto _$PetDtoFromJson(Map<String, dynamic> json) =>
    $checkedCreate('PetDto', json, ($checkedConvert) {
      final val = PetDto(
        id: $checkedConvert('id', (v) => v as String),
        name: $checkedConvert('name', (v) => v as String),
        species: $checkedConvert(
          'species',
          (v) => $enumDecode(_$PetSpeciesEnumMap, v),
        ),
        ageMonths: $checkedConvert('ageMonths', (v) => (v as num?)?.toInt()),
        sex: $checkedConvert(
          'sex',
          (v) => $enumDecodeNullable(_$PetSexEnumMap, v),
        ),
        weightKg: $checkedConvert('weightKg', (v) => (v as num?)?.toDouble()),
      );
      return val;
    });

Map<String, dynamic> _$PetDtoToJson(PetDto instance) => <String, dynamic>{
  'id': instance.id,
  'name': instance.name,
  'species': _$PetSpeciesEnumMap[instance.species]!,
  'ageMonths': instance.ageMonths,
  'sex': _$PetSexEnumMap[instance.sex],
  'weightKg': instance.weightKg,
};

const _$PetSpeciesEnumMap = {PetSpecies.cat: 'cat', PetSpecies.dog: 'dog'};

const _$PetSexEnumMap = {
  PetSex.female: 'female',
  PetSex.male: 'male',
  PetSex.unknown: 'unknown',
};
