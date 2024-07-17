import 'dart:async';

import 'package:postgres/postgres.dart';

abstract class DatabaseConnection {
  /// Method to execute any statement
  FutureOr<Result> execute(String statement);
}
