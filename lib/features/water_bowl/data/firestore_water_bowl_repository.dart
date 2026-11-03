import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_firebase_core/firebase_failure.dart';

import '../../shared_data/data/group_media_storage.dart';
import '../domain/water_bowl.dart';
import '../domain/water_level.dart';

class FirestoreWaterBowlRepository implements WaterBowlRepository {
  FirestoreWaterBowlRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
    required this.groupId,
  }) : _firestore = firestore,
       _media = GroupMediaStorage(storage);

  final FirebaseFirestore _firestore;
  final GroupMediaStorage _media;
  final String groupId;

  CollectionReference<Map<String, dynamic>> get _bowls =>
      _firestore.collection('groups').doc(groupId).collection('waterBowls');

  @override
  Future<Result<List<WaterBowl>>> list() async {
    try {
      final snapshot = await _bowls.orderBy('name').get();
      final bowls = <WaterBowl>[];
      for (final doc in snapshot.docs) {
        final data = doc.data();
        final registrationPhotos = <String, Uint8List>{};
        final photoPaths = Map<String, dynamic>.from(
          data['registrationPhotoPaths'] as Map? ?? const {},
        );
        for (final entry in photoPaths.entries) {
          registrationPhotos[entry.key] = await _media.get(
            entry.value as String,
          );
        }
        final baselines = <WaterBaseline>[];
        for (final value in (data['baselines'] as List<dynamic>? ?? const [])) {
          final item = Map<String, dynamic>.from(value as Map);
          baselines.add(
            WaterBaseline(
              version: (item['version'] as num).toInt(),
              createdAt: _date(item['createdAt']),
              photo: await _media.get(item['photoPath'] as String),
              notes: item['notes'] as String? ?? '',
            ),
          );
        }
        bowls.add(
          WaterBowl(
            id: doc.id,
            name: data['name'] as String,
            petIds: List<String>.from(
              data['petIds'] as List<dynamic>? ?? const [],
            ),
            emptyWeightGrams: (data['emptyWeightGrams'] as num?)?.toDouble(),
            fullWaterMl: (data['fullWaterMl'] as num?)?.toDouble(),
            levelProfile: data['levelProfile'] is Map
                ? WaterLevelProfile(
                    conditions:
                        (data['levelProfile'] as Map)['conditions'] as String,
                    createdAt: _date(
                      (data['levelProfile'] as Map)['createdAt'],
                    ),
                  )
                : null,
            baselines: baselines,
            registrationPhotos: registrationPhotos,
          ),
        );
      }
      return Success(List.unmodifiable(bowls));
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<void>> create(WaterBowl bowl) async {
    if (bowl.baselines.isEmpty) return const Failure(RequestFailure());
    try {
      final registrationPhotoPaths = <String, String>{};
      for (final entry in bowl.registrationPhotos.entries) {
        final path = _media.photoPath(
          groupId: groupId,
          collection: 'waterBowls',
          documentId: bowl.id,
          name: 'registration/${entry.key}.jpg',
        );
        await _media.put(path: path, bytes: entry.value);
        registrationPhotoPaths[entry.key] = path;
      }
      final baselineData = <Map<String, dynamic>>[];
      for (final baseline in bowl.baselines) {
        final path = _media.photoPath(
          groupId: groupId,
          collection: 'waterBowls',
          documentId: bowl.id,
          name: 'baselines/v${baseline.version}.jpg',
        );
        await _media.put(path: path, bytes: baseline.photo);
        baselineData.add({
          'version': baseline.version,
          'createdAt': baseline.createdAt,
          'photoPath': path,
          'notes': baseline.notes,
        });
      }
      final document = _bowls.doc(bowl.id);
      return await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(document);
        if (existing.exists) {
          return const Failure(RequestFailure('이미 등록된 물그릇입니다.'));
        }
        transaction.set(document, {
          'name': bowl.name,
          'petIds': bowl.petIds,
          'emptyWeightGrams': bowl.emptyWeightGrams,
          'fullWaterMl': bowl.fullWaterMl,
          if (bowl.levelProfile case final profile?)
            'levelProfile': {
              'conditions': profile.conditions,
              'createdAt': profile.createdAt,
            },
          'baselines': baselineData,
          'registrationPhotoPaths': registrationPhotoPaths,
        });
        return const Success(null);
      });
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<void>> replaceBaseline(
    String bowlId,
    Uint8List photo,
    DateTime createdAt, {
    String notes = '',
  }) async {
    if (photo.isEmpty) return const Failure(RequestFailure());
    try {
      final reference = _bowls.doc(bowlId);
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
        collection: 'waterBowls',
        documentId: bowlId,
        name: 'baselines/v$version.jpg',
      );
      await _media.put(path: path, bytes: photo);
      current.add({
        'version': version,
        'createdAt': createdAt,
        'photoPath': path,
        'notes': notes,
      });
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
