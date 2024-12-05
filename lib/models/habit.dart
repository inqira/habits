import 'dart:convert';

import 'package:habits/core/extensions/map_extension.dart';
import 'package:habits/core/utils/id_generator.dart';
import 'package:habits/core/utils/list_utils.dart';

class Habit {
  final String id;
  final String title;
  final String? description;
  final String categoryId;
  final HabitType type;
  final FrequencyType frequencyType;
  final int targetValue;
  final int? targetDays;
  final String? icon;
  final PeriodOfDay period;
  final List<int> selectedDays;
  final DateTime startDate;
  final DateTime? endDate;
  final DateTime createdAt;
  final DateTime? archivedAt;
  final bool isArchived;
  final TargetCompletionType targetCompletionType;
  final String? unit;
  final Map<String, dynamic>? extraAttributes;

  static const String tableName = 'habit';

  static const String createTableQuery = '''
    CREATE TABLE $tableName (
      id TEXT PRIMARY KEY,
      created_at INTEGER NOT NULL,
      title TEXT NOT NULL,
      description TEXT,
      category_id TEXT,
      type TEXT NOT NULL CHECK (type IN ('checkbox', 'numeric', 'duration')),
      frequency_type TEXT NOT NULL CHECK (frequency_type IN ('daily', 'weekly', 'monthly','yearly')),
      target_value INTEGER NOT NULL CHECK(target_value > 0),
      target_days INTEGER,
      icon TEXT,
      period TEXT NOT NULL CHECK (period IN ('morning', 'afternoon', 'evening', 'anytime')),
      selected_days TEXT,
      start_date INTEGER NOT NULL,
      end_date INTEGER,
      archived_at INTEGER,
      is_archived INTEGER NOT NULL DEFAULT 0,
      target_completion_type TEXT NOT NULL CHECK (target_completion_type IN ('atLeast', 'atMost', 'exactly')),
      unit TEXT,
      extra_attributes TEXT,
      FOREIGN KEY (category_id) REFERENCES category (id)
        ON DELETE SET NULL
        ON UPDATE CASCADE
    )
  ''';

  const Habit({
    required this.id,
    required this.title,
    this.description,
    required this.categoryId,
    required this.type,
    required this.frequencyType,
    this.targetValue = 1,
    this.targetDays,
    this.icon,
    required this.period,
    required this.selectedDays,
    required this.startDate,
    this.endDate,
    required this.createdAt,
    this.archivedAt,
    required this.isArchived,
    this.targetCompletionType = TargetCompletionType.atLeast,
    this.unit,
    this.extraAttributes,
  });

  // Create a new habit
  static Future<Habit> create({
    required String title,
    String? description,
    required String categoryId,
    required HabitType type,
    required FrequencyType frequencyType,
    int targetValue = 1,
    int? targetDays,
    String? icon,
    required PeriodOfDay period,
    required List<int> selectedDays,
    required DateTime startDate,
    DateTime? endDate,
    Map<String, dynamic>? extraAttributes,
  }) async {
    final id = await IdGenerator().generate();
    return Habit(
      id: id,
      title: title,
      description: description,
      categoryId: categoryId,
      type: type,
      frequencyType: frequencyType,
      targetValue: targetValue,
      targetDays: targetDays,
      icon: icon,
      period: period,
      selectedDays: List<int>.from(selectedDays),
      startDate: startDate,
      endDate: endDate,
      createdAt: DateTime.now(),
      isArchived: false,
      targetCompletionType: type == HabitType.checkbox
          ? TargetCompletionType.exactly
          : TargetCompletionType.atLeast,
      extraAttributes: extraAttributes,
    );
  }

  // Create from JSON
  factory Habit.fromJson(Map<String, dynamic> json) {
    // Helper function to safely convert to int
    int? toInt(dynamic value) {
      if (value == null) return null;
      if (value is int) return value;
      if (value is String) return int.tryParse(value);
      return null;
    }

    return Habit(
      id: json['id'] as String,
      title: json.getStringOrDefaultValue('title'),
      description: json.getStringOrNull('description'),
      categoryId: json.getStringOrDefaultValue('category_id'),
      type: HabitType.values.byName(json.getStringOrDefaultValue('type')),
      frequencyType: FrequencyType.values
          .byName(json.getStringOrDefaultValue('frequency_type')),
      targetValue: toInt(json['target_value']) ?? 1,
      targetDays: toInt(json['target_days']),
      icon: json.getStringOrNull('icon'),
      period: PeriodOfDay.values.byName(json.getStringOrDefaultValue('period')),
      selectedDays: ListUtils.fromString<int>(json['selected_days'] as String?),
      startDate: DateTime.fromMillisecondsSinceEpoch(json['start_date'] as int),
      endDate: json['end_date'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['end_date'] as int)
          : null,
      createdAt: DateTime.fromMillisecondsSinceEpoch(json['created_at'] as int),
      archivedAt: json['archived_at'] != null
          ? DateTime.fromMillisecondsSinceEpoch(json['archived_at'] as int)
          : null,
      isArchived: json['is_archived'] == 1,
      targetCompletionType: TargetCompletionType.values
          .byName(json.getStringOrDefaultValue('target_completion_type')),
      unit: json.getStringOrNull('unit'),
      extraAttributes: json['extra_attributes'] != null
          ? jsonDecode(json['extra_attributes'] as String)
          : null,
    );
  }

