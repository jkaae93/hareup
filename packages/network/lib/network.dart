import 'package:dio/dio.dart';
import 'package:hareup_core/core.dart';

/// Shared HTTP client. Authentication tokens are only sent to the configured
/// origin. Authenticated redirects are disabled to avoid leaking credentials.
class NetworkClient {
  NetworkClient({
    required String baseUrl,
    Future<String?> Function()? token,
    Dio? client,
  }) : dio = client ?? Dio() {
    final origin = Uri.parse(baseUrl);
    if (!origin.hasAuthority ||
        (origin.scheme != 'https' && origin.scheme != 'http') ||
        origin.userInfo.isNotEmpty) {
      throw ArgumentError.value(baseUrl, 'baseUrl', 'Invalid HTTP base URL');
    }
    dio.options.baseUrl = baseUrl;
    dio.options.connectTimeout = const Duration(seconds: 15);
    dio.options.receiveTimeout = const Duration(seconds: 15);
    if (token != null) {
      dio.interceptors.add(
        InterceptorsWrapper(
          onRequest: (options, handler) async {
            try {
              final target = options.uri;
              if (target.scheme != origin.scheme ||
                  target.host != origin.host ||
                  target.port != origin.port) {
                handler.reject(
                  DioException(
                    requestOptions: options,
                    error: const AppException('허용되지 않은 요청 주소입니다.'),
                    type: DioExceptionType.unknown,
                  ),
                );
                return;
              }
              final value = await token();
              if (value != null && value.isNotEmpty) {
                options.headers['Authorization'] = 'Bearer $value';
                options.followRedirects = false;
              }
              handler.next(options);
            } catch (error) {
              handler.reject(
                DioException(requestOptions: options, error: error),
              );
            }
          },
        ),
      );
    }
  }

  final Dio dio;

  AppFailure failureFor(DioException error) {
    if (error.type == DioExceptionType.cancel) return const CancelledFailure();
    if (error.type == DioExceptionType.connectionTimeout ||
        error.type == DioExceptionType.sendTimeout ||
        error.type == DioExceptionType.receiveTimeout) {
      return const TimeoutFailure();
    }
    if (error.type == DioExceptionType.connectionError ||
        error.type == DioExceptionType.badCertificate) {
      return const NetworkFailure();
    }
    final status = error.response?.statusCode;
    if (status == 401 || status == 403) return const AuthorizationFailure();
    if (status == 404) return const NotFoundFailure();
    if (status != null && status >= 500) return const ServerFailure();
    if (status != null && status >= 400) return const RequestFailure();
    return const UnexpectedFailure();
  }
}
