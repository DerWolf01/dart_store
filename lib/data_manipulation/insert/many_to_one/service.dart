import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/service.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

class ManyToOneInsertService with DartStoreUtility {
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

  Future<EntityInstance> postInsert(
      EntityInstance manyToOneEntityInstance) async {
    for (final foreignColumnInstance
        in manyToOneEntityInstance.manyToOneColumnsInstances()) {
      final mapId = foreignColumnInstance.mapId;
      if (!mapId) {
        final EntityInstance insertedOneToManyEntityInstance =
            await InsertService().insert(foreignColumnInstance.value);

        manyToOneEntityInstance.setField(
            foreignColumnInstance.name, insertedOneToManyEntityInstance);

        await _createConnection(
            oneToManyEntityInstance: insertedOneToManyEntityInstance,
            manyToOneEntityInstance: manyToOneEntityInstance);
        continue;
      }
      await _createConnection(
          oneToManyEntityInstance: foreignColumnInstance.value,
          manyToOneEntityInstance: manyToOneEntityInstance);
    }

    return manyToOneEntityInstance;
  }
}
