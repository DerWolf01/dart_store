import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/statement.dart';

class ManyToOneQueryService with DartStoreUtility {
  Future<EntityInstance> queryManyToOneColumnData(
      {required EntityInstance connectionInstance,
      required ForeignColumnInstance oneToManyColumnInstance,
      List<Where> where = const []}) async {
    final oneToManyTableDescription = TableService()
        .findTable(oneToManyColumnInstance.foreignKey.referencedEntity);
    final oneToManyItem = (await DataQueryService()
            .query(description: oneToManyTableDescription, where: [
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: oneToManyTableDescription.primaryKeyColumn(),
          value: connectionInstance
              .columnByNameAndType<InternalColumnInstance>(
                  oneToManyTableDescription.tableName)
              .value)
    ]))
        .first;
    return oneToManyItem;
  }

  Future<List<EntityInstance>> queryConnections({
    required EntityInstance manyToOneHolder,
    required ForeignColumnInstance oneToManyColumnInstance,
  }) async {
    final TableDescription oneToManyTableDescription = TableService()
        .findTable(oneToManyColumnInstance.foreignKey.referencedEntity);
    final TableConnectionDescription tableConnectionDescription =
        TableConnectionDescriptionService().generateTableDescription(
            manyToOneHolder, oneToManyTableDescription);
    final List<EntityInstance> connectionInstances = await DataQueryService()
        .query(description: tableConnectionDescription, where: [
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: tableConnectionDescription
              .columnByName(manyToOneHolder.tableName),
          value: manyToOneHolder.primaryKeyColumn().value)
    ]);

    return connectionInstances;
  }

  Future<EntityInstance> postQuery(
      {required EntityInstance entityInstance,
      List<Where> where = const []}) async {
    for (final foreignColumnInstance in entityInstance.manyToOneColumns()) {
      final connectionInstances = await queryConnections(
          manyToOneHolder: entityInstance,
          oneToManyColumnInstance: foreignColumnInstance);

      final EntityInstance oneToManyInstance = await queryManyToOneColumnData(
          connectionInstance: connectionInstances.first,
          oneToManyColumnInstance: foreignColumnInstance,
          where: where);

      entityInstance.setField(foreignColumnInstance.sqlName, oneToManyInstance);
    }

    return entityInstance;
  }
}
