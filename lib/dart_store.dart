library dart_store;

export 'package:dart_store/sql/mirrors/mirrors.dart';
export 'package:dart_store/sql/clauses/clauses.dart';
export 'package:dart_store/sql/sql_anotations/sql_anotations.dart';
export 'package:dart_store/database/database_connection.dart';

import 'dart:async';
import 'dart:mirrors';
import 'package:dart_store/database/database_connection.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/services/ddl_service.dart';
import 'package:dart_store/services/dml_service.dart';
import 'package:dart_store/services/dql_service.dart';
import 'package:dart_store/sql/clauses/where.dart';
import 'package:dart_store/sql/mirrors/mirrors.dart';
import 'package:postgres/postgres.dart' as pg;


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
  FutureOr<pg.Result> execute(String statement) async =>
      connection.execute(statement);

  Future<List<T>> query<T>({WhereCollection? where, Type? type}) async {
    return DqlService().query<T>(where: where, type: type);
  }

  Future<int> save(dynamic model) async {
    var id = await DMLService().insert(model);
    return id;
  }

  Future<int> update(dynamic model) async {
    return await DMLService().update(model);
  }

  Future<void> delete(dynamic model) async {
    final _entityMirror = EntityMirror.byType(type: model.runtimeType);
    await DMLService().delete(_entityMirror.name,
        where: WhereCollection(
            wheres: ConversionService.objectToMap(model).entries.map(
          (e) {
            final column = _entityMirror.column
                .firstWhere((element) => element.name == e.key);
            return Where(
                field: e.key,
                compareTo: e.value,
                comporator: WhereOperator.equals);
          },
        ).toList()));
  }

  Future<void> drop<T>() async {
    final entityMirror = EntityMirror<T>.byType(type: T);
    final query = 'DROP TABLE IF EXISTS ${entityMirror.name}';
    await execute(query);
  }

  Future<void> create<T>() async {
    return await DDLService().createTable(EntityMirror<T>.byType());
  }
}

extension StringFormatter on String {
  String camelCaseToSnakeCase() {
    return replaceAllMapped(RegExp(r'[A-Z]'), (match) {
      return '_${match.group(0)!.toLowerCase()}';
    });
  }

  String snakeCaseToCamelCase() {
    return replaceAllMapped(RegExp(r'_[a-z]'), (match) {
      return match.group(0)!.toUpperCase().substring(1);
    });
  }
}

extension SymbolFormatter on Symbol {
  String name() => MirrorSystem.getName(this);
}
