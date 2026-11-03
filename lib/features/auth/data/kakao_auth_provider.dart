import 'dart:convert';
import 'dart:math';

import 'package:crypto/crypto.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/services.dart';
import 'package:kakao_flutter_sdk_user/kakao_flutter_sdk_user.dart';

import 'federated_auth_provider.dart';

/// Exchanges a Kakao OpenID Connect ID token for a Firebase credential.
///
/// Call `KakaoSdk.init(nativeAppKey: ...)` once during app startup before
/// invoking this adapter. The key must come from Kakao's Native App Key.
class KakaoAuthProvider implements FederatedAuthProvider {
  const KakaoAuthProvider();

  @override
  FederatedProviderId get id => FederatedProviderId.kakao;

  @override
  Future<UserCredential> signIn(FirebaseAuth auth) async {
    final rawNonce = _createNonce();
    final hashedNonce = sha256.convert(utf8.encode(rawNonce)).toString();
    try {
      late final OAuthToken token;
      if (await isKakaoTalkInstalled()) {
        try {
          token = await UserApi.instance.loginWithKakaoTalk(nonce: hashedNonce);
        } catch (error) {
          if (_isCancelled(error)) {
            throw const FederatedSignInCancelled();
          }
          // Kakao's recommended native flow falls back to account login when
          // KakaoTalk is unavailable or cannot complete authentication.
          token = await UserApi.instance.loginWithKakaoAccount(
            nonce: hashedNonce,
          );
        }
      } else {
        token = await UserApi.instance.loginWithKakaoAccount(
          nonce: hashedNonce,
        );
      }

      final idToken = token.idToken;
      if (idToken == null || idToken.isEmpty) {
        throw StateError(
          'Kakao did not return an ID token. Enable OpenID Connect for the Kakao app.',
        );
      }

      final credential = OAuthProvider(
        'oidc.kakao',
      ).credential(idToken: idToken, rawNonce: rawNonce);
      return await auth.signInWithCredential(credential);
    } catch (error) {
      if (_isCancelled(error)) {
        throw const FederatedSignInCancelled();
      }
      rethrow;
    }
  }

  @override
  Future<void> signOut() => UserApi.instance.logout();

  String _createNonce() {
    final random = Random.secure();
    final bytes = List<int>.generate(32, (_) => random.nextInt(256));
    return base64Url.encode(bytes).replaceAll('=', '');
  }

  bool _isCancelled(Object error) {
    if (error is PlatformException) {
      final code = error.code.toUpperCase();
      if (code == 'CANCELED' || code == 'CANCELLED') return true;
    }
    if (error is KakaoClientException &&
        error.reason == ClientErrorCause.cancelled) {
      return true;
    }
    if (error is KakaoApiException &&
        error.code == ApiErrorCause.accessDenied) {
      return true;
    }
    return error is KakaoAuthException &&
        error.error == AuthErrorCause.accessDenied;
  }
}
