import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:google_sign_in/google_sign_in.dart';

import 'federated_auth_provider.dart';

/// Google OAuth adapter for Firebase Authentication.
///
/// The Google client is initialized lazily and only once. Platform client IDs
/// are read from the Firebase/Google native configuration where supported.
class GoogleAuthProviderAdapter implements FederatedAuthProvider {
  GoogleAuthProviderAdapter();

  static final Future<void> _initialization = GoogleSignIn.instance
      .initialize();

  @override
  FederatedProviderId get id => FederatedProviderId.google;

  @override
  Future<UserCredential> signIn(FirebaseAuth auth) async {
    if (kIsWeb) {
      return auth.signInWithPopup(GoogleAuthProvider());
    }

    await _initialization;

    try {
      final account = await GoogleSignIn.instance.authenticate();
      final idToken = account.authentication.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError('Google sign-in did not return an ID token.');
      }

      final credential = GoogleAuthProvider.credential(idToken: idToken);
      return await auth.signInWithCredential(credential);
    } on GoogleSignInException catch (error) {
      if (error.code == GoogleSignInExceptionCode.canceled) {
        throw const FederatedSignInCancelled();
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() async {
    if (kIsWeb) return;
    await GoogleSignIn.instance.signOut();
  }
}
