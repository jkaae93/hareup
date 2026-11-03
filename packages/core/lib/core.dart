import 'dart:typed_data';

sealed class AppFailure {
  const AppFailure(this.message);
  final String message;
}

final class UnexpectedFailure extends AppFailure {
  const UnexpectedFailure([super.message = '요청을 처리하지 못했습니다.']);
}

final class NetworkFailure extends AppFailure {
  const NetworkFailure([super.message = '네트워크 연결을 확인해 주세요.']);
}

final class SerializationFailure extends AppFailure {
  const SerializationFailure([super.message = '데이터를 읽을 수 없습니다.']);
}

class AppException implements Exception {
  const AppException(this.message);
  final String message;
}

abstract interface class UseCase<Output, Input> {
  Future<Output> call(Input input);
}

/// An explicit success or failure returned across an application boundary.
sealed class Result<T> {
  const Result();

  const factory Result.success(T value) = Success<T>;
  const factory Result.failure(AppFailure failure) = Failure<T>;
}

final class Success<T> extends Result<T> {
  const Success(this.value);
  final T value;
}

final class Failure<T> extends Result<T> {
  const Failure(this.failure);
  final AppFailure failure;
}

final class TimeoutFailure extends AppFailure {
  const TimeoutFailure([super.message = '요청 시간이 초과되었습니다. 다시 시도해 주세요.']);
}

final class CancelledFailure extends AppFailure {
  const CancelledFailure([super.message = '요청이 취소되었습니다.']);
}

final class AuthorizationFailure extends AppFailure {
  const AuthorizationFailure([super.message = '접근 권한을 확인해 주세요.']);
}

final class NotFoundFailure extends AppFailure {
  const NotFoundFailure([super.message = '요청한 정보를 찾을 수 없습니다.']);
}

final class ServerFailure extends AppFailure {
  const ServerFailure([super.message = '서버에 문제가 발생했습니다. 다시 시도해 주세요.']);
}

final class RequestFailure extends AppFailure {
  const RequestFailure([super.message = '요청을 확인해 주세요.']);
}

/// Immutable in-memory snapshot; persistence must use a separate storage ID.
class PhotoBaseline {
  PhotoBaseline({
    required this.version,
    required this.createdAt,
    required Uint8List photo,
    this.notes = '',
  }) : _photo = Uint8List.fromList(photo);
  final int version;
  final DateTime createdAt;
  final String notes;
  final Uint8List _photo;
  Uint8List get photo => Uint8List.fromList(_photo);
}
