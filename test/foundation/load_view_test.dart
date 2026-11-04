import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_presentation_core/load_view.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../test_support.dart';

void main() {
  testWidgets('renders states and invokes retry', (tester) async {
    var retries = 0;
    Widget view(LoadState<int> state) => MaterialApp(
      theme: testTheme,
      localizationsDelegates: testLocalizationsDelegates,
      locale: const Locale('ko'),
      supportedLocales: appSupportedLocales,
      home: Scaffold(
        body: LoadView<int>(
          state: state,
          emptyMessage: '비어 있음',
          onRetry: () => retries++,
          builder: (context, value) => Text('결과 $value'),
        ),
      ),
    );
    await tester.pumpWidget(view(const Loading<int>()));
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
    await tester.pumpWidget(view(const Empty<int>()));
    expect(find.text('비어 있음'), findsOneWidget);
    await tester.pumpWidget(view(const Failed<int>(NetworkFailure())));
    await tester.tap(find.text('다시 시도'));
    expect(retries, 1);
    await tester.pumpWidget(view(const Loaded<int>(42)));
    expect(find.text('결과 42'), findsOneWidget);
  });
}
