import 'package:freezed_annotation/freezed_annotation.dart';

/// DateTime을 Firestore Timestamp로 변환하는 컨버터
class DateTimeConverter implements JsonConverter<DateTime, Object> {
  const DateTimeConverter();

  @override
  DateTime fromJson(Object json) {
    if (json is DateTime) {
      return json;
    } else if (json is String) {
      return DateTime.parse(json);
    } else if (json is Map && json['_seconds'] != null) {
      // Firestore Timestamp
      return DateTime.fromMillisecondsSinceEpoch(
        (json['_seconds'] as int) * 1000,
      );
    }
    throw ArgumentError('Cannot convert $json to DateTime');
  }

  @override
  Object toJson(DateTime object) {
    return object.toIso8601String();
  }
}

