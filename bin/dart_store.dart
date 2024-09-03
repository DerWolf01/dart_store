import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/entity.dart';
import 'package:dart_store/mapping/map_id.dart';
import 'package:dart_store/postgres_connection/connection.dart';
import 'package:postgres/postgres.dart';

// TODO: search for after-query-implementation and implement missing functionality
// TODO implement or chaining for wheres.
// TODO: IMplement delete logic for connections
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
  await DartStore.init(await PostgresConnection.init(
      endpoint: Endpoint(
          host: 'localhost',
          database: 'ebay_watcher',
          username: 'ebay_watcher',
          password: 'ebay_watcher'),
      settings: ConnectionSettings(
          onOpen: (connection) async =>
              print('Connected to the database $connection'),
          sslMode: SslMode.disable)));

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
