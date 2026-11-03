import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

import 'federated_auth_provider.dart';

/// Apple Sign In adapter for native iOS and Android.
///
/// Android requires `APPLE_SERVICE_ID` at build time. Its redirect URL is
/// derived from the Firebase Auth domain configured in Firebase Options.
class AppleFederatedAuthProvider implements FederatedAuthProvider {
  const AppleFederatedAuthProvider();

  static const _serviceId = String.fromEnvironment('APPLE_SERVICE_ID');

  @override
  FederatedProviderId get id => FederatedProviderId.apple;

  @override
  Future<UserCredential> signIn(FirebaseAuth auth) async {
    if (kIsWeb ||
        (defaultTargetPlatform != TargetPlatform.iOS &&
            defaultTargetPlatform != TargetPlatform.android)) {
      throw UnsupportedError(
        'Apple sign-in is configured for the iOS and Android apps.',
      );
    }

    final rawNonce = generateNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();

    try {
      final appleCredential = await SignInWithApple.getAppleIDCredential(
        scopes: const [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
        nonce: hashedNonce,
        webAuthenticationOptions: _webOptionsFor(auth),
      );

      final idToken = appleCredential.identityToken;
      if (idToken == null || idToken.isEmpty) {
        throw FirebaseAuthException(
          code: 'missing-apple-id-token',
          message: 'Apple did not return an identity token.',
        );
      }

      final credential = AppleAuthProvider.credentialWithIDToken(
        idToken,
        rawNonce,
        AppleFullPersonName(
          givenName: appleCredential.givenName,
          familyName: appleCredential.familyName,
        ),
      );
      return await auth.signInWithCredential(credential);
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        throw const FederatedSignInCancelled();
      }
      rethrow;
    }
  }

  WebAuthenticationOptions? _webOptionsFor(FirebaseAuth auth) {
    if (defaultTargetPlatform != TargetPlatform.android) return null;

    if (_serviceId.isEmpty) {
      throw StateError(
        'Set APPLE_SERVICE_ID to the Apple Services ID before Android sign-in.',
      );
    }

    final authDomain = auth.app.options.authDomain;
    if (authDomain == null || authDomain.isEmpty) {
      throw StateError(
        'Configure a Firebase Auth domain before Android Apple sign-in.',
      );
    }

    return WebAuthenticationOptions(
      clientId: _serviceId,
      redirectUri: Uri.parse('https://$authDomain/__/auth/handler'),
    );
  }

  /// Apple has no app-level sign-out API. The repository clears the Firebase
  /// session after invoking provider cleanup.
  @override
  Future<void> signOut() async {}
}
