import 'package:logging/logging.dart';

import 'package:habits/models/habit_entry.dart';
import 'package:habits/repositories/base_repository.dart';

export 'package:habits/models/habit_entry.dart';

final _logger = Logger('HabitEntryRepository');

class HabitEntryRepository extends BaseRepository {
  static const String table = 'habit_entry';

  Future<List<HabitEntry>> getAllEntries() async {
    final data = await getAll(table);
    return data.map((json) => HabitEntry.fromJson(json)).toList();
  }

  Future<HabitEntry?> getEntryById(String id) async {
    final data = await getById(table, id);
    return data != null ? HabitEntry.fromJson(data) : null;
  }

  Future<bool> insertEntry(HabitEntry entry) async {
    final result = await insert(table, entry.toJson());
    return result > 0;
  }

  Future<bool> updateEntry(HabitEntry entry) async {
    final result = await update(table, entry.toJson(), entry.id);
    return result > 0;
  }

  Future<bool> deleteEntry(String id) async {
    final result = await delete(table, id);
    return result > 0;
  }

  Future<List<HabitEntry>> getEntriesForHabit(
    String habitId,
    String startDate,
    String endDate,
  ) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'habit_id = ? AND date >= ? AND date <= ?',
      whereArgs: [habitId, startDate, endDate],
      orderBy: 'date ASC',
    );
    return results.map((json) => HabitEntry.fromJson(json)).toList();
  }

  Future<HabitEntry?> getEntryForDate(String habitId, String date) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'habit_id = ? AND date = ?',
      whereArgs: [habitId, date],
      limit: 1,
    );
    return results.isNotEmpty ? HabitEntry.fromJson(results.first) : null;
  }

  Future<List<HabitEntry>> getEntriesForDate(String date) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'date = ?',
      whereArgs: [date],
    );
    return results.map((json) => HabitEntry.fromJson(json)).toList();
  }

  Future<bool> insertOrUpdateEntry(HabitEntry entry) async {
    try {
      final existingEntry = await getEntryForDate(entry.habitId, entry.date);

      if (existingEntry != null) {
        // Update existing entry
        final updatedEntry = entry.copyWith(
          createdAt: existingEntry.createdAt,
        );
        return await updateEntry(updatedEntry);
      } else {
        // Insert new entry
        return await insertEntry(entry);
      }
    } catch (e) {
      _logger.warning('Error in insertOrUpdateEntry: $e');
      return false;
    }
  }
}
