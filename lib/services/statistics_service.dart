import 'package:habits/services/habit_entry_service.dart';
import 'package:habits/services/habit_service.dart';

class StatisticsTimeframe {
  final DateTime startDate;
  final DateTime endDate;

  StatisticsTimeframe({required this.startDate, required this.endDate});

  static StatisticsTimeframe today() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, now.day);
    return StatisticsTimeframe(startDate: start, endDate: now);
  }

  static StatisticsTimeframe thisWeek() {
    final now = DateTime.now();
    final start = now.subtract(Duration(days: now.weekday - 1));
    final startDate = DateTime(start.year, start.month, start.day);
    return StatisticsTimeframe(startDate: startDate, endDate: now);
  }

  static StatisticsTimeframe thisMonth() {
    final now = DateTime.now();
    final start = DateTime(now.year, now.month, 1);
    return StatisticsTimeframe(startDate: start, endDate: now);
  }

  static StatisticsTimeframe overall() {
    final now = DateTime.now();
    // You might want to adjust this based on your needs
    final start = DateTime(2020, 1, 1);
    return StatisticsTimeframe(startDate: start, endDate: now);
  }
}

class HabitStatistics {
  final double successRate;
  final double completionRate;
  final int totalEntries;
  final int successfulEntries;
  final int failedEntries;
  final double averageValue;
  final int totalValue;

  HabitStatistics({
    required this.successRate,
    required this.completionRate,
    required this.totalEntries,
    required this.successfulEntries,
    required this.failedEntries,
    required this.averageValue,
    required this.totalValue,
  });
}

class StatisticsService {
  final HabitService _habitService;
  final HabitEntryService _habitEntryService;

  StatisticsService(this._habitService, this._habitEntryService);

  Future<HabitStatistics> calculateStatistics(
      String habitId, StatisticsTimeframe timeframe) async {
    final habit = _habitService.getHabit(habitId);
    if (habit == null) {
      throw Exception('Habit not found');
    }

    final entriesMap = await _habitEntryService.getEntriesForHabit(
      habitId,
      timeframe.startDate,
      timeframe.endDate,
    );

    final totalDays = _calculateTotalDays(habit, timeframe);
    final successfulDays =
        _calculateSuccessfulDays(habit, entriesMap, timeframe);
    final failedDays =
        _calculateFailedDays(habit, entriesMap, timeframe, successfulDays);
    final averageValue = _calculateAverageValue(habit, entriesMap.values);

    final successRate =
        totalDays > 0 ? (successfulDays / totalDays) * 100 : 0.0;
    final completionRate =
        totalDays > 0 ? ((successfulDays + failedDays) / totalDays) * 100 : 0.0;

    return HabitStatistics(
      successRate: successRate,
      completionRate: completionRate,
      totalEntries: successfulDays + failedDays,
      successfulEntries: successfulDays,
      failedEntries: failedDays,
      averageValue: averageValue,
      totalValue: (averageValue * (successfulDays + failedDays)).toInt(),
    );
  }

  int _calculateTotalDays(Habit habit, StatisticsTimeframe timeframe) {
    // Don't count days before habit start date
    final effectiveStartDate = timeframe.startDate.isBefore(habit.startDate)
        ? habit.startDate
        : timeframe.startDate;

    // Don't count days after today or habit end date
    final now = DateTime.now();
    final habitEndDate = habit.endDate;
    final effectiveEndDate =
        timeframe.endDate.isBefore(now) ? timeframe.endDate : now;
    final finalEndDate =
        habitEndDate != null && habitEndDate.isBefore(effectiveEndDate)
            ? habitEndDate
            : effectiveEndDate;

    // If the effective start date is after the final end date, return 0
    if (effectiveStartDate.isAfter(finalEndDate)) {
      return 0;
    }

    switch (habit.frequencyType) {
      case FrequencyType.daily:
        return finalEndDate.difference(effectiveStartDate).inDays + 1;

      case FrequencyType.weekly:
        if (habit.selectedDays.isNotEmpty) {
          // Count selected days in the timeframe
          return _countSelectedDaysInTimeframe(
            habit.selectedDays,
            StatisticsTimeframe(
              startDate: effectiveStartDate,
              endDate: finalEndDate,
            ),
          );
        } else if (habit.targetDays != null) {
          // Count weeks * targetDays
          final weeks = finalEndDate.difference(effectiveStartDate).inDays / 7;
          return (weeks.ceil() * habit.targetDays!);
        }
        return finalEndDate.difference(effectiveStartDate).inDays + 1;

      case FrequencyType.monthly:
        if (habit.selectedDays.isNotEmpty) {
          // Count selected days in the timeframe
          return _countSelectedDaysInTimeframe(
            habit.selectedDays,
            StatisticsTimeframe(
              startDate: effectiveStartDate,
              endDate: finalEndDate,
            ),
          );
        } else if (habit.targetDays != null) {
          // Count months * targetDays
          final months = (finalEndDate.year - effectiveStartDate.year) * 12 +
              finalEndDate.month -
              effectiveStartDate.month +
              1;
          return months * habit.targetDays!;
        }
        return finalEndDate.difference(effectiveStartDate).inDays + 1;

      case FrequencyType.yearly:
        return 0;
    }
  }

