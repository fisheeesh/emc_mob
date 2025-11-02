import 'dart:async';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import '../models/check_in_model.dart';

/// A singleton class that manages the SQLite database for check-in records.
///
/// This class provides methods to initialize the database, perform CRUD operations,
/// and maintain a single instance of the database connection.
class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._privateConstructor();

  DatabaseHelper._privateConstructor();

  static Database? _database;

  Future<Database> get database async {
    _database ??= await _initDatabase();
    return _database!;
  }

  Future<Database> _initDatabase() async {
    try {
      final path = join(await getDatabasesPath(), 'checkins.db');
      return await openDatabase(
        path,
        version: 3,
        onCreate: (db, version) async {
          await db.execute('''
            CREATE TABLE IF NOT EXISTS checkins (
              id INTEGER PRIMARY KEY AUTOINCREMENT,
              emoji TEXT NOT NULL,
              textFeeling TEXT NOT NULL,
              createdAt TEXT NOT NULL,
              checkInTime TEXT NOT NULL
            )
          ''');
        },
        onUpgrade: (db, oldVersion, newVersion) async {
          if (oldVersion < 3) {
            await db.execute('DROP TABLE IF EXISTS checkins');
            await db.execute('''
              CREATE TABLE checkins (
                id INTEGER PRIMARY KEY AUTOINCREMENT,
                emoji TEXT NOT NULL,
                textFeeling TEXT NOT NULL,
                createdAt TEXT NOT NULL,
                checkInTime TEXT NOT NULL
              )
            ''');
          }
        },
      );
    } catch (e) {
      throw Exception("Database Initialization Error: $e");
    }
  }

  Future<void> insertCheckIn(CheckIn checkIn) async {
    final db = await database;
    await db.insert(
      'checkins',
      checkIn.toJson(),
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  Future<List<CheckIn>> getCheckIns() async {
    final db = await database;
    final List<Map<String, dynamic>> maps = await db.query('checkins');
    return maps.map((json) => CheckIn.fromJson(json)).toList();
  }

  Future<void> clearCheckIns() async {
    final db = await database;
    await db.execute("DELETE FROM checkins");
  }
}