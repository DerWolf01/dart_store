import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/statement.dart';

class ManyToOneQueryService with DartStoreUtility {
  Future<EntityInstance> queryManyToOneColumnData(
      {required EntityInstance connectionInstance,
      required ForeignColumn oneToManyColumn,
      List<Where> where = const []}) async {
    final oneToManyTableDescription =
        TableService().findTable(oneToManyColumn.foreignKey.referencedEntity);
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
    required ForeignColumn oneToManyColumn,
  }) async {
    final TableDescription oneToManyTableDescription =
        TableService().findTable(oneToManyColumn.foreignKey.referencedEntity);
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
    for (final foreignColumn in TableService()
        .findTable(entityInstance.objectType)
        .manyToOneColumns()) {
      final connectionInstances = await queryConnections(
          manyToOneHolder: entityInstance, oneToManyColumn: foreignColumn);

      final EntityInstance oneToManyInstance = await queryManyToOneColumnData(
          connectionInstance: connectionInstances.first,
          oneToManyColumn: foreignColumn,
          where: where);

      entityInstance.columns.add(ManyToOneColumnInstance(
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name,
          value: oneToManyInstance));
    }

    return entityInstance;
  }
}
