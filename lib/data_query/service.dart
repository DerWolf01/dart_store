import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/exception.dart';
import 'package:dart_store/data_query/many_to_many/service.dart';
import 'package:dart_store/data_query/many_to_one/service.dart';
import 'package:dart_store/data_query/one_to_many/service.dart';
import 'package:dart_store/data_query/one_to_one/service.dart';
import 'package:dart_store/data_query/order_by/order_by.dart';
import 'package:dart_store/data_query/pagination/page.dart';
import 'package:dart_store/data_query/statement.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/where/statement.dart';
import 'package:dart_store/where/statement_filter.dart';

class DataQueryService {
  postQuery(
      {required EntityInstance entityInstance,
      List<Where> where = const [],
      Page? page}) async {
    await ManyToManyQueryService().postQuery(entityInstance, where: where);
    await OneToManyQueryService().postQuery(entityInstance, where: where);
    await ManyToOneQueryService().postQuery(entityInstance, where: where);
    await OneToOneQueryService().postQuery(entityInstance, where: where);
    return;
  }

  Future<List<EntityInstance>> query(
      {required TableDescription description,
      List<Where> where = const [],
      Page? page,
      OrderBy? orderBy}) async {
    QueryStatement queryStatement =
        QueryStatement(tableDescription: description);

    final StatementComposition statementComposition = StatementComposition(
        statement: queryStatement,
        where: filterWheres(where: where),
        page: page,
        orderBy: orderBy);

    final statementString = statementComposition.define();

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
      try {
        await postQuery(
            entityInstance: entityInstance, where: where, page: page);
      } on ConnecitonNotFoundException catch (e) {
        continue;
      }
      entityInstances.add(entityInstance);
    }
    return entityInstances;
  }
}
