import 'package:dart_store/connection/description/description.dart';
import 'package:dart_store/connection/description/service.dart';
import 'package:dart_store/connection/instance/instance.dart';
import 'package:dart_store/converter/converter.dart';
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

  Future<List<TableConnectionInstance>> _queryConnection(
    EntityInstance instance,
    TableDescription referencedTableDescription,
  ) async {
    TableConnectionDescription connectionDescription =
        TableConnectionDescriptionService()
            .generateTableDescription(instance, referencedTableDescription);

    QueryStatement queryStatement =
        QueryStatement(tableDescription: connectionDescription);
    final primaryKeyColumn = instance.primaryKeyColumn();

    Where where = Where(
        comparisonOperator: ComparisonOperator.equals,
        internalColumn: InternalColumn(
            dataType: primaryKeyColumn.dataType,
            constraints: primaryKeyColumn.constraints,
            name: instance.tableName.toCamelCase()),
        value: primaryKeyColumn.value);

    final StatementComposition statementComposition =
        StatementComposition(statement: queryStatement, where: [where]);
    print("Many-To-Many connection-query: ${statementComposition.define()}");
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

    for (final foreignColumn in TableService()
        .findTable(entityInstance.objectType)
        .manyToManyColumns()) {
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
          value: items,
          foreignKey: foreignColumn.foreignKey,
          constraints: foreignColumn.constraints,
          name: foreignColumn.name));
    }

    return entityInstance;
  }
}
