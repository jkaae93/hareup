import 'dart:typed_data';
import 'package:hareup_core/core.dart';

typedef LitterBaseline = PhotoBaseline;

class LitterBox {
  LitterBox({
    required this.id,
    required this.name,
    required List<String> catIds,
    required List<LitterBaseline> baselines,
    this.widthCm,
    this.lengthCm,
    this.litterHeightCm,
  }) : catIds = List.unmodifiable(catIds),
       baselines = List.unmodifiable(baselines);
  final String id;
  final String name;
  final List<String> catIds;
  final List<LitterBaseline> baselines;
  final double? widthCm;
  final double? lengthCm;
  final double? litterHeightCm;
  LitterBaseline get currentBaseline => baselines.last;
}

class CatOption {
  const CatOption({required this.id, required this.name});
  final String id;
  final String name;
}

abstract interface class LitterBoxRepository {
  Future<Result<List<LitterBox>>> list();
  Future<Result<void>> create(LitterBox box);
  Future<Result<void>> rename(String id, String name);
  Future<Result<void>> delete(String id);
  Future<Result<void>> replaceBaseline(
    String id,
    Uint8List photo,
    DateTime time,
  );
}
