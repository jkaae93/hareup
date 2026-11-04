import 'dart:typed_data';
import 'package:hareup_core/core.dart';

class HealthChatMessage {
  const HealthChatMessage({
    required this.id,
    required this.role,
    required this.text,
    required this.createdAt,
    this.mentions = const [],
    this.photoPath,
    this.sequence = 0,
  });
  final String id;
  final String role;
  final String text;
  final DateTime createdAt;
  final List<String> mentions;
  final String? photoPath;
  final int sequence;
}

abstract interface class HealthChatRepository {
  Stream<List<HealthChatMessage>> watch(String groupId);
  Future<Result<void>> send({
    required String groupId,
    required String text,
    required List<String> petIds,
    String languageCode = 'ko',
    Uint8List? photo,
  });
  Future<Uint8List?> loadPhoto(String path);
}
