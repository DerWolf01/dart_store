library dart_store;

import 'dart:async';
export 'package:dart_store/sql_anotations/sql_anotations.dart';
export 'package:dart_store/database/database_connection.dart';

import 'package:dart_store/database/database_connection.dart';
import 'package:dart_store/services/ddl_service.dart';
import 'package:dart_store/services/dml_service.dart';
import 'package:dart_store/sql_anotations/sql_anotations.dart';
import 'package:postgres/postgres.dart';

DartStore get dartStore => DartStore();

class DartStore implements DatabaseConnection {
  static DartStore? _instance;
  DatabaseConnection connection;
  DartStore._internal(this.connection);

  static Future<DartStore> init(DatabaseConnection connection) async {
    _instance ??= DartStore._internal(connection);
    await DDLService().createTables();
    return _instance!;
  }

  factory DartStore() {
    if (_instance == null) {
      throw Exception('DartStore not initialized');
    }

    return _instance!;
  }

  @override
  FutureOr<Result> execute(String statement) async =>
      connection.execute(statement);

  Future<int> save(dynamic model) async {
    var res = await DMLService().insert(model);

    var id = (await dartStore.execute(
            "SELECT currval('${entityDecl(type: model.runtimeType).name}');"))
        .first
        .first;
    return id as int;
  }

  Future<void> drop<T>() async {
    final _entityDecl = entityDecl<T>(type: T);
    final query = 'DROP TABLE IF EXISTS ${_entityDecl.name}';
    await execute(query);
  }
}
