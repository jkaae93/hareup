import 'package:hareup_core/core.dart';

class FamilyMember {
  const FamilyMember({
    required this.id,
    required this.displayName,
    this.roleLabel,
  });
  final String id;
  final String displayName;
  final String? roleLabel;
}

class FamilyGroup {
  const FamilyGroup({required this.id, required this.name});
  final String id;
  final String name;
}

class FamilyJoinRequest {
  const FamilyJoinRequest({required this.id, required this.displayName});
  final String id;
  final String displayName;
}

/// Permissions and pending requests are returned by the trusted backend.
class FamilyOverview {
  FamilyOverview({
    required this.groupId,
    required this.groupName,
    required List<FamilyMember> members,
    required List<FamilyJoinRequest> joinRequests,
    required this.canCreateInviteCode,
    required this.canApproveJoinRequests,
    required Set<String> removableMemberIds,
  }) : members = List.unmodifiable(members),
       joinRequests = List.unmodifiable(joinRequests),
       removableMemberIds = Set.unmodifiable(removableMemberIds);

  final String groupId;
  final String groupName;
  final List<FamilyMember> members;
  final List<FamilyJoinRequest> joinRequests;
  final bool canCreateInviteCode;
  final bool canApproveJoinRequests;
  final Set<String> removableMemberIds;
}

abstract interface class FamilyRepository {
  Future<Result<String>> createFamily(String name);
  Future<Result<List<FamilyGroup>>> listMyFamilies();
  Future<Result<String>> getJoinStatus(String groupId);
  Future<Result<FamilyOverview>> getOverview(String groupId);
  Future<Result<String>> createInviteCode(String groupId);
  Future<Result<String>> requestToJoin(String inviteCode);
  Future<Result<void>> approveJoinRequest({
    required String groupId,
    required String requestId,
  });
  Future<Result<void>> removeMember({
    required String groupId,
    required String memberId,
  });
}
