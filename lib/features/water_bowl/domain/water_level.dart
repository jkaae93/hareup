import 'dart:typed_data';
import 'package:hareup_core/core.dart';

abstract interface class WaterLevelHistoryService {
  Future<Result<List<WaterLevelHistoryItem>>> listWaterLevels({
    required String groupId,
    required String bowlId,
  });
}

class WaterLevelHistoryItem {
  const WaterLevelHistoryItem({
    required this.result,
    required this.createdAt,
    required this.setup,
  });
  final WaterLevelResult result;
  final DateTime? createdAt;
  final bool setup;
}

/// A model-generated description of the reservoir, not a verified volume.
class WaterLevelProfile {
  const WaterLevelProfile({required this.conditions, required this.createdAt});

  final String conditions;
  final DateTime createdAt;
}

/// Fill percentages are relative to a full reservoir, not measured millilitres.
class WaterLevelReading {
  const WaterLevelReading({
    required this.fillPercent,
    required this.observedAt,
  });

  final double fillPercent;
  final DateTime observedAt;
}

/// Positive values indicate a fall; negative values indicate a rise.
double waterLevelChange(WaterLevelReading previous, WaterLevelReading current) {
  for (final value in [previous.fillPercent, current.fillPercent]) {
    if (!value.isFinite || value < 0 || value > 100) {
      throw ArgumentError.value(value, 'fillPercent', 'Expected 0 to 100');
    }
  }
  return previous.fillPercent - current.fillPercent;
}

abstract interface class WaterLevelService {
  Future<Result<WaterLevelResult>> observeWaterLevel({
    required String groupId,
    required String bowlId,
    required String requestId,
    required bool setup,
    Map<String, Uint8List> photos = const {},
    Uint8List? photo,
  });
}

class WaterLevelResult {
  const WaterLevelResult({
    required this.status,
    this.current,
    this.previous,
    this.reason = '',
  });
  final String status;
  final double? current;
  final double? previous;
  final String reason;
}
