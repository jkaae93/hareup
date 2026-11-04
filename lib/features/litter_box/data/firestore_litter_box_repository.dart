import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_firebase_core/firebase_failure.dart';

import '../../shared_data/data/group_media_storage.dart';
import '../domain/litter_box.dart';

class FirestoreLitterBoxRepository implements LitterBoxRepository {
  FirestoreLitterBoxRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required this.groupId,
  }) : _firestore = firestore,
       _media = GroupMediaStorage(storage);

  final FirebaseFirestore _firestore;
  final GroupMediaStorage _media;
  final String groupId;

  CollectionReference<Map<String, dynamic>> get _boxes =>
      _firestore.collection('groups').doc(groupId).collection('litterBoxes');

  @override
  Future<Result<void>> delete(String id) async {
    try {
      await _boxes.doc(id).delete();
      return const Success(null);
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<void>> rename(String id, String name) async {
    final trimmed = name.trim();
    if (trimmed.isEmpty || trimmed.length > 30) {
      return const Failure(RequestFailure());
    }
    try {
      await _boxes.doc(id).update({'name': trimmed});
      return const Success(null);
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<List<LitterBox>>> list() async {
    try {
      final snapshot = await _boxes.orderBy('name').get();
      final boxes = <LitterBox>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final baselines = <LitterBaseline>[];
        for (final value in (data['baselines'] as List<dynamic>? ?? const [])) {
          final item = Map<String, dynamic>.from(value as Map);
          baselines.add(
            LitterBaseline(
              version: (item['version'] as num).toInt(),
              createdAt: _date(item['createdAt']),
              photo: await _media.get(item['photoPath'] as String),
            ),
          );
        }
        boxes.add(
          LitterBox(
            id: doc.id,
            name: data['name'] as String,
            catIds: List<String>.from(
              data['catIds'] as List<dynamic>? ?? const [],
            ),
            widthCm: (data['widthCm'] as num?)?.toDouble(),
            lengthCm: (data['lengthCm'] as num?)?.toDouble(),
            litterHeightCm: (data['litterHeightCm'] as num?)?.toDouble(),
            baselines: baselines,
          ),
        );
      }
      return Success(List.unmodifiable(boxes));
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<void>> create(LitterBox box) async {
    if (box.baselines.isEmpty) return const Failure(RequestFailure());
    try {
      final baselineData = <Map<String, dynamic>>[];
      for (final baseline in box.baselines) {
        final path = _media.photoPath(
          groupId: groupId,
          collection: 'litterBoxes',
          documentId: box.id,
          name: 'baselines/v${baseline.version}.jpg',
        );
        await _media.put(path: path, bytes: baseline.photo);
        baselineData.add({
          'version': baseline.version,
          'createdAt': baseline.createdAt,
          'photoPath': path,
        });
      }
      final document = _boxes.doc(box.id);
      return await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(document);
        if (existing.exists) {
          return const Failure(
            RequestFailure(
              '이미 등록된 화장실입니다.',
              FailureMessageKeys.litterAlreadyRegistered,
            ),
          );
        }
        transaction.set(document, {
          'name': box.name,
          'catIds': box.catIds,
          'widthCm': box.widthCm,
          'lengthCm': box.lengthCm,
          'litterHeightCm': box.litterHeightCm,
          'baselines': baselineData,
        });
        return const Success(null);
      });
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<void>> replaceBaseline(
    String id,
    Uint8List photo,
    DateTime time,
  ) async {
    if (photo.isEmpty) return const Failure(RequestFailure());
    try {
      final reference = _boxes.doc(id);
      final snapshot = await reference.get();
      if (!snapshot.exists) return const Failure(NotFoundFailure());
      final data = snapshot.data()!;
      final current = List<Map<String, dynamic>>.from(
        (data['baselines'] as List<dynamic>).map(
          (item) => Map<String, dynamic>.from(item as Map),
        ),
      );
      final version =
          current
              .map((item) => (item['version'] as num).toInt())
              .fold<int>(
                0,
                (largest, value) => value > largest ? value : largest,
              ) +
          1;
      final path = _media.photoPath(
        groupId: groupId,
        collection: 'litterBoxes',
        documentId: id,
        name: 'baselines/v$version.jpg',
      );
      await _media.put(path: path, bytes: photo);
      current.add({'version': version, 'createdAt': time, 'photoPath': path});
      await reference.update({'baselines': current});
      return const Success(null);
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  DateTime _date(Object? value) => value is Timestamp
      ? value.toDate()
      : value is DateTime
      ? value
      : DateTime.parse(value as String);
}
