import 'dart:convert';

import 'package:hareup_core/core.dart';

/// Errors at the serialization boundary contain no source data.
class DataFormatException extends AppException {
  const DataFormatException() : super('데이터를 읽을 수 없습니다.');
}

Map<String, dynamic> decodeJsonObject(String source) {
  try {
    final decoded = jsonDecode(source);
    if (decoded is! Map<String, dynamic>) throw const DataFormatException();
    return decoded;
  } on FormatException {
    throw const DataFormatException();
  }
}

/// Timestamps without an explicit offset are ambiguous and are rejected.
DateTime parseUtcDate(Object? value) {
  if (value is! String ||
      !RegExp(r'(Z|[+-]\d{2}:?\d{2})$', caseSensitive: false).hasMatch(value)) {
    throw const DataFormatException();
  }
  final date = DateTime.tryParse(value);
  if (date == null) throw const DataFormatException();
  return date.toUtc();
}

String formatUtcDate(DateTime value) => value.toUtc().toIso8601String();
