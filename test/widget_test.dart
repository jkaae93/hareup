import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/app/app.dart';
import 'test_support.dart';

void main() {
  testWidgets('반려동물을 추가하고 홈에서 확인한다', (tester) async {
    await tester.pumpWidget(
      const HareupApp(authRepository: TestSignedInAuth()),
    );
    await tester.pumpAndSettle();
    await tester.tap(find.text('반려동물 관리'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('반려동물 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '이름'), '나비');
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    expect(find.text('나비'), findsOneWidget);
    await tester.pageBack();
    await tester.pumpAndSettle();
    expect(find.text('반려동물 1마리'), findsOneWidget);
  });
}
