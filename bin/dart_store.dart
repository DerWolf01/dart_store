import 'dart:async';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/sql_anotations/data_types/created_at.dart';
import 'package:dart_store/sql/sql_anotations/data_types/text_list.dart';
import 'package:postgres/postgres.dart';

@Entity()
class TextListTest {
  TextListTest();
  TextListTest.init({
    this.id,
    required this.textlist,
  });

  @PrimaryKey()
  @Serial()
  late final int? id;

  @TextList()
  late final List<String> textlist;
}

void main(List<String> arguments) async {
  await DartStore.init(await PostgresConnection.init());

  print(await dartStore.save(
    TextListTest.init(
      id: -1,
      textlist: ['a', 'b', 'c'],
    ),
  ));
  print(dartStore.query(type: TextListTest));
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
