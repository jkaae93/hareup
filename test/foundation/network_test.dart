import 'dart:typed_data';

import 'package:dio/dio.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_network/network.dart';

class RecordingAdapter implements HttpClientAdapter {
  RequestOptions? last;
  @override
  Future<ResponseBody> fetch(
    RequestOptions options,
    Stream<Uint8List>? requestStream,
    Future<void>? cancelFuture,
  ) async {
    last = options;
    return ResponseBody.fromString(
      '{}',
      200,
      headers: {
        Headers.contentTypeHeader: ['application/json'],
      },
    );
  }

  @override
  void close({bool force = false}) {}
}

void main() {
  test(
    'sends token only to configured origin and disables redirects',
    () async {
      final adapter = RecordingAdapter();
      final dio = Dio()..httpClientAdapter = adapter;
      final client = NetworkClient(
        baseUrl: 'https://example.com/api/',
        token: () async => 'secret',
        client: dio,
      );
      await client.dio.get('items');
      expect(adapter.last!.headers['Authorization'], 'Bearer secret');
      expect(adapter.last!.followRedirects, isFalse);
      await expectLater(
        client.dio.get('https://other.example/items'),
        throwsA(isA<DioException>()),
      );
      expect(adapter.last!.uri.host, 'example.com');
    },
  );

  test('maps network errors without exposing response details', () {
    final client = NetworkClient(baseUrl: 'https://example.com');
    final options = RequestOptions(path: '/');
    expect(
      client.failureFor(
        DioException(
          requestOptions: options,
          type: DioExceptionType.receiveTimeout,
        ),
      ),
      isA<TimeoutFailure>(),
    );
    expect(
      client.failureFor(
        DioException(
          requestOptions: options,
          response: Response(
            requestOptions: options,
            statusCode: 403,
            data: 'secret',
          ),
        ),
      ),
      isA<AuthorizationFailure>(),
    );
    expect(
      client.failureFor(
        DioException(
          requestOptions: options,
          response: Response(requestOptions: options, statusCode: 503),
        ),
      ),
      isA<ServerFailure>(),
    );
  });
}
