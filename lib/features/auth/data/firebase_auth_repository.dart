import 'package:firebase_auth/firebase_auth.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_firebase_core/firebase_failure.dart';
import '../domain/auth_repository.dart';
import 'federated_auth_provider.dart';

class FirebaseAuthRepository implements AuthRepository {
  FirebaseAuthRepository({
    required FirebaseAuth auth,
    Iterable<FederatedAuthProvider> providers = const [],
  }) : _auth = auth,
       _providers = {
         for (final provider in providers) provider.id.name: provider,
       };

  final FirebaseAuth _auth;
  final Map<String, FederatedAuthProvider> _providers;

  @override
  List<AuthProviderOption> get providers => [
    for (final provider in FederatedProviderId.values)
      if (_providers.containsKey(provider.name))
        AuthProviderOption(
          id: provider.name,
          label: switch (provider) {
            FederatedProviderId.google => 'Google로 계속',
            FederatedProviderId.apple => 'Apple로 계속',
            FederatedProviderId.kakao => '카카오로 계속',
          },
        ),
  ];

  @override
  Stream<AuthSession?> observeSession() => _auth.authStateChanges().map(
    (user) => user == null
        ? null
        : AuthSession(
            userId: user.uid,
            displayName: user.displayName,
            email: user.email,
          ),
  );

  @override
  Future<Result<void>> signUp({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      final credential = await _auth.createUserWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      final name = displayName?.trim();
      if (name != null && name.isNotEmpty) {
        await credential.user?.updateDisplayName(name);
      }
      return const Success(null);
    } catch (error) {
      return Failure(_authFailure(error));
    }
  }

  @override
  Future<Result<void>> signIn({
    required String email,
    required String password,
  }) async {
    try {
      await _auth.signInWithEmailAndPassword(
        email: email.trim(),
        password: password,
      );
      return const Success(null);
    } catch (error) {
      return Failure(_authFailure(error));
    }
  }

  @override
  Future<Result<void>> signInWithProvider(String providerId) async {
    final provider = _providers[providerId];
    if (provider == null) {
      return const Failure(
        RequestFailure(
          '로그인 제공자를 사용할 수 없습니다.',
          FailureMessageKeys.authProviderUnavailable,
        ),
      );
    }
    try {
      await provider.signIn(_auth);
      return const Success(null);
    } on FederatedSignInCancelled {
      return const Failure(
        CancelledFailure('로그인을 취소했습니다.', FailureMessageKeys.authCancelled),
      );
    } catch (error) {
      return Failure(_authFailure(error));
    }
  }

  @override
  Future<Result<void>> signOut() async {
    try {
      for (final provider in _providers.values) {
        try {
          await provider.signOut();
        } catch (_) {
          // Firebase sign-out still clears the app's authenticated session.
        }
      }
      await _auth.signOut();
      return const Success(null);
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  AppFailure _authFailure(Object error) {
    if (error is FirebaseAuthException) {
      return switch (error.code) {
        'invalid-email' => const RequestFailure(
          '이메일 주소 형식이 올바르지 않습니다.',
          FailureMessageKeys.authInvalidEmail,
        ),
        'email-already-in-use' => const RequestFailure(
          '이미 가입된 이메일입니다. 로그인해 주세요.',
          FailureMessageKeys.authEmailInUse,
        ),
        'weak-password' => const RequestFailure(
          '비밀번호를 6자 이상 입력해 주세요.',
          FailureMessageKeys.authWeakPassword,
        ),
        'invalid-credential' ||
        'wrong-password' ||
        'user-not-found' => const AuthorizationFailure(
          '이메일 또는 비밀번호를 확인해 주세요.',
          FailureMessageKeys.authInvalidCredential,
        ),
        'too-many-requests' => const RequestFailure(
          '시도가 너무 많습니다. 잠시 후 다시 시도해 주세요.',
          FailureMessageKeys.authTooManyRequests,
        ),
        'operation-not-allowed' => const RequestFailure(
          'Firebase Console에서 이 로그인 제공자를 활성화해 주세요.',
          FailureMessageKeys.authNotEnabled,
        ),
        'popup-closed-by-user' ||
        'web-context-cancelled' => const CancelledFailure(
          '로그인을 취소했습니다.',
          FailureMessageKeys.authCancelled,
        ),
        _ => firebaseFailure(error),
      };
    }
    return firebaseFailure(error);
  }
}
