import 'dart:typed_data';
import 'package:hareup_core/core.dart';
import 'water_level.dart';

typedef WaterBaseline = PhotoBaseline;

class WaterBowl {
  WaterBowl({
    required this.id,
    required this.name,
    required List<String> petIds,
    required List<WaterBaseline> baselines,
    Map<String, Uint8List> registrationPhotos = const {},
    this.emptyWeightGrams,
    this.fullWaterMl,
    this.levelProfile,
  }) : registrationPhotos = Map.unmodifiable(
         registrationPhotos.map(
           (key, value) => MapEntry(key, Uint8List.fromList(value)),
         ),
       ),
       petIds = List.unmodifiable(petIds),
       baselines = List.unmodifiable(baselines);
  final String id;
  final String name;
  final List<String> petIds;
  final List<WaterBaseline> baselines;
  final Map<String, Uint8List> registrationPhotos;
  final double? emptyWeightGrams;
  final double? fullWaterMl;
  final WaterLevelProfile? levelProfile;
  WaterBaseline get currentBaseline => baselines.last;
}

class BowlPetOption {
  const BowlPetOption({required this.id, required this.name});
  final String id;
  final String name;
}

abstract interface class WaterBowlRepository {
  Future<Result<List<WaterBowl>>> list();
  Future<Result<void>> create(WaterBowl bowl);
  Future<Result<void>> rename(String id, String name);
  Future<Result<void>> delete(String id);
  Future<Result<void>> replaceBaseline(
    String bowlId,
    Uint8List photo,
    DateTime createdAt, {
    String notes = '',
  });
}
