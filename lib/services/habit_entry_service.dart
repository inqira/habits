import 'package:flutter/material.dart';

import 'package:habits/core/extensions/date_extension.dart';
import 'package:habits/models/habit_entry_extended.dart';
import 'package:habits/repositories/habit_entry_repository.dart';
import 'package:habits/services/habit_service.dart';

export 'package:habits/models/habit_entry.dart';
export 'package:habits/models/habit_entry_extended.dart';

class HabitEntryService {
  final HabitEntryRepository _repository;
  final HabitService _habitService;

  HabitEntryService(this._habitService, this._repository);

  Future<List<HabitEntryExtended>> getEntriesForDate(DateTime date) async {
    try {
      final normalizedDate = date.toNormalizedDate();
      final availableHabits = _habitService.habits.value
          .where((habit) => habit.availableAtDate(normalizedDate))
          .toList();

      final entries = await _repository
          .getEntriesForDate(normalizedDate.toShortDateString());
      final entriesMap = {for (var e in entries) e.habitId.toString(): e};

      return availableHabits.map((habit) {
        final entry = entriesMap[habit.id.toString()];
        return HabitEntryExtended(
          habit: habit,
          date: normalizedDate.toShortDateString(),
          entry: entry,
        );
      }).toList();
    } catch (e) {
      debugPrint('Error getting entries for date: $e');
      return [];
    }
  }

  Future<Map<String, HabitEntryExtended>> getEntriesForHabit(
    String habitId,
    DateTime startDate,
    DateTime endDate,
  ) async {
    try {
      final habit = _habitService.getHabit(habitId);
      if (habit == null) return {};

      final normalizedStartDate = startDate.toNormalizedDate();
      final normalizedEndDate = endDate.toNormalizedDate();

      final entries = await _repository.getEntriesForHabit(
        habitId,
        normalizedStartDate.toShortDateString(),
        normalizedEndDate.toShortDateString(),
      );

      return {
        for (var entry in entries)
          entry.date: HabitEntryExtended(
            date: entry.date,
            habit: habit,
            entry: entry,
          )
      };
    } catch (e) {
      debugPrint('Error getting entries for habit: $e');
      return {};
    }
  }

  Future<HabitEntry?> createEntry({
    required String habitId,
    required String date,
    required HabitEntryStatus status,
    int? value,
    String? note,
  }) async {
    try {
      final entry = HabitEntry.create(
        habitId: habitId,
        date: date,
        habitStatus: status,
        value: value ?? 0,
        note: note,
      );

      final success = await _repository.insertEntry(entry);
      return success ? entry : null;
    } catch (e) {
      debugPrint('Error creating entry: $e');
      return null;
    }
  }

  Future<bool> updateEntryAttributes({
    required String id,
    required String habitId,
    required String date,
    required HabitEntryStatus status,
    int value = 0,
    String? note,
  }) async {
    try {
      final entry = HabitEntry(
        habitId: habitId,
        date: date,
        status: status,
        value: value,
        note: note,
        createdAt: DateTime.now(),
        updatedAt: DateTime.now(),
      );

      return await _repository.updateEntry(entry);
    } catch (e) {
      debugPrint('Error updating entry: $e');
      return false;
    }
  }

  Future<bool> updateEntry(HabitEntry? entry) async {
    if (entry == null) return false;

    try {
      return await _repository.insertOrUpdateEntry(entry);
    } catch (e) {
      debugPrint('Error updating entry: $e');
      return false;
    }
  }

  Future<bool> updateValue(String habitEntryId, int newValue) async {
    try {
      final entry = await _repository.getEntryById(habitEntryId);
      if (entry == null) {
        debugPrint('Error updating value: Entry not found');
        return false;
      }

      final updatedEntry = entry.copyWith(
        value: newValue,
        updatedAt: DateTime.now(),
      );

      return await _repository.updateEntry(updatedEntry);
    } catch (e) {
      debugPrint('Error updating value: $e');
      return false;
    }
  }

  Future<bool> deleteEntry(String id) async {
    try {
      return await _repository.deleteEntry(id);
    } catch (e) {
      debugPrint('Error deleting entry: $e');
      return false;
    }
  }

  Future<HabitEntryExtended?> getEntry(String habitId, String date) async {
    try {
      final habit = _habitService.getHabit(habitId);
      if (habit == null) return null;

      final entry = await _repository.getEntryForDate(habitId, date);
      return HabitEntryExtended(
        habit: habit,
        date: date,
        entry: entry,
      );
    } catch (e) {
      debugPrint('Error getting entry: $e');
      return null;
    }
  }
}
