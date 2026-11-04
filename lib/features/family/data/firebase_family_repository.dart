import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:hareup_core/core.dart';

import '../domain/family.dart';

/// Family operations run through trusted Functions; membership data is never
/// writable directly from a client.
class FirebaseFamilyRepository implements FamilyRepository {
  FirebaseFamilyRepository({FirebaseFunctions? functions})
    : _functions =
          functions ?? FirebaseFunctions.instanceFor(region: 'us-central1');

  final FirebaseFunctions _functions;

  @override
  Future<Result<String>> createFamily(String name) async {
    try {
      final response = await _call('createFamily', {'name': name.trim()});
      return Success(_string(response['groupId']));
    } on FirebaseFunctionsException catch (error) {
      return Failure(_mapError(error));
    } on Object {
      return const Failure(SerializationFailure());
    }
  }

  @override
  Future<Result<List<FamilyGroup>>> listMyFamilies() async {
    try {
      final response = await _call('listMyFamilies', const {});
      final groups = _list(response['groups'])
          .map(
            (item) => FamilyGroup(
              id: _string(item['groupId']),
              name: _string(item['groupName']),
            ),
          )
          .toList(growable: false);
      return Success(groups);
    } on FirebaseFunctionsException catch (error) {
      return Failure(_mapError(error));
    } on Object {
      return const Failure(SerializationFailure());
    }
  }

  @override
  Future<Result<String>> getJoinStatus(String groupId) async {
    try {
      final response = await _call('getFamilyJoinStatus', {'groupId': groupId});
      return Success(_string(response['status']));
    } on FirebaseFunctionsException catch (error) {
      return Failure(_mapError(error));
    } on Object {
      return const Failure(SerializationFailure());
    }
  }

  @override
  Future<Result<FamilyOverview>> getOverview(String groupId) async {
    try {
      final response = await _call('getFamilyOverview', {'groupId': groupId});
      final members = _list(response['members'])
          .map(
            (item) => FamilyMember(
              id: _string(item['id']),
              displayName: _string(item['displayName']),
              roleLabel: item['roleLabel'] as String?,
            ),
          )
          .toList(growable: false);
      final requests = _list(response['joinRequests'])
          .map(
            (item) => FamilyJoinRequest(
              id: _string(item['id']),
              displayName: _string(item['displayName']),
            ),
          )
          .toList(growable: false);
      final overview = FamilyOverview(
        groupId: _string(response['groupId']),
        groupName: _string(response['groupName']),
        members: members,
        joinRequests: requests,
        canCreateInviteCode: response['canCreateInviteCode'] == true,
        canApproveJoinRequests: response['canApproveJoinRequests'] == true,
        removableMemberIds: _list(
          response['removableMemberIds'],
        ).cast<String>().toSet(),
      );
      if (overview.groupId != groupId) {
        return const Failure(AuthorizationFailure());
      }
      return Success(overview);
    } on FirebaseFunctionsException catch (error) {
      return Failure(_mapError(error));
    } on Object {
      return const Failure(SerializationFailure());
    }
  }

  @override
  Future<Result<String>> createInviteCode(String groupId) async {
    try {
      final response = await _call('createFamilyInviteCode', {
        'groupId': groupId,
      });
      return Success(_string(response['code']));
    } on FirebaseFunctionsException catch (error) {
      return Failure(_mapError(error));
    } on Object {
      return const Failure(SerializationFailure());
    }
  }

  @override
  Future<Result<String>> requestToJoin(String inviteCode) async {
    try {
      final response = await _call('requestFamilyJoin', {'code': inviteCode});
      return Success(_string(response['groupId']));
    } on FirebaseFunctionsException catch (error) {
      return Failure(_mapError(error));
    } on Object {
      return const Failure(SerializationFailure());
    }
  }

  @override
  Future<Result<void>> approveJoinRequest({
    required String groupId,
    required String requestId,
  }) => _callVoid('approveFamilyJoinRequest', {
    'groupId': groupId,
    'requestId': requestId,
  });

  @override
  Future<Result<void>> removeMember({
    required String groupId,
    required String memberId,
  }) => _callVoid('removeFamilyMember', {
    'groupId': groupId,
    'memberId': memberId,
  });

  Future<Result<void>> _callVoid(String name, Map<String, Object?> data) async {
    try {
      await _call(name, data);
      return const Success(null);
    } on FirebaseFunctionsException catch (error) {
      return Failure(_mapError(error));
    } on Object {
      return const Failure(ServerFailure());
    }
  }

  Future<Map<Object?, Object?>> _call(
    String name,
    Map<String, Object?> data,
  ) async {
    final result = await _functions
        .httpsCallable(name)
        .call<Map<Object?, Object?>>(data);
    return result.data;
  }

  static List<Map<Object?, Object?>> _list(Object? value) {
    if (value is! List) throw const FormatException('Expected list');
    return value
        .map((item) {
          if (item is! Map) throw const FormatException('Expected map');
          return item;
        })
        .toList(growable: false);
  }

  static String _string(Object? value) {
    if (value is! String || value.isEmpty) {
      throw const FormatException('Expected string');
    }
    return value;
  }

  static AppFailure _mapError(FirebaseFunctionsException error) =>
      switch (error.code) {
        'unauthenticated' ||
        'permission-denied' => const AuthorizationFailure(),
        'not-found' => const NotFoundFailure(),
        'invalid-argument' || 'already-exists' || 'failed-precondition' =>
          RequestFailure(error.message ?? '요청을 확인해 주세요.'),
        'unavailable' || 'deadline-exceeded' => const NetworkFailure(),
        'internal' => const ServerFailure(
          '가족 정보를 불러오지 못했습니다. 잠시 후 다시 시도해 주세요.',
          FailureMessageKeys.familyLoadFailed,
        ),
        _ => ServerFailure(
          error.message ?? '서버에 문제가 있습니다.',
          error.message == null ? FailureMessageKeys.familyServerError : null,
        ),
      };
}
