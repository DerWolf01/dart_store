import 'dart:mirrors';

import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/entity.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/mapping/map_id.dart';
import 'package:dart_store/postgres_connection/connection.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

// TODO: search for after-query-implementation and implement missing functionality
// TODO implement "OR" chaining for wheres.
// TODO: IMplement delete logic for connections
// * Implement MapId logic
// TODO implement sqlTableName logixc to avoid toCamelCase call when instanciating models
// TODO: Finish ManyToMany logic implementation
// TODO Implement QueryPsuedoColumn.byPrimaryKeyColumn
@Entity()
class TextListTest {
  TextListTest();
  TextListTest.init(
      {required this.id, required this.title, required this.manyToOneTest});

  @PrimaryKey(autoIncrement: true)
  @Serial()
  late final int id;

  @Varchar()
  late final String title;

  @MapId()
  @ManyToOne<ManyToOneTest>()
  late final int manyToOneTest;
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
  await dartStore.save(ManyToOneTest.init(id: 0, textList: ['a', 'b']));
  // await dartStore.save(ManyToOneTest.init(id: -1, textList: ['a', 'b']));

  final model = await dartStore
      .save(TextListTest.init(id: 0, manyToOneTest: 0, title: 'tte'));

  // await dartStore.delete(model);

  print((await dartStore.query<TextListTest>()).firstOrNull?.manyToOneTest);
}
