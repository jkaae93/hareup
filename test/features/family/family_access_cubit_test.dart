import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/features/family/domain/family.dart';
import 'package:hareup/features/family/presentation/family_access_cubit.dart';
import 'package:hareup_core/core.dart';

class _FamilyRepository implements FamilyRepository {
  int listCalls = 0;

  @override
  Future<Result<String>> createFamily(String name) async =>
      const Success('new-family');

  @override
  Future<Result<List<FamilyGroup>>> listMyFamilies() async {
    listCalls++;
    return const Failure(ServerFailure('internal'));
  }

  @override
  Future<Result<String>> getJoinStatus(String groupId) async =>
      const Success('none');

  @override
  Future<Result<FamilyOverview>> getOverview(String groupId) async =>
      throw UnimplementedError();

  @override
  Future<Result<String>> createInviteCode(String groupId) async =>
      throw UnimplementedError();

  @override
  Future<Result<String>> requestToJoin(String inviteCode) async =>
      throw UnimplementedError();

  @override
  Future<Result<void>> approveJoinRequest({
    required String groupId,
    required String requestId,
  }) async => throw UnimplementedError();

  @override
  Future<Result<void>> removeMember({
    required String groupId,
    required String memberId,
  }) async => throw UnimplementedError();
}

void main() {
  test(
    'family creation does not wait for a separate family-list request',
    () async {
      final repository = _FamilyRepository();
      final cubit = FamilyAccessCubit(repository);

      expect(await cubit.createFamily('우리 가족'), 'new-family');
      expect(repository.listCalls, 0);
      expect(cubit.state.families, hasLength(1));
      expect(cubit.state.families.single.id, 'new-family');
      expect(cubit.state.families.single.name, '우리 가족');
      expect(cubit.state.failureMessage, isNull);

      await cubit.close();
    },
  );
}
