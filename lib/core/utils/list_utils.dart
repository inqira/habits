import 'dart:convert';

import 'package:logging/logging.dart';

final _logger = Logger('ListUtils');

class ListUtils {
  /// Converts a JSON string to a List<T>
  /// Returns an empty list if the string is null or invalid
  static List<T> fromString<T>(String? jsonString,
      {T Function(dynamic)? converter}) {
    if (jsonString == null || jsonString.isEmpty) {
      return [];
    }

    try {
      final List<dynamic> jsonList = jsonDecode(jsonString);

      if (converter != null) {
        return jsonList.map((item) => converter(item)).toList();
      }

      return jsonList.map((item) => item as T).toList();
    } catch (e) {
      _logger.warning('Error converting string to List<$T>: $e');
      return [];
    }
  }

  /// Converts a List to a JSON string
  /// Returns null if the list is null or empty
  static String? convertToString<T>(List<T>? list) {
    if (list == null || list.isEmpty) {
      return null;
    }

    try {
      return jsonEncode(list);
    } catch (e) {
      _logger.warning('Error converting List<$T> to string: $e');
      return null;
    }
  }
}
