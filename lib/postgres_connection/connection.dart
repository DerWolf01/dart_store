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

  // @override
  // Future<int> update(String statement) {
  //   // TODO: implement update
  //   throw UnimplementedError();
  // }
}
