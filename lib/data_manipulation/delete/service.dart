import 'package:dart_store/data_manipulation/delete/statement.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/statement.dart';

class DeleteService with DartStoreUtility {
  ///
  Future<void> delete(
    EntityInstance entityInstance,
  ) async {
    try {
      myLogger.d(
          "Deleting ${entityInstance.objectType} with id: ${entityInstance.primaryKeyColumn().value}",
          header: "DeleteService");

      /// Delete all related data
      // await ManyToManyDeleteService().preDelete(entityInstance);
      // await OneToOneDeleteService().preDelete(entityInstance);
      // await OneToManyAndManyToOneDeleteService().preDelete(entityInstance);

      /// start deleting actual data
      final DeleteStatement deleteStatement =
          DeleteStatement(entityInstance: entityInstance);

      final primaryKeyColumn = entityInstance.primaryKeyColumn();

      final Where whereStatement = Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: primaryKeyColumn,
          value: primaryKeyColumn.value);

      final StatementComposition statementComposition = StatementComposition(
          statement: deleteStatement, where: [whereStatement]);

      await executeSQL(statementComposition.define());
    } catch (e, s) {
      myLogger.e(e, stackTrace: s, header: "DeleteService");
    }
  }

  // Future<void> deleteUsingType(Type modelType,
  //     {List<Where> where = const []}) {

  //     }
}
