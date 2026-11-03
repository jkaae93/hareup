import 'dart:typed_data';

import 'package:firebase_storage/firebase_storage.dart';

/// Stores feature photos under the approved family's namespace.
/// Firestore/Storage rules remain the authority for membership and role checks.
class GroupMediaStorage {
  GroupMediaStorage(this._storage);

  final FirebaseStorage _storage;

  String photoPath({
    required String groupId,
    required String collection,
    required String documentId,
    required String name,
  }) => 'groups/$groupId/$collection/$documentId/$name';

  Future<String> put({required String path, required Uint8List bytes}) async {
    if (bytes.isEmpty) {
      throw ArgumentError.value(bytes, 'bytes', 'Cannot be empty');
    }
    await _storage
        .ref(path)
        .putData(bytes, SettableMetadata(contentType: 'image/jpeg'));
    return path;
  }

  Future<Uint8List> get(String path) async {
    final bytes = await _storage.ref(path).getData(20 * 1024 * 1024);
    if (bytes == null) throw StateError('Stored image is missing.');
    return bytes;
  }

  Future<void> remove(String path) => _storage.ref(path).delete();
}
