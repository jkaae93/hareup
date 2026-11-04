import 'package:hareup_design_system/design_system.dart';
import 'package:hareup/features/water_bowl/presentation/water_level_page.dart';
import 'dart:convert';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/app/app.dart';
import '../../test_support.dart';
import 'package:hareup/features/home/presentation/home_page.dart';
import 'package:hareup/features/family/presentation/family_page.dart';
import 'package:hareup/features/settings/presentation/settings_page.dart';
import 'package:hareup/features/shared_data/target_widgets.dart';
import 'package:hareup/features/pet/domain/pet.dart';
import 'package:hareup/features/pet/presentation/pet_cubit.dart';
import 'package:hareup/features/water_bowl/presentation/water_bowl_cubit.dart';
import 'package:hareup/features/litter_box/presentation/litter_box_cubit.dart';
import 'package:hareup/features/photo_analysis/presentation/analysis_page.dart';
import 'package:hareup_presentation_core/presentation_core.dart';

void main() {
  testWidgets(
    'home shows registered animals and targets and opens target details',
    (tester) async {
      await tester.pumpWidget(
        const HareupApp(
          authRepository: TestSignedInAuth(),
          initialLocale: Locale('ko'),
        ),
      );
      await tester.pumpAndSettle();
      final context = tester.element(find.byType(HomePage));
      final pets = context.read<PetCubit>();
      await pets.save(name: '나비', species: PetSpecies.cat);
      final petId = (pets.state as Loaded<List<Pet>>).data.single.id;
      final photo = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
      );
      await context.read<WaterBowlCubit>().create(
        name: '물 A',
        petIds: [petId],
        photo: photo,
      );
      await context.read<LitterBoxCubit>().create(
        name: '화장실 B',
        catIds: [petId],
        photo: photo,
        isAutomatic: false,
      );
      await tester.pumpAndSettle();
      expect(find.text('반려동물 1마리'), findsOneWidget);
      expect(find.text('나비'), findsOneWidget);
      expect(find.text('물 A'), findsOneWidget);
      await tester.scrollUntilVisible(
        find.text('화장실 B'),
        200,
        scrollable: find
            .descendant(
              of: find.byType(HomePage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      expect(find.text('화장실 B'), findsOneWidget);
      await tester.ensureVisible(find.text('물 A'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('물 A'));
      await tester.pumpAndSettle();
      await tester.scrollUntilVisible(find.text('수위 관찰'), 200);
      expect(find.text('수위 관찰'), findsOneWidget);

      await tester.tap(find.text('수위 관찰'));
      await tester.pumpAndSettle();
      expect(find.byType(WaterLevelPage), findsOneWidget);
      await tester.scrollUntilVisible(find.text('초기 설정 분석'), 200);
      expect(find.text('초기 설정 분석'), findsOneWidget);
      expect(tester.takeException(), isNull);
    },
  );
  testWidgets('empty dashboard exposes registration entry points', (
    tester,
  ) async {
    await tester.pumpWidget(
      const HareupApp(
        authRepository: TestSignedInAuth(),
        initialLocale: Locale('ko'),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('반려동물을 등록해 주세요.'), findsOneWidget);
    expect(find.text('물그릇을 등록해 주세요.'), findsOneWidget);
    expect(find.text('화장실을 등록해 주세요.'), findsOneWidget);
  });

  testWidgets(
    'bottom navigation switches between four tabs and keeps reports and settings accessible',
    (tester) async {
      await tester.pumpWidget(
        const HareupApp(
          authRepository: TestSignedInAuth(),
          initialLocale: Locale('ko'),
        ),
      );
      await tester.pumpAndSettle();
      final homeContext = tester.element(find.byType(HomePage));
      final pets = homeContext.read<PetCubit>();
      await pets.save(name: '나비', species: PetSpecies.cat);
      final petId = (pets.state as Loaded<List<Pet>>).data.single.id;
      await homeContext.read<WaterBowlCubit>().create(
        name: '거실 물그릇',
        petIds: [petId],
        photo: base64Decode(
          'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
        ),
      );
      await tester.pumpAndSettle();
      final bar = tester.widget<NavigationBar>(find.byType(NavigationBar));
      expect(bar.destinations, hasLength(4));
      Future<void> selectTab(String name) async {
        await tester.tap(find.widgetWithText(NavigationDestination, name));
        await tester.pumpAndSettle();
      }

      await selectTab('건강리포트');
      expect(
        tester.widget<NavigationBar>(find.byType(NavigationBar)).selectedIndex,
        1,
      );
      expect(
        find.text('반려동물별 음수량은 아직 측정할 수 없어 그래프를 제공하지 않습니다.'),
        findsOneWidget,
      );
      await tester.scrollUntilVisible(find.text('기록 대상 선택'), 200);
      await tester.tap(find.text('기록 대상 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('거실 물그릇'));
      await tester.pumpAndSettle();
      expect(find.text('수위 기록'), findsOneWidget);
      await tapBackButton(tester);
      await tester.pumpAndSettle();
      await selectTab('채팅');
      expect(find.text('반려동물 건강 상담'), findsOneWidget);
      await tester.enterText(find.byType(TextField), '작성 중인 메시지');
      await selectTab('마이페이지');
      expect(find.text('가족 관리'), findsOneWidget);
      expect(find.text('설정'), findsOneWidget);
      await tester.tap(find.text('가족 관리'));
      await tester.pumpAndSettle();
      expect(find.byType(FamilyPage), findsOneWidget);
      await tapBackButton(tester);
      await tester.pumpAndSettle();
      await tester.tap(find.text('설정'));
      await tester.pump();
      await tester.pump(const Duration(milliseconds: 400));
      expect(find.byType(SettingsPage), findsOneWidget);
      await tapBackButton(tester);
      await tester.pumpAndSettle();
      await selectTab('채팅');
      expect(find.text('작성 중인 메시지'), findsOneWidget);
      await selectTab('홈');
      expect(find.text('거실 물그릇'), findsOneWidget);
    },
  );

  testWidgets('litter detail and record routes keep dependencies', (
    tester,
  ) async {
    await tester.pumpWidget(
      const HareupApp(
        authRepository: TestSignedInAuth(),
        initialLocale: Locale('ko'),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(HomePage));
    final pets = context.read<PetCubit>();
    await pets.save(name: '나비', species: PetSpecies.cat);
    final petId = (pets.state as Loaded<List<Pet>>).data.single.id;
    await context.read<LitterBoxCubit>().create(
      name: '화장실',
      catIds: [petId],
      isAutomatic: false,
      photo: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpAndSettle();
    final litterTile = find.widgetWithText(TargetGridTile, '화장실');
    await tester.scrollUntilVisible(
      litterTile,
      200,
      scrollable: find
          .descendant(
            of: find.byType(HomePage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.ensureVisible(litterTile);
    await tester.pumpAndSettle();
    await tester.tap(litterTile);
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.ensureVisible(find.text('기록 보기'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('기록 보기'));
    await tester.pumpAndSettle();
    expect(find.text('저장된 분석 기록이 없습니다.'), findsOneWidget);
    await tapBackButton(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('사진 비교'));
    await tester.pumpAndSettle();
    expect(find.byType(AnalysisPage), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('water bowl registration route and dialog retain their cubit', (
    tester,
  ) async {
    await tester.pumpWidget(
      const HareupApp(
        authRepository: TestSignedInAuth(),
        initialLocale: Locale('ko'),
      ),
    );
    await tester.pumpAndSettle();

    final edit = find.byTooltip('물그릇 관리');
    expect(
      find.descendant(of: edit, matching: find.text('수정')),
      findsOneWidget,
    );
    final header = find.ancestor(
      of: edit,
      matching: find.byType(HareupSectionHeader),
    );
    expect(
      tester.getRect(edit).right,
      closeTo(tester.getRect(header).right, 0.1),
    );
    await tester.tap(find.byTooltip('물그릇 관리'));
    await tester.pumpAndSettle();
    expect(find.text('물그릇 관리'), findsOneWidget);
    expect(find.text('등록된 물그릇이 없습니다.'), findsOneWidget);

    await tester.tap(find.text('물그릇 추가'));
    await tester.pumpAndSettle();
    expect(find.text('물그릇 등록'), findsOneWidget);
    expect(find.text('먼저 반려동물을 등록해 주세요.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });

  testWidgets('litter management and detail routes retain their dependencies', (
    tester,
  ) async {
    await tester.pumpWidget(
      const HareupApp(
        authRepository: TestSignedInAuth(),
        initialLocale: Locale('ko'),
      ),
    );
    await tester.pumpAndSettle();
    final context = tester.element(find.byType(HomePage));
    final pets = context.read<PetCubit>();
    await pets.save(name: '나비', species: PetSpecies.cat);
    final petId = (pets.state as Loaded<List<Pet>>).data.single.id;
    await context.read<LitterBoxCubit>().create(
      name: '화장실 테스트',
      catIds: [petId],
      isAutomatic: false,
      photo: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(
      find.byTooltip('화장실 관리'),
      200,
      scrollable: find
          .descendant(
            of: find.byType(HomePage),
            matching: find.byType(Scrollable),
          )
          .first,
    );
    await tester.pumpAndSettle();
    await tester.tap(find.byTooltip('화장실 관리'));
    await tester.pumpAndSettle();
    expect(find.text('화장실 추가'), findsOneWidget);
    await tester.tap(find.text('화장실 테스트'));
    await tester.pumpAndSettle();
    expect(find.text('선택한 1개 삭제'), findsOneWidget);
    await tester.tap(find.text('선택한 1개 삭제'));
    await tester.pumpAndSettle();
    expect(find.text('선택한 1개를 삭제할까요?'), findsOneWidget);
    await tester.tap(find.text('취소'));
    await tester.pumpAndSettle();
    await tapBackButton(tester);
    await tester.pumpAndSettle();
    await tester.tap(find.text('화장실 테스트'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('기록 보기'), 200);
    await tester.tap(find.text('기록 보기'));
    await tester.pumpAndSettle();
    expect(find.text('저장된 분석 기록이 없습니다.'), findsOneWidget);
    expect(tester.takeException(), isNull);
  });
  for (final target in ['반려동물', '물그릇', '화장실']) {
    testWidgets('$target edit screen selects and deletes an item', (
      tester,
    ) async {
      await tester.pumpWidget(
        const HareupApp(
          authRepository: TestSignedInAuth(),
          initialLocale: Locale('ko'),
        ),
      );
      await tester.pumpAndSettle();
      final homeContext = tester.element(find.byType(HomePage));
      final pets = homeContext.read<PetCubit>();
      await pets.save(name: '테스트 동물', species: PetSpecies.cat);
      final petId = (pets.state as Loaded<List<Pet>>).data.single.id;
      final photo = base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
      );
      await homeContext.read<WaterBowlCubit>().create(
        name: '테스트 물그릇',
        petIds: [petId],
        photo: photo,
      );
      await homeContext.read<LitterBoxCubit>().create(
        name: '테스트 화장실',
        catIds: [petId],
        photo: photo,
        isAutomatic: false,
      );
      await tester.pumpAndSettle();
      final edit = find.byTooltip('$target 관리');
      await tester.scrollUntilVisible(
        edit,
        200,
        scrollable: find
            .descendant(
              of: find.byType(HomePage),
              matching: find.byType(Scrollable),
            )
            .first,
      );
      await tester.pumpAndSettle();
      await tester.tap(edit);
      await tester.pumpAndSettle();
      final item = target == '반려동물' ? '테스트 동물' : '테스트 $target';
      expect(find.byType(CheckboxListTile), findsOneWidget);
      expect(find.text('$target 추가'), findsOneWidget);
      await tester.tap(find.text(item));
      await tester.pumpAndSettle();
      expect(find.text('선택한 1개 삭제'), findsOneWidget);
      await tester.tap(find.text('선택한 1개 삭제'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('삭제'));
      await tester.pumpAndSettle();
      expect(find.text(item), findsNothing);
      expect(find.text('$target 추가'), findsOneWidget);
    });
  }
}
