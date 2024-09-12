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
import 'package:dart_store/data_query/one_to_many/service.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/data_query/statement.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/filter_wheres.dart';
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
      ...filterWheres(
          where: where,
          columnName: oneToManyColumn.name,
          externalColumnType: oneToManyColumn.foreignKey.referencedEntity),
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

  Future<List<EntityInstance>> queryConnectionsUsingOneToManyInstance({
    required TableDescription manyToOneHolder,
    required EntityInstance oneToManyInstance,
  }) async {
    final TableConnectionDescription tableConnectionDescription =
        TableConnectionDescriptionService()
            .generateManyToOneAndOneToManyDescription(
                oneToManyTableDescription: oneToManyInstance,
                manyToOneTableDescription: manyToOneHolder);

    final List<EntityInstance> connectionInstances = await DataQueryService()
        .query(description: tableConnectionDescription, where: [
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: InternalColumn(
              name: oneToManyInstance.tableName,
              constraints: [],
              dataType: oneToManyInstance.primaryKeyColumn().dataType),
          value: oneToManyInstance.primaryKeyColumn().value)
    ]);
    print("Connection instances length --> ${connectionInstances.length}");

    return connectionInstances;
  }

  Future<List<EntityInstance>> preQuery(
      TableDescription tableDescription, List<Where> where) async {
    final lefterPKey = tableDescription.primaryKeyColumn();

    Map<dynamic, ManyToOneColumnInstance> entityInstances = {};
    //TODO: implement querying using filteredWhere to ManyToMany righter table and then wuery connections using these to create the List of EntityInstances
    for (final manyToOneColumn in tableDescription.manyToOneColumns()) {
      final referencedEntity = manyToOneColumn.foreignKey.referencedEntity;
      final filteredWhere =
          filterWheres(where: where, externalColumnType: referencedEntity);
      final oneToManyTable = TableService().findTable(referencedEntity);
      List<EntityInstance> tempOneToManyRighterResultEntities =
          (await DataQueryService().query(
              description: oneToManyTable,
              where: filteredWhere
                  .map(
                    (e) => e..foreignField = dynamic,
                  )
                  .toList()));
      print("MANY TO ONE pre query --> $tempOneToManyRighterResultEntities");
      for (final tempEntry in tempOneToManyRighterResultEntities) {
        final connections = await queryConnectionsUsingOneToManyInstance(
            manyToOneHolder: tableDescription, oneToManyInstance: tempEntry);
        for (final connection in connections) {
          (entityInstances[connection.columns
                  .firstWhere(
                    (element) => element.sqlName == tableDescription.tableName,
                  )
                  .value] ??=
              ManyToOneColumnInstance(
                  foreignKey: manyToOneColumn.foreignKey,
                  constraints: manyToOneColumn.constraints,
                  name: manyToOneColumn.name,
                  value: tempEntry,
                  mapId: manyToOneColumn.mapId));
        }
      }
    }
    return entityInstances.entries
        .map((e) => EntityInstance(
                objectType: tableDescription.objectType,
                entity: tableDescription.entity,
                columns: [
                  InternalColumnInstance(
                      value: e.key,
                      dataType: lefterPKey.dataType,
                      constraints: lefterPKey.constraints,
                      name: "id"),
                  e.value
                ]))
        .toList();
  }

  Future<EntityInstance> postQuery(
      {required EntityInstance entityInstance,
      List<Where> where = const []}) async {
    for (final foreignColumn in entityInstance.manyToOneColumns()) {
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
