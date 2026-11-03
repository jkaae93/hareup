import 'package:hareup_presentation_core/presentation_core.dart';
import '../domain/settings.dart';

class SettingsCubit extends LoadCubit<SettingsInfo> {
  SettingsCubit(this.repository) {
    openCommand = Command1<void, Uri>(repository.openExternal);
  }
  final SettingsRepository repository;
  late final Command1<void, Uri> openCommand;
  Future<void> load() => loadResult(repository.load);
  @override
  Future<void> close() async {
    await openCommand.close();
    await super.close();
  }
}
