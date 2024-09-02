import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/update/service.dart';
import 'package:dart_store/data_manipulation/update/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/service.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class ManyToManyUpdateService with DartStoreUtility {
  Future<EntityInstance> _updateForeignColumnItem(
    dynamic item,
    String columnName,
  ) async {
    final EntityInstance itemEntityInstance =
        EntityInstanceService().entityInstanceByValueInstance(item);
    return await UpdateService().update(
      itemEntityInstance,
    );
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
      print(e.message);
      print(e.severity);
      print(s);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  Future<EntityInstance> postUpdate(
    EntityInstance entityInstance,
  ) async {
    if (entityInstance.primaryKeyColumn().value == -1 ||
        entityInstance.primaryKeyColumn().value == null) {
      throw Exception(
          "Entity of table ${entityInstance.tableName} has to be updateed before updateing foreign columns");
    }

    for (final foreignColumnInstance in entityInstance.manyToManyColumns()) {
      final List<dynamic> values = foreignColumnInstance.value;
      final List newValues = [];
      for (final item in values) {
        // TODO: after-query-implementation
        // TODO query connection and update connection ids without updating id of connection entity itsself
        final updatedItemEntityInstance = await _updateForeignColumnItem(
          item,
          foreignColumnInstance.originalName,
        );
        newValues.add(updatedItemEntityInstance);
        await _updateConnection(entityInstance, updatedItemEntityInstance);
      }
      entityInstance.setField(foreignColumnInstance.name, newValues);
    }

    return entityInstance;
  }
}
