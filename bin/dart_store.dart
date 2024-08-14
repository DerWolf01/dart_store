import 'dart:async';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/sql_anotations/data_types/created_at.dart';
import 'package:postgres/postgres.dart';

@Entity()
class CreatedAtTest {
  CreatedAtTest.init(this.id, this.createdat);
  CreatedAtTest();

  @PrimaryKey()
  @Serial()
  late final int id;

  @CreatedAt()
  late final DateTime createdat;
}

void main(List<String> arguments) async {
  await DartStore.init(await PostgresConnection.init());
  print((await dartStore.query<CreatedAtTest>()).first.createdat);
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

    return PostgresConnection._internal(connection);
  }

  @override
  FutureOr<Result> execute(String statement) async {
    return await connection.execute(statement);
  }
}
