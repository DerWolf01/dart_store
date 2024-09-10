import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/update/service.dart';
import 'package:dart_store/data_manipulation/update/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

class OneToOneUpdateService with DartStoreUtility {
  Future<EntityInstance> _updateForeignColumnItem(EntityInstance item) async =>
      await UpdateService().update(item);

  Future _updateConnection(
      EntityInstance updatedEntityInstance, EntityInstance instance2) async {
    TableConnectionInstance connectionInstance =
        TableConnectionInstanceService()
            .generateTableConnectionInstance(updatedEntityInstance, instance2);
    final connectionName = connectionInstance.tableName;
    final pKey1 = updatedEntityInstance.primaryKeyColumn();
    final pKey2 = instance2.primaryKeyColumn();

    print(
        "updating connection with values ${updatedEntityInstance.tableName}:${pKey1.value} and ${instance2.tableName}${pKey2.value}");

    final statement =
        "INSERT INTO $connectionName (${updatedEntityInstance.tableName}, ${instance2.tableName}) VALUES (${pKey1.dataType.convert(pKey1.value)}, ${pKey2.dataType.convert(pKey2.value)}) ON CONFLICT(${instance2.tableName}) DO UPDATE SET ${instance2.tableName} = EXCLUDED.${instance2.tableName} WHERE $connectionName.${instance2.tableName} = ${pKey2.dataType.convert(pKey2.value)}";
    print(statement);
    try {
      await executeSQL(statement);
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
      final EntityInstance value = foreignColumnInstance.value;
      late final EntityInstance newValue;
      if (foreignColumnInstance.mapId) {
        await _updateConnection(entityInstance, value);
        continue;
      }

      final updatedItemEntityInstance = await _updateForeignColumnItem(value);
      newValue = updatedItemEntityInstance;
      await _updateConnection(entityInstance, updatedItemEntityInstance);

      entityInstance.setField(foreignColumnInstance.name, newValue);
    }

    return entityInstance;
  }
}
