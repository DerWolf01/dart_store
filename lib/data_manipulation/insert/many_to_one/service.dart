import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/conflict.dart';
import 'package:dart_store/data_manipulation/insert/service.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

class ManyToOneInsertService with DartStoreUtility {
  Future<EntityInstance> postInsert(EntityInstance manyToOneEntityInstance,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    for (final foreignColumnInstance
        in manyToOneEntityInstance.manyToOneColumnsInstances()) {
      final mapId = foreignColumnInstance.mapId;
      if (!mapId) {
        final EntityInstance insertedOneToManyEntityInstance =
            await InsertService().insert(foreignColumnInstance.value,
                conflictAlgorithm: conflictAlgorithm);

        manyToOneEntityInstance.setField(
            foreignColumnInstance.name, insertedOneToManyEntityInstance);

        await _createConnection(
            oneToManyEntityInstance: insertedOneToManyEntityInstance,
            manyToOneEntityInstance: manyToOneEntityInstance,
            conflictAlgorithm: conflictAlgorithm);
        continue;
      }
      await _createConnection(
          oneToManyEntityInstance: foreignColumnInstance.value,
          manyToOneEntityInstance: manyToOneEntityInstance,
          conflictAlgorithm: conflictAlgorithm);
    }

    return manyToOneEntityInstance;
  }

  Future _createConnection(
      {required EntityInstance oneToManyEntityInstance,
      required EntityInstance manyToOneEntityInstance,
      ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    TableConnectionInstance connectionInstance =
        TableConnectionInstanceService()
            .generateManyToOneAndOneToManyConnectionInstance(
                manyToOne: manyToOneEntityInstance,
                oneToMany: oneToManyEntityInstance);

    InsertStatement insertStatement = InsertStatement(
        entityInstance: connectionInstance,
        conflictAlgorithm: conflictAlgorithm);
    try {
      await executeSQL(insertStatement.define());
    } on PgException catch (e, s) {
      myLogger.i(e.message);
      myLogger.i(e.severity);
      myLogger.i(s);
    } catch (e, s) {
      myLogger.i(e);
      myLogger.i(s);
    }
  }
}
