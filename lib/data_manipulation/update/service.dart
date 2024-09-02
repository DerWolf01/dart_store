import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/update/many_to_many/service.dart';
import 'package:dart_store/data_manipulation/update/one_to_many/service.dart';
import 'package:dart_store/data_manipulation/update/one_to_one/service.dart';
import 'package:dart_store/data_manipulation/update/statement.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

class UpdateService with DartStoreUtility {
  ///
  Future<EntityInstance> update(
    EntityInstance entityInstance,
  ) async {
    late final EntityInstance updatedEntityInstance;
    try {
      final UpdateStatement updateStatement =
          UpdateStatement(entityInstance: entityInstance);
      final primaryKeyColumn = entityInstance.primaryKeyColumn();
      final Where whereStatement = Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: primaryKeyColumn,
          value: primaryKeyColumn.value);

      final StatementComposition statementComposition = StatementComposition(
          statement: updateStatement, wheres: [whereStatement]);
      final Result updateResult =
          await executeSQL(statementComposition.define());

      final id = updateResult.first.first;
      final isOfPrimaryKeyType =
          entityInstance.primaryKeyColumn().dataType.compareToValue(id);
      if (!isOfPrimaryKeyType) {
        throw Exception(
            "Couldn't parse resulting id to type ${entityInstance.primaryKeyColumn().dataType.primitiveType} after updateing data into table ${entityInstance.tableName};  ");
      }

      updatedEntityInstance = await ManyToManyUpdateService().postUpdate(
          await OneToOneUpdateService().postUpdate(
              await OneToManyUpdateService().postUpdate(entityInstance)));
    } catch (e, s) {
      print(e);
      print(s);
    }

    return updatedEntityInstance;
  }
}
