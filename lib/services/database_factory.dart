import 'database_interface.dart';
import 'database_service.dart' if (dart.library.html) 'database_service_web.dart';

class DatabaseFactory {
  static BaseDatabaseService? _instance;

  static void initialize() {
    _instance = null;
  }

  static BaseDatabaseService getDatabaseService() {
    _instance = createDatabaseService();
    return _instance!;
  }
}
