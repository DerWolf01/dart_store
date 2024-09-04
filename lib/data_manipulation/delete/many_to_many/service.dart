import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/delete/service.dart';
import 'package:dart_store/data_manipulation/delete/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class ManyToManyDeleteService with DartStoreUtility {
  Future<void> _deleteForeignColumnItem(EntityInstance item) async {
    await DeleteService().delete(item);
  }

  Future _deleteConnection(
      EntityInstance instance, EntityInstance instance2) async {
    TableConnectionInstance connectionInstance =
        TableConnectionInstanceService()
            .generateTableConnectionInstance(instance, instance2);

    DeleteStatement deleteStatement =
        DeleteStatement(entityInstance: connectionInstance);
    try {
      await executeSQL(deleteStatement.define());
    } on PgException catch (e, s) {
      print(e.message);
      print(e.severity);
      print(s);
    } catch (e, s) {
      print(e);
      print(s);
    }
  }

  Future<void> preDelete(EntityInstance entityInstance,
      {bool recursive = false}) async {
    if (entityInstance.primaryKeyColumn().value == -1 ||
        entityInstance.primaryKeyColumn().value == null) {
      throw Exception(
          "Entity of table ${entityInstance.tableName} has to be deleteed before deleteing foreign columns");
    }
    for (final foreignColumnInstance in entityInstance.manyToManyColumnsInstances()) {
      final List<dynamic> values = foreignColumnInstance.value;
      for (final itemEntityInstance in values) {
        await _deleteConnection(entityInstance, itemEntityInstance);
        if (recursive) {
          await _deleteForeignColumnItem(itemEntityInstance);
        }
      }
    }
  }
}
