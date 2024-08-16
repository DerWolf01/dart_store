import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/sql/mirrors/entity/entity_instance_mirror.dart';
import 'package:dart_store/sql/mirrors/entity/entity_mirror_with_id.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/legacy.dart';

class OneToOneConnectionInstance with DartStoreUtility {
  // The entity used to orient query later.
  final EntityMirrorWithId entity$1;

  // The entity to be queried.
  final EntityMirror entity$2;

  OneToOneConnectionInstance(this.entity$1, this.entity$2);

  String get connectionTableName => '${entity$1.name}_${entity$2.name}';

  List<EntityMirror> get ordered =>
      [entity$1, entity$2]..sort((a, b) => a.name.compareTo(b.name));

  List<EntityMirrorWithId> orderWithIds(List<EntityMirrorWithId> entities) {
    return entities..sort((a, b) => a.name.compareTo(b.name));
  }

  Future<int> insert({required EntityMirrorWithId otherEntityWithid}) async {
    final entities = orderWithIds([entity$1, otherEntityWithid]);
    final name1 = entities[0].name;
    final id1Name = "${name1}_id";
    final id1 = entities[0].runtimeType == entity$1.runtimeType
        ? entity$1.id
        : otherEntityWithid.id;
    final name2 = entities[1].name;
    final id2Name = "${name2}_id";
    final id2 = entities[1].runtimeType == entity$1.runtimeType
        ? entity$1.id
        : otherEntityWithid.id;
    try {
      // TODO evaluate if ON CONFLICT should be included
      final statement =
          "INSERT INTO $connectionTableName ($id1Name, $id2Name) VALUES ($id1, $id2)";
      print("OneToOneConnectionInstance.insert() --> $statement");
      await executeSQL(statement);
    } on PostgreSQLException catch (e, s) {
      print(e);
      print(s);
    } catch (e, s) {
      print(e);
      print(s);
    }
    return await lastInsertedId();
  }

  Future<int> lastInsertedId() async {
    try {
      final query = "SELECT currval('${connectionTableName}_id_seq');";
      final result = await executeSQL(query);
      return result.first.first as int;
    } catch (e) {
      final query = "SELECT NEXTVAL('${connectionTableName}_id_seq');";
      final result = await executeSQL(query);
      return result.first.first as int;
    }
  }

// Queries only the entity which wasn't queried before so that no id of it is present.
  Future<dynamic> query() async {
    final query =
        "SELECT * FROM $connectionTableName WHERE ${entity$1.name}_id = ${entity$1.id}";
    print("OneToOneConnectionInstance.query() --> $query");

    final connectionResult = await executeSQL(query);
    print(
        "OneToOneConnectionInstance.query<Map>() --> ${connectionResult.first.toColumnMap()}");

    if (connectionResult.isEmpty) {
      return null;
    }
    final object = await dartStore.query(
        type: entity$2.classMirror.reflectedType,
        where: WhereCollection(wheres: [
          Where(
              field: "id",
              comporator: WhereOperator.equals,
              compareTo:
                  connectionResult.first.toColumnMap()["${entity$2.name}_id"])
        ]));
    print("OneToOneConnectionInstance.query() --> $object");

    return object.first;
  }
}