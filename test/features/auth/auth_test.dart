import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:hareup/features/auth/domain/auth_repository.dart';
import 'package:hareup/features/auth/presentation/auth_cubit.dart';
import 'package:hareup/features/auth/presentation/auth_gate.dart';
import 'package:hareup_core/core.dart';

class FakeAuth implements AuthRepository {
  final changes = StreamController<AuthSession?>.broadcast(sync: true);
  Completer<Result<void>>? pending;
  int calls = 0;
  @override
  List<AuthProviderOption> get providers => const [
    AuthProviderOption(id: 'test', label: '테스트 로그인'),
  ];
  @override
  Stream<AuthSession?> observeSession() => changes.stream;
  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async => const Success(null);

  @override
  Future<Result<void>> signInWithProvider(String providerId) {
    calls++;
    return (pending ??= Completer()).future;
  }

  @override
  Future<Result<void>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => const Success(null);

  @override
  Future<Result<void>> signOut() async => const Success(null);
}

void main() {
  test(
    'prevents duplicate login, handles failure and removes session on logout',
    () async {
      final fake = FakeAuth();
      final cubit = AuthCubit(fake);
      await cubit.start();
      fake.changes.add(null);
      await Future<void>.delayed(Duration.zero);
      final pending = cubit.signInWithProvider('test');
      await cubit.signInWithProvider('test');
      expect(fake.calls, 1);
      fake.pending!.complete(const Failure(NetworkFailure()));
      await pending;
      expect(cubit.state.failure, isA<NetworkFailure>());
      fake.changes.add(const AuthSession(userId: 'a'));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.session?.userId, 'a');
      await cubit.signOut();
      expect(cubit.state.session, isNull);
      await cubit.close();
      await fake.changes.close();
    },
  );

  test(
    'stream errors revoke session and cancelled requests cannot update a restarted cubit',
    () async {
      final fake = FakeAuth();
      final cubit = AuthCubit(fake);
      await cubit.start();
      fake.changes.add(null);
      await Future<void>.delayed(Duration.zero);
      final pending = cubit.signInWithProvider('test');
      await cubit.start();
      fake.changes.add(const AuthSession(userId: 'new'));
      await Future<void>.delayed(Duration.zero);
      fake.pending!.complete(const Failure(NetworkFailure()));
      await pending;
      expect(cubit.state.session?.userId, 'new');
      expect(cubit.state.failure, isNull);
      fake.changes.addError(Exception('sensitive'));
      await Future<void>.delayed(Duration.zero);
      expect(cubit.state.session, isNull);
      expect(cubit.state.failure, isA<UnexpectedFailure>());
      await cubit.close();
      await fake.changes.close();
    },
  );

  testWidgets(
    'gate shows provider and discards user subtree on session change',
    (tester) async {
      final fake = FakeAuth();
      final cubit = AuthCubit(fake);
      await cubit.start();
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: testTheme,
            home: AuthGate(
              signedInBuilder: (_, session) => Text('사용자 ${session.userId}'),
            ),
          ),
        ),
      );
      fake.changes.add(null);
      await tester.pump();
      await tester.pump();
      expect(find.text('테스트 로그인'), findsOneWidget);
      fake.changes.add(const AuthSession(userId: 'a'));
      await tester.pump();
      await tester.pump();
      expect(find.text('사용자 a'), findsOneWidget);
      fake.changes.add(const AuthSession(userId: 'b'));
      await tester.pump();
      await tester.pump();
      expect(find.text('사용자 a'), findsNothing);
      expect(find.text('사용자 b'), findsOneWidget);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(() async {
        await cubit.close();
        await fake.changes.close();
      });
    },
  );
}
