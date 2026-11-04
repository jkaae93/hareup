import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup/app/app.dart';
import 'package:hareup/features/home/presentation/home_page.dart';
import 'package:hareup/features/litter_box/domain/litter_box.dart';
import 'package:hareup/features/litter_box/presentation/litter_box_cubit.dart';
import 'package:hareup/features/pet/domain/pet.dart';
import 'package:hareup/features/pet/presentation/pet_cubit.dart';
import 'package:hareup/features/water_bowl/domain/water_bowl.dart';
import 'package:hareup/features/water_bowl/presentation/water_bowl_cubit.dart';
import 'package:hareup_presentation_core/presentation_core.dart';

import '../../test_support.dart';

void main() {
  for (final isLitter in [true, false]) {
    testWidgets(
      '${isLitter ? 'litter box' : 'water bowl'} can be renamed and preserves its data',
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
        final litter = context.read<LitterBoxCubit>();
        final water = context.read<WaterBowlCubit>();
        if (isLitter) {
          await litter.create(
            name: '기존 화장실',
            catIds: [petId],
            photo: photo,
            isAutomatic: false,
          );
        } else {
          await water.create(
            name: '기존 물그릇',
            petIds: [petId],
            photo: photo,
            fullWaterMl: 1000,
          );
        }
        await tester.pumpAndSettle();
        final oldName = isLitter ? '기존 화장실' : '기존 물그릇';
        await tester.scrollUntilVisible(
          find.text(oldName),
          200,
          scrollable: find
              .descendant(
                of: find.byType(HomePage),
                matching: find.byType(Scrollable),
              )
              .first,
        );
        await tester.ensureVisible(find.text(oldName));
        await tester.pumpAndSettle();
        await tester.tap(find.text(oldName));
        await tester.pumpAndSettle();
        await tester.tap(find.text('이름 변경'));
        await tester.pumpAndSettle();
        expect(find.text(oldName), findsOneWidget);
        await tester.enterText(find.byType(TextFormField), '   ');
        await tester.tap(find.text('저장'));
        await tester.pumpAndSettle();
        expect(find.text('이름을 입력해 주세요.'), findsOneWidget);
        final newName = isLitter ? '새 화장실' : '새 물그릇';
        await tester.enterText(find.byType(TextFormField), '  $newName  ');
        await tester.tap(find.text('저장'));
        await tester.pumpAndSettle();
        expect(find.text(newName), findsOneWidget);
        if (isLitter) {
          final box = (litter.state as Loaded<List<LitterBox>>).data.single;
          expect(box.name, newName);
          expect(box.catIds, [petId]);
          expect(box.baselines.single.photo, photo);
        } else {
          final bowl = (water.state as Loaded<List<WaterBowl>>).data.single;
          expect(bowl.name, newName);
          expect(bowl.petIds, [petId]);
          expect(bowl.fullWaterMl, 1000);
          expect(bowl.baselines.single.photo, photo);
        }
        await tapBackButton(tester);
        await tester.pumpAndSettle();
        expect(find.text(newName), findsOneWidget);
        await tester.ensureVisible(find.text(newName));
        await tester.tap(find.text(newName));
        await tester.pumpAndSettle();
        final deleteLabel = isLitter ? '화장실 삭제' : '물그릇 삭제';
        await tester.tap(find.text(deleteLabel));
        await tester.pumpAndSettle();
        expect(find.textContaining('기존 사진과 관찰 기록은 보관됩니다.'), findsOneWidget);
        await tester.tap(find.text('취소'));
        await tester.pumpAndSettle();
        expect(find.text(newName), findsOneWidget);
        await tester.tap(find.text(deleteLabel));
        await tester.pumpAndSettle();
        await tester.tap(find.text('삭제'));
        await tester.pumpAndSettle();
        expect(find.text(newName), findsNothing);
        expect(isLitter ? litter.state : water.state, isA<Empty>());
      },
    );
  }
}
