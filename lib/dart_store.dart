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
            "SELECT currval('${entityDecl(type: model.runtimeType).name}_id_seq');"))
        .first
        .first;
    return id as int;
  }

  Future<void> drop<T>() async {
    final _entityDecl = entityDecl<T>(type: T);
    final query = 'DROP TABLE IF EXISTS ${_entityDecl.name}';
    await execute(query);
  }

  Future<void> create<T>() async {
    final _entityDecl = entityDecl<T>(type: T);
    final query =
        'CREATE TABLE IF NOT EXISTS ${_entityDecl.name} ( ${_entityDecl.column.map((column) {
      final columnName = column.name;
      final dataType = column.dataType;
      final nullable = column.nullable ? 'NULL' : 'NOT NULL';
      final isPrimaryKey = column.isPrimaryKey ? 'PRIMARY KEY' : '';

      return '$columnName ${dataType.runtimeType.toString()} $nullable $isPrimaryKey';
    }).join(', ')})';
    await execute(query);
  }
}
