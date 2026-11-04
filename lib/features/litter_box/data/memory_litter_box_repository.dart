import 'dart:typed_data';
import 'package:hareup_core/core.dart';
import '../domain/litter_box.dart';

/// Development data is temporary and is not shared or persisted.
class MemoryLitterBoxRepository implements LitterBoxRepository {
  final _items = <String, LitterBox>{};
  @override
  Future<Result<void>> delete(String id) async => _items.remove(id) == null
      ? const Failure(NotFoundFailure())
      : const Success(null);
  @override
  Future<Result<void>> rename(String id, String name) async {
    final box = _items[id];
    if (box == null) return const Failure(NotFoundFailure());
    if (name.trim().isEmpty || name.trim().length > 30) {
      return const Failure(RequestFailure());
    }
    _items[id] = LitterBox(
      id: box.id,
      name: name.trim(),
      catIds: box.catIds,
      baselines: box.baselines,
      widthCm: box.widthCm,
      lengthCm: box.lengthCm,
      litterHeightCm: box.litterHeightCm,
    );
    return const Success(null);
  }

  @override
  Future<Result<List<LitterBox>>> list() async =>
      Success(List.unmodifiable(_items.values));
  @override
  Future<Result<void>> create(LitterBox box) async {
    if (_items.containsKey(box.id) || box.baselines.isEmpty) {
      return const Failure(RequestFailure());
    }
    _items[box.id] = box;
    return const Success(null);
  }

  @override
  Future<Result<void>> replaceBaseline(
    String id,
    Uint8List photo,
    DateTime time,
  ) async {
    final box = _items[id];
    if (box == null) return const Failure(NotFoundFailure());
    if (photo.isEmpty) return const Failure(RequestFailure());
    _items[id] = LitterBox(
      id: box.id,
      name: box.name,
      catIds: box.catIds,
      widthCm: box.widthCm,
      lengthCm: box.lengthCm,
      litterHeightCm: box.litterHeightCm,
      baselines: [
        ...box.baselines,
        LitterBaseline(
          version: box.currentBaseline.version + 1,
          createdAt: time,
          photo: photo,
        ),
      ],
    );
    return const Success(null);
  }
}
