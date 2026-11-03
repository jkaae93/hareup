import 'dart:typed_data';
import 'package:hareup_core/core.dart';

enum AnalysisKind { water, litter }

/// Feature gates are only enabled after the relevant model has been validated.
class AnalysisValidation {
  const AnalysisValidation({
    this.waterPercent = false,
    this.waterVolume = false,
    this.litterCounts = false,
    this.litterVolume = false,
  });
  final bool waterPercent;
  final bool waterVolume;
  final bool litterCounts;
  final bool litterVolume;
}

class AnalysisCat {
  const AnalysisCat({required this.id, required this.name});
  final String id;
  final String name;
}

class AnalysisRequest {
  AnalysisRequest({
    required this.id,
    required this.groupId,
    required this.targetId,
    required this.targetName,
    required this.kind,
    required this.baseline,
    required Uint8List photo,
    required this.photoSelectedAt,
    List<AnalysisCat> eligibleCats = const [],
    this.emptyWeightGrams,
    this.fullWaterMl,
    this.registrationPhoto = false,
    Map<String, Uint8List> registrationPhotos = const {},
    this.widthCm,
    this.lengthCm,
    this.litterHeightCm,
  }) : registrationPhotos = Map.unmodifiable(
         registrationPhotos.map(
           (key, value) => MapEntry(key, Uint8List.fromList(value)),
         ),
       ),
       _photo = Uint8List.fromList(photo),
       eligibleCats = List.unmodifiable(eligibleCats);
  final String id;
  final String groupId;
  final String targetId;
  final String targetName;
  final AnalysisKind kind;
  final PhotoBaseline baseline;
  final Uint8List _photo;
  final DateTime photoSelectedAt;
  final List<AnalysisCat> eligibleCats;
  final bool registrationPhoto;
  final Map<String, Uint8List> registrationPhotos;
  final double? emptyWeightGrams;
  final double? fullWaterMl;
  final double? widthCm;
  final double? lengthCm;
  final double? litterHeightCm;
  Uint8List get photo => Uint8List.fromList(_photo);
}

sealed class AnalysisOutcome {
  const AnalysisOutcome({this.modelResponse});
  final String? modelResponse;
}

class AnalysisUnavailable extends AnalysisOutcome {
  const AnalysisUnavailable(this.reason, {super.modelResponse});
  final String reason;
}

class WaterOutcome extends AnalysisOutcome {
  const WaterOutcome({
    required this.percent,
    this.volumeMl,
    this.confidencePercent,
    super.modelResponse,
  });
  final double percent;
  final double? volumeMl;
  final double? confidencePercent;
}

class LitterOutcome extends AnalysisOutcome {
  const LitterOutcome({
    required this.urineCount,
    required this.stoolCount,
    this.observedQuantity,
    this.quantityUnit,
    this.uncertain = false,
    super.modelResponse,
  });
  final int urineCount;
  final int stoolCount;
  final double? observedQuantity;
  final String? quantityUnit;
  final bool uncertain;
}

/// Application composition supplies the service, group, and verified gates.
class AnalysisRuntime {
  const AnalysisRuntime({
    required this.service,
    required this.groupId,
    this.validation = const AnalysisValidation(),
  });
  final AnalysisService service;
  final String groupId;
  final AnalysisValidation validation;
}

abstract interface class AnalysisService {
  Future<Result<AnalysisOutcome>> analyze(AnalysisRequest request);
}

/// Validate inputs and gate every optional value before display or storage.
AnalysisOutcome gateAnalysis(
  AnalysisRequest request,
  AnalysisOutcome result,
  AnalysisValidation validation,
) {
  if (result is AnalysisUnavailable) return result;
  if (request.kind == AnalysisKind.water && result is WaterOutcome) {
    if ((!validation.waterPercent && !request.registrationPhoto) ||
        !result.percent.isFinite ||
        result.percent < 0 ||
        result.percent > 100) {
      return const AnalysisUnavailable('물 감소율을 신뢰할 수 없어 분석할 수 없습니다.');
    }
    final confidence = result.confidencePercent;
    if (request.registrationPhoto &&
        (confidence == null ||
            !confidence.isFinite ||
            confidence < 0 ||
            confidence > 100)) {
      return const AnalysisUnavailable('분석 신뢰도를 확인할 수 없습니다.');
    }
    final volume = result.volumeMl;
    final hasMeasurements =
        request.emptyWeightGrams != null &&
        request.fullWaterMl != null &&
        request.emptyWeightGrams!.isFinite &&
        request.fullWaterMl!.isFinite &&
        request.emptyWeightGrams! > 0 &&
        request.fullWaterMl! > 0;
    final validVolume =
        hasMeasurements &&
        volume != null &&
        volume.isFinite &&
        volume >= 0 &&
        volume <= request.fullWaterMl!;
    return WaterOutcome(
      percent: result.percent,
      confidencePercent: confidence,
      volumeMl: validation.waterVolume && hasMeasurements && validVolume
          ? volume
          : null,
    );
  }
  if (request.kind == AnalysisKind.litter && result is LitterOutcome) {
    if (!validation.litterCounts ||
        result.urineCount < 0 ||
        result.stoolCount < 0) {
      return const AnalysisUnavailable('배설 흔적을 신뢰할 수 없어 분석할 수 없습니다.');
    }
    final quantity = result.observedQuantity;
    final dimensions = [
      request.widthCm,
      request.lengthCm,
      request.litterHeightCm,
    ];
    final allowQuantity =
        validation.litterVolume &&
        dimensions.every((v) => v != null && v.isFinite && v > 0) &&
        quantity != null &&
        quantity.isFinite &&
        quantity >= 0 &&
        result.quantityUnit != null &&
        result.quantityUnit!.trim().isNotEmpty;
    return LitterOutcome(
      urineCount: result.urineCount,
      stoolCount: result.stoolCount,
      uncertain: result.uncertain,
      observedQuantity: allowQuantity ? quantity : null,
      quantityUnit: allowQuantity ? result.quantityUnit : null,
    );
  }
  return const AnalysisUnavailable('분석 결과 유형을 확인할 수 없습니다.');
}
