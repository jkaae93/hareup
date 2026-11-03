import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_functions/cloud_functions.dart' hide Result;
import 'package:hareup_core/core.dart';
import 'package:hareup_firebase_core/firebase_failure.dart';

import '../domain/analysis.dart';
import '../../water_bowl/domain/water_level.dart';

Future<Object?> callAnalysisWithRetry(
  Future<Object?> Function() call, {
  required bool registrationPhoto,
}) async {
  for (var attempt = 0; ; attempt++) {
    try {
      final data = await call();
      if (attempt == 0 &&
          !registrationPhoto &&
          data is Map &&
          data['status'] == 'uncertain') {
        continue;
      }
      return data;
    } on FirebaseFunctionsException catch (error) {
      if (attempt == 0 &&
          const {'unavailable', 'deadline-exceeded'}.contains(error.code)) {
        continue;
      }
      rethrow;
    }
  }
}

/// Calls the authenticated server function; the Meta credential stays server-side.
class FirebaseMetaAnalysisService
    implements AnalysisService, WaterLevelService, WaterLevelHistoryService {
  FirebaseMetaAnalysisService({required FirebaseFunctions functions})
    : _analyzePhoto = functions.httpsCallable('analyzePhoto'),
      _historyWater = functions.httpsCallable('listWaterLevelReadings'),
      _observeWater = functions.httpsCallable(
        'observeWaterLevel',
        options: HttpsCallableOptions(timeout: const Duration(seconds: 130)),
      );

  final HttpsCallable _analyzePhoto;
  final HttpsCallable _observeWater;
  final HttpsCallable _historyWater;

  @override
  Future<Result<List<WaterLevelHistoryItem>>> listWaterLevels({
    required String groupId,
    required String bowlId,
  }) async {
    try {
      final data = (await _historyWater.call({
        'groupId': groupId,
        'bowlId': bowlId,
      })).data;
      if (data is! Map || data['readings'] is! List) {
        return const Failure(SerializationFailure());
      }
      final items = <WaterLevelHistoryItem>[];
      for (final item in data['readings'] as List) {
        if (item is! Map || item['status'] != 'ok') {
          return const Failure(SerializationFailure());
        }
        final current = _asDouble(item['currentFillPercent']);
        final previous = _asDouble(item['previousFillPercent']);
        if (current == null ||
            current < 0 ||
            current > 100 ||
            (previous != null && (previous < 0 || previous > 100))) {
          return const Failure(SerializationFailure());
        }
        items.add(
          WaterLevelHistoryItem(
            result: WaterLevelResult(
              status: 'ok',
              current: current,
              previous: previous,
              reason: item['reason'] is String ? item['reason'] as String : '',
            ),
            createdAt: item['createdAt'] is String
                ? DateTime.tryParse(item['createdAt'] as String)
                : null,
            setup: item['setup'] == true,
          ),
        );
      }
      return Success(List.unmodifiable(items));
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  @override
  Future<Result<WaterLevelResult>> observeWaterLevel({
    required String groupId,
    required String bowlId,
    required String requestId,
    required bool setup,
    Map<String, Uint8List> photos = const {},
    Uint8List? photo,
  }) async {
    final images = setup ? photos.values : [?photo];
    if ((setup &&
            ![
              'front',
              'back',
              'top',
            ].every((key) => photos[key]?.isNotEmpty == true)) ||
        (!setup && (photo == null || photo.isEmpty))) {
      return const Failure(RequestFailure('필요한 사진을 선택해 주세요.'));
    }
    if (images.any(
      (image) =>
          image.lengthInBytes > _maxImageBytes || _imageType(image) == null,
    )) {
      return const Failure(
        RequestFailure('각 사진은 3MB 이하의 JPEG, PNG 또는 WebP여야 합니다.'),
      );
    }
    try {
      final data = (await _observeWater.call(<String, Object>{
        'groupId': groupId,
        'bowlId': bowlId,
        'requestId': requestId,
        'setup': setup,
        if (setup)
          'photos': photos.map(
            (key, value) => MapEntry(key, base64Encode(value)),
          ),
        if (!setup) 'photo': base64Encode(photo!),
      })).data;
      if (data is! Map || !['ok', 'uncertain'].contains(data['status'])) {
        return const Failure(SerializationFailure());
      }
      final current = _asDouble(data['currentFillPercent']);
      final previous = _asDouble(data['previousFillPercent']);
      if (data['status'] == 'ok' &&
          (current == null ||
              current < 0 ||
              current > 100 ||
              (!setup &&
                  (previous == null || previous < 0 || previous > 100)))) {
        return const Failure(SerializationFailure());
      }
      return Success(
        WaterLevelResult(
          status: data['status'] as String,
          current: current,
          previous: previous,
          reason: data['reason'] is String ? data['reason'] as String : '',
        ),
      );
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  static const _maxImageBytes = 3 * 1024 * 1024;

  @override
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request) async {
    final baseline = request.baseline.photo;
    final photo = request.photo;
    if (baseline.isEmpty || photo.isEmpty) {
      return const Failure(RequestFailure('기준 사진과 비교할 사진을 확인해 주세요.'));
    }
    if (baseline.lengthInBytes > _maxImageBytes ||
        photo.lengthInBytes > _maxImageBytes ||
        request.registrationPhotos.values.any(
          (value) => value.lengthInBytes > _maxImageBytes,
        )) {
      return const Failure(RequestFailure('분석할 사진은 각각 3MB 이하여야 합니다.'));
    }
    final baselineType = _imageType(baseline);
    final photoType = _imageType(photo);
    if (baselineType == null ||
        photoType == null ||
        request.registrationPhotos.values.any(
          (value) => _imageType(value) == null,
        )) {
      return const Failure(RequestFailure('JPEG, PNG 또는 WebP 사진만 분석할 수 있습니다.'));
    }

    try {
      final payload = <String, Object>{
        'groupId': request.groupId,
        'kind': request.kind.name,
        if (!request.registrationPhoto)
          'baselineBase64': base64Encode(baseline),
        'registrationPhoto': request.registrationPhoto,
        if (request.registrationPhoto && request.registrationPhotos.isNotEmpty)
          'registrationPhotos': request.registrationPhotos.map(
            (key, value) => MapEntry(key, base64Encode(value)),
          ),
        if (request.baseline.notes.isNotEmpty)
          'photoNotes': request.baseline.notes,
        if (request.fullWaterMl != null) 'fullWaterMl': request.fullWaterMl!,
        'photoBase64': base64Encode(photo),
      };
      final data = await callAnalysisWithRetry(
        () async => (await _analyzePhoto.call(payload)).data,
        registrationPhoto: request.registrationPhoto,
      );
      if (data is! Map) {
        return const Failure(SerializationFailure());
      }
      if (!request.registrationPhoto && data['status'] == 'uncertain') {
        return Success(
          AnalysisUnavailable(
            '사진에서 변화를 명확히 확인할 수 없습니다.',
            modelResponse: data['modelResponse'] is String
                ? data['modelResponse'] as String
                : null,
          ),
        );
      }
      if (!request.registrationPhoto && data['status'] != 'ok') {
        return const Failure(SerializationFailure());
      }
      if (request.kind == AnalysisKind.water) {
        final baselineFill = _asDouble(data['baselineFillPercent']);
        final currentFill = _asDouble(data['currentFillPercent']);
        final percent = request.registrationPhoto
            ? _asDouble(data['decreasePercent'])
            : baselineFill != null &&
                  baselineFill > 0 &&
                  baselineFill <= 100 &&
                  currentFill != null &&
                  currentFill >= 0 &&
                  currentFill <= 100
            ? ((baselineFill - currentFill) / baselineFill * 100).clamp(
                0.0,
                100.0,
              )
            : _asDouble(data['decreasePercent']);
        if (percent == null) return const Failure(SerializationFailure());
        final confidence = _asDouble(data['confidencePercent']);
        if (request.registrationPhoto && confidence == null) {
          return const Failure(SerializationFailure());
        }
        return Success(
          WaterOutcome(
            percent: percent,
            confidencePercent: confidence,
            modelResponse: data['modelResponse'] is String
                ? data['modelResponse'] as String
                : null,
          ),
        );
      }
      final urineCount = _asInt(data['urineCount']);
      final stoolCount = _asInt(data['stoolCount']);
      if (urineCount == null || stoolCount == null) {
        return const Failure(SerializationFailure());
      }
      return Success(
        LitterOutcome(
          urineCount: urineCount,
          stoolCount: stoolCount,
          modelResponse: data['modelResponse'] is String
              ? data['modelResponse'] as String
              : null,
        ),
      );
    } catch (error) {
      return Failure(firebaseFailure(error));
    }
  }

  static String? _imageType(Uint8List bytes) {
    if (bytes.length >= 3 &&
        bytes[0] == 0xff &&
        bytes[1] == 0xd8 &&
        bytes[2] == 0xff) {
      return 'image/jpeg';
    }
    const png = <int>[0x89, 0x50, 0x4e, 0x47, 0x0d, 0x0a, 0x1a, 0x0a];
    if (bytes.length >= png.length &&
        List<int>.generate(png.length, (index) => bytes[index]).toString() ==
            png.toString()) {
      return 'image/png';
    }
    if (bytes.length >= 12 &&
        String.fromCharCodes(bytes.sublist(0, 4)) == 'RIFF' &&
        String.fromCharCodes(bytes.sublist(8, 12)) == 'WEBP') {
      return 'image/webp';
    }
    return null;
  }

  static double? _asDouble(Object? value) {
    if (value is num && value.isFinite) return value.toDouble();
    return null;
  }

  static int? _asInt(Object? value) {
    if (value is int) return value;
    if (value is num && value.isFinite && value == value.roundToDouble()) {
      return value.toInt();
    }
    return null;
  }
}
