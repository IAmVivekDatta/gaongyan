import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart' as p;
import 'database_interface.dart';

BaseDatabaseService createDatabaseService() => DatabaseServiceImpl();

class DatabaseServiceImpl implements BaseDatabaseService {
  // Singleton pattern
  DatabaseServiceImpl._();
  static final DatabaseServiceImpl _instance = DatabaseServiceImpl._();
  factory DatabaseServiceImpl() => _instance;

  // Database instance
  static Database? _database;
  
  Future<Database> get database async {
    if (_database != null) return _database!;
    String path = p.join(await getDatabasesPath(), 'app_database.db');
    _database = await openDatabase(
      path,
      version: 1,
      onCreate: (Database db, int version) async {
        // Create Users table
        await db.execute('''
          CREATE TABLE users (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            name TEXT NOT NULL,
            age INTEGER NOT NULL,
            preferredLanguage TEXT NOT NULL,
            email TEXT,
            avatar TEXT,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');

        // Create Achievements table
        await db.execute('''
          CREATE TABLE achievements (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            title TEXT NOT NULL,
            description TEXT NOT NULL,
            type TEXT NOT NULL,
            icon TEXT,
            unlocked INTEGER DEFAULT 0,
            createdAt TEXT,
            unlockedAt TEXT,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');

        // Create Module Progress table
        await db.execute('''
          CREATE TABLE module_progress (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            moduleId TEXT NOT NULL,
            progress REAL DEFAULT 0.0,
            lastAccessed TEXT,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');

        // Create Quiz Results table
        await db.execute('''
          CREATE TABLE quiz_results (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            userId INTEGER,
            moduleId TEXT NOT NULL,
            score INTEGER NOT NULL,
            totalQuestions INTEGER NOT NULL,
            completedAt TEXT,
            FOREIGN KEY (userId) REFERENCES users(id)
          )
        ''');

        // Create Modules table
        await db.execute('''
          CREATE TABLE modules (
            moduleId TEXT PRIMARY KEY,
            title TEXT NOT NULL,
            description TEXT,
            content TEXT NOT NULL,
            createdAt TEXT,
            updatedAt TEXT
          )
        ''');
      },
    );
    return _database!;
  }

  // User Operations
  @override
  Future<int> createUser(String name, int age, String preferredLanguage, {String? email, String? avatar}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('users', {
      'name': name,
      'age': age,
      'preferredLanguage': preferredLanguage,
      'email': email,
      'avatar': avatar,
      'createdAt': now,
      'updatedAt': now,
    });
  }

  @override
  Future<Map<String, dynamic>?> getUser(int id) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'users',
      where: 'id = ?',
      whereArgs: [id],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    final db = await database;
    return await db.query('users', orderBy: 'name');
  }

  @override
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    final db = await database;
    data['updatedAt'] = DateTime.now().toIso8601String();
    await db.update(
      'users',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteUser(int id) async {
    final db = await database;
    await db.transaction((txn) async {
      await txn.delete('quiz_results', where: 'userId = ?', whereArgs: [id]);
      await txn.delete('module_progress', where: 'userId = ?', whereArgs: [id]);
      await txn.delete('achievements', where: 'userId = ?', whereArgs: [id]);
      await txn.delete('users', where: 'id = ?', whereArgs: [id]);
    });
  }

  @override
  Future<void> updateUserLanguage(int id, String language) async {
    await updateUser(id, {'preferredLanguage': language});
  }

  // Achievement Operations
  @override
  Future<int> createAchievement(int userId, String title, String description, String type, {String? icon, bool unlocked = false}) async {
    final db = await database;
    final now = DateTime.now().toIso8601String();
    return await db.insert('achievements', {
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'icon': icon,
      'unlocked': unlocked ? 1 : 0,
      'createdAt': now,
      'unlockedAt': unlocked ? now : null,
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getUserAchievements(int userId) async {
    final db = await database;
    return await db.query(
      'achievements',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  @override
  Future<void> updateAchievement(int id, Map<String, dynamic> data) async {
    final db = await database;
    await db.update(
      'achievements',
      data,
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteAchievement(int id) async {
    final db = await database;
    await db.delete(
      'achievements',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> unlockAchievement(int userId, int achievementId) async {
    final db = await database;
    await db.update(
      'achievements',
      {
        'unlocked': 1,
        'unlockedAt': DateTime.now().toIso8601String(),
      },
      where: 'id = ? AND userId = ?',
      whereArgs: [achievementId, userId],
    );
  }

  // Module Progress Operations
  @override
  Future<int> createProgress(int userId, String moduleId, double progress) async {
    final db = await database;
    return await db.insert('module_progress', {
      'userId': userId,
      'moduleId': moduleId,
      'progress': progress,
      'lastAccessed': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<void> updateProgress(int userId, String moduleId, double progress) async {
    final db = await database;
    await db.insert(
      'module_progress',
      {
        'userId': userId,
        'moduleId': moduleId,
        'progress': progress,
        'lastAccessed': DateTime.now().toIso8601String(),
      },
      conflictAlgorithm: ConflictAlgorithm.replace,
    );
  }

  @override
  Future<double> getProgress(int userId, String moduleId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'module_progress',
      where: 'userId = ? AND moduleId = ?',
      whereArgs: [userId, moduleId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first['progress'] as double : 0.0;
  }

  @override
  Future<List<Map<String, dynamic>>> getUserProgress(int userId) async {
    final db = await database;
    return await db.query(
      'module_progress',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'lastAccessed DESC',
    );
  }

  @override
  Future<void> deleteProgress(int userId, String moduleId) async {
    final db = await database;
    await db.delete(
      'module_progress',
      where: 'userId = ? AND moduleId = ?',
      whereArgs: [userId, moduleId],
    );
  }

  // Quiz Results Operations
  @override
  Future<int> saveQuizResult(int userId, String moduleId, int score, int totalQuestions) async {
    final db = await database;
    return await db.insert('quiz_results', {
      'userId': userId,
      'moduleId': moduleId,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': DateTime.now().toIso8601String(),
    });
  }

  @override
  Future<List<Map<String, dynamic>>> getQuizResults(int userId) async {
    final db = await database;
    return await db.query(
      'quiz_results',
      where: 'userId = ?',
      whereArgs: [userId],
      orderBy: 'completedAt DESC',
    );
  }

  @override
  Future<List<Map<String, dynamic>>> getModuleQuizResults(int userId, String moduleId) async {
    final db = await database;
    return await db.query(
      'quiz_results',
      where: 'userId = ? AND moduleId = ?',
      whereArgs: [userId, moduleId],
      orderBy: 'completedAt DESC',
    );
  }

  @override
  Future<void> deleteQuizResult(int id) async {
    final db = await database;
    await db.delete(
      'quiz_results',
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  @override
  Future<void> deleteUserQuizResults(int userId) async {
    final db = await database;
    await db.delete(
      'quiz_results',
      where: 'userId = ?',
      whereArgs: [userId],
    );
  }

  // Module Operations
  @override
  Future<List<Map<String, dynamic>>> getModules() async {
    final db = await database;
    return await db.query('modules', orderBy: 'title');
  }

  @override
  Future<Map<String, dynamic>?> getModule(String moduleId) async {
    final db = await database;
    final List<Map<String, dynamic>> results = await db.query(
      'modules',
      where: 'moduleId = ?',
      whereArgs: [moduleId],
      limit: 1,
    );
    return results.isNotEmpty ? results.first : null;
  }

  @override
  Future<void> updateModuleContent(String moduleId, Map<String, dynamic> content) async {
    final db = await database;
    content['updatedAt'] = DateTime.now().toIso8601String();
    await db.update(
      'modules',
      content,
      where: 'moduleId = ?',
      whereArgs: [moduleId],
    );
  }
}
