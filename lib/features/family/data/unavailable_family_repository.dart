import 'package:hareup_core/core.dart';
import '../domain/family.dart';

/// Active until Firebase Auth, Functions, and the family data contract exist.
class UnavailableFamilyRepository implements FamilyRepository {
  const UnavailableFamilyRepository();
  static const _failure = RequestFailure(
    '가족 공유는 계정과 서버 연결 후 사용할 수 있습니다.',
    FailureMessageKeys.familyUnavailable,
  );

  @override
  Future<Result<String>> createFamily(String name) async =>
      const Failure(_failure);
  @override
  Future<Result<List<FamilyGroup>>> listMyFamilies() async =>
      const Failure(_failure);
  @override
  Future<Result<String>> getJoinStatus(String groupId) async =>
      const Failure(_failure);
  @override
  Future<Result<FamilyOverview>> getOverview(String groupId) async =>
      const Failure(_failure);
  @override
  Future<Result<String>> createInviteCode(String groupId) async =>
      const Failure(_failure);
  @override
  Future<Result<String>> requestToJoin(String inviteCode) async =>
      const Failure(_failure);
  @override
  Future<Result<void>> approveJoinRequest({
    required String groupId,
    required String requestId,
  }) async => const Failure(_failure);
  @override
  Future<Result<void>> removeMember({
    required String groupId,
    required String memberId,
  }) async => const Failure(_failure);
}
