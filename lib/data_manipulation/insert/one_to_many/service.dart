import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/service.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

class OneToManyInsertService with DartStoreUtility {
  Future<EntityInstance> postInsert(EntityInstance entityInstance) async {
    for (final foreignColumnInstance
        in entityInstance.oneToManyColumnsInstances()) {
      final List<EntityInstance> values = foreignColumnInstance.value;
      final List<EntityInstance> newValues =
          foreignColumnInstance.mapId ? values : [];
      for (final oneOfManyItems in values) {
        if (!foreignColumnInstance.mapId) {
          newValues.add(await InsertService().insert(oneOfManyItems));
        }
        await _createConnection(
            oneToManyEntityInstance: entityInstance,
            manyToOneEntityInstance: oneOfManyItems);
      }

      entityInstance.setField(foreignColumnInstance.name, newValues);
    }

    return entityInstance;
  }

  Future _createConnection(
      {required EntityInstance oneToManyEntityInstance,
      required EntityInstance manyToOneEntityInstance}) async {
    TableConnectionInstance connectionInstance =
        TableConnectionInstanceService()
            .generateManyToOneAndOneToManyConnectionInstance(
                oneToMany: oneToManyEntityInstance,
                manyToOne: manyToOneEntityInstance);

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
}
