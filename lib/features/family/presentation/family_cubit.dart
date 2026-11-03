import 'package:hareup_core/core.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../domain/family.dart';

class FamilyCubit extends LoadCubit<FamilyOverview> {
  FamilyCubit(this.repository, this.groupId) {
    createCodeCommand = Command0<String>(
      () => repository.createInviteCode(groupId),
    );
    joinCommand = Command1<String, String>(repository.requestToJoin);
    approveCommand = Command1<void, String>(
      (requestId) =>
          repository.approveJoinRequest(groupId: groupId, requestId: requestId),
    );
    removeCommand = Command1<void, String>(
      (id) => repository.removeMember(groupId: groupId, memberId: id),
    );
  }

  final FamilyRepository repository;
  final String groupId;
  late final Command0<String> createCodeCommand;
  late final Command1<String, String> joinCommand;
  late final Command1<void, String> approveCommand;
  late final Command1<void, String> removeCommand;

  Future<void> load() => loadResult(() async {
    final result = await repository.getOverview(groupId);
    if (result case Success<FamilyOverview>(:final value)) {
      if (value.groupId != groupId) {
        return const Failure(AuthorizationFailure());
      }
    }
    return result;
  });

  Future<bool> createInviteCode() async {
    final overview = state;
    if (overview is! Loaded<FamilyOverview> ||
        !overview.data.canCreateInviteCode ||
        createCodeCommand.state is CommandRunning<String>) {
      return false;
    }
    await createCodeCommand.execute();
    return !isClosed && createCodeCommand.state is CommandSuccess<String>;
  }

  Future<String?> requestToJoin(String input) async {
    final code = input.trim().toUpperCase();
    if (!isValidInviteCode(code) ||
        joinCommand.state is CommandRunning<String>) {
      return null;
    }
    await joinCommand.execute(code);
    if (isClosed || joinCommand.state is! CommandSuccess<String>) {
      return null;
    }
    return (joinCommand.state as CommandSuccess<String>).value;
  }

  Future<bool> approve(String requestId) async {
    final overview = state;
    if (overview is! Loaded<FamilyOverview> ||
        !overview.data.canApproveJoinRequests ||
        !overview.data.joinRequests.any((request) => request.id == requestId) ||
        approveCommand.state is CommandRunning<void>) {
      return false;
    }
    await approveCommand.execute(requestId);
    if (isClosed || approveCommand.state is! CommandSuccess<void>) {
      return false;
    }
    await load();
    return true;
  }

  Future<bool> remove(String memberId) async {
    final overview = state;
    if (overview is! Loaded<FamilyOverview> ||
        !overview.data.removableMemberIds.contains(memberId) ||
        removeCommand.state is CommandRunning<void>) {
      return false;
    }
    await removeCommand.execute(memberId);
    if (isClosed || removeCommand.state is! CommandSuccess<void>) {
      return false;
    }
    await load();
    return true;
  }

  static bool isValidInviteCode(String value) =>
      RegExp(r'^[A-Z0-9]{6,12}$').hasMatch(value);

  @override
  Future<void> close() async {
    await Future.wait([
      createCodeCommand.close(),
      joinCommand.close(),
      approveCommand.close(),
      removeCommand.close(),
    ]);
    await super.close();
  }
}
