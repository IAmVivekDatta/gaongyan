import 'database_interface.dart';

BaseDatabaseService createDatabaseService() {
  throw UnsupportedError(
      'No suitable database service implementation found for this platform.');
}
