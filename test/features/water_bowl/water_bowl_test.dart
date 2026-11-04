import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:hareup/features/water_bowl/data/memory_water_bowl_repository.dart';
import 'package:hareup/features/water_bowl/domain/water_bowl.dart';
import 'package:hareup/features/water_bowl/domain/water_level.dart';
import 'package:hareup/features/water_bowl/presentation/water_bowl_cubit.dart';
import 'package:hareup/features/water_bowl/presentation/water_bowl_page.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hareup/features/photo_analysis/data/unavailable_analysis_service.dart';
import 'package:hareup/features/photo_analysis/domain/analysis.dart';
import 'package:hareup/features/records/data/memory_records_repository.dart';

class SamplePhoto implements PhotoSource {
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

class RecordingAnalysis implements AnalysisService, WaterLevelService {
  final setups = <Map<String, Uint8List>>[];
  @override
  Future<Result<WaterLevelResult>> observeWaterLevel({
    required String groupId,
    required String bowlId,
    required String requestId,
    required bool setup,
    Map<String, Uint8List> photos = const {},
    Uint8List? photo,
  }) async {
    if (setup) setups.add(Map.of(photos));
    return const Success(
      WaterLevelResult(status: "uncertain", reason: "수위 확인 불가"),
    );
  }

  final requests = <AnalysisRequest>[];
  @override
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request) async {
    requests.add(request);
    return const Success(AnalysisUnavailable('사진을 확인할 수 없습니다.'));
  }
}

