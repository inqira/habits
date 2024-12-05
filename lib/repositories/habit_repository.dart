import 'package:habits/models/habit.dart';
import 'package:habits/repositories/base_repository.dart';

export 'package:habits/models/habit.dart';

class HabitRepository extends BaseRepository {
  static const String table = 'habit';

  Future<List<Habit>> getAllHabits() async {
    final data = await getAll(table);
    return data.map((json) => Habit.fromJson(json)).toList();
  }

  Future<Habit?> getHabitById(String id) async {
    final data = await getById(table, id);
    return data != null ? Habit.fromJson(data) : null;
  }

  Future<bool> insertHabit(Habit habit) async {
    final result = await insert(table, habit.toJson());
    return result > 0;
  }

  Future<bool> updateHabit(Habit habit) async {
    final result = await update(table, habit.toJson(), habit.id);
    return result > 0;
  }

  Future<bool> deleteHabit(String id) async {
    final result = await delete(table, id);
    return result > 0;
  }

  Future<List<Habit>> getHabitsByCategoryId(String categoryId) async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'category_id = ?',
      whereArgs: [categoryId],
    );
    return results.map((json) => Habit.fromJson(json)).toList();
  }

  Future<List<Habit>> getActiveHabits() async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'is_archived = ?',
      whereArgs: [0],
    );
    return results.map((json) => Habit.fromJson(json)).toList();
  }

  Future<List<Habit>> getArchivedHabits() async {
    final db = await database;
    final results = await db.query(
      table,
      where: 'is_archived = ?',
      whereArgs: [1],
    );
    return results.map((json) => Habit.fromJson(json)).toList();
  }
}
