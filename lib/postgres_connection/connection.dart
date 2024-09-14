import 'dart:async';

import 'package:dart_store/dart_store.dart';
import 'package:postgres/postgres.dart';

class PostgresConnection extends DatabaseConnection<Result> {
  PostgresConnection._internal(this.connection);

  Connection connection;

  static Future<PostgresConnection> init(
      {required Endpoint endpoint, ConnectionSettings? settings}) async {
    Connection? connection;

    connection = await Connection.open(endpoint, settings: settings);

    return PostgresConnection._internal(connection);
  }

  @override
  Future<Result> execute(String statement) async {
    return await connection.execute(statement);
  }

  // @override
  // Future<void> delete(String statement) {
  //   // TODO: implement delete
  //   throw UnimplementedError();
  // }

  // @override
  // Future<int> insert(String statement) {
  //   // TODO: implement insert
  //   throw UnimplementedError();
  // }

  @override
  Future<List<Map<String, dynamic>>> query(String statement) async =>
      (await execute(statement)).map((e) => e.toColumnMap()).toList();

  @override
  Future<int> insert(String statement, String tableName) async {
    return (await execute(statement)).first.first as int;
  }

  Future<int> lastInsertedId(String tableName) async {
    try {
      final query = "SELECT currval('${tableName}_id_seq');";
      final result = await execute(query);
      return result.first.first as int;
    } catch (e) {
      final query = "SELECT NEXTVAL('${tableName}_id_seq');";
      final result = await execute(query);
      return result.first.first as int;
    }
  }
  // @override
  // Future<int> update(String statement) {
  //   // TODO: implement update
  //   throw UnimplementedError();
  // }
}
