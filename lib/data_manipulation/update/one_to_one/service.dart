import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/update/service.dart';
import 'package:dart_store/data_manipulation/update/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

class OneToOneUpdateService with DartStoreUtility {
  Future<EntityInstance> _updateForeignColumnItem(dynamic item) async {
    final EntityInstance itemEntityInstance =
        EntityInstanceService().entityInstanceByValueInstance(item);
    return await UpdateService().update(itemEntityInstance);
  }

  Future _createConnection(
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

  Future<EntityInstance> postUpdate(EntityInstance entityInstance) async {
    if (entityInstance.primaryKeyColumn().value == -1 ||
        entityInstance.primaryKeyColumn().value == null) {
      throw Exception(
          "Entity of table ${entityInstance.tableName} has to be updateed before updateing foreign columns");
    }

    for (final foreignColumnInstance
        in entityInstance.oneToOneColumnsInstances()) {
      final dynamic value = foreignColumnInstance.value;
      late final EntityInstance newValue;

      final updatedItemEntityInstance = await _updateForeignColumnItem(value);
      newValue = updatedItemEntityInstance;
      await _createConnection(entityInstance, updatedItemEntityInstance);

      entityInstance.setField(foreignColumnInstance.sqlName, newValue);
    }

    return entityInstance;
  }
}
