import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:hareup/features/litter_box/data/memory_litter_box_repository.dart';
import 'package:hareup/features/litter_box/domain/litter_box.dart';
import 'package:hareup/features/litter_box/presentation/litter_box_cubit.dart';
import 'package:hareup/features/litter_box/presentation/litter_box_page.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import 'package:image_picker/image_picker.dart';

class FakePhoto implements PhotoSource {
  @override
  Future<PhotoSelection> pickFromCamera() => pickFromGallery();
  @override
  Future<PhotoSelection> pickFromGallery() async => PhotoSelected(
    XFile.fromData(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
      ),
      name: 'sample.png',
    ),
  );
  @override
  Future<PhotoSelection> recoverInterruptedSelection() async =>
      const PhotoCancelled();
}

void main() {
  test(
    'rejects automatic, invalid dimensions and keeps previous baselines',
    () async {
      final cubit = LitterBoxCubit(MemoryLitterBoxRepository());
      await cubit.load();
      final photo = Uint8List.fromList([1, 2]);
      expect(
        await cubit.create(
          name: '화장실',
          catIds: ['a'],
          photo: photo,
          isAutomatic: true,
        ),
        isFalse,
      );
      expect(
        await cubit.create(
          name: '화장실',
          catIds: ['a'],
          photo: photo,
          isAutomatic: false,
          widthCm: 0,
        ),
        isFalse,
      );
      expect(
        await cubit.create(
          name: '화장실',
          catIds: [],
          photo: photo,
          isAutomatic: false,
        ),
        isFalse,
      );
      expect(
        await cubit.create(
          name: ' 화장실 ',
          catIds: ['a', 'b'],
          photo: photo,
          isAutomatic: false,
          widthCm: 40,
        ),
        isTrue,
      );
      photo[0] = 9;
      final box = (cubit.state as Loaded<List<LitterBox>>).data.single;
      expect(box.widthCm, 40);
      expect(box.lengthCm, isNull);
      expect(box.currentBaseline.photo, [1, 2]);
      expect(
        await cubit.changeBaseline(box.id, Uint8List.fromList([3])),
        isTrue,
      );
      final updated = (cubit.state as Loaded<List<LitterBox>>).data.single;
      expect(updated.baselines.map((e) => e.version), [1, 2]);
      expect(updated.baselines.first.photo, [1, 2]);
      expect(updated.currentBaseline.photo, [3]);
      await cubit.close();
    },
  );

  testWidgets(
    'blocks automatic box and permits regular box with partial dimensions',
    (tester) async {
      final cubit = LitterBoxCubit(MemoryLitterBoxRepository());
      await cubit.load();
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: testTheme,
            localizationsDelegates: testLocalizationsDelegates,
            locale: const Locale('ko'),
            supportedLocales: appSupportedLocales,
            home: LitterBoxPage(
              cats: const [CatOption(id: 'a', name: '나비')],
              photoSource: FakePhoto(),
            ),
          ),
        ),
      );
      await tester.tap(find.text('화장실 추가'));
      await tester.pumpAndSettle();
      expect(find.byType(AlertDialog), findsNothing);
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.tap(find.byType(SwitchListTile));
      await tester.pumpAndSettle();
      expect(find.text('자동화장실은 분석 대상으로 등록할 수 없습니다.'), findsOneWidget);
      expect(
        tester
            .widget<FilledButton>(find.widgetWithText(FilledButton, '등록'))
            .onPressed,
        isNull,
      );
      await tester.ensureVisible(find.byType(SwitchListTile));
      await tester.tap(find.byType(SwitchListTile));
      await tester.enterText(
        find.widgetWithText(TextFormField, '화장실 이름'),
        '화장실 A',
      );
      await tester.ensureVisible(find.text('나비'));
      await tester.tap(find.text('나비'));
      await tester.ensureVisible(
        find.widgetWithText(TextFormField, '내부 가로 (cm, 선택)'),
      );
      await tester.enterText(
        find.widgetWithText(TextFormField, '내부 가로 (cm, 선택)'),
        '40',
      );
      await tester.ensureVisible(find.text('기준 사진 선택'));
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      await tester.tap(find.text('기준 사진 선택'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('등록'));
      await tester.pumpAndSettle();
      expect(find.text('화장실 A'), findsOneWidget);
      expect(
        (cubit.state as Loaded<List<LitterBox>>).data.single.lengthCm,
        isNull,
      );
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(cubit.close);
    },
  );
}
