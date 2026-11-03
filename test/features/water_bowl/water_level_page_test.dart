import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_media/media.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hareup/features/photo_analysis/domain/analysis.dart';
import 'package:hareup/features/water_bowl/domain/water_bowl.dart';
import 'package:hareup/features/water_bowl/domain/water_level.dart';
import 'package:hareup/features/water_bowl/presentation/water_level_page.dart';

class FakeSource implements PhotoSource {
  @override
  Future<PhotoSelection> pickFromCamera() => pickFromGallery();
  @override
  Future<PhotoSelection> pickFromGallery() async => PhotoSelected(
    XFile.fromData(Uint8List.fromList([1, 2, 3]), name: 'water.jpg'),
  );
  @override
  Future<PhotoSelection> recoverInterruptedSelection() async =>
      const PhotoCancelled();
}

class FakeService implements AnalysisService, WaterLevelService {
  final requests = <bool>[];
  @override
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request) async =>
      const Success(AnalysisUnavailable('unused'));
  @override
  Future<Result<WaterLevelResult>> observeWaterLevel({
    required String groupId,
    required String bowlId,
    required String requestId,
    required bool setup,
    Map<String, Uint8List> photos = const {},
    Uint8List? photo,
  }) async {
    requests.add(setup);
    return Success(
      WaterLevelResult(
        status: 'ok',
        current: setup ? 70 : 50,
        previous: setup ? null : 70,
      ),
    );
  }
}

void main() {
  testWidgets('setup followed by one photo observation shows change', (
    tester,
  ) async {
    final service = FakeService();
    final now = DateTime.utc(2026);
    final bowl = WaterBowl(
      id: 'bowl',
      name: '정수기',
      petIds: const ['pet'],
      baselines: [
        PhotoBaseline(
          version: 1,
          createdAt: now,
          photo: Uint8List.fromList([1]),
        ),
      ],
      registrationPhotos: {
        'front': Uint8List.fromList([1]),
        'back': Uint8List.fromList([2]),
        'top': Uint8List.fromList([3]),
      },
    );
    await tester.pumpWidget(
      MaterialApp(
        home: WaterLevelPage(
          bowl: bowl,
          photoSource: FakeSource(),
          runtime: AnalysisRuntime(
            service: service,
            groupId: 'group',
            validation: const AnalysisValidation(waterPercent: true),
          ),
        ),
      ),
    );
    await tester.scrollUntilVisible(find.text('초기 설정 분석'), 300);
    await tester.tap(find.text('초기 설정 분석'));
    await tester.pumpAndSettle();
    expect(service.requests, [true]);
    expect(find.text('현재 수위: 70.0% (추정)'), findsOneWidget);
    await tester.tap(find.text('사진 선택'));
    await tester.pumpAndSettle();
    await tester.tap(find.text('수위 분석'));
    await tester.pumpAndSettle();
    expect(service.requests, [true, false]);
    expect(find.text('이전보다 20.0%p 감소'), findsOneWidget);
  });
}
