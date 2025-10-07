abstract class BaseDatabaseService {
  // User CRUD Operations
  Future<int> createUser(String name, int age, String preferredLanguage, {String? email, String? avatar});
  Future<Map<String, dynamic>?> getUser(int id);
  Future<List<Map<String, dynamic>>> getAllUsers();
  Future<void> updateUser(int id, Map<String, dynamic> data);
  Future<void> deleteUser(int id);
  Future<void> updateUserLanguage(int id, String language);

  // Achievement CRUD Operations
  Future<int> createAchievement(int userId, String title, String description, String type, {String? icon, bool unlocked = false});
  Future<List<Map<String, dynamic>>> getUserAchievements(int userId);
  Future<void> updateAchievement(int id, Map<String, dynamic> data);
  Future<void> deleteAchievement(int id);
  Future<void> unlockAchievement(int userId, int achievementId);

  // Module Progress CRUD Operations
  Future<int> createProgress(int userId, String moduleId, double progress);
  Future<void> updateProgress(int userId, String moduleId, double progress);
  Future<double> getProgress(int userId, String moduleId);
  Future<List<Map<String, dynamic>>> getUserProgress(int userId);
  Future<void> deleteProgress(int userId, String moduleId);

  // Quiz Results CRUD Operations
  Future<int> saveQuizResult(int userId, String moduleId, int score, int totalQuestions);
  Future<List<Map<String, dynamic>>> getQuizResults(int userId);
  Future<List<Map<String, dynamic>>> getModuleQuizResults(int userId, String moduleId);
  Future<void> deleteQuizResult(int id);
  Future<void> deleteUserQuizResults(int userId);

  // Module Management
  Future<List<Map<String, dynamic>>> getModules();
  Future<Map<String, dynamic>?> getModule(String moduleId);
  Future<void> updateModuleContent(String moduleId, Map<String, dynamic> content);
}
