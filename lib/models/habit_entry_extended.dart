import 'package:habits/models/habit.dart';
import 'package:habits/models/habit_entry.dart';

export 'package:habits/models/habit.dart';
export 'package:habits/models/habit_entry.dart';

/// A model that combines a habit with its optional entry for a specific date.
/// This is used to display habit status and progress for a particular day.
class HabitEntryExtended {
  final Habit habit;
  final HabitEntry? _entry;
  final String date;

  DateTime get dateObj => DateTime.parse(date);

  /// Getter for the entry
  HabitEntry? get entry => _entry;

  /// Computed properties for easy access to common fields
  bool get hasEntry => _entry != null;
  int get value => _entry?.value ?? 0;
  String? get note => _entry?.note;
  DateTime? get lastUpdated => _entry?.updatedAt;

  HabitEntryExtended({
    required this.habit,
    required this.date,
    HabitEntry? entry,
  }) : _entry = entry;

  /// Creates a copy of this HabitEntryExtended with the given fields replaced with new values
  HabitEntryExtended copyWith({
    Habit? habit,
    HabitEntry? entry,
    String? date,
  }) {
    return HabitEntryExtended(
      habit: habit ?? this.habit,
      entry: entry ?? _entry,
      date: date ?? this.date,
    );
  }

  /// Returns the status of the habit based on its type, target, and completion type
  HabitEntryStatus get status => _calculateStatus(value);

  /// Calculates the status based on entry, habit type, and must-complete rules
  HabitEntryStatus _calculateStatus(int value) {
    // For checkbox type, return current status if it's failed or succeeded
    if (habit.type == HabitType.checkbox && hasEntry) {
      final currentStatus = _entry!.status;
      if (currentStatus == HabitEntryStatus.failed ||
          currentStatus == HabitEntryStatus.success) {
        return currentStatus;
      }
    }

    if (!hasEntry) {
      if (habit.mustCompleteOnDate(dateObj)) {
        final today = DateTime(
            DateTime.now().year, DateTime.now().month, DateTime.now().day);
        final normalizedDate =
            DateTime(dateObj.year, dateObj.month, dateObj.day);

        return normalizedDate.isBefore(today)
            ? HabitEntryStatus.failed
            : HabitEntryStatus.notStarted;
      }
      return HabitEntryStatus.notStarted;
    }

    if (_entry?.status == HabitEntryStatus.failed) {
      return HabitEntryStatus.failed;
    }

    switch (habit.type) {
      case HabitType.checkbox:
        return _entry?.status ?? HabitEntryStatus.notStarted;
      case HabitType.numeric:
      case HabitType.duration:
        if (value == 0) return HabitEntryStatus.notStarted;

        final target = habit.targetValue;
        switch (habit.targetCompletionType) {
          case TargetCompletionType.atLeast:
            return value >= target
                ? HabitEntryStatus.success
                : HabitEntryStatus.onGoing;
          case TargetCompletionType.atMost:
            return value <= target
                ? HabitEntryStatus.success
                : HabitEntryStatus.failed;
          case TargetCompletionType.exactly:
            return value == target
                ? HabitEntryStatus.success
                : value > target
                    ? HabitEntryStatus.failed
                    : HabitEntryStatus.onGoing;
        }
    }
  }

  /// Returns whether this habit is successful
  bool get isSuccess => status == HabitEntryStatus.success;

  /// Returns the progress percentage (0-100) for numeric and duration habits
  double? get progress {
    if (!hasEntry || habit.type == HabitType.checkbox) {
      return null;
    }

    return (value / habit.targetValue) * 100;
  }

  /// Update or add to the value in entry
  /// For numeric/duration habits:
  /// - If [add] is false, sets the value directly (default)
  /// - If [add] is true, adds the value to the current value
  /// For checkbox habits, this method does nothing and returns the current instance
  HabitEntryExtended updateValue(int value, {bool add = false}) {
    switch (habit.type) {
      case HabitType.checkbox:
        return this;
      case HabitType.numeric:
      case HabitType.duration:
        final newValue = add ? this.value + value : value;
        return _updateEntry(value: newValue);
    }
  }

  /// Update the status of a checkbox habit
  /// For non-checkbox habits, this method does nothing and returns the current instance
  HabitEntryExtended updateStatus(HabitEntryStatus status) {
    if (habit.type != HabitType.checkbox) return this;
    return _updateEntry(habitStatus: status);
  }

  /// Cycles through the status states for checkbox habits in the following order:
  /// not_started -> succeeded -> failed -> succeeded
  /// For non-checkbox habits, this method does nothing and returns the current instance
  HabitEntryExtended cycleStatus() {
    if (habit.type != HabitType.checkbox) {
      return this;
    }

    final currentStatus = _entry?.status ?? HabitEntryStatus.notStarted;
    final HabitEntryStatus newStatus;

    switch (currentStatus) {
      case HabitEntryStatus.notStarted:
        newStatus = HabitEntryStatus.success;
        break;
      case HabitEntryStatus.success:
        newStatus = HabitEntryStatus.failed;
        break;
      case HabitEntryStatus.failed:
        newStatus = HabitEntryStatus.notStarted;
        break;
      case HabitEntryStatus.onGoing:
        newStatus = HabitEntryStatus.failed;
        break;
    }

    return updateStatus(newStatus);
  }

  /// Internal method to update or create a habit entry with the given parameters
  /// Returns the updated or created entry
  HabitEntryExtended _updateEntry({
    HabitEntryStatus? habitStatus,
    int? value,
    String? note,
  }) {
    // Handle value and status based on habit type
    late int newValue;
    late HabitEntryStatus newStatus;

    switch (habit.type) {
      case HabitType.checkbox:
        // For checkbox, ignore value and use status
        newValue = this.value;
        newStatus =
            habitStatus ?? _entry?.status ?? HabitEntryStatus.notStarted;
        break;
      case HabitType.numeric:
      case HabitType.duration:
        // For numeric/duration, ignore status and use value
        newValue = value ?? this.value;
        newStatus = _calculateStatus(newValue);
        if (newValue > 0) {
          switch (habit.targetCompletionType) {
            case TargetCompletionType.atLeast:
              if (newValue >= habit.targetValue) {
                newStatus = HabitEntryStatus.success;
              }
              break;
            case TargetCompletionType.atMost:
              if (newValue <= habit.targetValue) {
                newStatus = HabitEntryStatus.success;
              }
              break;
            case TargetCompletionType.exactly:
              if (newValue == habit.targetValue) {
                newStatus = HabitEntryStatus.success;
              }
              break;
          }
        }
        break;
    }

    // Create or update the entry
    HabitEntry updatedEntry;

    updatedEntry = _entry == null
        ? HabitEntry.create(
            habitId: habit.id,
            date: date,
            habitStatus: newStatus,
            note: note,
          ).addProgress(newValue)
        : HabitEntry(
            habitId: _entry.habitId,
            date: _entry.date,
            status: newStatus,
            value: newValue,
            createdAt: _entry.createdAt,
            updatedAt: DateTime.now(),
            note: note ?? _entry.note,
          );

    // Return a new instance with the updated entry
    return HabitEntryExtended(
      habit: habit,
      date: date,
      entry: updatedEntry,
    );
  }
}
