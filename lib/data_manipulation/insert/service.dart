import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/insert/statement.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:postgres/postgres.dart';

class InsertService with DartStoreUtility {
  ///
  Future<dynamic> insert(EntityInstance entityInstance) async {
    try {
      final InsertStatement insertStatement =
          InsertStatement(entityInstance: entityInstance);

      final Result insertResult = await executeSQL(insertStatement.define());

      final id = insertResult.first.first;
      final isOfPrimaryKeyType =
          entityInstance.primaryKeyColumn().dataType.comppareToValue(id);
      if (!isOfPrimaryKeyType) {
        throw Exception(
            "Couldn't parse resulting id to type ${entityInstance.primaryKeyColumn().dataType.primitiveType} after inserting data into table ${entityInstance.tableName};  ");
      }

      return id;
    } catch (e, s) {
      print(e);
      print(s);
    }
  }
}
