import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/update/many_to_many/service.dart';
import 'package:dart_store/data_manipulation/update/one_to_one/service.dart';
import 'package:dart_store/data_manipulation/update/otm_mto/service.dart';
import 'package:dart_store/data_manipulation/update/statement.dart';
import 'package:dart_store/data_manipulation/where_utils.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

class UpdateService with DartStoreUtility {
  ///
  Future<EntityInstance> update(EntityInstance entityInstance,
      {List<Where> where = const []}) async {
    late final EntityInstance updatedEntityInstance;
    try {
      final UpdateStatement updateStatement =
          UpdateStatement(entityInstance: entityInstance);
      final primaryKeyColumn = entityInstance.primaryKeyColumn();

      final StatementComposition statementComposition = StatementComposition(
          statement: updateStatement,
          where: automaticallyFilterWhere(
              where: where,
              primaryKeyColumn: primaryKeyColumn,
              id: primaryKeyColumn.value));

      final statement = statementComposition.define();
      myLogger.i(
        statement,
      );

      await executeSQL(statementComposition.define());

      final id = primaryKeyColumn.value;

      myLogger.i("Updated data into table ${entityInstance.tableName}");
      final isOfPrimaryKeyType =
          entityInstance.primaryKeyColumn().dataType.compareToValue(id);
      if (!isOfPrimaryKeyType) {
        throw Exception(
            "Couldn't parse resulting id to type ${entityInstance.primaryKeyColumn().dataType.primitiveType} after updateing data into table ${entityInstance.tableName};  ");
      }

      await ManyToManyUpdateService().postUpdate(entityInstance, where: where);
      await OneToOneUpdateService().postUpdate(entityInstance);

      await OneToManyAndManyToOneUpdateService().postUpdate(entityInstance);

      updatedEntityInstance = entityInstance;
    } catch (e, s) {
      myLogger.i(e);
      myLogger.i(s);
    }

    return updatedEntityInstance;
  }
}
