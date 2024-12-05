import 'dart:convert';

import 'package:synchronized/synchronized.dart';

class IdGenerator {
  static final IdGenerator _instance = IdGenerator._internal();
  factory IdGenerator() => _instance;

  // Lock for thread safety
  final Lock _lock = Lock();

  IdGenerator._internal();

  // Reference date (2024-12-01) in seconds since epoch
  static final int _referenceDate =
      DateTime(2024, 12, 1).millisecondsSinceEpoch ~/ 1000;

  // Keep track of last generated ID to ensure uniqueness
  int _lastGeneratedId = 0;

  /// Generates a unique ID as integer based on the current timestamp
  /// The ID is calculated as seconds since 2024-12-01
  /// If multiple IDs are generated in the same second,
  /// it will increment the last generated ID
  Future<int> generateInt() async {
    return await _lock.synchronized(() async {
      final now = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final timeDiff = now - _referenceDate;

      // If new timestamp is less than or equal to last generated ID,
      // increment the last ID to ensure uniqueness
      if (timeDiff <= _lastGeneratedId) {
        _lastGeneratedId++;
        return _lastGeneratedId;
      }

      _lastGeneratedId = timeDiff;
      return timeDiff;
    });
  }

  /// Generates a unique ID as string based on generateInt()
  Future<String> generate() async {
    final id = await generateInt();
    return id.toString();
  }

  /// Generates a unique ID in hexadecimal format
  Future<String> generateHex() async {
    final id = await generateInt();
    return id.toRadixString(16);
  }

  /// Generates a unique ID in base64 format
  Future<String> generate64() async {
    final id = await generateInt();
    final bytes = id.toString().codeUnits;
    return base64Url.encode(bytes);
  }

  /// Generates a unique ID with a prefix
  /// Useful for different types of entities (e.g., habits, categories)
  Future<String> generateWithPrefix(String prefix) async {
    final id = await generate();
    return '${prefix}_$id';
  }
}
