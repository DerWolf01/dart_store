import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/conflict.dart';
import 'package:dart_store/data_manipulation/insert/service.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

class OneToManyInsertService with DartStoreUtility {
  Future<EntityInstance> postInsert(EntityInstance entityInstance,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    for (final foreignColumnInstance
        in entityInstance.oneToManyColumnsInstances()) {
      final List<EntityInstance> values = foreignColumnInstance.value;
      final List<EntityInstance> newValues =
          foreignColumnInstance.mapId ? values : [];
      for (final oneOfManyItems in values) {
        if (!foreignColumnInstance.mapId) {
          newValues.add(await InsertService()
              .insert(oneOfManyItems, conflictAlgorithm: conflictAlgorithm));
        }
        await _insertConnection(
            oneToManyEntityInstance: entityInstance,
            manyToOneEntityInstance: oneOfManyItems,
            conflictAlgorithm: conflictAlgorithm);
      }

      entityInstance.setField(foreignColumnInstance.name, newValues);
    }

    return entityInstance;
  }

  Future _insertConnection(
      {required EntityInstance oneToManyEntityInstance,
      required EntityInstance manyToOneEntityInstance,
      ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    TableConnectionInstance connectionInstance =
        TableConnectionInstanceService()
            .generateManyToOneAndOneToManyConnectionInstance(
                oneToMany: oneToManyEntityInstance,
                manyToOne: manyToOneEntityInstance);

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
