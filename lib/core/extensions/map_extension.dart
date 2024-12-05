import 'dart:ui';

extension MapExtension on Map<String, dynamic> {
  // Int methods
  int? getIntOrNull(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is int) return value;
    if (value is String) {
      return int.tryParse(value.toString());
    }
    if (value is double) {
      return value.toInt();
    }
    return null;
  }

  int getIntOrDefaultValue(String key, {int defaultValue = 0}) {
    return getIntOrNull(key) ?? defaultValue;
  }

  // Double methods
  double? getDoubleOrNull(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      return double.tryParse(value);
    }
    return null;
  }

  double getDoubleOrDefaultValue(String key, {double defaultValue = 0.0}) {
    return getDoubleOrNull(key) ?? defaultValue;
  }

  // String methods
  String? getStringOrNull(String key) {
    final value = this[key];
    if (value == null) return null;

    return value.toString();
  }

  String getStringOrDefaultValue(String key, {String defaultValue = ''}) {
    return getStringOrNull(key) ?? defaultValue;
  }

  // DateTime methods
  DateTime? getDateTimeOrNull(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is DateTime) return value;
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (e) {
        return null;
      }
    }
    if (value is int) {
      return DateTime.fromMillisecondsSinceEpoch(value);
    }
    return null;
  }

  DateTime getDateTimeOrDefaultValue(String key, {DateTime? defaultValue}) {
    return getDateTimeOrNull(key) ?? defaultValue ?? DateTime.now();
  }

  // Bool methods
  bool? getBoolOrNull(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is bool) return value;
    if (value is String) {
      return value.toLowerCase() == 'true';
    }
    if (value is int) {
      return value == 1;
    }
    return null;
  }

  bool getBoolOrDefaultValue(String key, {bool defaultValue = false}) {
    return getBoolOrNull(key) ?? defaultValue;
  }

  // Color methods
  Color? getColorOrNull(String key) {
    final value = this[key];
    if (value == null) return null;

    if (value is Color) return value;
    if (value is String) {
      try {
        return Color(int.parse(value));
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  Color getColorOrDefaultValue(String key,
      {Color defaultValue = const Color(0xFF42A5F5)}) {
    return getColorOrNull(key) ?? defaultValue;
  }
}
