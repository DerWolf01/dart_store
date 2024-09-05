import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/converter/converter.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/data_query/statement.dart';
import 'package:dart_store/statement/compositor.dart';
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
                  oneToManyTableDescription.tableName.toCamelCase())
              .value)
    ]))
        .first;
    return oneToManyItem;
  }

  Future<EntityInstance> queryConnections({
    required EntityInstance manyToOneHolder,
    required ForeignColumn oneToManyColumn,
  }) async {
    final TableDescription oneToManyTableDescription =
        TableService().findTable(oneToManyColumn.foreignKey.referencedEntity);
    final TableConnectionDescription tableConnectionDescription =
        TableConnectionDescriptionService()
            .generateManyToOneAndOneToManyDescription(
                manyToOneTableDescription: manyToOneHolder,
                oneToManyTableDescription: oneToManyTableDescription);

    QueryStatement queryStatement =
        QueryStatement(tableDescription: tableConnectionDescription);

    final manyToOneHolderPrimaryColumn = manyToOneHolder.primaryKeyColumn();

    final StatementComposition statementComposition =
        StatementComposition(statement: queryStatement, where: [
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: InternalColumn(
              dataType: manyToOneHolderPrimaryColumn.dataType,
              constraints: manyToOneHolderPrimaryColumn.constraints,
              name: manyToOneHolder.tableName.toCamelCase()),
          value: manyToOneHolder.primaryKeyColumn().value)
    ]);
    final List<EntityInstance> connectionInstances =
        mapListToTableConnectionInstance(
            maps:
                await dartStore.connection.query(statementComposition.define()),
            tableConnectionDescription: tableConnectionDescription);

    return connectionInstances.first;
  }

  Future<EntityInstance> postQuery(
      {required EntityInstance entityInstance,
      List<Where> where = const []}) async {
    for (final foreignColumn in TableService()
        .findTable(entityInstance.objectType)
        .manyToOneColumns()) {
      final connectionInstance = await queryConnections(
          manyToOneHolder: entityInstance, oneToManyColumn: foreignColumn);

      final EntityInstance oneToManyInstance = await queryManyToOneColumnData(
          connectionInstance: connectionInstance,
          oneToManyColumn: foreignColumn,
          where: where);

      entityInstance.columns.add(ManyToOneColumnInstance(
          mapId: foreignColumn.mapId,
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name,
          value: oneToManyInstance));
    }

    return entityInstance;
  }
}
