import 'dart:async';
import 'package:dart_store/dart_store.dart';
import 'package:postgres/postgres.dart';

@Entity()
class Role {
  Role.init(this.id, this.name);
  Role();
  @PrimaryKey()
  @Integer()
  late final int id;
  @Varchar()
  late final String name;
}

@Entity()
class UserEntity {
  UserEntity.init(this.id, this.name, this.email, this.password, this.role);
  UserEntity();
  @PrimaryKey(autoIncrement: true)
  @Serial()
  late final int id;
  @Varchar()
  late final String name;

  @Varchar()
  @Unique()
  late final String email;

  @Varchar()
  @Unique()
  late final String password;

  @ManyToOne<Role>()
  late final Role role;
}

void main(List<String> arguments) async {
  await DartStore.init(await PostgresConnection.init());
  print(await dartStore.save(Role.init(0, "admin")));
  print(await dartStore.save(UserEntity.init(
      -1, "test@email.com", "test", "test", Role.init(0, "admin"))));

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
