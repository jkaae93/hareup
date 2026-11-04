import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/features/shared_data/selection_management_page.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import '../../test_support.dart';

class ItemsCubit extends LoadCubit<List<String>> {
  final items = ['첫째', '둘째'];
  Future<void> load() =>
      loadValue(() async => List.of(items), isEmpty: (items) => items.isEmpty);
}

void main() {
  testWidgets('selection replaces add with delete and retains failed items', (
    tester,
  ) async {
    final cubit = ItemsCubit();
    await cubit.load();
    addTearDown(cubit.close);
    final attempts = <String>[];
    await tester.pumpWidget(
      MaterialApp(
        theme: testTheme,
        localizationsDelegates: testLocalizationsDelegates,
        supportedLocales: appSupportedLocales,
        locale: const Locale('ko'),
        home: SelectionManagementPage<String>(
          title: '관리',
          emptyMessage: '없음',
          addLabel: '추가',
          confirmMessage: '확인',
          cubit: cubit,
          idOf: (item) => item,
          nameOf: (item) => item,
          iconOf: (_) => Icons.pets,
          onAdd: () {},
          onRetry: cubit.load,
          onDelete: (item) async {
            attempts.add(item);
            if (item == '둘째') return false;
            cubit.items.remove(item);
            await cubit.load();
            return true;
          },
          failureMessage: () => '삭제 실패',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('추가'), findsOneWidget);
    await tester.tap(find.text('첫째'));
    await tester.tap(find.text('둘째'));
    await tester.pumpAndSettle();
    expect(find.text('선택한 2개 삭제'), findsOneWidget);
    expect(find.text('추가'), findsNothing);
    await tester.tap(find.text('선택한 2개 삭제'));
    await tester.pumpAndSettle();
    expect(find.textContaining('첫째, 둘째'), findsOneWidget);
    await tester.tap(find.text('삭제'));
    await tester.pumpAndSettle();
    expect(attempts, ['첫째', '둘째']);
    expect(find.text('첫째'), findsNothing);
    expect(find.text('선택한 1개 삭제'), findsOneWidget);
    expect(find.text('삭제 실패'), findsOneWidget);
    await tester.tap(find.text('둘째'));
    await tester.pumpAndSettle();
    expect(find.text('추가'), findsOneWidget);
  });
}
