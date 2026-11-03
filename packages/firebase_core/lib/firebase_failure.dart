import 'package:firebase_core/firebase_core.dart';
import 'package:hareup_core/core.dart';

/// Translate provider codes at the data boundary without exposing server text.
AppFailure firebaseFailure(Object error) {
  if (error is! FirebaseException) return const UnexpectedFailure();
  switch (error.code) {
    case 'unauthenticated':
    case 'permission-denied':
    case 'unauthorized':
    case 'user-disabled':
      return const AuthorizationFailure();
    case 'network-request-failed':
    case 'unavailable':
      return const NetworkFailure();
    case 'deadline-exceeded':
      return const TimeoutFailure();
    case 'cancelled':
    case 'canceled':
    case 'popup-closed-by-user':
    case 'web-context-cancelled':
      return const CancelledFailure();
    case 'not-found':
      return const NotFoundFailure();
    case 'object-not-found':
      if (error.plugin == 'firebase_storage') {
        return const NotFoundFailure(
          '저장된 사진 파일을 찾지 못했습니다. 사진 저장소 설정을 확인해 주세요.',
        );
      }
      return const NotFoundFailure();
    case 'bucket-not-found':
      return const RequestFailure(
        '사진 저장소가 설정되지 않았습니다. Firebase Console에서 Storage 버킷을 생성해 주세요.',
      );
    case 'invalid-argument':
    case 'failed-precondition':
      return const RequestFailure();
    case 'internal':
    case 'unknown':
      return const ServerFailure();
    default:
      return const UnexpectedFailure();
  }
}