  // Convert to JSON
  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'title': title,
      'description': description,
      'category_id': categoryId,
      'type': type.name,
      'frequency_type': frequencyType.name,
      'target_value': targetValue,
      'target_days': targetDays,
      'icon': icon,
      'period': period.name,
      'selected_days': ListUtils.convertToString(selectedDays),
      'start_date': startDate.millisecondsSinceEpoch,
      'end_date': endDate?.millisecondsSinceEpoch,
      'created_at': createdAt.millisecondsSinceEpoch,
      'archived_at': archivedAt?.millisecondsSinceEpoch,
      'is_archived': isArchived ? 1 : 0,
      'target_completion_type': targetCompletionType.name,
      'unit': unit,
      'extra_attributes':
          extraAttributes != null ? jsonEncode(extraAttributes) : null,
    };
  }

  // Create a copy with some fields replaced
  Habit copyWith({
    String? id,
    String? title,
    String? description,
    String? categoryId,
    HabitType? type,
    FrequencyType? frequencyType,
    int? targetValue,
    int? targetDays,
    String? icon,
    PeriodOfDay? period,
    List<int>? selectedDays,
    DateTime? startDate,
    DateTime? endDate,
    DateTime? createdAt,
    DateTime? archivedAt,
    bool? isArchived,
    TargetCompletionType? targetCompletionType,
    String? unit,
    Map<String, dynamic>? extraAttributes,
  }) {
    return Habit(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      categoryId: categoryId ?? this.categoryId,
      type: type ?? this.type,
      frequencyType: frequencyType ?? this.frequencyType,
      targetValue: targetValue ?? this.targetValue,
      targetDays: targetDays ?? this.targetDays,
      icon: icon ?? this.icon,
      period: period ?? this.period,
      selectedDays: selectedDays ?? List<int>.from(this.selectedDays),
      startDate: startDate ?? this.startDate,
      endDate: endDate ?? this.endDate,
      createdAt: createdAt ?? this.createdAt,
      archivedAt: archivedAt ?? this.archivedAt,
      isArchived: isArchived ?? this.isArchived,
      targetCompletionType: targetCompletionType ?? this.targetCompletionType,
      unit: unit ?? this.unit,
      extraAttributes: extraAttributes ?? this.extraAttributes,
    );
  }

  // Calculate start and end dates for a given date based on frequency type
  (DateTime, DateTime) getPeriodDates(DateTime date) {
    switch (frequencyType) {
      case FrequencyType.daily:
        return (
          date.copyWith(hour: 0, minute: 0, second: 0, millisecond: 0),
          date.copyWith(hour: 23, minute: 59, second: 59, millisecond: 999)
        );
      case FrequencyType.weekly:
        final startOfWeek = date
            .subtract(Duration(days: date.weekday - 1))
            .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
        final endOfWeek = startOfWeek
            .add(const Duration(days: 6))
            .copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
        return (startOfWeek, endOfWeek);
      case FrequencyType.monthly:
        final startOfMonth = DateTime(date.year, date.month, 1)
            .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
        final endOfMonth = DateTime(date.year, date.month + 1, 0)
            .copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
        return (startOfMonth, endOfMonth);
      case FrequencyType.yearly:
        final startOfYear = DateTime(date.year, 1, 1)
            .copyWith(hour: 0, minute: 0, second: 0, millisecond: 0);
        final endOfYear = DateTime(date.year, 12, 31)
            .copyWith(hour: 23, minute: 59, second: 59, millisecond: 999);
        return (startOfYear, endOfYear);
      default:
        throw UnimplementedError('Frequency type not implemented');
    }
  }

  bool availableAtDate(DateTime date) {
    final normalizedDate = DateTime(date.year, date.month, date.day);
    final normalizedStartDate =
        DateTime(startDate.year, startDate.month, startDate.day);

    // Check if habit is archived and the date is after archival
    if (isArchived &&
        archivedAt != null &&
        !normalizedDate.isBefore(archivedAt!)) {
      return false;
    }

    // Check if date is within start and end date range
    if (normalizedDate.isBefore(normalizedStartDate)) {
      return false;
    }
    if (endDate != null) {
      final normalizedEndDate =
          DateTime(endDate!.year, endDate!.month, endDate!.day);
      if (normalizedDate.isAfter(normalizedEndDate)) {
        return false;
      }
    }

    // Check frequency and selected days
    switch (frequencyType) {
      case FrequencyType.daily:
        return true;
      case FrequencyType.weekly:
        // For weekly, check if the day of week is in selectedDays
        return selectedDays.contains(normalizedDate.weekday);
      case FrequencyType.monthly:
        // For monthly, check if the day of month is in selectedDays
        return selectedDays.contains(normalizedDate.day);
      case FrequencyType.yearly:
        // For yearly, check if the day of year is in selectedDays
        return selectedDays.contains(normalizedDate.day);
    }
  }

  // Check if the habit MUST be completed on the given date
  bool mustCompleteOnDate(DateTime date) {
    // First check if the habit is available on this date
    if (!availableAtDate(date)) {
      return false;
    }

    // For daily habits, it must be done every day
    if (frequencyType == FrequencyType.daily) {
      return true;
    }

    // For weekly habits with specific days selected
    if (frequencyType == FrequencyType.weekly && selectedDays.isNotEmpty) {
      return selectedDays.contains(date.weekday);
    }

    // For monthly habits with specific days selected
    if (frequencyType == FrequencyType.monthly && selectedDays.isNotEmpty) {
      return selectedDays.contains(date.day);
    }

    // For all other cases (target days per week/month/year),
    // the habit can be completed on any day within the period
    return false;
  }
}

enum HabitType {
  checkbox,
  numeric,
  duration,
}

enum PeriodOfDay {
  anytime,
  morning,
  afternoon,
  evening,
}

enum TargetCompletionType {
  atLeast,
  atMost,
  exactly,
}

enum FrequencyType {
  daily,
  weekly,
  monthly,
  yearly,
}
