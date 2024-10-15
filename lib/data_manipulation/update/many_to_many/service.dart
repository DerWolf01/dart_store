import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/update/service.dart';
import 'package:dart_store/data_manipulation/update/statement.dart';
import 'package:dart_store/data_manipulation/where_utils.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class ManyToManyUpdateService with DartStoreUtility {
  Future<EntityInstance> postUpdate(EntityInstance entityInstance,
      {List<Where> where = const []}) async {
    final primaryKeyColumn = entityInstance.primaryKeyColumn();
    if (primaryKeyColumn.value == -1 || primaryKeyColumn.value == null) {
      throw Exception(
          "Entity of table ${entityInstance.tableName} has to be updateed before updateing foreign columns");
    }

    for (final foreignColumnInstance
        in entityInstance.manyToManyColumnsInstances()) {
      final List<EntityInstance> values = foreignColumnInstance.value;
      final List newValues = foreignColumnInstance.mapId ? values : [];
      for (final item in values) {
        if (!foreignColumnInstance.mapId) {
          // TODO: after-query-implementation
          // TODO query connection and update connection ids without updating id of connection entity itsself
          final updatedItemEntityInstance = await _updateForeignColumnItem(
              item, foreignColumnInstance.name,
              where: where);
          newValues.add(updatedItemEntityInstance);
          await _updateConnection(entityInstance, updatedItemEntityInstance);
          continue;
        }
        await _updateConnection(entityInstance, item);
      }
      entityInstance.setField(foreignColumnInstance.sqlName, newValues);
    }

    return entityInstance;
  }

  Future _updateConnection(
      EntityInstance instance, EntityInstance instance2) async {
    TableConnectionInstance connectionInstance =
        TableConnectionInstanceService()
            .generateTableConnectionInstance(instance, instance2);

    UpdateStatement updateStatement =
        UpdateStatement(entityInstance: connectionInstance);
    try {
      await executeSQL(updateStatement.define());
    } on PgException catch (e, s) {
      myLogger.i(e.message);
      myLogger.i(e.severity);
      myLogger.i(s);
    } catch (e, s) {
      myLogger.e(e, stackTrace: s);
    }
  }

  Future<EntityInstance> _updateForeignColumnItem(
      EntityInstance itemEntityInstance, String columnName,
      {List<Where> where = const []}) async {
    final itemPrimaryKeyColumnInstance = itemEntityInstance.primaryKeyColumn();
    return await UpdateService().update(itemEntityInstance,
        where: automaticallyFilterWhere(
            where: where,
            id: itemPrimaryKeyColumnInstance.value,
            primaryKeyColumn: itemPrimaryKeyColumnInstance,
            columnName: columnName,
            externalColumnType: itemEntityInstance.objectType));
  }
}
