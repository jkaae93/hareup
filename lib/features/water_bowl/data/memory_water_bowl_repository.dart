import 'dart:typed_data';
import 'package:hareup_core/core.dart';
import '../domain/water_bowl.dart';

/// Development-only implementation. Its contents are not persisted or shared.
class MemoryWaterBowlRepository implements WaterBowlRepository {
  final _items = <String, WaterBowl>{};
  @override
  Future<Result<List<WaterBowl>>> list() async =>
      Success(List.unmodifiable(_items.values));
  @override
  Future<Result<void>> create(WaterBowl bowl) async {
    if (_items.containsKey(bowl.id) || bowl.baselines.isEmpty) {
      return const Failure(RequestFailure());
    }
    _items[bowl.id] = bowl;
    return const Success(null);
  }

  @override
  Future<Result<void>> replaceBaseline(
    String bowlId,
    Uint8List photo,
    DateTime createdAt, {
    String notes = '',
  }) async {
    final bowl = _items[bowlId];
    if (bowl == null) return const Failure(NotFoundFailure());
    if (photo.isEmpty) return const Failure(RequestFailure());
    _items[bowlId] = WaterBowl(
      id: bowl.id,
      name: bowl.name,
      petIds: bowl.petIds,
      emptyWeightGrams: bowl.emptyWeightGrams,
      fullWaterMl: bowl.fullWaterMl,
      levelProfile: bowl.levelProfile,
      registrationPhotos: bowl.registrationPhotos,
      baselines: [
        ...bowl.baselines,
        WaterBaseline(
          version: bowl.currentBaseline.version + 1,
          createdAt: createdAt,
          photo: photo,
          notes: notes,
        ),
      ],
    );
    return const Success(null);
  }
}
