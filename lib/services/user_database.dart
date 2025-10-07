import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';
import '../models/user.dart';

class UserDatabase {
  static Future<int> updateUserLanguage(int userId, String language) async {
    final db = await database;
    return await db.update('users', {'preferredLanguage': language}, where: 'id = ?', whereArgs: [userId]);
  }
  static Database? _database;

  static Future<Database> get database async {
    if (_database != null) return _database!;
    _database = await _initDB('user.db');
    return _database!;
  }

  static Future<Database> _initDB(String filePath) async {
    final dbPath = await getDatabasesPath();
    final path = join(dbPath, filePath);
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE users(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT,
            level INTEGER,
            xp INTEGER
          )
        ''');
        await db.execute('''
          CREATE TABLE progress(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            moduleId TEXT,
            progress INTEGER,
            FOREIGN KEY(userId) REFERENCES users(id)
          )
        ''');
        await db.execute('''
          CREATE TABLE quiz_results(
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            moduleId TEXT,
            score INTEGER,
            date TEXT,
            FOREIGN KEY(userId) REFERENCES users(id)
          )
        ''');
      },
    );
  }

  static Future<int> insertUser(User user) async {
    final db = await database;
    return await db.insert('users', user.toMap());
  }

  static Future<User?> getUser(int id) async {
    final db = await database;
    final maps = await db.query('users', where: 'id = ?', whereArgs: [id]);
    if (maps.isNotEmpty) {
      return User.fromMap(maps.first);
    }
    return null;
  }

  static Future<List<User>> getAllUsers() async {
    final db = await database;
    final result = await db.query('users');
    return result.map((map) => User.fromMap(map)).toList();
  }

  static Future<int> updateUser(User user) async {
    final db = await database;
    return await db.update('users', user.toMap(), where: 'id = ?', whereArgs: [user.id]);
  }

  static Future<int> deleteUser(int id) async {
    final db = await database;
    return await db.delete('users', where: 'id = ?', whereArgs: [id]);
  }

  // Progress CRUD
  static Future<int> insertProgress(int userId, String moduleId, int progress) async {
    final db = await database;
    return await db.insert('progress', {
      'userId': userId,
      'moduleId': moduleId,
      'progress': progress,
    });
  }

  static Future<List<Map<String, dynamic>>> getUserProgress(int userId) async {
    final db = await database;
    return await db.query('progress', where: 'userId = ?', whereArgs: [userId]);
  }

  static Future<int> updateProgress(int userId, String moduleId, int progress) async {
    final db = await database;
    return await db.update('progress', {'progress': progress}, where: 'userId = ? AND moduleId = ?', whereArgs: [userId, moduleId]);
  }

  static Future<int> deleteProgress(int userId, String moduleId) async {
    final db = await database;
    return await db.delete('progress', where: 'userId = ? AND moduleId = ?', whereArgs: [userId, moduleId]);
  }

  // Quiz Results CRUD
  static Future<int> insertQuizResult(int userId, String moduleId, int score, String date) async {
    final db = await database;
    return await db.insert('quiz_results', {
      'userId': userId,
      'moduleId': moduleId,
      'score': score,
      'date': date,
    });
  }

  static Future<List<Map<String, dynamic>>> getQuizResults(int userId) async {
    final db = await database;
    return await db.query('quiz_results', where: 'userId = ?', whereArgs: [userId]);
  }

  static Future<List<Map<String, dynamic>>> getModuleQuizResults(int userId, String moduleId) async {
    final db = await database;
    return await db.query('quiz_results', where: 'userId = ? AND moduleId = ?', whereArgs: [userId, moduleId]);
  }

  static Future<int> deleteUserQuizResults(int userId) async {
    final db = await database;
    return await db.delete('quiz_results', where: 'userId = ?', whereArgs: [userId]);
  }
}
