import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_firebase_core/firebase_failure.dart';

void main() {
  FirebaseException error(String code) =>
      FirebaseException(plugin: 'test', code: code, message: 'private details');
  test('maps service failures without exposing provider message', () {
    expect(
      firebaseFailure(error('permission-denied')),
      isA<AuthorizationFailure>(),
    );
    expect(
      firebaseFailure(error('network-request-failed')),
      isA<NetworkFailure>(),
    );
    expect(firebaseFailure(error('deadline-exceeded')), isA<TimeoutFailure>());
    expect(firebaseFailure(error('object-not-found')), isA<NotFoundFailure>());
    expect(firebaseFailure(error('unrecognized')), isA<UnexpectedFailure>());
    expect(
      firebaseFailure(error('permission-denied')).message,
      isNot(contains('private details')),
    );
  });

  test('explains missing Storage bucket and photo objects', () {
    final bucket = firebaseFailure(
      FirebaseException(
        plugin: 'firebase_storage',
        code: 'bucket-not-found',
        message: 'private details',
      ),
    );
    expect(bucket, isA<RequestFailure>());
    expect(bucket.message, contains('Storage 버킷을 생성'));

    final photo = firebaseFailure(
      FirebaseException(
        plugin: 'firebase_storage',
        code: 'object-not-found',
        message: 'private details',
      ),
    );
    expect(photo, isA<NotFoundFailure>());
    expect(photo.message, contains('저장된 사진 파일'));
  });
}
