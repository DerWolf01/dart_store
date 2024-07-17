import 'dart:async';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql_anotations/entity.dart';
import 'package:postgres/postgres.dart';

@Entity()
class UserEntity {
  const UserEntity(
      {this.id = 0, this.name = '', this.email = '', this.password = ''});
  @PrimaryKey(autoIncrement: true)
  @Serial()
  final int id;
  @Varchar()
  final String name;
  @Varchar()
  final String email;
  @Varchar()
  final String password;
}

void main(List<String> arguments) async {
  await DartStore.init(await PostgresConnection.init());

  print(await dartStore.save(
      UserEntity(email: "test@email.com", name: "test", password: "test")));
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
