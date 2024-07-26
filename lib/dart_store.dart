library dart_store;

export 'package:dart_store/sql/declarations/declarations.dart';
export 'package:dart_store/sql/clauses/clauses.dart';
export 'package:dart_store/sql/sql_anotations/sql_anotations.dart';
export 'package:dart_store/database/database_connection.dart';

import 'dart:async';
import 'package:dart_store/database/database_connection.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/services/ddl_service.dart';
import 'package:dart_store/services/dml_service.dart';
import 'package:dart_store/services/dql_service.dart';
import 'package:dart_store/sql/clauses/where.dart';
import 'package:dart_store/sql/declarations/declarations.dart';
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

  Future<List<T>> query<T>({WhereCollection? where}) async {
    return DqlService().query<T>(where: where);
  }

  Future<int> save(dynamic model) async {
    var id = await DMLService().insert(model);
    return id;
  }

  Future<int> update(dynamic model) async {
    return await DMLService().update(model);
  }

  Future<void> delete(dynamic model) async {
    final _entityDecl = entityDecl(type: model.runtimeType);
    await DMLService().delete(_entityDecl.name,
        where: WhereCollection(
            wheres: ConversionService.objectToMap(model).entries.map(
          (e) {
            final column = _entityDecl.column
                .firstWhere((element) => element.name == e.key);
            return Where(
                field: e.key,
                compareTo: e.value,
                comporator: WhereOperator.equals);
          },
        ).toList()));
  }

  Future<void> drop<T>() async {
    final _entityDecl = entityDecl<T>(type: T);
    final query = 'DROP TABLE IF EXISTS ${_entityDecl.name}';
    await execute(query);
  }

  Future<void> create<T>() async {
    return await DDLService().createTable(entityDecl<T>());
  }
}
