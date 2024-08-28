import 'dart:async';
import 'dart:mirrors';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/mapping/map_id.dart';
import 'package:dart_store/sql/mirrors/column/column_mirror.dart';
import 'package:dart_store/sql/mirrors/dart_store_mirror.dart';
import 'package:dart_store/sql/mirrors/entity/entity_mirror.dart';
import 'package:dart_store/data_definition/data_types/created_at.dart';
import 'package:dart_store/data_definition/data_types/text_list.dart';
import 'package:postgres/postgres.dart';

@Entity()
class TextListTest {
  TextListTest();
  TextListTest.init({
    this.id,
    required this.textList,
    required this.title,
  });

  @PrimaryKey()
  @Serial()
  late final int? id;

  @Varchar()
  late final String title;

  @MapId()
  @OneToMany<ManyToOneTest>()
  late final List<int> textList;
}

@Entity()
class ManyToOneTest {
  ManyToOneTest();
  ManyToOneTest.init({
    required this.id,
    required this.textList,
  });

  @PrimaryKey()
  @Serial()
  late int id;

  @TextList()
  late final List<String> textList;
}

void main(List<String> arguments) async {
  await DartStore.init(await PostgresConnection.init());

  print(await dartStore
      .save(ManyToOneTest.init(id: 0, textList: ["a", "b", "c"])));
  print(await dartStore
      .save(ManyToOneTest.init(id: 1, textList: ["a", "b", "c"])));
  print(await dartStore.save(
    TextListTest.init(
      id: -1,
      title: "title",
      textList: [0, 1],
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
