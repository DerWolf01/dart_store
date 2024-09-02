import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/service.dart';
import 'package:dart_store/data_manipulation/delete/service.dart';
import 'package:dart_store/data_manipulation/delete/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class OneToOneDeleteService with DartStoreUtility {
  Future<void> _deleteForeignColumnItem(dynamic item) async {
    final EntityInstance itemEntityInstance =
        EntityInstanceService().entityInstanceByValueInstance(item);
    await DeleteService().deleteUsingEntityInstance(itemEntityInstance);
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
      {bool recursive = true}) async {
    for (final foreignColumnInstance in entityInstance.oneToOneColumns()) {
      final dynamic value = foreignColumnInstance.value;

      final itemEntityInstance =
          EntityInstanceService().entityInstanceByValueInstance(value);
      await _deleteConnection(entityInstance, itemEntityInstance);
      if (recursive) {
        await _deleteForeignColumnItem(value);
      }
    }
  }
}
