import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:flutter/widget_previews.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hareup_core/core.dart';
import '../domain/auth_repository.dart';
import 'auth_cubit.dart';
import 'auth_gate.dart';

class _PreviewAuth implements AuthRepository {
  @override
  List<AuthProviderOption> get providers => const [];

  @override
  Stream<AuthSession?> observeSession() => Stream.value(null);
  @override
  Future<Result<void>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => const Failure(CancelledFailure('Preview에서는 계정을 만들 수 없습니다.'));
  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async => const Failure(CancelledFailure('Preview에서는 로그인할 수 없습니다.'));
  @override
  Future<Result<void>> signInWithProvider(String providerId) async =>
      const Failure(CancelledFailure('Preview에서는 로그인할 수 없습니다.'));
  @override
  Future<Result<void>> signOut() async => const Success(null);
}

@Preview(name: '로그인', group: '인증')
Widget authPreview() => BlocProvider(
  create: (_) => AuthCubit(_PreviewAuth())..start(),
  child: MaterialApp(
    theme: HareupTheme.light,
    home: AuthGate(signedInBuilder: (_, _) => const SizedBox()),
  ),
);
