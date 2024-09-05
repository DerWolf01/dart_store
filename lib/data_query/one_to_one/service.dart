import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/converter/converter.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/service.dart';
import 'package:dart_store/data_query/statement.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/filter_wheres.dart';
import 'package:dart_store/where/statement.dart';
import 'package:postgres/postgres.dart';

// TODO: Implement logic to instanciate EntityInstance using a value
class OneToOneQueryService {
  Future<List<EntityInstance>> _queryForeignColumnItems(
      {required ForeignColumn oneToOneColumn,
      required TableConnectionInstance connectionInstance,
      List<Where> where = const []}) async {
    final TableDescription tableDescription =
        TableService().findTable(oneToOneColumn.foreignKey.referencedEntity);

    return await DataQueryService().query(
        description: tableDescription,
        where: filterWheres(
            where: [
              ...where,
              Where(
                  comparisonOperator: ComparisonOperator.equals,
                  internalColumn: connectionInstance.primaryKeyColumn(),
                  value: connectionInstance.columnByNameAndType<InternalColumn>(
                      tableDescription.tableName.toCamelCase()))
            ],
            columnName: oneToOneColumn.name,
            externalColumnType: oneToOneColumn.foreignKey.referencedEntity));
  }

  Future<List<TableConnectionInstance>> _queryConnection(
    EntityInstance instance,
    TableDescription referencedTableDescription,
  ) async {
    print("instance: ${instance.tableName}");
    print(
        "referencedTableDescription: ${referencedTableDescription.tableName}");
    final TableConnectionDescription connectionDescription =
        TableConnectionDescriptionService()
            .generateTableDescription(instance, referencedTableDescription);

    QueryStatement queryStatement =
        QueryStatement(tableDescription: connectionDescription);
    final primaryKeyColumn = instance.primaryKeyColumn();
    final queryColumn = InternalColumn(
        dataType: primaryKeyColumn.dataType,
        constraints: primaryKeyColumn.constraints,
        name: instance.tableName);
    print(
        "querying connection with primaryKeyColumn: $primaryKeyColumn and value: ${primaryKeyColumn.value}");
    Where where = Where(
        comparisonOperator: ComparisonOperator.equals,
        internalColumn: queryColumn,
        value: primaryKeyColumn.value);

    final StatementComposition statementComposition =
        StatementComposition(statement: queryStatement, where: [where]);
    try {
      final statementCompositionString = statementComposition.define();
      print("statementCompositionString: $statementCompositionString");
      return mapListToTableConnectionInstance(
          maps: await dartStore.connection.query(statementCompositionString),
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

    for (final foreignColumn in TableService()
        .findTable(entityInstance.objectType)
        .oneToOneColumns()) {
      final List<TableConnectionInstance> connectionInstances =
          await _queryConnection(
              entityInstance,
              TableService()
                  .findTable(foreignColumn.foreignKey.referencedEntity));
      print("OneToOneQueryService: connectionInstances: $connectionInstances");
      if (connectionInstances.isEmpty) {
        throw Exception(
            "No connection found for ${entityInstance.tableName} and ${foreignColumn.foreignKey.referencedEntity}");
      }
      final List<EntityInstance> items = await _queryForeignColumnItems(
          oneToOneColumn: foreignColumn,
          connectionInstance: connectionInstances.first,
          where: where);

      entityInstance.columns.add(OneToOneColumnInstance(
          mapId: foreignColumn.mapId,
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name,
          value: items.first));
    }

    return entityInstance;
  }
}
