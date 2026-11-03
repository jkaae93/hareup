import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_serialization/serialization.dart';

void main() {
  test('decodes JSON objects and rejects invalid JSON or non-objects', () {
    expect(decodeJsonObject('{"name":"나비"}'), {'name': '나비'});
    expect(() => decodeJsonObject('['), throwsA(isA<DataFormatException>()));
    expect(() => decodeJsonObject('[]'), throwsA(isA<DataFormatException>()));
  });
  test('normalizes explicit offsets and rejects ambiguous timestamps', () {
    final date = parseUtcDate('2026-10-28T09:00:00+09:00');
    expect(formatUtcDate(date), '2026-10-28T00:00:00.000Z');
    expect(
      () => parseUtcDate('2026-10-28T09:00:00'),
      throwsA(isA<DataFormatException>()),
    );
    expect(
      () => parseUtcDate('not a date'),
      throwsA(isA<DataFormatException>()),
    );
  });
}
