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

class OneToManyQueryService with DartStoreUtility {
  Future<List<EntityInstance>> queryOneToManyColumnData(
      {required List<EntityInstance> connectionInstances,
      required ForeignColumnInstance oneToManyColumnInstance,
      List<Where> where = const []}) async {
    final List<EntityInstance> manyToOneInstances = [];
    for (final connectionInstance in connectionInstances) {
      final manyToOneTableDescription = TableService()
          .findTable(oneToManyColumnInstance.foreignKey.referencedEntity);
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
    required ForeignColumnInstance oneToManyColumnInstance,
  }) async {
    final TableDescription manyToOneTableDescription = TableService()
        .findTable(oneToManyColumnInstance.foreignKey.referencedEntity);
    final TableConnectionDescription tableConnectionDescription =
        TableConnectionDescriptionService().generateTableDescription(
            oneToManyHolder, manyToOneTableDescription);
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
    for (final foreignColumnInstance in entityInstance.oneToManyColumns()) {
      final connectionInstances = await queryConnections(
          oneToManyHolder: entityInstance,
          oneToManyColumnInstance: foreignColumnInstance);

      final List<EntityInstance> manyToOneInstances =
          await queryOneToManyColumnData(
              connectionInstances: connectionInstances,
              oneToManyColumnInstance: foreignColumnInstance,
              where: where);

      entityInstance.setField(
          foreignColumnInstance.sqlName, manyToOneInstances);
    }

    return entityInstance;
  }
}
