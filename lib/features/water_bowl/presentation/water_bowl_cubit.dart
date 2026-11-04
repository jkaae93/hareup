import 'dart:typed_data';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../domain/water_bowl.dart';

class WaterBowlCubit extends LoadCubit<List<WaterBowl>> {
  WaterBowlCubit(this.repository) {
    createCommand = Command1<void, WaterBowl>(repository.create);
    deleteCommand = Command1<void, String>(repository.delete);
    renameCommand = Command1<void, (String, String)>(
      (input) => repository.rename(input.$1, input.$2),
    );
    baselineCommand = Command1<void, (String, Uint8List, DateTime, String)>(
      (input) => repository.replaceBaseline(
        input.$1,
        input.$2,
        input.$3,
        notes: input.$4,
      ),
    );
  }
  final WaterBowlRepository repository;
  late final Command1<void, WaterBowl> createCommand;
  late final Command1<void, String> deleteCommand;
  late final Command1<void, (String, String)> renameCommand;
  late final Command1<void, (String, Uint8List, DateTime, String)>
  baselineCommand;
  int _sequence = 0;
  WaterBowl? lastCreated;
  Future<void> load() =>
      loadResult(repository.list, isEmpty: (items) => items.isEmpty);

  Future<bool> remove(String id) async {
    if (deleteCommand.state is CommandRunning<void>) return false;
    await deleteCommand.execute(id);
    if (isClosed || deleteCommand.state is! CommandSuccess<void>) return false;
    await load();
    return true;
  }

  Future<bool> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        trimmed.length > 30 ||
        renameCommand.state is CommandRunning<void>) {
      return false;
    }
    await renameCommand.execute((id, trimmed));
    if (isClosed || renameCommand.state is! CommandSuccess<void>) return false;
    await load();
    return true;
  }

  Future<bool> create({
    required String name,
    required List<String> petIds,
    required Uint8List photo,
    Map<String, Uint8List> registrationPhotos = const {},
    double? emptyWeightGrams,
    double? fullWaterMl,
    String notes = '',
  }) async {
    bool invalid(double? value) =>
        value != null && (!value.isFinite || value <= 0);
    final trimmed = name.trim();
    if (trimmed.isEmpty ||
        petIds.isEmpty ||
        photo.isEmpty ||
        invalid(emptyWeightGrams) ||
        invalid(fullWaterMl) ||
        createCommand.state is CommandRunning<void>) {
      return false;
    }
    final now = DateTime.now().toUtc();
    final item = WaterBowl(
      id: '${now.microsecondsSinceEpoch}-${_sequence++}',
      name: trimmed,
      petIds: petIds,
      emptyWeightGrams: emptyWeightGrams,
      fullWaterMl: fullWaterMl,
      registrationPhotos: registrationPhotos,
      baselines: [
        WaterBaseline(
          version: 1,
          createdAt: now,
          photo: photo,
          notes: notes.trim(),
        ),
      ],
    );
    await createCommand.execute(item);
    if (isClosed || createCommand.state is! CommandSuccess<void>) return false;
    lastCreated = item;
    await load();
    return true;
  }

  Future<bool> changeBaseline(
    String id,
    Uint8List photo, {
    String notes = '',
  }) async {
    if (photo.isEmpty || baselineCommand.state is CommandRunning<void>) {
      return false;
    }
    await baselineCommand.execute((
      id,
      photo,
      DateTime.now().toUtc(),
      notes.trim(),
    ));
    if (isClosed || baselineCommand.state is! CommandSuccess<void>) {
      return false;
    }
    await load();
    return true;
  }

  @override
  Future<void> close() async {
    await Future.wait([
      createCommand.close(),
      baselineCommand.close(),
      renameCommand.close(),
      deleteCommand.close(),
    ]);
    await super.close();
  }
}
