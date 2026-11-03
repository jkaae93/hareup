import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/features/photo_analysis/data/firebase_meta_analysis_service.dart';

void main() {
  test('retries uncertain once and returns the second response', () async {
    var calls = 0;
    final result = await callAnalysisWithRetry(() async {
      calls++;
      return {'status': calls == 1 ? 'uncertain' : 'ok'};
    }, registrationPhoto: false);
    expect(calls, 2);
    expect((result as Map)['status'], 'ok');
  });

  test('stops after two uncertain responses', () async {
    var calls = 0;
    await callAnalysisWithRetry(() async {
      calls++;
      return {'status': 'uncertain'};
    }, registrationPhoto: false);
    expect(calls, 2);
  });

  test('retries transient errors but not permission errors', () async {
    var calls = 0;
    final result = await callAnalysisWithRetry(() async {
      if (++calls == 1) {
        throw FirebaseFunctionsException(
          code: 'unavailable',
          message: 'unavailable',
        );
      }
      return {'status': 'ok'};
    }, registrationPhoto: true);
    expect(calls, 2);
    expect((result as Map)['status'], 'ok');
    calls = 0;
    await expectLater(
      callAnalysisWithRetry(() async {
        calls++;
        throw FirebaseFunctionsException(
          code: 'permission-denied',
          message: 'permission denied',
        );
      }, registrationPhoto: false),
      throwsA(isA<FirebaseFunctionsException>()),
    );
    expect(calls, 1);
  });
}
