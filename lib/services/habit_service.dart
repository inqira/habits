import 'package:flutter/material.dart';

import 'package:collection/collection.dart';
import 'package:signals/signals_flutter.dart';

import 'package:habits/repositories/habit_repository.dart';

export 'package:habits/models/habit.dart';

class HabitService {
  final HabitRepository _repository;
  final _habits = signal<List<Habit>>([]);
  final _archivedHabits = signal<List<Habit>>([]);

  List<Habit> get allHabits => [..._habits.value, ..._archivedHabits.value];

  HabitService(this._repository) {
    _loadHabits();
  }

  Signal<List<Habit>> get habits => _habits;
  Signal<List<Habit>> get archivedHabits => _archivedHabits;

  void _loadHabits() async {
    try {
      final activeHabits = await _repository.getActiveHabits();
      final archived = await _repository.getArchivedHabits();

      _habits.value = activeHabits;
      _archivedHabits.value = archived;
    } catch (e) {
      debugPrint('Error loading habits: $e');
      _habits.value = [];
      _archivedHabits.value = [];
    }
  }

  Future<void> addHabit(Habit habit) async {
    try {
      final success = await _repository.insertHabit(habit);
      if (success) {
        if (habit.isArchived) {
          _archivedHabits.value = [..._archivedHabits.value, habit];
        } else {
          _habits.value = [..._habits.value, habit];
        }
      }
    } catch (e) {
      debugPrint('Error adding habit: $e');
    }
    _loadHabits();
  }

  Future<void> _updateHabit(Habit habit) async {
    try {
      await _repository.updateHabit(habit);
    } catch (e) {
      debugPrint('Error updating habit: $e');
    }
    _loadHabits();
  }

  Future<void> deleteHabit(String id) async {
    try {
      final success = await _repository.deleteHabit(id);
      if (success) {
        _habits.value =
            _habits.value.where((h) => h.id.toString() != id).toList();
        _archivedHabits.value =
            _archivedHabits.value.where((h) => h.id.toString() != id).toList();
      }
    } catch (e) {
      debugPrint('Error deleting habit: $e');
    }
    _loadHabits();
  }

  Future<void> toggleHabitArchived(Habit habit) async {
    if (habit.isArchived) {
      await unarchiveHabit(habit);
    } else {
      await archiveHabit(habit);
    }
  }

  Future<void> archiveHabit(Habit habit) async {
    final archivedHabit = habit.copyWith(
      isArchived: true,
      archivedAt: DateTime.now(),
    );
    await _updateHabit(archivedHabit);
  }

  Future<void> unarchiveHabit(Habit habit) async {
    final unarchivedHabit = habit.copyWith(
      isArchived: false,
      archivedAt: null,
    );
    await _updateHabit(unarchivedHabit);
  }

  Habit? getHabit(String id) {
    return allHabits.firstWhereOrNull((Habit h) => h.id == id);
  }

  List<Habit> getHabitsByCategoryId(String categoryId) {
    return _habits.value
        .where((h) => h.categoryId.toString() == categoryId)
        .toList();
  }

  Future<void> updateHabitWithFields(
    String habitId, {
    String? title,
    String? description,
    String? categoryId,
    DateTime? endDate,
  }) async {
    try {
      final habit = getHabit(habitId);
      if (habit == null) {
        debugPrint('Habit not found: $habitId');
        return;
      }

      final updatedHabit = habit.copyWith(
        title: title ?? habit.title,
        description: description,
        categoryId: categoryId ?? habit.categoryId,
        endDate: endDate ?? habit.endDate,
      );

      await _updateHabit(updatedHabit);
    } catch (e) {
      debugPrint('Error updating habit fields: $e');
      rethrow;
    }
  }

  late final firstHabitDay = computed(() {
    if (allHabits.isEmpty) return DateTime.now();
    return allHabits
        .map((h) => h.startDate)
        .reduce((a, b) => a.isBefore(b) ? a : b);
  });
}
