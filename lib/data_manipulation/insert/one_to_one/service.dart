import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/service.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class OneToOneInsertService with DartStoreUtility {
  Future<EntityInstance> postInsert(EntityInstance entityInstance) async {
    if (entityInstance.primaryKeyColumn().value == -1 ||
        entityInstance.primaryKeyColumn().value == null) {
      throw Exception(
          "Entity of table ${entityInstance.tableName} has to be inserted before inserting foreign columns");
    }

    for (final foreignColumnInstance
        in entityInstance.oneToOneColumnsInstances()) {
      final mapId = foreignColumnInstance.mapId;

      final EntityInstance value = foreignColumnInstance.value;
      if (mapId) {
        await _createConnection(entityInstance, value);

        continue;
      }
      late final EntityInstance newValue;

      final insertedItemEntityInstance = await _insertForeignColumnItem(value);
      newValue = insertedItemEntityInstance;
      await _createConnection(entityInstance, insertedItemEntityInstance);

      entityInstance.setField(foreignColumnInstance.name, newValue);

      continue;
    }

    return entityInstance;
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
      myLogger.i(e.message);
      myLogger.i(e.severity);
      myLogger.i(s);
    } catch (e, s) {
      myLogger.e(e);
      myLogger.e(s);
    }
  }

  Future<EntityInstance> _insertForeignColumnItem(
          EntityInstance itemEntityInstance) async =>
      await InsertService().insert(itemEntityInstance);
}
