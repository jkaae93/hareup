import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_presentation_core/presentation_core.dart';

void main() {
  test(
    'command prevents duplicate execution, emits success and resets',
    () async {
      final pending = Completer<Result<int>>();
      var calls = 0;
      final command = Command0<int>(() {
        calls++;
        return pending.future;
      });
      final first = command.execute();
      expect(command.state, isA<CommandRunning<int>>());
      command.reset();
      await command.execute();
      expect(calls, 1);
      pending.complete(const Result.success(42));
      await first;
      expect((command.state as CommandSuccess<int>).value, 42);
      command.reset();
      expect(command.state, isA<CommandIdle<int>>());
      await command.close();
    },
  );

  test('command forwards arguments and preserves failure', () async {
    const failure = NetworkFailure();
    final command = Command1<int, String>((value) async {
      expect(value, 'input');
      return const Result.failure(failure);
    });
    await command.execute('input');
    expect((command.state as CommandFailure<int>).failure, same(failure));
    await command.close();
  });

  test('command maps thrown errors and ignores results after close', () async {
    final command = Command0<int>(() async => throw Exception());
    await command.execute();
    expect(
      (command.state as CommandFailure<int>).failure,
      isA<UnexpectedFailure>(),
    );
    await command.close();
    final pending = Completer<Result<int>>();
    final closing = Command0<int>(() => pending.future);
    final work = closing.execute();
    await closing.close();
    pending.complete(const Result.success(1));
    await work;
    expect(closing.state, isA<CommandRunning<int>>());
  });
}
