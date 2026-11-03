import 'dart:async';

import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_presentation_core/presentation_core.dart';

class TestLoadCubit extends LoadCubit<List<int>> {}

void main() {
  test('loadValue emits loading and loaded or empty', () async {
    final cubit = TestLoadCubit();
    final states = <LoadState<List<int>>>[];
    final subscription = cubit.stream.listen(states.add);
    await cubit.loadValue(() async => [1], isEmpty: (value) => value.isEmpty);
    await cubit.loadValue(() async => [], isEmpty: (value) => value.isEmpty);
    await Future<void>.delayed(Duration.zero);
    expect(states, [
      isA<Loading<List<int>>>(),
      isA<Loaded<List<int>>>(),
      isA<Loading<List<int>>>(),
      isA<Empty<List<int>>>(),
    ]);
    await subscription.cancel();
    await cubit.close();
  });

  test('loadValue maps errors and ignores older or closed requests', () async {
    final cubit = TestLoadCubit();
    await cubit.loadValue(() async => throw Exception());
    expect(cubit.state, isA<Failed<List<int>>>());
    final old = Completer<List<int>>();
    final pending = cubit.loadValue(() => old.future);
    await cubit.loadValue(() async => [2]);
    old.complete([1]);
    await pending;
    expect((cubit.state as Loaded<List<int>>).data, [2]);
    final late = Completer<List<int>>();
    final closing = cubit.loadValue(() => late.future);
    await cubit.close();
    late.complete([3]);
    await closing;
  });
}
