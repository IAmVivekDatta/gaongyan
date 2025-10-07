import 'dart:convert';
import 'dart:html';
import 'database_interface.dart';

BaseDatabaseService createDatabaseService() => WebDatabaseService();

class WebDatabaseService implements BaseDatabaseService {
  static final WebDatabaseService _instance = WebDatabaseService._internal();

  factory WebDatabaseService() => _instance;

  WebDatabaseService._internal() {
    // Initialize collections if they don't exist
    if (_getData('users') == null) _saveData('users', []);
    if (_getData('achievements') == null) _saveData('achievements', []);
    if (_getData('modules') == null) {
      _saveData('modules', [
        {
          'id': 'banking_telugu',
          'title': 'Banking in Telugu',
          'icon': 'account_balance',
          'content': 'Learn about banking services in Telugu language.',
          'progress': 0.0,
          'updatedAt': DateTime.now().toIso8601String(),
        }
      ]);
    }
  }

  // Helper methods to work with localStorage
  void _saveData(String key, dynamic data) {
    window.localStorage[key] = json.encode(data);
  }

  dynamic _getData(String key) {
    String? data = window.localStorage[key];
    return data != null ? json.decode(data) : null;
  }

  List<dynamic> _getCollection(String collection) {
    return _getData(collection) ?? [];
  }

  void _saveCollection(String collection, List<dynamic> data) {
    _saveData(collection, data);
  }

  // User Operations
  @override
  Future<int> createUser(String name, int age, String preferredLanguage, {String? email, String? avatar}) async {
    List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(_getCollection('users'));
    int id = users.isEmpty ? 1 : users.last['id'] + 1;
    
    Map<String, dynamic> user = {
      'id': id,
      'name': name,
      'age': age,
      'preferredLanguage': preferredLanguage,
      'email': email,
      'avatar': avatar,
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    };

    users.add(user);
    _saveCollection('users', users);
    return id;
  }

  @override
  Future<Map<String, dynamic>?> getUser(int id) async {
    List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(_getCollection('users'));
    try {
      return users.cast<Map<String, dynamic>>().firstWhere(
        (user) => user['id'] == id,
      );
    } catch (e) {
      return null;
    }
  }

  @override
  Future<void> updateUserLanguage(int id, String language) async {
    List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(_getCollection('users'));
    int index = users.indexWhere((user) => user['id'] == id);
    if (index != -1) {
      users[index]['preferredLanguage'] = language;
      _saveCollection('users', users);
    }
  }

  // Progress Operations
  // Achievement Operations
  @override
  Future<int> createAchievement(int userId, String title, String description, String type, {String? icon, bool unlocked = false}) async {
    List<Map<String, dynamic>> achievements = List<Map<String, dynamic>>.from(_getCollection('achievements'));
    int id = achievements.isEmpty ? 1 : achievements.last['id'] + 1;

    Map<String, dynamic> achievement = {
      'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'type': type,
      'icon': icon,
      'unlocked': unlocked,
      'createdAt': DateTime.now().toIso8601String(),
      'unlockedAt': unlocked ? DateTime.now().toIso8601String() : null,
    };

    achievements.add(achievement);
    _saveCollection('achievements', achievements);
    return id;
  }

  @override
  Future<List<Map<String, dynamic>>> getUserAchievements(int userId) async {
    List<Map<String, dynamic>> achievements = List<Map<String, dynamic>>.from(_getCollection('achievements'));
    return achievements.where((a) => a['userId'] == userId).toList();
  }

  @override
  Future<void> updateAchievement(int id, Map<String, dynamic> data) async {
    List<Map<String, dynamic>> achievements = List<Map<String, dynamic>>.from(_getCollection('achievements'));
    int index = achievements.indexWhere((a) => a['id'] == id);
    if (index != -1) {
      achievements[index] = {...achievements[index], ...data, 'updatedAt': DateTime.now().toIso8601String()};
      _saveCollection('achievements', achievements);
    }
  }

  @override
  Future<void> deleteAchievement(int id) async {
    List<Map<String, dynamic>> achievements = List<Map<String, dynamic>>.from(_getCollection('achievements'));
    achievements.removeWhere((a) => a['id'] == id);
    _saveCollection('achievements', achievements);
  }

  @override
  Future<void> unlockAchievement(int userId, int achievementId) async {
    List<Map<String, dynamic>> achievements = List<Map<String, dynamic>>.from(_getCollection('achievements'));
    int index = achievements.indexWhere((a) => a['id'] == achievementId && a['userId'] == userId);
    if (index != -1 && !achievements[index]['unlocked']) {
      achievements[index]['unlocked'] = true;
      achievements[index]['unlockedAt'] = DateTime.now().toIso8601String();
      achievements[index]['updatedAt'] = DateTime.now().toIso8601String();
      _saveCollection('achievements', achievements);
    }
  }

  @override
  Future<void> updateProgress(int userId, String moduleId, double progress) async {
    List<Map<String, dynamic>> progressList = List<Map<String, dynamic>>.from(_getCollection('progress'));
    
    var existingProgress = progressList.indexWhere(
      (p) => p['userId'] == userId && p['moduleId'] == moduleId
    );

    Map<String, dynamic> progressData = {
      'userId': userId,
      'moduleId': moduleId,
      'progress': progress,
      'lastAccessed': DateTime.now().toIso8601String(),
    };

    if (existingProgress != -1) {
      progressList[existingProgress] = progressData;
    } else {
      progressData['id'] = progressList.isEmpty ? 1 : progressList.last['id'] + 1;
      progressList.add(progressData);
    }

    _saveCollection('progress', progressList);
  }

