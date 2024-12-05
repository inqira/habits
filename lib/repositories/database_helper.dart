import 'dart:async';

import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';

import 'package:habits/models/category.dart';
import 'package:habits/models/habit.dart';
import 'package:habits/models/habit_entry.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('habits.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    // Create tables in order of dependencies
    await db.execute(Category.createTableQuery);
    await db.execute(Habit.createTableQuery);
    await db.execute(HabitEntry.createTableQuery);
  }

  Future<void> close() async {
    final db = await instance.database;
    db.close();
  }
}
