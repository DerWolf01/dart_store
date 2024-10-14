import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/connection/instance/service.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_manipulation/delete/service.dart';
import 'package:dart_store/data_manipulation/delete/statement.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class ManyToManyDeleteService with DartStoreUtility {
  Future<void> preDelete(EntityInstance entityInstance,
      {bool recursive = false}) async {
    if (entityInstance.primaryKeyColumn().value == -1 ||
        entityInstance.primaryKeyColumn().value == null) {
      throw Exception(
          "Entity of table ${entityInstance.tableName} has to be deleteed before deleteing foreign columns");
    }
    for (final foreignColumnInstance
        in entityInstance.manyToManyColumnsInstances()) {
      final List<EntityInstance> values = foreignColumnInstance.value;
      for (final itemEntityInstance in values) {
        await _deleteConnection(entityInstance, itemEntityInstance);
        if (recursive && !foreignColumnInstance.mapId) {
          await _deleteForeignColumnItem(itemEntityInstance);
        }
      }
    }
  }

  Future _deleteConnection(
      EntityInstance instance, EntityInstance instance2) async {
    TableConnectionInstance connectionInstance =
        TableConnectionInstanceService()
            .generateTableConnectionInstance(instance, instance2);

    DeleteStatement deleteStatement =
        DeleteStatement(entityInstance: connectionInstance);
    final pKeyColumn = instance.primaryKeyColumn();
    final pKeyColumn2 = instance2.primaryKeyColumn();

    List<Where> whereStatements = [
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: InternalColumn(
              dataType: pKeyColumn.dataType,
              constraints: pKeyColumn.constraints,
              name: instance.tableName),
          value: pKeyColumn.value),
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: InternalColumn(
              dataType: pKeyColumn2.dataType,
              constraints: pKeyColumn2.constraints,
              name: instance2.tableName),
          value: pKeyColumn2.value)
    ];
    StatementComposition statementComposition = StatementComposition(
        statement: deleteStatement, where: whereStatements);

    try {
      await executeSQL(statementComposition.define());
    } on PgException catch (e, s) {
      myLogger.log(e.message);
      myLogger.log(e.severity);
      myLogger.log(s);
    } catch (e, s) {
      myLogger.log(e);
      myLogger.log(s);
    }
  }

  Future<void> _deleteForeignColumnItem(EntityInstance item) async {
    await DeleteService().delete(item);
  }
}
