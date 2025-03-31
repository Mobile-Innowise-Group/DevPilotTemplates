import 'package:json_annotation/json_annotation.dart';

class UtcDateTimeConverter implements JsonConverter<DateTime, String> {
  const UtcDateTimeConverter();

  @override
  DateTime fromJson(String json) {
    return DateTime.parse(json).toLocal();
  }

  @override
  String toJson(DateTime json) {
    return json.toUtc().toIso8601String();
  }
}
