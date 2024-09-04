import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/statement.dart';

class OneToManyQueryService with DartStoreUtility {
  Future<List<EntityInstance>> queryOneToManyColumnData(
      {required List<EntityInstance> connectionInstances,
      required ForeignColumn oneToManyColumn,
      List<Where> where = const []}) async {
    final List<EntityInstance> manyToOneInstances = [];
    for (final connectionInstance in connectionInstances) {
      final manyToOneTableDescription =
          TableService().findTable(oneToManyColumn.foreignKey.referencedEntity);
      final manyToOneItem = (await DataQueryService()
              .query(description: manyToOneTableDescription, where: [
        Where(
            comparisonOperator: ComparisonOperator.equals,
            internalColumn: manyToOneTableDescription.primaryKeyColumn(),
            value: connectionInstance
                .columnByNameAndType<InternalColumnInstance>(
                    manyToOneTableDescription.tableName)
                .value)
      ]))
          .first;
      manyToOneInstances.add(manyToOneItem);
    }

    return manyToOneInstances;
  }

  Future<List<EntityInstance>> queryConnections({
    required EntityInstance oneToManyHolder,
    required ForeignColumn oneToManyColumn,
  }) async {
    final TableDescription manyToOneTableDescription =
        TableService().findTable(oneToManyColumn.foreignKey.referencedEntity);

    final TableConnectionDescription tableConnectionDescription =
        TableConnectionDescriptionService()
            .generateManyToOneAndOneToManyDescription(
                oneToManyTableDescription: oneToManyHolder,
                manyToOneTableDescription: manyToOneTableDescription);

    final List<EntityInstance> connectionInstances = await DataQueryService()
        .query(description: tableConnectionDescription, where: [
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: tableConnectionDescription
              .columnByName(oneToManyHolder.tableName),
          value: oneToManyHolder.primaryKeyColumn().value)
    ]);

    return connectionInstances;
  }

  Future<EntityInstance> postQuery(
      {required EntityInstance entityInstance,
      List<Where> where = const []}) async {
    for (final foreignColumn in TableService()
        .findTable(entityInstance.objectType)
        .oneToManyColumns()) {
      final connectionInstances = await queryConnections(
          oneToManyHolder: entityInstance, oneToManyColumn: foreignColumn);

      final List<EntityInstance> manyToOneInstances =
          await queryOneToManyColumnData(
              connectionInstances: connectionInstances,
              oneToManyColumn: foreignColumn,
              where: where);

      entityInstance.columns.add(OneToManyColumnInstance(
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name,
          value: manyToOneInstances));
    }

    return entityInstance;
  }
}
