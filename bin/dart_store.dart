import 'dart:async';
import 'package:dart_store/dart_store.dart';
import 'package:postgres/postgres.dart';

@Entity()
class Role {
  const Role(this.id, this.name);

  @PrimaryKey()
  @Integer()
  final int id;
  @Varchar()
  final String name;
}

@Entity()
class UserEntity {
  const UserEntity(this.id, this.name, this.email, this.password, this.role);

  @PrimaryKey(autoIncrement: true)
  @Serial()
  final int id;
  @Varchar()
  final String name;

  @Varchar()
  final String email;
  @Varchar()
  final String password;

  @ManyToOne<Role>()
  final Role role;
}

void main(List<String> arguments) async {
  await DartStore.init(await PostgresConnection.init());
  print(await dartStore.save(Role(0, "admin")));
  print(await dartStore.save(
      UserEntity(-1, "test@email.com", "test", "test", Role(0, "admin"))));

  print(await dartStore.query<UserEntity>(
      where: WhereCollection(wheres: [
    Where(
        field: "name",
        compareTo: "test@email.com",
        comporator: WhereOperator.equals)
  ])));
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
