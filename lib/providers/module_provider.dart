import 'package:flutter/foundation.dart';
import '../services/database_factory.dart';
import '../services/database_interface.dart';

class ModuleProvider extends ChangeNotifier {
  final BaseDatabaseService _db = DatabaseFactory.getDatabaseService();
  List<Map<String, dynamic>>? _modules;
  Map<String, Map<String, dynamic>>? _moduleProgress;
  int? _currentUserId;

  List<Map<String, dynamic>> get modules => _modules ?? [];
  Map<String, Map<String, dynamic>>? get moduleProgress => _moduleProgress;

  Future<void> loadModules() async {
    _modules = await _db.getModules();
    notifyListeners();
  }

  Future<Map<String, dynamic>?> getModule(String moduleId) async {
    return await _db.getModule(moduleId);
  }

  Future<void> updateModuleContent(String moduleId, Map<String, dynamic> content) async {
    await _db.updateModuleContent(moduleId, content);
    await loadModules(); // Reload modules to reflect changes
  }

  Future<void> loadProgressForUser(int userId) async {
    if (_currentUserId != userId) {
      _currentUserId = userId;
      _moduleProgress = {};
      final progress = await _db.getUserProgress(userId);
      
      for (var item in progress) {
        _moduleProgress![item['moduleId']] = item;
      }
      
      notifyListeners();
    }
  }

  Future<void> updateProgress(int userId, String moduleId, double progress) async {
    await _db.updateProgress(userId, moduleId, progress);
    
    if (_moduleProgress != null) {
      _moduleProgress![moduleId] = {
        'userId': userId,
        'moduleId': moduleId,
        'progress': progress,
        'lastAccessed': DateTime.now().toIso8601String(),
      };
      notifyListeners();
    }
  }

  Future<void> clearProgress(int userId, String moduleId) async {
    await _db.deleteProgress(userId, moduleId);
    
    if (_moduleProgress != null) {
      _moduleProgress!.remove(moduleId);
      notifyListeners();
    }
  }

  double getProgressForModule(String moduleId) {
    if (_moduleProgress == null || !_moduleProgress!.containsKey(moduleId)) {
      return 0.0;
    }
    return _moduleProgress![moduleId]!['progress'] ?? 0.0;
  }

  Future<void> recordQuizResult(int userId, String moduleId, int score, int totalQuestions) async {
    await _db.saveQuizResult(userId, moduleId, score, totalQuestions);
    // Update module progress based on quiz performance
    double progress = score / totalQuestions * 100;
    await updateProgress(userId, moduleId, progress);
  }

  Future<List<Map<String, dynamic>>> getQuizHistory(int userId, String moduleId) async {
    return await _db.getModuleQuizResults(userId, moduleId);
  }

  void clearUserData() {
    _moduleProgress = null;
    _currentUserId = null;
    notifyListeners();
  }
}
