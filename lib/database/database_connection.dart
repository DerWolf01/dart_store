import 'dart:async';
import 'package:postgres/postgres.dart';
export './database_connection.dart';

abstract class DatabaseConnection<ResultType> {
  /// Method to execute any statement

  Future<ResultType> execute(String statement);

  // Future<int> insert(String statement);

  // Future<int> update(String statement);

  // Future<List<Map<String, dynamic>>> query(String statement);

  // Future<void> delete(String statement);
}
