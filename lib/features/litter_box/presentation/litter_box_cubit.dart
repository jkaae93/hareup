import 'dart:typed_data';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../domain/litter_box.dart';

class LitterBoxCubit extends LoadCubit<List<LitterBox>> {
  LitterBoxCubit(this.repository) {
    createCommand = Command1<void, LitterBox>(repository.create);
    deleteCommand = Command1<void, String>(repository.delete);
    renameCommand = Command1<void, (String, String)>(
      (input) => repository.rename(input.$1, input.$2),
    );
    baselineCommand = Command1<void, (String, Uint8List, DateTime)>(
      (input) => repository.replaceBaseline(input.$1, input.$2, input.$3),
    );
  }
  final LitterBoxRepository repository;
  late final Command1<void, LitterBox> createCommand;
  late final Command1<void, String> deleteCommand;
  late final Command1<void, (String, String)> renameCommand;
  late final Command1<void, (String, Uint8List, DateTime)> baselineCommand;
  int _sequence = 0;
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
    required List<String> catIds,
    required Uint8List photo,
    required bool isAutomatic,
    double? widthCm,
    double? lengthCm,
    double? litterHeightCm,
  }) async {
    bool invalid(double? value) =>
        value != null && (!value.isFinite || value <= 0);
    final trimmed = name.trim();
    if (isAutomatic ||
        trimmed.isEmpty ||
        catIds.isEmpty ||
        photo.isEmpty ||
        invalid(widthCm) ||
        invalid(lengthCm) ||
        invalid(litterHeightCm) ||
        createCommand.state is CommandRunning<void>) {
      return false;
    }
    final now = DateTime.now().toUtc();
    await createCommand.execute(
      LitterBox(
        id: '${now.microsecondsSinceEpoch}-${_sequence++}',
        name: trimmed,
        catIds: catIds,
        widthCm: widthCm,
        lengthCm: lengthCm,
        litterHeightCm: litterHeightCm,
        baselines: [LitterBaseline(version: 1, createdAt: now, photo: photo)],
      ),
    );
    if (isClosed || createCommand.state is! CommandSuccess<void>) return false;
    await load();
    return true;
  }

  Future<bool> changeBaseline(String id, Uint8List photo) async {
    if (photo.isEmpty || baselineCommand.state is CommandRunning<void>) {
      return false;
    }
    await baselineCommand.execute((id, photo, DateTime.now().toUtc()));
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
