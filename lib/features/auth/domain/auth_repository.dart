import 'package:hareup_core/core.dart';

class AuthSession {
  const AuthSession({required this.userId, this.displayName, this.email});
  final String userId;
  final String? displayName;
  final String? email;
}

class AuthProviderOption {
  const AuthProviderOption({required this.id, required this.label});
  final String id;
  final String label;
}

abstract interface class AuthRepository {
  List<AuthProviderOption> get providers;
  Stream<AuthSession?> observeSession();
  Future<Result<void>> signUp({
    required String email,
    required String password,
    String? displayName,
  });
  Future<Result<void>> signIn({
    required String email,
    required String password,
  });
  Future<Result<void>> signInWithProvider(String providerId);
  Future<Result<void>> signOut();
}
