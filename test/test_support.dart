import 'package:flutter/material.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup/features/auth/domain/auth_repository.dart';
import 'package:hareup_core/core.dart';

/// Uses a non-shader splash so widget tests do not depend on engine shader
/// compilation support in the host test renderer.
final ThemeData testTheme = HareupTheme.light;

class TestSignedInAuth implements AuthRepository {
  const TestSignedInAuth();

  @override
  List<AuthProviderOption> get providers => const [];

  @override
  Stream<AuthSession?> observeSession() =>
      Stream.value(const AuthSession(userId: 'widget-test-user'));

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async => const Success(null);

  @override
  Future<Result<void>> signInWithProvider(String providerId) async =>
      const Success(null);

  @override
  Future<Result<void>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async => const Success(null);

  @override
  Future<Result<void>> signOut() async => const Success(null);
}
