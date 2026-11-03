import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:hareup_core/core.dart';
import 'package:hareup_firebase_core/firebase_failure.dart';

import '../../photo_analysis/domain/analysis.dart';
import '../../shared_data/data/group_media_storage.dart';
import '../domain/record.dart';

/// Group-scoped durable analysis history. Record IDs use the request ID.
class FirestoreRecordsRepository implements RecordsRepository {
  FirestoreRecordsRepository({
    required FirebaseFirestore firestore,
    required FirebaseStorage storage,
  }) : _firestore = firestore,
       _media = GroupMediaStorage(storage);

  final FirebaseFirestore _firestore;
  final GroupMediaStorage _media;

  CollectionReference<Map<String, dynamic>> _records(String groupId) =>
      _firestore.collection('groups').doc(groupId).collection('records');

  @override
  Future<Result<List<ObservationRecord>>> listAll({
    required String groupId,
  }) async {
    try {
      final snapshot = await _records(groupId).get();
      final records = await Future.wait(
        snapshot.docs.map((document) => _fromJson(groupId, document.data())),
      );
      return Success(List.unmodifiable(records));
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<List<ObservationRecord>>> list({
    required String groupId,
    required String targetId,
  }) async {
    try {
      final snapshot = await _records(
        groupId,
      ).where('targetId', isEqualTo: targetId).get();
      final records = <ObservationRecord>[];
      for (final document in snapshot.docs) {
        records.add(await _fromJson(groupId, document.data()));
      }
      return Success(List.unmodifiable(records));
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<void>> updateAnnotations({
    required ObservationRecord original,
    required ObservationRecord updated,
  }) async {
    if (original.request.groupId != updated.request.groupId ||
        original.request.id != updated.request.id ||
        !validRecordAnnotations(
          original.withAnnotations(
            urineCount: updated.correctedUrineCount,
            stoolCount: updated.correctedStoolCount,
            catId: updated.selectedCatId,
            notes: updated.notes,
          ),
        )) {
      return const Failure(RequestFailure('수정한 내용을 확인해 주세요.'));
    }
    try {
      final document = _records(
        original.request.groupId,
      ).doc(original.request.id);
      return await _firestore.runTransaction((transaction) async {
        final snapshot = await transaction.get(document);
        final data = snapshot.data();
        if (data == null) return const Failure<void>(NotFoundFailure());
        if (data['correctedUrineCount'] != original.correctedUrineCount ||
            data['correctedStoolCount'] != original.correctedStoolCount ||
            data['selectedCatId'] != original.selectedCatId ||
            (data['notes'] ?? '') != original.notes) {
          return const Failure<void>(
            RequestFailure('기록이 변경되었습니다. 다시 불러온 후 수정해 주세요.'),
          );
        }
        transaction.update(document, {
          'correctedUrineCount': updated.correctedUrineCount,
          'correctedStoolCount': updated.correctedStoolCount,
          'selectedCatId': updated.selectedCatId,
          'notes': updated.notes,
        });
        return const Success<void>(null);
      });
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<void>> save(ObservationRecord record) async {
    final request = record.request;
    try {
      final baselinePath = _media.photoPath(
        groupId: request.groupId,
        collection: request.kind == AnalysisKind.water
            ? 'waterBowls'
            : 'litterBoxes',
        documentId: request.targetId,
        name: 'baselines/v${request.baseline.version}.jpg',
      );
      final photoPath = _media.photoPath(
        groupId: request.groupId,
        collection: 'records',
        documentId: request.id,
        name: 'observation.jpg',
      );
      await _media.put(path: photoPath, bytes: request.photo);

      final payload = _toJson(
        record,
        baselinePath: baselinePath,
        photoPath: photoPath,
      );
      final document = _records(request.groupId).doc(request.id);
      return await _firestore.runTransaction((transaction) async {
        final existing = await transaction.get(document);
        if (existing.exists) {
          if (_canonical(existing.data()) == _canonical(payload)) {
            return const Success(null);
          }
          return const Failure(RequestFailure('이미 저장된 분석입니다.'));
        }
        transaction.set(document, payload);
        return const Success(null);
      });
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  Map<String, dynamic> _toJson(
    ObservationRecord record, {
    required String baselinePath,
    required String photoPath,
  }) {
    final request = record.request;
    final outcome = switch (record.outcome) {
      WaterOutcome value => <String, dynamic>{
        'type': 'water',
        'percent': value.percent,
        'volumeMl': value.volumeMl,
        'confidencePercent': value.confidencePercent,
      },
      LitterOutcome value => <String, dynamic>{
        'type': 'litter',
        'urineCount': value.urineCount,
        'stoolCount': value.stoolCount,
        'observedQuantity': value.observedQuantity,
        'quantityUnit': value.quantityUnit,
        'uncertain': value.uncertain,
      },
      AnalysisUnavailable value => <String, dynamic>{
        'type': 'unavailable',
        'reason': value.reason,
      },
    };
    return {
      'id': request.id,
      'groupId': request.groupId,
      'targetId': request.targetId,
      'targetName': request.targetName,
      'kind': request.kind.name,
      'baseline': {
        'version': request.baseline.version,
        'createdAt': request.baseline.createdAt,
        'photoPath': baselinePath,
        'notes': request.baseline.notes,
      },
      'photoPath': photoPath,
      'photoSelectedAt': request.photoSelectedAt,
      'registrationPhoto': request.registrationPhoto,
      'eligibleCats': request.eligibleCats
          .map((cat) => {'id': cat.id, 'name': cat.name})
          .toList(growable: false),
      'emptyWeightGrams': request.emptyWeightGrams,
      'fullWaterMl': request.fullWaterMl,
      'widthCm': request.widthCm,
      'lengthCm': request.lengthCm,
      'litterHeightCm': request.litterHeightCm,
      'outcome': outcome,
      'analyzedAt': record.analyzedAt,
      'correctedUrineCount': record.correctedUrineCount,
      'correctedStoolCount': record.correctedStoolCount,
      'selectedCatId': record.selectedCatId,
      'notes': record.notes,
    };
  }

  Future<ObservationRecord> _fromJson(
    String groupId,
    Map<String, dynamic> data,
  ) async {
    final baseline = Map<String, dynamic>.from(data['baseline'] as Map);
    final baselineBytes = await _media.get(baseline['photoPath'] as String);
    final currentBytes = await _media.get(data['photoPath'] as String);
    final kind = AnalysisKind.values.byName(data['kind'] as String);
    final cats = (data['eligibleCats'] as List<dynamic>? ?? const [])
        .map((value) {
          final cat = Map<String, dynamic>.from(value as Map);
          return AnalysisCat(
            id: cat['id'] as String,
            name: cat['name'] as String,
          );
        })
        .toList(growable: false);
    final request = AnalysisRequest(
      id: data['id'] as String,
      groupId: groupId,
      targetId: data['targetId'] as String,
      targetName: data['targetName'] as String,
      kind: kind,
      baseline: PhotoBaseline(
        version: (baseline['version'] as num).toInt(),
        createdAt: _date(baseline['createdAt']),
        photo: baselineBytes,
        notes: baseline['notes'] as String? ?? '',
      ),
      photo: currentBytes,
      photoSelectedAt: _date(data['photoSelectedAt']),
      registrationPhoto: data['registrationPhoto'] as bool? ?? false,
      eligibleCats: cats,
      emptyWeightGrams: (data['emptyWeightGrams'] as num?)?.toDouble(),
      fullWaterMl: (data['fullWaterMl'] as num?)?.toDouble(),
      widthCm: (data['widthCm'] as num?)?.toDouble(),
      lengthCm: (data['lengthCm'] as num?)?.toDouble(),
      litterHeightCm: (data['litterHeightCm'] as num?)?.toDouble(),
    );
    final outcomeData = Map<String, dynamic>.from(data['outcome'] as Map);
    final outcome = switch (outcomeData['type']) {
      'water' => WaterOutcome(
        percent: (outcomeData['percent'] as num).toDouble(),
        volumeMl: (outcomeData['volumeMl'] as num?)?.toDouble(),
        confidencePercent: (outcomeData['confidencePercent'] as num?)
            ?.toDouble(),
      ),
      'litter' => LitterOutcome(
        urineCount: (outcomeData['urineCount'] as num).toInt(),
        stoolCount: (outcomeData['stoolCount'] as num).toInt(),
        observedQuantity: (outcomeData['observedQuantity'] as num?)?.toDouble(),
        quantityUnit: outcomeData['quantityUnit'] as String?,
        uncertain: outcomeData['uncertain'] as bool? ?? false,
      ),
      'unavailable' => AnalysisUnavailable(outcomeData['reason'] as String),
      _ => throw const FormatException('Unknown analysis outcome.'),
    };
    return ObservationRecord(
      request: request,
      outcome: outcome,
      analyzedAt: _date(data['analyzedAt']),
      correctedUrineCount: (data['correctedUrineCount'] as num?)?.toInt(),
      correctedStoolCount: (data['correctedStoolCount'] as num?)?.toInt(),
      selectedCatId: data['selectedCatId'] as String?,
      notes: data['notes'] as String? ?? '',
    );
  }

  DateTime _date(Object? value) => value is Timestamp
      ? value.toDate()
      : value is DateTime
      ? value
      : DateTime.parse(value as String);

  String _canonical(Object? value) => jsonEncode(_normalise(value));

  Object? _normalise(Object? value) {
    if (value is Timestamp) return value.toDate().microsecondsSinceEpoch;
    if (value is DateTime) return value.microsecondsSinceEpoch;
    if (value is Map) {
      final keys = value.keys.map((key) => key.toString()).toList()..sort();
      return {for (final key in keys) key: _normalise(value[key])};
    }
    if (value is Iterable) return value.map(_normalise).toList(growable: false);
    return value;
  }
}
