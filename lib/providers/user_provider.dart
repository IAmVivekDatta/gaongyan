import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../services/user_database.dart';
import '../models/user.dart';

class UserProvider extends ChangeNotifier {
  Future<void> updateUser(int id, Map<String, dynamic> data) async {
    // Use current values for level and xp if not provided
    final currentUser = await UserDatabase.getUser(id);
    final int level = currentUser?.level ?? 1;
    final int xp = currentUser?.xp ?? 0;
    await UserDatabase.updateUser(User(
      id: id,
      name: data['name'],
      level: level,
      xp: xp,
    ));
    // Reload user data after update
    final updatedUser = await UserDatabase.getUser(id);
    if (updatedUser != null) {
      _name = updatedUser.name;
    }
    notifyListeners();
  }

  Future<void> deleteUser(int id) async {
    await UserDatabase.deleteUser(id);
    await logout();
    notifyListeners();
  }
  int? _userId;
  String? _name;
  int? _age;
  String _preferredLanguage = 'en';
  String? _email;
  String? _avatar;
  String? _createdAt;
  List<Map<String, dynamic>>? _achievements;
  // Remove old database service, use UserDatabase static methods
  final SharedPreferences _prefs;

  Map<String, dynamic>? get user => _userId == null ? null : {
    'id': _userId,
    'name': _name,
    'age': _age,
    'preferredLanguage': _preferredLanguage,
    'email': _email,
    'avatar': _avatar,
    'createdAt': _createdAt,
    'achievements': _achievements,
  };

  UserProvider(this._prefs) {
    _loadUserData();
  }

  bool get isLoggedIn => _userId != null;
  int? get userId => _userId;
  String? get name => _name;
  int? get age => _age;
  String get preferredLanguage => _preferredLanguage;
  String? get email => _email;
  String? get avatar => _avatar;
  String? get createdAt => _createdAt;
  List<Map<String, dynamic>>? get achievements => _achievements;

  Future<void> _loadUserData() async {
    _userId = _prefs.getInt('userId');
    if (_userId != null) {
      final user = await UserDatabase.getUser(_userId!);
      if (user != null) {
        _name = user.name;
        _age = null; // Not in new model, set to null or add to User model if needed
        _email = null;
        _avatar = null;
        _createdAt = null;
        _achievements = null;
        _preferredLanguage = 'en'; // Not in new model, set to default or add to User model if needed
        notifyListeners();
      }
    }
  }

  Future<void> login(String name, int age, String language) async {
    User user = User(name: name, level: 1, xp: 0);
    int id = await UserDatabase.insertUser(user);
    _userId = id;
    _name = name;
    _age = age;
    _preferredLanguage = language;
    await _prefs.setInt('userId', _userId!);
    notifyListeners();
  }

  Future<void> updateProfile({String? name, int? level, int? xp}) async {
    if (_userId == null) return;
    User? user = await UserDatabase.getUser(_userId!);
    if (user != null) {
      User updatedUser = User(
        id: user.id,
        name: name ?? user.name,
        level: level ?? user.level,
        xp: xp ?? user.xp,
      );
      await UserDatabase.updateUser(updatedUser);
      _name = updatedUser.name;
      notifyListeners();
    }
  }

  Future<void> updateLanguage(String language) async {
    if (_userId != null) {
      await UserDatabase.updateUserLanguage(_userId!, language);
      _preferredLanguage = language;
      notifyListeners();
    }
  }

  Future<void> updatePreferredLanguage(String language) async {
    if (_userId != null) {
      await UserDatabase.updateUserLanguage(_userId!, language);
      _preferredLanguage = language;
      notifyListeners();
    }
  }

  Future<void> deleteAccount() async {
    if (_userId != null) {
      await UserDatabase.deleteUser(_userId!);
      await logout();
    }
  }

  Future<void> logout() async {
    await _prefs.remove('userId');
    _userId = null;
    _name = null;
    _age = null;
    _preferredLanguage = 'en';
    notifyListeners();
  }

  Future<List<Map<String, dynamic>>> getUserProgress() async {
    if (_userId == null) return [];
    return await UserDatabase.getUserProgress(_userId!);
  }

  Future<List<Map<String, dynamic>>> getQuizHistory() async {
    if (_userId == null) return [];
    return await UserDatabase.getQuizResults(_userId!);
  }

  Future<List<Map<String, dynamic>>> getModuleQuizResults(String moduleId) async {
    if (_userId == null) return [];
    return await UserDatabase.getModuleQuizResults(_userId!, moduleId);
  }

  Future<void> clearProgressForModule(String moduleId) async {
    if (_userId != null) {
      await UserDatabase.deleteProgress(_userId!, moduleId);
      notifyListeners();
    }
  }

  Future<void> clearAllProgress() async {
    if (_userId != null) {
      final progress = await getUserProgress();
      for (var item in progress) {
        await UserDatabase.deleteProgress(_userId!, item['moduleId']);
      }
      notifyListeners();
    }
  }

  Future<void> clearQuizHistory() async {
    if (_userId != null) {
      await UserDatabase.deleteUserQuizResults(_userId!);
      notifyListeners();
    }
  }
}
