import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/conflict.dart';
import 'package:dart_store/data_manipulation/insert/many_to_many/service.dart';
import 'package:dart_store/data_manipulation/insert/many_to_one/service.dart';
import 'package:dart_store/data_manipulation/insert/one_to_many/service.dart';
import 'package:dart_store/data_manipulation/insert/one_to_one/service.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class InsertService with DartStoreUtility {
  ///
  Future<EntityInstance> insert(EntityInstance entityInstance,
      {ConflictAlgorithm conflictAlgorithm = ConflictAlgorithm.replace}) async {
    late final EntityInstance insertedEntityInstance;
    try {
      final InsertStatement insertStatement = InsertStatement(
          entityInstance: entityInstance, conflictAlgorithm: conflictAlgorithm);
      final primaryKeyColumn = entityInstance.primaryKeyColumn();
      final int? insertResult = await dartStore.connection.insert(
        insertStatement.define(),
        entityInstance.tableName,
      );

      final id =
          (primaryKeyColumn.value != -1 && primaryKeyColumn.value != null)
              ? primaryKeyColumn.value
              : insertResult;
      final isOfPrimaryKeyType =
          entityInstance.primaryKeyColumn().dataType.compareToValue(id);
      if (!isOfPrimaryKeyType) {
        throw Exception(
            "Couldn't parse resulting id to type ${entityInstance.primaryKeyColumn().dataType.primitiveType} after inserting data into table ${entityInstance.tableName};  ");
      }
      entityInstance.setField("id", id);
      myLogger.i(
          "Inserted ${entityInstance.objectType} with id: ${entityInstance.primaryKeyColumn().value}",
          header: "InsertService");
      await ManyToManyInsertService().postInsert(entityInstance);
      await OneToOneInsertService().postInsert(entityInstance);
      await OneToManyInsertService().postInsert(entityInstance);
      await ManyToOneInsertService().postInsert(entityInstance);
      myLogger.i(
          "Inserted foreign fields of model ${entityInstance.objectType} with id: ${entityInstance.primaryKeyColumn().value}",
          header: "InsertService");
      insertedEntityInstance = entityInstance;
    } catch (e, s) {
      myLogger.e(e, stackTrace: s);
    }

    return insertedEntityInstance;
  }
}
