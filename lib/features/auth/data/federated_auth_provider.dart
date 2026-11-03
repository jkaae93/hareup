import 'package:firebase_auth/firebase_auth.dart';

enum FederatedProviderId { google, apple, kakao }

/// A provider adapter returns a Firebase credential after platform OAuth.
abstract interface class FederatedAuthProvider {
  FederatedProviderId get id;

  Future<UserCredential> signIn(FirebaseAuth auth);

  Future<void> signOut();
}

/// Lets the repository keep user-cancelled sign-in separate from failures.
class FederatedSignInCancelled implements Exception {
  const FederatedSignInCancelled();
}
