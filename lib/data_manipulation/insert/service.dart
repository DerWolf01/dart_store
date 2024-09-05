import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/many_to_many/service.dart';
import 'package:dart_store/data_manipulation/insert/many_to_one/service.dart';
import 'package:dart_store/data_manipulation/insert/one_to_many/service.dart';
import 'package:dart_store/data_manipulation/insert/one_to_one/service.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class InsertService with DartStoreUtility {
  ///
  Future<EntityInstance> insert(EntityInstance entityInstance) async {
    late final EntityInstance insertedEntityInstance;
    try {
      final InsertStatement insertStatement =
          InsertStatement(entityInstance: entityInstance);
      final primaryKeyColumn = entityInstance.primaryKeyColumn();
      final id = (primaryKeyColumn.value == -1 || primaryKeyColumn.value == null
          ? await dartStore.connection
              .insert(insertStatement.define(), entityInstance.tableName)
          : primaryKeyColumn.value);

      final isOfPrimaryKeyType =
          entityInstance.primaryKeyColumn().dataType.compareToValue(id);
      if (!isOfPrimaryKeyType) {
        throw Exception(
            "Couldn't parse resulting id to type ${entityInstance.primaryKeyColumn().dataType.primitiveType} after inserting data into table ${entityInstance.tableName};  ");
      }
      entityInstance.setField("id", id);

      await ManyToManyInsertService().postInsert(entityInstance);
      await OneToOneInsertService().postInsert(entityInstance);
      await OneToManyInsertService().postInsert(entityInstance);
      await ManyToOneInsertService().postInsert(entityInstance);
      insertedEntityInstance = entityInstance;
    } catch (e, s) {
      print(e);
      print(s);
    }

    return insertedEntityInstance;
  }
}
