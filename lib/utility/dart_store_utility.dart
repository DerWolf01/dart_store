import 'package:dart_store/dart_store.dart';
import 'package:postgres/postgres.dart';

mixin class DartStoreUtility {
  Future<Result> executeSQL(String sql) async {
    return await dartStore.execute(sql);
  }

  Future<List<Map<String, dynamic>>> query(String statement) async =>
      await dartStore.connection.query(statement);
}
