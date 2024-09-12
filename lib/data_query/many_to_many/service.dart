import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/converter/converter.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/data_query/statement.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/filter_wheres.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';
import 'package:change_case/change_case.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class ManyToManyQueryService with DartStoreUtility {
  Future<List<EntityInstance>> _queryForeignColumnItems(
      {required ForeignColumn itemColumn,
      required List<TableConnectionInstance> connectionInstances,
      List<Where> where = const []}) async {
    final TableDescription tableDescription =
        TableService().findTable(itemColumn.foreignKey.referencedEntity);

    final List<EntityInstance> entityInstances = [];
    for (final connectionInstance in connectionInstances) {
      entityInstances.addAll(
          await DataQueryService().query(description: tableDescription, where: [
        ...filterWheres(
            where: where,
            columnName: itemColumn.name,
            externalColumnType: itemColumn.foreignKey.referencedEntity),
        Where(
            comparisonOperator: ComparisonOperator.equals,
            internalColumn: connectionInstance.primaryKeyColumn(),
            value: connectionInstance
                .columnByNameAndType<InternalColumnInstance>(itemColumn.name))
      ]));
    }
    return entityInstances;
  }

  Future<List<TableConnectionInstance>> _queryConnectionUsingWhere(
      TableDescription instance, TableDescription referencedTableDescription,
      {required List<Where> where}) async {
    TableConnectionDescription connectionDescription =
        TableConnectionDescriptionService()
            .generateTableDescription(instance, referencedTableDescription);

    QueryStatement queryStatement =
        QueryStatement(tableDescription: connectionDescription);
    final primaryKeyColumn = instance.primaryKeyColumn();

    final StatementComposition statementComposition =
        StatementComposition(statement: queryStatement, where: where);
    try {
      return mapListToTableConnectionInstance(
          maps: await query(statementComposition.define()),
          tableConnectionDescription: connectionDescription);
    } on PgException catch (e, s) {
      print(e.message);
      print(e.severity);
      print(s);
    } catch (e, s) {
      print(e);
      print(s);
    }
    return [];
  }

  Future<List<TableConnectionInstance>> _queryConnection(
      EntityInstance instance, TableDescription referencedTableDescription,
      {List<Where> where = const []}) async {
    TableConnectionDescription connectionDescription =
        TableConnectionDescriptionService()
            .generateTableDescription(instance, referencedTableDescription);

    QueryStatement queryStatement =
        QueryStatement(tableDescription: connectionDescription);
    final primaryKeyColumn = instance.primaryKeyColumn();

    Where lefterIdWhere = Where(
        comparisonOperator: ComparisonOperator.equals,
        internalColumn: InternalColumn(
            dataType: primaryKeyColumn.dataType,
            constraints: primaryKeyColumn.constraints,
            name: instance.tableName.toCamelCase()),
        value: primaryKeyColumn.value);

    final StatementComposition statementComposition = StatementComposition(
        statement: queryStatement, where: [lefterIdWhere, ...where]);
    try {
      return mapListToTableConnectionInstance(
          maps: await query(statementComposition.define()),
          tableConnectionDescription: connectionDescription);
    } on PgException catch (e, s) {
      print(e.message);
      print(e.severity);
      print(s);
    } catch (e, s) {
      print(e);
      print(s);
    }
    return [];
  }

  Future<EntityInstance> postQuery(EntityInstance entityInstance,
      {List<Where> where = const []}) async {
    if (entityInstance.primaryKeyColumn().value == -1 ||
        entityInstance.primaryKeyColumn().value == null) {
      throw Exception(
          "Entity of table ${entityInstance.tableName} has to be queryed before querying foreign columns");
    }
    print(
        "entityInstance --> ${entityInstance.tableName} --> entity --> ${entityInstance.entity} --> ${entityInstance.entity.name}");
    for (final foreignColumn in entityInstance.manyToManyColumns()) {
      final List<TableConnectionInstance> connectionInstances =
          await _queryConnection(
              entityInstance,
              TableService()
                  .findTable(foreignColumn.foreignKey.referencedEntity));
      final List<EntityInstance> items = await _queryForeignColumnItems(
          itemColumn: foreignColumn,
          connectionInstances: connectionInstances,
          where: where);

      entityInstance.columns.add(ManyToManyColumnInstance(
          mapId: foreignColumn.mapId,
          value: items,
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name));
    }

    return entityInstance;
  }

  Future<List<EntityInstance>> preQuery(
      TableDescription tableDescription, List<Where> where) async {
    final lefterPKey = tableDescription.primaryKeyColumn();

    Map<dynamic, ManyToManyColumnInstance> entityInstances = {};
    //TODO: implement querying using filteredWhere to ManyToMany righter table and then wuery connections using these to create the List of EntityInstances
    for (final manyToManyColumn in tableDescription.manyToManyColumns()) {
      final referencedEntity = manyToManyColumn.foreignKey.referencedEntity;
      final filteredWhere =
          filterWheres(where: where, externalColumnType: referencedEntity);

      final manyToManyRighterTable = TableService()
          .findTable(manyToManyColumn.foreignKey.referencedEntity);
      List<EntityInstance> tempManyToManyRighterResultEntities =
          (await DataQueryService().query(
              description: manyToManyRighterTable,
              where: filteredWhere
                  .map(
                    (e) => e..foreignField = dynamic,
                  )
                  .toList()));
      print("MANY TO MANY PRE QUERY $tempManyToManyRighterResultEntities");
      for (final tempEntry in tempManyToManyRighterResultEntities) {
        final connections = await _queryConnection(tempEntry, tableDescription);
        print("MANY TO MANY CONNECTIONS --> ${connections.length}");
        for (final connection in connections) {
          (entityInstances[connection.columns
                      .firstWhere(
                        (element) =>
                            element.sqlName == tableDescription.tableName,
                      )
                      .value] ??=
                  ManyToManyColumnInstance(
                      foreignKey: manyToManyColumn.foreignKey,
                      constraints: manyToManyColumn.constraints,
                      name: manyToManyColumn.name,
                      value: [],
                      mapId: manyToManyColumn.mapId))
              .value
              .add(tempEntry);
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
                      name: lefterPKey.name),
                  e.value
                ]))
        .toList();
  }

  Future<bool> connectionExists(EntityInstance compareUsing,
          TableDescription memberDescription) async =>
      await dartStore.rawExists(
          tablename: TableConnectionDescriptionService()
              .connectionName(memberDescription, compareUsing),
          where: Where(
              comparisonOperator: ComparisonOperator.equals,
              internalColumn: InternalColumn(
                  dataType: compareUsing.primaryKeyColumn().dataType,
                  constraints: [],
                  name: compareUsing.tableName),
              value: compareUsing.primaryKeyColumn().value));
}
