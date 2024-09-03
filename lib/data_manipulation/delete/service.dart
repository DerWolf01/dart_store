import 'package:dart_store/data_manipulation/delete/one_to_many/service.dart';
import 'package:dart_store/data_manipulation/delete/one_to_one/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_manipulation/delete/many_to_many/service.dart';
import 'package:dart_store/data_manipulation/delete/statement.dart';
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
      /// Delete all related data
      await ManyToManyDeleteService().preDelete(entityInstance);
      await OneToOneDeleteService().preDelete(entityInstance);
      await OneToManyDeleteService().preDelete(entityInstance);

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
      print(e);
      print(s);
    }
  }

  // Future<void> deleteUsingType(Type modelType,
  //     {List<Where> where = const []}) {

  //     }
}
