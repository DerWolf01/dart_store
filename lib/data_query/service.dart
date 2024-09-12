import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/many_to_many/service.dart';
import 'package:dart_store/data_query/many_to_one/service.dart';
import 'package:dart_store/data_query/one_to_many/service.dart';
import 'package:dart_store/data_query/one_to_one/service.dart';
import 'package:dart_store/data_query/pagination/page.dart';
import 'package:dart_store/data_query/statement.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/filter_wheres.dart';
import 'package:dart_store/where/statement.dart';

class DataQueryService {
  Future<List<EntityInstance>> query(
      {required TableDescription description,
      List<Where> where = const [],
      Page? page}) async {
    print(where.map(
      (e) => e.foreignField,
    ));
    final externalWhere = where.any((element) =>
        element.foreignField != null && element.foreignField != dynamic);
    if (!externalWhere) {
      print("Filter wheres is empty $where");
      return await queryBySelf(
          description: description, where: where, page: page);
    }

    print("Filter wheres is not empty $where");

    return await queryByExternalField(
        description: description, where: where, page: page);
  }

  Future<List<EntityInstance>> queryByExternalField(
      {required TableDescription description,
      List<Where> where = const [],
      Page? page}) async {
    final List<EntityInstance> entityInstances = [
      ...(await ManyToManyQueryService().preQuery(description, where)),
      ...(await OneToOneQueryService().preQuery(description, where)),
      ...(await ManyToOneQueryService().preQuery(description, where)),
      ...(await OneToManyQueryService().preQuery(description, where))
    ].unite();
    print("UNITED: ${entityInstances.map(
      (e) => e.columns.map((e) => e.name),
    )}");
    QueryStatement queryStatement =
        QueryStatement(tableDescription: description);

    final List<Where> filteredWhere = [
      ...where,
      ...entityInstances.map(
        (e) => OrWhere(
            comparisonOperator: ComparisonOperator.equals,
            internalColumn: InternalColumn(
                dataType: e.primaryKeyColumn().dataType,
                constraints: [],
                name: e.primaryKeyColumn().name),
            value: e.primaryKeyColumn().value),
      )
    ];
    print("filtered-where: $filteredWhere");
    final StatementComposition statementComposition = StatementComposition(
        statement: queryStatement, where: filteredWhere, page: page);
    print("used $filteredWhere for composition");
    final statementString = statementComposition.define();
    print("query-statementString: $statementString");
    final queryResults = await dartStore.connection.query(statementString);

    for (final queryResult in queryResults) {
      final instance = EntityInstance(
          entity: description.entity,
          objectType: description.objectType,
          columns: description.columns
              .whereType<InternalColumn>()
              .map<ColumnInstance>((InternalColumn e) => InternalColumnInstance(
                  dataType: e.dataType,
                  constraints: e.constraints,
                  name: e.name,
                  value: queryResult[e.sqlName]))
              .toList());
      final pKey = instance.primaryKeyColumn();
      for (final existingInstance in entityInstances) {
        if (existingInstance.primaryKeyColumn().value == pKey.value) {
          existingInstance.columns.addAll(instance.columns
            ..removeWhere(
              (element) => element.isPrimaryKey,
            ));
          continue;
        }
      }
    }

    return entityInstances.unite();
  }

  Future<List<EntityInstance>> queryBySelf(
      {required TableDescription description,
      List<Where> where = const [],
      Page? page}) async {
    QueryStatement queryStatement =
        QueryStatement(tableDescription: description);
    final List<Where> filteredWhere = filterWheres(where: where);
    print("filtered-where: $filteredWhere");
    final StatementComposition statementComposition = StatementComposition(
        statement: queryStatement, where: filteredWhere, page: page);

    final statementString = statementComposition.define();
    print("query-statementString: $statementString");
    final queryResults = await dartStore.connection.query(statementString);

    final List<EntityInstance> entityInstances = [];
    for (final queryResult in queryResults) {
      final entityInstance = EntityInstance(
        objectType: description.objectType,
        entity: description.entity,
        columns: description.columns
            .whereType<InternalColumn>()
            .map<ColumnInstance>((InternalColumn e) => InternalColumnInstance(
                dataType: e.dataType,
                constraints: e.constraints,
                name: e.name,
                value: queryResult[e.sqlName]))
            .toList(),
      );

      await ManyToManyQueryService().postQuery(entityInstance);
      await OneToManyQueryService()
          .postQuery(entityInstance: entityInstance, where: where);
      await ManyToOneQueryService()
          .postQuery(entityInstance: entityInstance, where: where);
      await OneToOneQueryService().postQuery(
        entityInstance,
      );
      entityInstances.add(entityInstance);
    }
    return entityInstances;
  }
}

extension EntityUniter on List<EntityInstance> {
  List<EntityInstance> unite() {
    final List<EntityInstance> united = [];
    for (final entityInstance in this) {
      for (final unitedInstance in united) {
        if (entityInstance.primaryKeyColumn().value ==
            unitedInstance.primaryKeyColumn().value) {
          unitedInstance.columns.addAll(entityInstance.columns);
          continue;
        }
      }

      united.add(entityInstance);
    }
    return united;
  }
}
