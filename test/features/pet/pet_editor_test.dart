import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_test/flutter_test.dart';
import '../../test_support.dart';
import 'package:hareup/features/pet/data/memory_pet_repository.dart';
import 'package:hareup/features/pet/presentation/pet_cubit.dart';
import 'package:hareup/features/pet/presentation/pet_editor.dart';
import 'package:hareup_media/media.dart';
import 'package:hareup_presentation_core/presentation_core.dart';
import 'package:hareup/features/pet/domain/pet.dart';

class DeniedPhotos implements PhotoSource {
  @override
  Future<PhotoSelection> pickFromCamera() async =>
      const PhotoSelectionFailed(PhotoFailureReason.permissionDenied);
  @override
  Future<PhotoSelection> pickFromGallery() async =>
      const PhotoSelectionFailed(PhotoFailureReason.permissionDenied);
  @override
  Future<PhotoSelection> recoverInterruptedSelection() async =>
      const PhotoCancelled();
}

void main() {
  testWidgets('사진 권한을 거부해도 선택 프로필을 저장한다', (tester) async {
    final cubit = PetCubit(MemoryPetRepository());
    await cubit.load();
    await tester.pumpWidget(
      BlocProvider.value(
        value: cubit,
        child: MaterialApp(
          theme: testTheme,
          localizationsDelegates: testLocalizationsDelegates,
          locale: const Locale('ko'),
          supportedLocales: appSupportedLocales,
          home: Scaffold(
            body: Builder(
              builder: (context) => TextButton(
                onPressed: () => Navigator.of(context).push(
                  MaterialPageRoute<void>(
                    builder: (_) => PetEditor(photoSource: DeniedPhotos()),
                  ),
                ),
                child: const Text('열기'),
              ),
            ),
          ),
        ),
      ),
    );
    await tester.tap(find.text('열기'));
    await tester.pumpAndSettle();
    expect(find.byType(AlertDialog), findsNothing);
    await tester.tap(find.text('사진 선택'));
    await tester.pump();
    expect(find.textContaining('사진 접근 권한'), findsOneWidget);
    await tester.enterText(find.widgetWithText(TextFormField, '이름'), '구름');
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, '나이 (개월, 선택)'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '나이 (개월, 선택)'),
      '12',
    );
    await tester.ensureVisible(
      find.widgetWithText(TextFormField, '체중 (kg, 선택)'),
    );
    await tester.enterText(
      find.widgetWithText(TextFormField, '체중 (kg, 선택)'),
      '4.2',
    );
    await tester.tap(find.text('저장'));
    await tester.pumpAndSettle();
    final pet = (cubit.state as Loaded<List<Pet>>).data.single;
    expect(pet.name, '구름');
    expect(pet.profile.ageMonths, 12);
    expect(pet.profile.weightKg, 4.2);
    expect(pet.profile.photoBytes, isNull);
    await tester.pumpWidget(const SizedBox());
    await tester.runAsync(cubit.close);
  });
}
