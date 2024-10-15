import 'dart:async';
export './database_connection.dart';

abstract class DatabaseConnection<ResultType> {
  /// Method to execute any statement

  Future<ResultType> execute(String statement);

  // Future<int> insert(String statement);

  // Future<int> update(String statement);

  Future<List<Map<String, dynamic>>> query(String statement);

  Future<int?> insert(String statement, String tableName,);
  // Future<void> delete(String statement);
}
