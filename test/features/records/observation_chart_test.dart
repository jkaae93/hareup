import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/features/records/presentation/widgets/observation_chart.dart';
import '../../test_support.dart';

void main() {
  testWidgets('shows each observation and both values including zero', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        localizationsDelegates: testLocalizationsDelegates,
        locale: const Locale('ko'),
        supportedLocales: appSupportedLocales,
        home: Scaffold(
          body: ObservationChart(
            title: '화장실 횟수 추이',
            labels: const ['소변', '대변'],
            unit: '회',
            points: [
              ObservationChartPoint(
                time: DateTime(2026, 1, 2, 9, 5),
                values: const [2, 0],
              ),
            ],
          ),
        ),
      ),
    );
    expect(find.text('소변'), findsOneWidget);
    expect(find.text('대변'), findsOneWidget);
    expect(find.text('2회'), findsOneWidget);
    expect(find.text('0회'), findsOneWidget);
    expect(find.text('1/2\n09:05'), findsOneWidget);
  });
}
