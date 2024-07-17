import 'dart:async';

import 'package:dart_persistence_api/dart_store.dart';
import 'package:dart_persistence_api/database/database_connection.dart';
import 'package:dart_persistence_api/sql_anotations/constraints/primary_key.dart';
import 'package:dart_persistence_api/sql_anotations/data_types/integer.dart';
import 'package:dart_persistence_api/sql_anotations/data_types/varchar.dart';
import 'package:dart_persistence_api/sql_anotations/entity.dart';
import 'package:postgres/postgres.dart';

@Entity()
class UserEntity {
  @PrimaryKey(autoIncrement: true)
  @Integer()
  int? id;
  @Varchar()
  String? name;
  @Varchar()
  String? email;
  @Varchar()
  String? password;
}

void main(List<String> arguments) async {
  await DartStore.init(await PostgresConnection.init());
  print(await dartStore.execute('SELECT * FROM users'));
}

class PostgresConnection extends DatabaseConnection {
  PostgresConnection._internal(this.connection);
  Connection connection;
  static Future<PostgresConnection> init() async {
    Connection? connection;

    connection = await Connection.open(
        Endpoint(
            host: 'localhost',
            database: 'ebay_watcher',
            username: 'ebay_watcher',
            password: 'ebay_watcher'),
        settings: ConnectionSettings(
            onOpen: (connection) async =>
                print('Connected to the database $connection'),
            sslMode: SslMode.disable));

    if (connection == null) {
      throw Exception('Connection not initialized');
    }
    return PostgresConnection._internal(connection);
  }

  @override
  FutureOr<Result> execute(String statement) async {
    return await connection.execute(statement);
  }
}
