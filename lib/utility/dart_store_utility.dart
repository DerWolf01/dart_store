import 'package:dart_store/dart_store.dart';
import 'package:dart_store/my_logger.dart';
import 'package:postgres/postgres.dart';

mixin class DartStoreUtility {
  Future<Result> executeSQL(String sql) async {
    myLogger.d("Executing SQL: $sql", header: "DartStoreUtility");
    return await dartStore.execute(sql);
  }

  Future<List<Map<String, dynamic>>> query(String statement) async =>
      await dartStore.connection.query(statement);
}
