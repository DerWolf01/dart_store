import 'package:dart_persistence_api/dart_store.dart';
import 'package:postgres/postgres.dart';

mixin class DartStoreUtility {
  Future<Result> executeSQL(String sql) async {
    return await dartStore.execute(sql);
  }
}
