import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_design_system/design_system.dart';
import 'package:hareup/app/app.dart';
import '../test_support.dart';

void main() {
  testWidgets('content uses the available width up to the shared maximum', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(1200, 800);
    tester.view.devicePixelRatio = 1;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    const key = ValueKey('content');
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: HareupContent(child: SizedBox.expand(key: key)),
        ),
      ),
    );
    expect(
      tester.getSize(find.byKey(key)).width,
      HareupSpacing.maxContentWidth,
    );
    tester.view.physicalSize = const Size(320, 800);
    await tester.pumpAndSettle();
    expect(tester.getSize(find.byKey(key)).width, 320);
  });

  test('theme uses accessible primary text and Pretendard', () {
    final theme = HareupTheme.light;
    double contrast(Color a, Color b) {
      final first = a.computeLuminance();
      final second = b.computeLuminance();
      return (first > second ? first + 0.05 : second + 0.05) /
          (first > second ? second + 0.05 : first + 0.05);
    }

    expect(
      contrast(theme.colorScheme.primary, theme.colorScheme.onPrimary),
      greaterThanOrEqualTo(4.5),
    );
    expect(
      contrast(theme.colorScheme.surface, theme.colorScheme.onSurface),
      greaterThanOrEqualTo(4.5),
    );
    expect(theme.textTheme.bodyMedium?.fontFamily, 'Pretendard');
    expect(theme.colorScheme.primary, HareupColors.primary700);
    expect(theme.colorScheme.primaryContainer, HareupColors.primary100);
    expect(theme.textTheme.headlineMedium?.fontSize, 20);
    expect(theme.textTheme.titleLarge?.fontSize, 18);
    expect(theme.textTheme.titleLarge?.letterSpacing, 0);
    for (final pair in [
      (HareupColors.secondary100, HareupColors.secondary900),
      (HareupColors.warning100, HareupColors.warning900),
      (HareupColors.error100, HareupColors.error900),
    ]) {
      expect(contrast(pair.$1, pair.$2), greaterThanOrEqualTo(4.5));
    }
  });

  test('button, input, and checkbox states use the shared theme', () {
    final theme = HareupTheme.light;
    final background = theme.filledButtonTheme.style!.backgroundColor!;
    expect(background.resolve({}), HareupColors.primary500);
    expect(background.resolve({WidgetState.hovered}), HareupColors.primary700);
    expect(background.resolve({WidgetState.pressed}), HareupColors.primary900);
    expect(
      theme.filledButtonTheme.style!.side!.resolve({
        WidgetState.focused,
      })!.color,
      HareupColors.primary300,
    );
    expect(
      theme.filledButtonTheme.style!.backgroundColor!.resolve({
        WidgetState.disabled,
      }),
      isNotNull,
    );
    expect(
      (theme.inputDecorationTheme.focusedBorder! as OutlineInputBorder)
          .borderSide
          .color,
      HareupColors.primary500,
    );
    expect(
      (theme.inputDecorationTheme.errorBorder! as OutlineInputBorder)
          .borderSide
          .color,
      HareupColors.error700,
    );
    expect(
      (theme.inputDecorationTheme.disabledBorder! as OutlineInputBorder)
          .borderSide
          .color,
      HareupColors.neutral200,
    );
    expect(
      theme.checkboxTheme.fillColor!.resolve({WidgetState.selected}),
      HareupColors.primary500,
    );
    expect(
      theme.checkboxTheme.fillColor!.resolve({WidgetState.disabled}),
      HareupColors.neutral100,
    );
  });

  testWidgets('home is usable at narrow width and enlarged text', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      const HareupApp(authRepository: TestSignedInAuth()),
    );
    await tester.pumpAndSettle();
    expect(find.text('하릅'), findsOneWidget);
    expect(find.text('반려동물 관리'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('photo actions expose enabled and disabled states', (
    tester,
  ) async {
    var cameraCalls = 0;
    var removeCalls = 0;
    await tester.pumpWidget(
      MaterialApp(
        theme: HareupTheme.light,
        home: Scaffold(
          body: HareupPhotoActions(
            onCamera: () => cameraCalls++,
            onGallery: null,
            onRemove: () => removeCalls++,
          ),
        ),
      ),
    );
    await tester.tap(find.text('사진 촬영'));
    await tester.tap(find.text('사진 삭제'));
    expect(cameraCalls, 1);
    expect(removeCalls, 1);
    expect(
      tester
          .widget<TextButton>(find.widgetWithText(TextButton, '사진 선택'))
          .onPressed,
      isNull,
    );
  });

  testWidgets('count field changes values without going below zero', (
    tester,
  ) async {
    final controller = TextEditingController(text: '0');
    addTearDown(controller.dispose);
    await tester.pumpWidget(
      MaterialApp(
        theme: HareupTheme.light,
        home: Scaffold(
          body: HareupCountField(
            controller: controller,
            label: '흔적 수',
            enabled: true,
          ),
        ),
      ),
    );
    await tester.tap(find.byTooltip('흔적 수 줄이기'));
    expect(controller.text, '0');
    await tester.tap(find.byTooltip('흔적 수 늘리기'));
    expect(controller.text, '1');
    await tester.tap(find.byTooltip('흔적 수 줄이기'));
    expect(controller.text, '0');
  });

  testWidgets('photo comparison adapts to large text', (tester) async {
    tester.view.physicalSize = const Size(320, 700);
    tester.view.devicePixelRatio = 1;
    tester.platformDispatcher.textScaleFactorTestValue = 2;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        theme: HareupTheme.light,
        home: const Scaffold(
          body: SingleChildScrollView(
            child: HareupPhotoComparison(before: null, after: null),
          ),
        ),
      ),
    );
    expect(find.text('기준 사진'), findsOneWidget);
    expect(find.text('비교 사진'), findsOneWidget);
    expect(find.text('선택된 사진이 없습니다.'), findsNWidgets(2));
    expect(tester.takeException(), isNull);
  });

  testWidgets('photo controls meet touch target and label guidance', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: HareupTheme.light,
        home: Scaffold(
          body: HareupPhotoActions(onCamera: () {}, onGallery: () {}),
        ),
      ),
    );
    await expectLater(tester, meetsGuideline(androidTapTargetGuideline));
    await expectLater(tester, meetsGuideline(iOSTapTargetGuideline));
    await expectLater(tester, meetsGuideline(labeledTapTargetGuideline));
    semantics.dispose();
  });

  testWidgets('photo preview shows empty and decoding error states', (
    tester,
  ) async {
    await tester.pumpWidget(
      MaterialApp(
        theme: HareupTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              const HareupPhotoPreview(bytes: null, label: '비교 사진'),
              HareupPhotoPreview(
                bytes: Uint8List.fromList([0, 1, 2]),
                label: '기준 사진',
              ),
            ],
          ),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('선택된 사진이 없습니다.'), findsOneWidget);
    expect(find.text('사진을 표시할 수 없습니다.'), findsOneWidget);
  });

  testWidgets('selection and loading states expose their meaning', (
    tester,
  ) async {
    final semantics = tester.ensureSemantics();
    await tester.pumpWidget(
      MaterialApp(
        theme: HareupTheme.light,
        home: Scaffold(
          body: Column(
            children: [
              FilterChip(
                label: const Text('고양이'),
                selected: true,
                onSelected: (_) {},
              ),
              const HareupLoading(),
            ],
          ),
        ),
      ),
    );
    expect(tester.widget<FilterChip>(find.byType(FilterChip)).selected, isTrue);
    expect(find.bySemanticsLabel('불러오는 중'), findsOneWidget);
    semantics.dispose();
  });

  testWidgets('text entry stays usable with keyboard on a narrow screen', (
    tester,
  ) async {
    tester.view.physicalSize = const Size(320, 640);
    tester.view.devicePixelRatio = 1;
    tester.view.viewInsets = const FakeViewPadding(bottom: 260);
    tester.platformDispatcher.textScaleFactorTestValue = 1.5;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
    addTearDown(tester.view.resetViewInsets);
    addTearDown(tester.platformDispatcher.clearTextScaleFactorTestValue);
    await tester.pumpWidget(
      MaterialApp(
        theme: HareupTheme.light,
        home: const HareupTextEntryPage(
          title: '가족 만들기',
          label: '가족 이름',
          submitLabel: '만들기',
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    expect(find.text('만들기'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('status and retry remain readable at larger text sizes', (
    tester,
  ) async {
    var retried = false;
    await tester.pumpWidget(
      MaterialApp(
        theme: HareupTheme.light,
        home: MediaQuery(
          data: const MediaQueryData(
            size: Size(320, 700),
            textScaler: TextScaler.linear(1.5),
          ),
          child: Scaffold(
            body: Column(
              children: [
                const HareupStatusBadge(
                  label: '확인이 필요합니다',
                  status: HareupStatus.warning,
                ),
                ErrorNotice(
                  message: '불러오지 못했습니다.',
                  onRetry: () => retried = true,
                ),
              ],
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('다시 시도'));
    expect(retried, isTrue);
    expect(tester.takeException(), isNull);
  });
}
