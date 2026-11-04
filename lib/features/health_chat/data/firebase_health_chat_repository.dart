import 'dart:convert';
import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_firebase_core/firebase_failure.dart';
import '../domain/health_chat.dart';

class FirebaseHealthChatRepository implements HealthChatRepository {
  FirebaseHealthChatRepository({
    required this.firestore,
    required this.functions,
    required this.storage,
  });
  final FirebaseFirestore firestore;
  final FirebaseFunctions functions;
  final FirebaseStorage storage;

  @override
  Stream<List<HealthChatMessage>> watch(String groupId) => firestore
      .collection('groups')
      .doc(groupId)
      .collection('healthChatMessages')
      .orderBy('createdAt', descending: true)
      .limit(100)
      .snapshots()
      .map((snapshot) {
        final messages = snapshot.docs.map((doc) {
          final data = doc.data();
          return HealthChatMessage(
            id: doc.id,
            role: data['role'] as String,
            text: data['text'] as String? ?? '',
            createdAt:
                (data['createdAt'] as Timestamp?)?.toDate() ??
                DateTime.fromMillisecondsSinceEpoch(0),
            sequence: (data['sequence'] as num?)?.toInt() ?? 0,
            photoPath: data['photoPath'] as String?,
            mentions: (data['mentions'] as List<dynamic>? ?? [])
                .map((item) => (item as Map)['name'] as String)
                .toList(),
          );
        }).toList();
        messages.sort((a, b) {
          final byTime = a.createdAt.compareTo(b.createdAt);
          return byTime != 0 ? byTime : a.sequence.compareTo(b.sequence);
        });
        return messages;
      });

  @override
  Future<Result<void>> send({
    required String groupId,
    required String text,
    required List<String> petIds,
    String languageCode = 'ko',
    Uint8List? photo,
  }) async {
    try {
      await functions
          .httpsCallable(
            'askPetHealth',
            options: HttpsCallableOptions(timeout: const Duration(seconds: 85)),
          )
          .call({
            'groupId': groupId,
            'message': text.trim(),
            'petIds': petIds,
            'languageCode': languageCode,
            'requestId': 'chat-${DateTime.now().microsecondsSinceEpoch}',
            if (photo != null) 'photoBase64': base64Encode(photo),
          });
      return const Success(null);
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Uint8List?> loadPhoto(String path) =>
      storage.ref(path).getData(3 * 1024 * 1024);
}

class UnavailableHealthChatRepository implements HealthChatRepository {
  const UnavailableHealthChatRepository();
  @override
  Stream<List<HealthChatMessage>> watch(String groupId) =>
      Stream.value(const []);
  @override
  Future<Result<void>> send({
    required String groupId,
    required String text,
    required List<String> petIds,
    String languageCode = 'ko',
    Uint8List? photo,
  }) async => const Failure(
    RequestFailure('건강 상담 연결을 사용할 수 없습니다.', FailureMessageKeys.chatUnavailable),
  );
  @override
  Future<Uint8List?> loadPhoto(String path) async => null;
}
