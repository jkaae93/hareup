import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:hareup/features/family/data/unavailable_family_repository.dart';
import 'package:hareup/features/family/domain/family.dart';
import 'package:hareup/features/family/presentation/family_cubit.dart';
import 'package:hareup/features/family/presentation/family_page.dart';
import 'package:hareup/features/family/presentation/family_access_page.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_presentation_core/presentation_core.dart';

class FakeFamilyRepository implements FamilyRepository {
  FakeFamilyRepository({this.allowed = true, this.returnedGroup = 'group-a'});
  bool allowed;
  String returnedGroup;
  int codesCreated = 0;
  int joinRequests = 0;
  int approvals = 0;
  int removals = 0;
  final requests = <FamilyJoinRequest>[
    const FamilyJoinRequest(id: 'request-1', displayName: '새 보호자'),
  ];

  @override
  Future<Result<FamilyOverview>> getOverview(String groupId) async => Success(
    FamilyOverview(
      groupId: returnedGroup,
      groupName: '우리 가족',
      members: const [FamilyMember(id: 'one', displayName: '나비 집사')],
      joinRequests: requests,
      canCreateInviteCode: allowed,
      canApproveJoinRequests: allowed,
      removableMemberIds: allowed ? {'one'} : {},
    ),
  );

  @override
  Future<Result<String>> createInviteCode(String groupId) async {
    codesCreated++;
    return const Success('AB12CD34');
  }

  @override
  Future<Result<String>> requestToJoin(String inviteCode) async {
    joinRequests++;
    return const Success('group-a');
  }

  @override
  Future<Result<String>> createFamily(String name) async =>
      const Success('group-a');

  @override
  Future<Result<List<FamilyGroup>>> listMyFamilies() async =>
      const Success([FamilyGroup(id: 'group-a', name: '우리 가족')]);

  @override
  Future<Result<String>> getJoinStatus(String groupId) async =>
      const Success('pending');

  @override
  Future<Result<void>> approveJoinRequest({
    required String groupId,
    required String requestId,
  }) async {
    approvals++;
    requests.removeWhere((request) => request.id == requestId);
    return const Success(null);
  }

  @override
  Future<Result<void>> removeMember({
    required String groupId,
    required String memberId,
  }) async {
    removals++;
    return const Success(null);
  }
}

void main() {
  test('enforces server capabilities and requested group identity', () async {
    final fake = FakeFamilyRepository(allowed: false);
    final cubit = FamilyCubit(fake, 'group-a');
    await cubit.load();
    expect(await cubit.createInviteCode(), isFalse);
    expect(await cubit.approve('request-1'), isFalse);
    expect(await cubit.remove('one'), isFalse);
    expect(await cubit.requestToJoin('bad-code'), isNull);
    expect(fake.codesCreated, 0);
    expect(fake.approvals, 0);
    expect(fake.removals, 0);
    expect(fake.joinRequests, 0);
    fake.returnedGroup = 'other-group';
    await cubit.load();
    expect(
      (cubit.state as Failed<FamilyOverview>).failure,
      isA<AuthorizationFailure>(),
    );
    await cubit.close();
  });

  test(
    'submits normalized code and only an authorized admin approves requests',
    () async {
      final fake = FakeFamilyRepository();
      final cubit = FamilyCubit(fake, 'group-a');
      await cubit.load();
      expect(await cubit.requestToJoin(' ab12cd34 '), 'group-a');
      expect(fake.joinRequests, 1);
      expect(await cubit.approve('unknown'), isFalse);
      expect(await cubit.approve('request-1'), isTrue);
      expect(fake.approvals, 1);
      expect(
        (cubit.state as Loaded<FamilyOverview>).data.joinRequests,
        isEmpty,
      );
      await cubit.close();
    },
  );

  testWidgets('unconfigured family service does not claim invitation success', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: testTheme,
        home: FamilyPage(
          repository: UnavailableFamilyRepository(),
          groupId: 'local-development',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('가족 공유는 계정과 서버 연결 후 사용할 수 있습니다.'), findsOneWidget);
  });

  testWidgets('family UI shows requests and asks backend for an invite code', (
    tester,
  ) async {
    final fake = FakeFamilyRepository();
    await tester.pumpWidget(
      MaterialApp(
        theme: testTheme,
        home: FamilyPage(repository: fake, groupId: 'group-a'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('나비 집사'), findsOneWidget);
    expect(find.text('새 보호자'), findsOneWidget);
    await tester.scrollUntilVisible(find.text('초대 코드 만들기'), 200);
    await tester.pumpAndSettle();
    await tester.tap(find.text('초대 코드 만들기'));
    await tester.pumpAndSettle();
    expect(find.text('AB12CD34'), findsOneWidget);
    expect(find.byType(AlertDialog), findsNothing);
    expect(fake.codesCreated, 1);
    await tester.tap(find.text('초대 코드 복사하기'));
    await tester.pumpAndSettle();
    expect(find.text('AB12CD34'), findsOneWidget);
    await tester.tap(find.text('닫기'));
    await tester.pumpAndSettle();
    expect(find.text('AB12CD34'), findsNothing);
  });

  testWidgets(
    'family creation and invite code are full pages with validation',
    (tester) async {
      final fake = FakeFamilyRepository();
      String? selected;
      await tester.pumpWidget(
        MaterialApp(
          theme: testTheme,
          home: FamilyAccessPage(
            repository: fake,
            onFamilySelected: (id) => selected = id,
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.text('초대 코드 입력'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextFormField, '초대 코드'),
        'bad',
      );
      await tester.tap(find.text('가입 요청'));
      await tester.pumpAndSettle();
      expect(find.text('6~12자의 영문 또는 숫자를 입력해 주세요.'), findsOneWidget);
      expect(fake.joinRequests, 0);
      await tester.enterText(
        find.widgetWithText(TextFormField, '초대 코드'),
        'ab12cd34',
      );
      await tester.tap(find.text('가입 요청'));
      await tester.pumpAndSettle();
      expect(fake.joinRequests, 1);
      await tester.tap(find.text('가족 만들기'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.enterText(
        find.widgetWithText(TextFormField, '가족 이름'),
        '우리 집',
      );
      await tester.tap(find.text('만들기'));
      await tester.pumpAndSettle();
      expect(selected, 'group-a');
    },
  );
}
