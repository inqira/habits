import 'dart:convert';

import 'package:habits/core/extensions/map_extension.dart';

enum HabitEntryStatus { success, failed, notStarted, onGoing }

class HabitEntry {
  final String habitId;
  final String date;
  final HabitEntryStatus status;
  final int value;
  final String? note;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final Map<String, dynamic>? extraAttributes;

  static const String tableName = 'habit_entry';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      habit_id TEXT NOT NULL,
      date TEXT NOT NULL,
      status TEXT NOT NULL CHECK (status IN ('success', 'failed', 'notStarted', 'onGoing')),
      value INTEGER,
      note TEXT,
      created_at INTEGER NOT NULL,
      updated_at INTEGER,
      extra_attributes TEXT,
      FOREIGN KEY (habit_id) REFERENCES habit (id)
        ON DELETE CASCADE
    )
  ''';

  String get id => '$habitId-$date';

  const HabitEntry({
    required this.habitId,
    required this.date,
    required this.status,
    required this.createdAt,
    this.value = 0,
    this.note,
    this.updatedAt,
    this.extraAttributes,
  });

  // Create a new habit entry
  static HabitEntry create({
    required String habitId,
    required String date,
    HabitEntryStatus habitStatus = HabitEntryStatus.notStarted,
    int value = 0,
    String? note,
    Map<String, dynamic>? extraAttributes,
  }) {
    return HabitEntry(
      habitId: habitId,
      date: date,
      status: habitStatus,
      value: value,
      note: note,
      createdAt: DateTime.now(),
      extraAttributes: extraAttributes,
    );
  }

  // Add a progress value
  HabitEntry addProgress(int value) {
    return HabitEntry(
      habitId: habitId,
      date: date,
      status: status,
      value: value,
      createdAt: createdAt,
      updatedAt: DateTime.now(),
      note: note,
      extraAttributes: extraAttributes,
    );
  }

  // Create from JSON
  factory HabitEntry.fromJson(Map<String, dynamic> json) {
    return HabitEntry(
      habitId: json['habit_id'] as String,
      date: json['date'] as String,
      status: HabitEntryStatus.values
          .byName(json.getStringOrDefaultValue('status')),
      value: json['value'] as int? ?? 0,
      note: json.getStringOrNull('note'),
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      updatedAt: json['updated_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['updated_at'] as int)
          : null,
      extraAttributes: json['extra_attributes'] != null
          ? jsonDecode(json['extra_attributes'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'habit_id': habitId,
      'date': date,
      'status': status.name,
      'value': value,
      'note': note,
      'created_at': createdAt.millisecondsSinceEpoch,
      'updated_at': updatedAt?.millisecondsSinceEpoch,
      'extra_attributes':
          extraAttributes != null ? jsonEncode(extraAttributes) : null,
    };
  }

  // Create a copy with some fields replaced
  HabitEntry copyWith({
    String? habitId,
    String? date,
    HabitEntryStatus? status,
    int? value,
    String? note,
    DateTime? createdAt,
    DateTime? updatedAt,
    Map<String, dynamic>? extraAttributes,
  }) {
    return HabitEntry(
      habitId: habitId ?? this.habitId,
      date: date ?? this.date,
      status: status ?? this.status,
      value: value ?? this.value,
      note: note ?? this.note,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      extraAttributes: extraAttributes ?? this.extraAttributes,
    );
  }
}
