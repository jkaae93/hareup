import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter/widget_previews.dart';
import 'package:hareup_core/core.dart';
import '../domain/family.dart';
import 'family_page.dart';

class _PreviewFamily implements FamilyRepository {
  @override
  Future<Result<String>> createFamily(String name) async =>
      const Failure(RequestFailure('미리보기에서는 가족을 만들 수 없습니다.'));
  @override
  Future<Result<List<FamilyGroup>>> listMyFamilies() async =>
      const Success([FamilyGroup(id: 'preview', name: '우리 가족')]);
  @override
  Future<Result<String>> getJoinStatus(String groupId) async =>
      const Success('pending');
  @override
  Future<Result<FamilyOverview>> getOverview(String groupId) async => Success(
    FamilyOverview(
      groupId: groupId,
      groupName: '우리 가족',
      members: const [FamilyMember(id: '1', displayName: '보호자')],
      joinRequests: const [
        FamilyJoinRequest(id: 'request-1', displayName: '새 보호자'),
      ],
      canCreateInviteCode: true,
      canApproveJoinRequests: true,
      removableMemberIds: const {},
    ),
  );
  @override
  Future<Result<String>> createInviteCode(String groupId) async =>
      const Failure(RequestFailure('미리보기에서는 코드를 만들 수 없습니다.'));
  @override
  Future<Result<String>> requestToJoin(String inviteCode) async =>
      const Failure(RequestFailure());
  @override
  Future<Result<void>> approveJoinRequest({
    required String groupId,
    required String requestId,
  }) async => const Failure(RequestFailure());
  @override
  Future<Result<void>> removeMember({
    required String groupId,
    required String memberId,
  }) async => const Failure(RequestFailure());
}

@Preview(name: '가족 관리', group: '가족')
Widget familyPreview() => MaterialApp(
  theme: HareupTheme.light,
  home: FamilyPage(repository: _PreviewFamily(), groupId: 'preview'),
);
