import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/features/water_bowl/domain/water_level.dart';

void main() {
  test('compares fill levels and preserves rises', () {
    final now = DateTime.utc(2026);
    final previous = WaterLevelReading(fillPercent: 70, observedAt: now);
    expect(
      waterLevelChange(
        previous,
        WaterLevelReading(fillPercent: 50, observedAt: now),
      ),
      20,
    );
    expect(
      waterLevelChange(
        previous,
        WaterLevelReading(fillPercent: 90, observedAt: now),
      ),
      -20,
    );
    expect(
      () => waterLevelChange(
        previous,
        WaterLevelReading(fillPercent: 101, observedAt: now),
      ),
      throwsArgumentError,
    );
  });
}
