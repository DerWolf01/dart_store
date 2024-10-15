import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/delete/service.dart';
import 'package:dart_store/data_manipulation/delete/statement.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class OneToOneDeleteService with DartStoreUtility {
  Future<void> preDelete(EntityInstance entityInstance,
      {bool recursive = true}) async {
    for (final foreignColumnInstance
        in entityInstance.oneToOneColumnsInstances()) {
      final EntityInstance value = foreignColumnInstance.value;

      await _deleteConnection(entityInstance, value);
      if (recursive && !foreignColumnInstance.mapId) {
        await _deleteForeignColumnItem(value);
      }
    }
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
      myLogger.i(e.message);
      myLogger.i(e.severity);
      myLogger.i(s);
    } catch (e, s) {
      myLogger.e(e, stackTrace: s);
    }
  }

  Future<void> _deleteForeignColumnItem(EntityInstance item) async {
    await DeleteService().delete(item);
  }
}
