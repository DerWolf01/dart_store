import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/insert/service.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class ManyToManyInsertService with DartStoreUtility {
  Future<EntityInstance> _insertForeignColumnItem(dynamic item) async {
    final EntityInstance itemEntityInstance =
        EntityInstanceService().entityInstanceByValueInstance(item);
    return await InsertService().insert(itemEntityInstance);
  }

  Future _createConnection(
      EntityInstance instance, EntityInstance instance2) async {
    TableConnectionInstance connectionInstance =
        TableConnectionInstanceService()
            .generateTableConnectionInstance(instance, instance2);

    InsertStatement insertStatement =
        InsertStatement(entityInstance: connectionInstance);
    try {
      await executeSQL(insertStatement.define());
    } on PgException catch (e, s) {
      print(e.message);
      print(e.severity);
      print(s);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  Future<EntityInstance> postInsert(EntityInstance entityInstance) async {
    if (entityInstance.primaryKeyColumn().value == -1 ||
        entityInstance.primaryKeyColumn().value == null) {
      throw Exception(
          "Entity of table ${entityInstance.tableName} has to be inserted before inserting foreign columns");
    }

    for (final foreignColumnInstance
        in entityInstance.manyToManyColumnsInstances()) {
      final List<dynamic> values = foreignColumnInstance.value;
      final List newValues = [];
      for (final item in values) {
        final insertedItemEntityInstance = await _insertForeignColumnItem(item);
        newValues.add(insertedItemEntityInstance);
        await _createConnection(entityInstance, insertedItemEntityInstance);
      }
      entityInstance.setField(foreignColumnInstance.sqlName, newValues);
    }

    return entityInstance;
  }
}