  int _countSelectedDaysInTimeframe(
      List<int> selectedDays, StatisticsTimeframe timeframe) {
    int count = 0;
    var currentDate = timeframe.startDate;
    while (!currentDate.isAfter(timeframe.endDate)) {
      if (selectedDays.contains(currentDate.weekday)) {
        count++;
      }
      currentDate = currentDate.add(const Duration(days: 1));
    }
    return count;
  }

  int _calculateSuccessfulDays(
    Habit habit,
    Map<String, HabitEntryExtended> entriesMap,
    StatisticsTimeframe timeframe,
  ) {
    final successfulEntries = entriesMap.values
        .where((entry) => entry.entry?.status == HabitEntryStatus.success)
        .toList();

    if (habit.frequencyType == FrequencyType.weekly &&
        habit.targetDays != null) {
      // Group by week and count successful days, capped at targetDays
      return _groupByWeekAndCount(successfulEntries, habit.targetDays!);
    } else if (habit.frequencyType == FrequencyType.monthly &&
        habit.targetDays != null) {
      // Group by month and count successful days, capped at targetDays
      return _groupByMonthAndCount(successfulEntries, habit.targetDays!);
    }

    return successfulEntries.length;
  }

  int _calculateFailedDays(
    Habit habit,
    Map<String, HabitEntryExtended> entriesMap,
    StatisticsTimeframe timeframe,
    int successfulDays,
  ) {
    if (habit.frequencyType == FrequencyType.weekly &&
        habit.targetDays != null) {
      final weeks =
          timeframe.endDate.difference(timeframe.startDate).inDays / 7;
      final totalTargetDays = weeks.ceil() * habit.targetDays!;
      return totalTargetDays - successfulDays;
    } else if (habit.frequencyType == FrequencyType.monthly &&
        habit.targetDays != null) {
      final months = (timeframe.endDate.year - timeframe.startDate.year) * 12 +
          timeframe.endDate.month -
          timeframe.startDate.month +
          1;
      final totalTargetDays = months * habit.targetDays!;
      return totalTargetDays - successfulDays;
    }

    return entriesMap.values
        .where((entry) => entry.entry?.status == HabitEntryStatus.failed)
        .length;
  }

  double _calculateAverageValue(
      Habit habit, Iterable<HabitEntryExtended> entries) {
    if (habit.type == HabitType.checkbox) {
      return 1.0; // For checkbox habits, consider value as 1
    }

    final completedEntries = entries
        .where((entry) => entry.entry?.status == HabitEntryStatus.success)
        .toList();

    if (completedEntries.isEmpty) return 0.0;

    final totalValue = completedEntries.fold<int>(
      0,
      (sum, entry) => sum + (entry.entry?.value ?? 0),
    );

    return totalValue / completedEntries.length;
  }

  int _groupByWeekAndCount(List<HabitEntryExtended> entries, int targetDays) {
    final weekMap = <int, int>{};
    for (final entry in entries) {
      final date = DateTime.parse(entry.date);
      final weekNumber = date.difference(DateTime(date.year)).inDays ~/ 7;
      weekMap[weekNumber] = (weekMap[weekNumber] ?? 0) + 1;
    }
    return weekMap.values
        .map((count) => count > targetDays ? targetDays : count)
        .fold(0, (sum, count) => sum + count);
  }

  int _groupByMonthAndCount(List<HabitEntryExtended> entries, int targetDays) {
    final monthMap = <String, int>{};
    for (final entry in entries) {
      final date = DateTime.parse(entry.date);
      final monthKey = '${date.year}-${date.month}';
      monthMap[monthKey] = (monthMap[monthKey] ?? 0) + 1;
    }
    return monthMap.values
        .map((count) => count > targetDays ? targetDays : count)
        .fold(0, (sum, count) => sum + count);
  }

  // Convenience methods for common timeframes
  Future<HabitStatistics> getTodayStatistics(String habitId) async {
    return calculateStatistics(habitId, StatisticsTimeframe.today());
  }

  Future<HabitStatistics> getThisWeekStatistics(String habitId) async {
    return calculateStatistics(habitId, StatisticsTimeframe.thisWeek());
  }

  Future<HabitStatistics> getThisMonthStatistics(String habitId) async {
    return calculateStatistics(habitId, StatisticsTimeframe.thisMonth());
  }

  Future<HabitStatistics> getOverallStatistics(String habitId) async {
    return calculateStatistics(habitId, StatisticsTimeframe.overall());
  }
}
