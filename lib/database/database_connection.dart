import 'dart:async';

abstract class DatabaseConnection {
  /// Method to create tables
  FutureOr<void> create(String statement);

  /// Method to insert data
  /// Returns the id of the inserted row
  FutureOr<int> insert(String statement);

  /// Method to update data
  /// Returns the number of updated row
  FutureOr<int> update(String statement);

  /// Method to delete data
  FutureOr<void> delete(String statement);

  /// any other method to execute a statement
  FutureOr<void> execute(String statement);
}
