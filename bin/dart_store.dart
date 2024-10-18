import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/mapping/map_id.dart';
import 'package:postgres/postgres.dart';

void main(List<String> arguments) async {
  await DartStore.init(
    await PostgresConnection.init(
        endpoint: Endpoint(
            host: 'localhost',
            database: 'ebay_watcher',
            username: 'ebay_watcher',
            password: 'ebay_watcher'),
        settings: ConnectionSettings(
            onOpen: (connection) async =>
                print('Connected to the database $connection'),
            sslMode: SslMode.disable)),
  );
}

// TODO: search for after-query-implementation and implement missing functionality
// TODO implement "OR" chaining for wheres.
// TODO: IMplement delete logic for connections
// * Implement MapId logic
// TODO implement sqlTableName logixc to avoid toCamelCase call when instanciating models
// TODO: Finish ManyToMany logic implementation
// TODO Implement QueryPsuedoColumn.byPrimaryKeyColumn
@Entity()
class Test1 {
  @PrimaryKey(autoIncrement: true)
  @Serial()
  late final int id;

  @MapId()
  @OneToMany<Test2>()
  late final List<int> test2;

  Test1();

  Test1.init({required this.id, required this.test2});
}

@Entity()
class Test2 {
  @PrimaryKey(autoIncrement: true)
  @Serial()
  late int id;

  @ManyToOne<Test1>()
  late Test1 textList;

  Test2();

  Test2.init({
    required this.id,
    @ListOf(type: Test1) required this.textList,
  });
}