  @override
  Future<double> getProgress(int userId, String moduleId) async {
    List<Map<String, dynamic>> progressList = List<Map<String, dynamic>>.from(_getCollection('progress'));
    
    var progress = progressList.cast<Map<String, dynamic>>().firstWhere(
      (p) => p['userId'] == userId && p['moduleId'] == moduleId,
      orElse: () => {'progress': 0.0},
    );

    return progress['progress'] ?? 0.0;
  }

  // Quiz Results Operations
  @override
  Future<List<Map<String, dynamic>>> getAllUsers() async {
    List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(_getCollection('users'));
    return users..sort((a, b) => a['name'].compareTo(b['name']));
  }

  @override
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(_getCollection('users'));
    int index = users.indexWhere((user) => user['id'] == id);
    if (index != -1) {
      data['updatedAt'] = DateTime.now().toIso8601String();
      users[index] = {...users[index], ...data};
      _saveCollection('users', users);
    }
  }

  @override
  Future<void> deleteUser(int id) async {
    // Delete user data from all collections
    List<Map<String, dynamic>> users = List<Map<String, dynamic>>.from(_getCollection('users'));
    users.removeWhere((user) => user['id'] == id);
    _saveCollection('users', users);

    // Delete associated progress records
    List<Map<String, dynamic>> progress = List<Map<String, dynamic>>.from(_getCollection('progress'));
    progress.removeWhere((p) => p['userId'] == id);
    _saveCollection('progress', progress);

    // Delete associated quiz results
    List<Map<String, dynamic>> quizResults = List<Map<String, dynamic>>.from(_getCollection('quiz_results'));
    quizResults.removeWhere((q) => q['userId'] == id);
    _saveCollection('quiz_results', quizResults);
  }

  @override
  Future<int> createProgress(int userId, String moduleId, double progress) async {
    List<Map<String, dynamic>> progressList = List<Map<String, dynamic>>.from(_getCollection('progress'));
    int id = progressList.isEmpty ? 1 : progressList.last['id'] + 1;
    
    Map<String, dynamic> progressData = {
      'id': id,
      'userId': userId,
      'moduleId': moduleId,
      'progress': progress,
      'lastAccessed': DateTime.now().toIso8601String(),
    };

    progressList.add(progressData);
    _saveCollection('progress', progressList);
    return id;
  }

  @override
  Future<List<Map<String, dynamic>>> getUserProgress(int userId) async {
    List<Map<String, dynamic>> progressList = List<Map<String, dynamic>>.from(_getCollection('progress'));
    return progressList.where((p) => p['userId'] == userId).toList()
      ..sort((a, b) => b['lastAccessed'].compareTo(a['lastAccessed']));
  }

  @override
  Future<void> deleteProgress(int userId, String moduleId) async {
    List<Map<String, dynamic>> progressList = List<Map<String, dynamic>>.from(_getCollection('progress'));
    progressList.removeWhere((p) => p['userId'] == userId && p['moduleId'] == moduleId);
    _saveCollection('progress', progressList);
  }

  @override
  Future<int> saveQuizResult(int userId, String moduleId, int score, int totalQuestions) async {
    List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(_getCollection('quiz_results'));
    int id = results.isEmpty ? 1 : results.last['id'] + 1;
    
    Map<String, dynamic> result = {
      'id': id,
      'userId': userId,
      'moduleId': moduleId,
      'score': score,
      'totalQuestions': totalQuestions,
      'completedAt': DateTime.now().toIso8601String(),
    };

    results.add(result);
    _saveCollection('quiz_results', results);
    return id;
  }

  @override
  Future<List<Map<String, dynamic>>> getQuizResults(int userId) async {
    List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(_getCollection('quiz_results'));
    return results.where((result) => result['userId'] == userId).toList()
      ..sort((a, b) => b['completedAt'].compareTo(a['completedAt']));
  }

  @override
  Future<List<Map<String, dynamic>>> getModuleQuizResults(int userId, String moduleId) async {
    List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(_getCollection('quiz_results'));
    return results.where((result) => result['userId'] == userId && result['moduleId'] == moduleId).toList()
      ..sort((a, b) => b['completedAt'].compareTo(a['completedAt']));
  }

  @override
  Future<void> deleteQuizResult(int id) async {
    List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(_getCollection('quiz_results'));
    results.removeWhere((result) => result['id'] == id);
    _saveCollection('quiz_results', results);
  }

  @override
  Future<void> deleteUserQuizResults(int userId) async {
    List<Map<String, dynamic>> results = List<Map<String, dynamic>>.from(_getCollection('quiz_results'));
    results.removeWhere((result) => result['userId'] == userId);
    _saveCollection('quiz_results', results);
  }

  @override
  Future<List<Map<String, dynamic>>> getModules() async {
    List<Map<String, dynamic>> modules = List<Map<String, dynamic>>.from(_getCollection('modules'));
    return modules..sort((a, b) => a['title'].compareTo(b['title']));
  }

  @override
  Future<Map<String, dynamic>?> getModule(String moduleId) async {
    List<Map<String, dynamic>> modules = List<Map<String, dynamic>>.from(_getCollection('modules'));
    try {
      return modules.firstWhere((module) => module['id'] == moduleId);
    } catch (_) {
      return null;
    }
  }

  @override
  Future<void> updateModuleContent(String moduleId, Map<String, dynamic> content) async {
    List<Map<String, dynamic>> modules = List<Map<String, dynamic>>.from(_getCollection('modules'));
    int index = modules.indexWhere((module) => module['id'] == moduleId);
    if (index != -1) {
      content['updatedAt'] = DateTime.now().toIso8601String();
      modules[index] = {...modules[index], ...content};
      _saveCollection('modules', modules);
    }
  }
}
