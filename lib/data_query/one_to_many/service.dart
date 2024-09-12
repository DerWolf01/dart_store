import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/filter_wheres.dart';
import 'package:dart_store/where/statement.dart';
import 'package:change_case/change_case.dart';

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
                    manyToOneTableDescription.tableName.toCamelCase())
                .value)
      ]))
          .first;
      manyToOneInstances.add(manyToOneItem);
    }

    return manyToOneInstances;
  }

  Future<List<EntityInstance>> queryConnectionsUsingManyToOneInstance({
    required TableDescription oneToManyHolder,
    required EntityInstance manyToOneColumn,
  }) async {
    final TableConnectionDescription tableConnectionDescription =
        TableConnectionDescriptionService()
            .generateManyToOneAndOneToManyDescription(
                oneToManyTableDescription: oneToManyHolder,
                manyToOneTableDescription: manyToOneColumn);

    final List<EntityInstance> connectionInstances = await DataQueryService()
        .query(description: tableConnectionDescription, where: [
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: InternalColumn(
              name: manyToOneColumn.tableName,
              constraints: [],
              dataType: tableConnectionDescription
                  .columnByName(manyToOneColumn.tableName)
                  .dataType),
          value: manyToOneColumn.primaryKeyColumn().value)
    ]);
    print("Connection instances length --> ${connectionInstances.length}");

    return connectionInstances;
  }

  Future<List<EntityInstance>> queryConnections({
    required EntityInstance oneToManyHolder,
    required ForeignColumn manyToOneColumn,
  }) async {
    final TableDescription manyToOneTableDescription =
        TableService().findTable(manyToOneColumn.foreignKey.referencedEntity);

    final TableConnectionDescription tableConnectionDescription =
        TableConnectionDescriptionService()
            .generateManyToOneAndOneToManyDescription(
                oneToManyTableDescription: oneToManyHolder,
                manyToOneTableDescription: manyToOneTableDescription);

    final List<EntityInstance> connectionInstances = await DataQueryService()
        .query(description: tableConnectionDescription, where: [
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: InternalColumn(
              dataType: oneToManyHolder.primaryKeyColumn().dataType,
              constraints: [],
              name: oneToManyHolder.tableName),
          value: oneToManyHolder.primaryKeyColumn().value)
    ]);

    return connectionInstances;
  }

  Future<List<EntityInstance>> preQuery(
      TableDescription tableDescription, List<Where> where) async {
    final lefterPKey = tableDescription.primaryKeyColumn();

    Map<dynamic, OneToManyColumnInstance> entityInstances = {};

    for (final oneToManyColumn in tableDescription.oneToManyColumns()) {
      final referencedEntity = oneToManyColumn.foreignKey.referencedEntity;
      final filteredWhere =
          filterWheres(where: where, externalColumnType: referencedEntity);
      print("PRE QUERY ONE TO MANY WHERE --> $filteredWhere ");
      final manyToOneTable = TableService().findTable(referencedEntity);
      List<EntityInstance> tempOneToManyRighterResultEntities =
          (await DataQueryService().query(
              description: manyToOneTable,
              where: filteredWhere
                  .map(
                    (e) => e..foreignField = dynamic,
                  )
                  .toList()));
      print(
          "tempOneToManyRighterResultEntities --> $tempOneToManyRighterResultEntities");
      for (final tempEntry in tempOneToManyRighterResultEntities) {
        final connections = await queryConnectionsUsingManyToOneInstance(
          manyToOneColumn: tempEntry,
          oneToManyHolder: tableDescription,
        );
        for (final connection in connections) {
          print(
              "--------------------- Connection: $connection --------------------- ");
          (entityInstances[connection.columns
                      .firstWhere(
                        (element) =>
                            element.sqlName == tableDescription.tableName,
                      )
                      .value] ??=
                  OneToManyColumnInstance(
                      foreignKey: oneToManyColumn.foreignKey,
                      constraints: oneToManyColumn.constraints,
                      name: oneToManyColumn.name,
                      value: [],
                      mapId: oneToManyColumn.mapId))
              .value
              .add(tempEntry);
          print("Added $tempEntry to ${oneToManyColumn.name}");
          print(entityInstances[connection.columns
              .firstWhere(
                (element) => element.sqlName == tableDescription.tableName,
              )
              .value]);
        }
      }
    }
    print("PRE QUERY ONE TO MANY --> $entityInstances");
    return entityInstances.entries
        .map((e) => EntityInstance(
                objectType: tableDescription.objectType,
                entity: tableDescription.entity,
                columns: [
                  InternalColumnInstance(
                      value: e.key,
                      dataType: lefterPKey.dataType,
                      constraints: lefterPKey.constraints,
                      name: lefterPKey.name),
                  e.value
                ]))
        .toList();
  }

  Future<EntityInstance> postQuery(
      {required EntityInstance entityInstance,
      List<Where> where = const []}) async {
    for (final foreignColumn in entityInstance.oneToManyColumns()) {
      final connectionInstances = await queryConnections(
          oneToManyHolder: entityInstance, manyToOneColumn: foreignColumn);

      final List<EntityInstance> manyToOneInstances =
          await queryOneToManyColumnData(
              connectionInstances: connectionInstances,
              oneToManyColumn: foreignColumn,
              where: where);

      entityInstance.columns.add(OneToManyColumnInstance(
          mapId: foreignColumn.mapId,
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name,
          value: manyToOneInstances));
    }

    return entityInstance;
  }
}
