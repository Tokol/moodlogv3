import 'dart:io';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

import '../models/mood_log_models.dart';
import '../models/to_do_models.dart';


class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB();
    return _database!;
  }

  Future<Database> _initDB() async {
    Directory documentsDirectory = await getApplicationDocumentsDirectory();
    String path = join(documentsDirectory.path, 'moodlog.db');

    return await openDatabase(
      path,
      version: 1,
      onCreate: _createDB,
    );
  }

  Future<void> _createDB(Database db, int version) async {
    await db.execute('''
      CREATE TABLE moods (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        mood TEXT NOT NULL,
        intensityLevel INTEGER NOT NULL,
        moodFactors TEXT NOT NULL,
        location TEXT NOT NULL,
        notes TEXT,
        selectedTime TEXT NOT NULL,
        selectedDate TEXT NOT NULL
      )
    ''');

    await db.execute('''
  CREATE TABLE todos (
    id INTEGER PRIMARY KEY AUTOINCREMENT,
    title TEXT NOT NULL,
    description TEXT,
    url TEXT,              
    thumbnailUrl TEXT,      
    duration TEXT,
    category TEXT,
    tags TEXT,
    completed INTEGER NOT NULL DEFAULT 0,
    date TEXT NOT NULL,
    resourceType TEXT DEFAULT 'text'  
  )
''');


    await db.execute('''
      CREATE TABLE forecasts (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        forecast TEXT NOT NULL,
        timestamp TEXT NOT NULL
      )
    ''');


  }



  Future<void> saveForecast(String forecast) async {
    final db = await database;
    await db.delete('forecasts'); // Replace old forecast
    await db.insert('forecasts', {
      'forecast': forecast,
      'timestamp': DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, dynamic>?> getLatestForecast() async {
    final db = await database;
    final result = await db.query('forecasts', orderBy: 'timestamp DESC', limit: 1);
    return result.isNotEmpty ? result.first : null;
  }

  // Existing Methods (unchanged, included for completeness)




  // ✅ Insert MoodLog
  Future<int> insertMoodLog(MoodLog moodLog) async {
    final db = await database;
    int result = await db.insert(
      'moods',
      moodLog.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );

    print("Inserted Mood Log: ${moodLog.toString()}"); // ✅ Debugging print statement
    return result;
  }

  // ✅ Fetch Mood Logs by Date
  Future<List<MoodLog>> getMoodsByDate(String date) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moods',
      where: "selectedDate = ?",
      whereArgs: [date], // ✅ Compare only date part
    );

    return List.generate(maps.length, (i) {
      return MoodLog(
        mood: maps[i]['mood'],
        intensityLevel: maps[i]['intensityLevel'],
        moodFactors: (maps[i]['moodFactors'] as String).split(','), // ✅ Convert back to List
        location: maps[i]['location'],
        notes: maps[i]['notes'],
        selectedTime: maps[i]['selectedTime'],
        selectedDate: DateTime.parse(maps[i]['selectedDate']), // ✅ Convert back to DateTime
      );
    });
  }



  // ✅ Check if a mood is logged for a specific date & time
  Future<bool> isMoodLogged(String date, String time) async {
    final db = await database;
    final result = await db.query(
      'moods',
      where: 'selectedDate = ? AND selectedTime = ?',
      whereArgs: [date, time],
    );
    return result.isNotEmpty;
  }

  // ✅ Delete Mood by ID
  Future<int> deleteMood(int id) async {
    final db = await database;
    return await db.delete('moods', where: 'id = ?', whereArgs: [id]);
  }

  Future<List<MoodLog>> getMoodsInRange(String startDate, String endDate) async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query(
      'moods',
      where: "selectedDate BETWEEN ? AND ?",
      whereArgs: [startDate, endDate], // ✅ Ensure the dates are formatted as strings
    );

    return List.generate(maps.length, (i) {
      return MoodLog.fromMap(maps[i]); // ✅ Convert map to MoodLog object
    });
  }


  Future<List<MoodLog>> getAllMoods() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('moods'); // ✅ No WHERE clause to fetch everything
    print("length"+ (maps.length).toString());
    return List.generate(maps.length, (i) {
      return MoodLog.fromMap(maps[i]);
    });
  }

  // ✅ Delete all mood logs (Empty the table but keep the structure)
  Future<void> deleteAllMoods() async {
    final db = await database;
    await db.delete('moods'); // ✅ Deletes all rows in the moods table
    print("✅ All mood logs deleted successfully.");
  }

  //delete all TODO
  Future<void> deleteAllTODO() async {
    final db = await database;
    await db.delete('todos'); // ✅ Deletes all rows in the moods table
    print("✅ All mood logs deleted successfully.");
  }


  //TODO

  Future<int> insertTodoItem(TodoItem item) async {
    final db = await database;
    return await db.insert(
      'todos',
      item.toMap(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }


  Future<List<TodoItem>> getTodoItemsByDate(String date) async {
    final db = await database;
    final result = await db.query(
      'todos',
      where: 'date = ?',
      whereArgs: [date],
    );
    return result.map((map) => TodoItem.fromMap(map)).toList();
  }


  Future<int> updateTodoCompletion(int id, bool completed) async {
    final db = await database;
    return await db.update(
      'todos',
      {'completed': completed ? 1 : 0},
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<TodoItem>> getTodoItemsByResourceType(String type) async {
    final db = await database;
    final result = await db.query(
      'todos',
      where: 'resourceType = ?',
      whereArgs: [type],
    );
    return result.map((map) => TodoItem.fromMap(map)).toList();
  }


  Future<void> deleteAllTodos() async {
    final db = await database;
    await db.delete('todos');
  }

  Future<void> close() async {
    final db = await database;
    db.close();
  }

  Future<List<TodoItem>> getTodoItemsInDateRange(
      String startDate,
      String endDate,
      ) async {
    final db = await database;
    final result = await db.query(
      'todos',
      where: 'date BETWEEN ? AND ?',
      whereArgs: [startDate, endDate],
    );
    return result.map((map) => TodoItem.fromMap(map)).toList();
  }



}
