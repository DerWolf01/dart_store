import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/entity.dart';
import 'package:dart_store/postgres_connection/connection.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

// TODO: search for after-query-implementation and implement missing functionality
// TODO implement or chaining for wheres.
// TODO: IMplement delete logic for connections
// Implement MapId logic
@Entity()
class TextListTest {
  TextListTest();
  TextListTest.init({
    this.id,
    @ListOf(type: ManyToOneTest) required this.textList,
    required this.title,
  });

  @PrimaryKey(autoIncrement: true)
  @Serial()
  late final int? id;

  @Varchar()
  late final String title;

  // @MapId()
  @ListOf(type: ManyToOneTest)
  @OneToMany<ManyToOneTest>()
  late final List<dynamic> textList;
}

@Entity()
class ManyToOneTest {
  ManyToOneTest();
  ManyToOneTest.init({
    required this.id,
    @ListOf(type: String) required this.textList,
  });

  @PrimaryKey(autoIncrement: true)
  @Serial()
  late int id;

  @ListOf(type: String)
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
      textList: [
        ManyToOneTest.init(id: 0, textList: ["a", "b", "c"]),
        ManyToOneTest.init(id: 0, textList: ["a", "b", "c"])
      ],
    ),
  ));
  print((await dartStore.query(type: TextListTest, where: [
    Where(
        comparisonOperator: ComparisonOperator.equals,
        internalColumn: InternalColumn(
            dataType: Serial(),
            constraints: [PrimaryKey(autoIncrement: true)],
            name: "id"),
        value: 1)
  ]))
      .first
      .id);
}
