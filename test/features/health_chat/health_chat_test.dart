import 'dart:convert';
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_media/media.dart';
import 'package:image_picker/image_picker.dart';
import 'package:hareup/features/health_chat/domain/health_chat.dart';
import 'package:hareup/features/health_chat/presentation/health_chat_page.dart';
import 'package:hareup/features/pet/domain/pet.dart';
import 'package:hareup/l10n/l10n.dart';
import 'package:hareup_design_system/design_system.dart';

class FakeChat implements HealthChatRepository {
  String? text;
  List<String>? pets;
  Uint8List? photo;
  String? languageCode;
  bool fail = false;
  @override
  Stream<List<HealthChatMessage>> watch(String groupId) =>
      Stream.value(const []);
  @override
  Future<Uint8List?> loadPhoto(String path) async => null;
  @override
  Future<Result<void>> send({
    required String groupId,
    required String text,
    required List<String> petIds,
    String languageCode = 'ko',
    Uint8List? photo,
  }) async {
    this.text = text;
    pets = petIds;
    this.languageCode = languageCode;
    this.photo = photo;
    return fail ? const Failure(RequestFailure()) : const Success(null);
  }
}

class FakePhoto implements PhotoSource {
  @override
  Future<PhotoSelection> pickFromGallery() async => PhotoSelected(
    XFile.fromData(
      base64Decode(
        'iVBORw0KGgoAAAANSUhEUgAAAAEAAAABCAQAAAC1HAwCAAAAC0lEQVR42mP8/x8AAwMCAO+/aXkAAAAASUVORK5CYII=',
      ),
      name: 'photo.png',
    ),
  );
  @override
  Future<PhotoSelection> pickFromCamera() async => const PhotoCancelled();
  @override
  Future<PhotoSelection> recoverInterruptedSelection() async =>
      const PhotoCancelled();
}

void main() {
  testWidgets('health chat uses English strings when English is selected', (
    tester,
  ) async {
    final chat = FakeChat();
    await tester.pumpWidget(
      MaterialApp(
        locale: const Locale('en'),
        localizationsDelegates: const [
          ...AppLocalizations.localizationsDelegates,
          DesignLocalizations.delegate,
        ],
        supportedLocales: AppLocalizations.supportedLocales,
        home: HealthChatPage(
          repository: chat,
          groupId: 'family',
          pets: const [],
          photoSource: FakePhoto(),
        ),
      ),
    );
    await tester.pumpAndSettle();
    expect(find.text('Pet health chat'), findsOneWidget);
    expect(find.text("Ask about your pet's health."), findsOneWidget);
    expect(find.byTooltip('Mention pets'), findsOneWidget);
    await tester.tap(find.byTooltip('Mention pets'));
    await tester.pumpAndSettle();
    expect(find.text('No pets registered.'), findsOneWidget);
    await tester.tap(find.text('Done'));
    await tester.pumpAndSettle();
    await tester.enterText(find.byType(TextField), 'Is my cat okay?');
    await tester.tap(find.byTooltip('Send'));
    await tester.pumpAndSettle();
    expect(chat.languageCode, 'en');
  });
  testWidgets(
    'sends question with selected pet and photo; preserves draft on failure',
    (tester) async {
      final chat = FakeChat();
      await tester.pumpWidget(
        MaterialApp(
          locale: const Locale('ko'),
          localizationsDelegates: const [
            ...AppLocalizations.localizationsDelegates,
            DesignLocalizations.delegate,
          ],
          supportedLocales: AppLocalizations.supportedLocales,
          home: HealthChatPage(
            repository: chat,
            groupId: 'family',
            pets: const [Pet(id: 'cat-1', name: '나비', species: PetSpecies.cat)],
            photoSource: FakePhoto(),
          ),
        ),
      );
      await tester.pumpAndSettle();
      await tester.tap(find.byTooltip('반려동물 멘션'));
      await tester.pumpAndSettle();
      await tester.tap(find.text('나비'));
      await tester.tap(find.text('완료'));
      await tester.pumpAndSettle();
      expect(find.text('@나비'), findsOneWidget);
      await tester.tap(find.byTooltip('사진 첨부'));
      await tester.pumpAndSettle();
      await tester.enterText(find.byType(TextField), '건강 상태가 궁금해요');
      chat.fail = true;
      await tester.tap(find.byTooltip('전송'));
      await tester.pumpAndSettle();
      expect(find.text('건강 상태가 궁금해요'), findsOneWidget);
      expect(find.text('@나비'), findsOneWidget);
      ScaffoldMessenger.of(
        tester.element(find.byType(HealthChatPage)),
      ).hideCurrentSnackBar();
      await tester.pumpAndSettle();
      chat.fail = false;
      await tester.tap(find.byTooltip('전송'));
      await tester.pumpAndSettle();
      expect(chat.pets, ['cat-1']);
      expect(chat.photo, isNotEmpty);
      expect(chat.text, '건강 상태가 궁금해요');
      expect(chat.languageCode, 'ko');
      expect(find.text('@나비'), findsNothing);
    },
  );
}
