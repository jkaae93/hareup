import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_presentation_core/presentation_core.dart';

class CounterCubit extends BaseCubit<int> {
  CounterCubit() : super(0);
}

void main() {
  test('runGuarded handles success and maps operation failures', () async {
    final cubit = CounterCubit();
    await cubit.runGuarded(
      () async => 2,
      onSuccess: cubit.emitIfOpen,
      onFailure: (_) => fail('unexpected'),
    );
    expect(cubit.state, 2);
    AppFailure? failure;
    await cubit.runGuarded<int>(
      () async => throw Exception(),
      onSuccess: (_) => fail('unexpected'),
      onFailure: (value) => failure = value,
    );
    expect(failure, isA<UnexpectedFailure>());
    await cubit.close();
  });

  test('runGuarded ignores completion after close', () async {
    final cubit = CounterCubit();
    final pending = Completer<int>();
    var called = false;
    final work = cubit.runGuarded(
      () => pending.future,
      onSuccess: (_) => called = true,
      onFailure: (_) => called = true,
    );
    await cubit.close();
    pending.complete(1);
    await work;
    cubit.emitIfOpen(2);
    expect(called, isFalse);
    expect(cubit.state, 0);
  });

  test(
    'exceptions in success callbacks are not mapped as operation failures',
    () async {
      final cubit = CounterCubit();
      var failed = false;
      await expectLater(
        cubit.runGuarded(
          () async => 1,
          onSuccess: (_) => throw StateError('callback'),
          onFailure: (_) => failed = true,
        ),
        throwsStateError,
      );
      expect(failed, isFalse);
      await cubit.close();
    },
  );
}
