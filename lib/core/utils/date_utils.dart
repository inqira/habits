import 'package:logging/logging.dart';

final _logger = Logger('DateUtils');

class DateUtils {
  /// Converts a string to DateTime
  /// Returns null if the string is null or invalid
  static DateTime? fromString(String? dateString) {
    if (dateString == null || dateString.isEmpty) {
      return null;
    }

    try {
      return DateTime.parse(dateString);
    } catch (e) {
      _logger.warning('Error converting string to DateTime: $e');
      return null;
    }
  }

  /// Converts a DateTime to ISO8601 string
  /// Returns null if the DateTime is null
  static String? convertToString(DateTime? date) {
    if (date == null) {
      return null;
    }

    try {
      return date.toIso8601String();
    } catch (e) {
      _logger.warning('Error converting DateTime to string: $e');
      return null;
    }
  }

  /// Converts a string to DateTime with a required default value
  /// Returns the default value if the string is null or invalid
  static DateTime fromStringOrDefault(
      String? dateString, DateTime defaultValue) {
    return fromString(dateString) ?? defaultValue;
  }
}