void main() {
  test(
    'requires a pet and baseline; preserves baseline versions and copied bytes',
    () async {
      final cubit = WaterBowlCubit(MemoryWaterBowlRepository());
      await cubit.load();
      final photo = Uint8List.fromList([1, 2, 3]);
      expect(await cubit.create(name: '물', petIds: [], photo: photo), isFalse);
      expect(
        await cubit.create(name: '물', petIds: ['pet'], photo: Uint8List(0)),
        isFalse,
      );
      expect(
        await cubit.create(
          name: '물',
          petIds: ['pet'],
          photo: photo,
          fullWaterMl: -1,
        ),
        isFalse,
      );
      expect(
        await cubit.create(
          name: ' 물그릇 ',
          petIds: ['cat', 'dog'],
          photo: photo,
          fullWaterMl: 500,
        ),
        isTrue,
      );
      photo[0] = 9;
      final original = (cubit.state as Loaded<List<WaterBowl>>).data.single;
      expect(original.name, '물그릇');
      expect(original.petIds, ['cat', 'dog']);
      expect(original.emptyWeightGrams, isNull);
      expect(original.currentBaseline.photo, [1, 2, 3]);
      expect(
        await cubit.changeBaseline(original.id, Uint8List.fromList([4, 5])),
        isTrue,
      );
      final updated = (cubit.state as Loaded<List<WaterBowl>>).data.single;
      expect(updated.baselines.map((item) => item.version), [1, 2]);
      expect(updated.baselines.first.photo, [1, 2, 3]);
      expect(updated.currentBaseline.photo, [4, 5]);
      expect(
        await cubit.changeBaseline('missing', Uint8List.fromList([1])),
        isFalse,
      );
      await cubit.close();
    },
  );

  testWidgets(
    'registers bowl with selected pets and photo without optional measurements',
    (tester) async {
      final cubit = WaterBowlCubit(MemoryWaterBowlRepository());
      await cubit.load();
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: testTheme,
            localizationsDelegates: testLocalizationsDelegates,
            locale: const Locale('ko'),
            supportedLocales: appSupportedLocales,
            home: WaterBowlPage(
              pets: const [BowlPetOption(id: 'a', name: '나비')],
              photoSource: SamplePhoto(),
              analysisRuntime: const AnalysisRuntime(
                service: UnavailableAnalysisService(),
                groupId: 'local-development',
              ),
              recordsRepository: MemoryRecordsRepository(),
            ),
          ),
        ),
      );
      await tester.tap(find.text('물그릇 추가'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, '그릇 이름'),
        '하루 물그릇',
      );
      await tester.ensureVisible(find.text('나비'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('나비'));
      for (final angle in ['앞', '뒤', '위']) {
        await tester.ensureVisible(find.text('$angle 사진 선택'));
        await tester.tap(find.text('$angle 사진 선택'));
        await tester.pumpAndSettle();
        expect(find.text('$angle 사진 선택됨'), findsOneWidget);
      }
      await tester.tap(find.text('등록'));
      await tester.pumpAndSettle();
      expect(find.text('하루 물그릇'), findsOneWidget);
      await tester.tap(find.text('하루 물그릇'));
      await tester.pumpAndSettle();
      expect(find.textContaining('정수기 사진 1번째'), findsWidgets);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(cubit.close);
    },
  );
  for (final field in ['가득 찬 물의 양 (mL, 선택)']) {
    testWidgets('registration analysis is saved for $field', (tester) async {
      final cubit = WaterBowlCubit(MemoryWaterBowlRepository());
      final records = MemoryRecordsRepository();
      final service = RecordingAnalysis();
      await cubit.load();
      await tester.pumpWidget(
        BlocProvider.value(
          value: cubit,
          child: MaterialApp(
            theme: testTheme,
            localizationsDelegates: testLocalizationsDelegates,
            locale: const Locale('ko'),
            supportedLocales: appSupportedLocales,
            home: WaterBowlPage(
              pets: const [BowlPetOption(id: 'a', name: '나비')],
              photoSource: SamplePhoto(),
              analysisRuntime: AnalysisRuntime(
                service: service,
                groupId: 'group',
              ),
              recordsRepository: records,
            ),
          ),
        ),
      );
      await tester.tap(find.text('물그릇 추가'));
      await tester.pumpAndSettle();
      await tester.enterText(
        find.widgetWithText(TextFormField, '그릇 이름'),
        '물그릇',
      );
      await tester.ensureVisible(find.text('나비'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('나비'));
      await tester.ensureVisible(find.widgetWithText(TextFormField, field));
      await tester.enterText(find.widgetWithText(TextFormField, field), '500');
      tester.testTextInput.hide();
      await tester.pumpAndSettle();
      for (final angle in ['앞', '뒤', '위']) {
        await tester.ensureVisible(find.text('$angle 사진 선택'));
        await tester.tap(find.text('$angle 사진 선택'));
        await tester.pumpAndSettle();
      }
      await tester.tap(find.text('등록'));
      await tester.pumpAndSettle();
      final bowl = (cubit.state as Loaded<List<WaterBowl>>).data.single;
      expect(
        bowl.registrationPhotos.keys,
        containsAll(['front', 'back', 'top']),
      );
      expect(service.setups.single.keys, containsAll(['front', 'back', 'top']));
      expect(service.requests, isEmpty);
      await tester.pumpWidget(const SizedBox());
      await tester.runAsync(cubit.close);
    });
  }
  testWidgets('changes baseline when the cubit is below the navigator', (
    tester,
  ) async {
    final cubit = WaterBowlCubit(MemoryWaterBowlRepository());
    await cubit.load();
    await cubit.create(
      name: '물그릇',
      petIds: ['a'],
      photo: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
      ),
    );
    await tester.pumpWidget(
      MaterialApp(
        theme: testTheme,
        localizationsDelegates: testLocalizationsDelegates,
        locale: const Locale('ko'),
        supportedLocales: appSupportedLocales,
        home: BlocProvider.value(
          value: cubit,
          child: WaterBowlPage(
            pets: const [BowlPetOption(id: 'a', name: '나비')],
            photoSource: SamplePhoto(),
            analysisRuntime: const AnalysisRuntime(
              service: UnavailableAnalysisService(),
              groupId: 'group',
            ),
            recordsRepository: MemoryRecordsRepository(),
          ),
        ),
      ),
    );
    await tester.tap(find.text('물그릇'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.ensureVisible(find.text('새 사진 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('새 사진 선택'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.enterText(
      find.widgetWithText(TextField, '사진 특이사항 (선택)'),
      '물이 70% 차 있음',
    );
    await tester.tap(find.text('정수기 사진 저장'));
    await tester.pumpAndSettle();
    expect(
      (cubit.state as Loaded<List<WaterBowl>>).data.single.baselines.length,
      2,
    );
    expect(
      (cubit.state as Loaded<List<WaterBowl>>)
          .data
          .single
          .currentBaseline
          .notes,
      '물이 70% 차 있음',
    );
    expect(find.text('사진을 읽지 못했습니다.'), findsNothing);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });
  testWidgets('empty bowl weight alone does not trigger analysis', (
    tester,
  ) async {
    final cubit = WaterBowlCubit(MemoryWaterBowlRepository());
    final service = RecordingAnalysis();
    await cubit.load();
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: testTheme,
          localizationsDelegates: testLocalizationsDelegates,
          locale: const Locale('ko'),
          supportedLocales: appSupportedLocales,
          home: WaterBowlPage(
            pets: const [BowlPetOption(id: 'a', name: '나비')],
            photoSource: SamplePhoto(),
            analysisRuntime: AnalysisRuntime(
              service: service,
              groupId: 'group',
            ),
            recordsRepository: MemoryRecordsRepository(),
          ),
        ),
      ),
    );
    await tester.tap(find.text('물그릇 추가'));
    await tester.pumpAndSettle();
    await tester.enterText(find.widgetWithText(TextFormField, '그릇 이름'), '물그릇');
    await tester.ensureVisible(find.text('나비'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('나비'));
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, '빈 그릇 무게 (g, 선택)'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '빈 그릇 무게 (g, 선택)'),
      '500',
    );
    tester.testTextInput.hide();
    await tester.pumpAndSettle();
    for (final angle in ['앞', '뒤', '위']) {
      await tester.ensureVisible(find.text('$angle 사진 선택'));
      await tester.tap(find.text('$angle 사진 선택'));
      await tester.pumpAndSettle();
    }
    await tester.tap(find.text('등록'));
    await tester.pumpAndSettle();
    expect(service.setups, hasLength(1));
    expect((cubit.state as Loaded<List<WaterBowl>>).data, hasLength(1));
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });
  testWidgets('reanalyzes the current baseline and saves a new record', (
    tester,
  ) async {
    final cubit = WaterBowlCubit(MemoryWaterBowlRepository());
    final service = RecordingAnalysis();
    final records = MemoryRecordsRepository();
    await cubit.load();
    await cubit.create(
      name: '물그릇',
      petIds: ['a'],
      photo: base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
      ),
      fullWaterMl: 500,
      registrationPhotos: {
        'front': Uint8List.fromList([1]),
        'back': Uint8List.fromList([2]),
        'top': Uint8List.fromList([3]),
      },
    );
    final bowl = (cubit.state as Loaded<List<WaterBowl>>).data.single;
    await tester.pumpWidget(
      MaterialApp(
        theme: testTheme,
        localizationsDelegates: testLocalizationsDelegates,
        locale: const Locale('ko'),
        supportedLocales: appSupportedLocales,
        home: BlocProvider.value(
          value: cubit,
          child: WaterBowlPage(
            pets: const [],
            photoSource: SamplePhoto(),
            analysisRuntime: AnalysisRuntime(
              service: service,
              groupId: 'group',
            ),
            recordsRepository: records,
          ),
        ),
      ),
    );
    await tester.tap(find.text('물그릇'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('등록 사진 다시 분석하기'), 300);
    await tester.tap(find.text('등록 사진 다시 분석하기'));
    await tester.pumpAndSettle();
    await tester.scrollUntilVisible(find.text('등록 사진 다시 분석하기'), 300);
    await tester.tap(find.text('등록 사진 다시 분석하기'));
    await tester.pumpAndSettle();
    expect(service.setups, hasLength(2));
    expect(service.setups.first['front'], bowl.registrationPhotos['front']);
    expect(service.requests, isEmpty);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });
}
