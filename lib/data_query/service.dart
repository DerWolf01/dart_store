import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/data_query/many_to_many/service.dart';
import 'package:dart_store/data_query/many_to_one/service.dart';
import 'package:dart_store/data_query/one_to_many/service.dart';
import 'package:dart_store/data_query/one_to_one/service.dart';
import 'package:dart_store/data_query/statement.dart';
import 'package:dart_store/statement/compositor.dart';
import 'package:dart_store/where/statement.dart';

class DataQueryService {
  Future<List<EntityInstance>> query(
      {required TableDescription description,
      List<Where> where = const []}) async {
    QueryStatement queryStatement =
        QueryStatement(tableDescription: description);

    final StatementComposition statementComposition =
        StatementComposition(statement: queryStatement, where: where);
    final queryResults =
        await dartStore.connection.query(statementComposition.define());

    final List<EntityInstance> entityInstances = [];
    for (final queryResult in queryResults) {
      final entityInstance =
          await ManyToManyQueryService().postQuery(EntityInstance(
        objectType: description.objectType,
        tableName: description.tableName,
        columns: description.columns
            .whereType<InternalColumn>()
            .map<InternalColumnInstance>((InternalColumn e) =>
                InternalColumnInstance(
                    dataType: e.dataType,
                    constraints: e.constraints,
                    name: e.name,
                    value: queryResult[e.name]))
            .toList(),
      ));

      entityInstances.add(await ManyToManyQueryService().postQuery(
          await OneToManyQueryService().postQuery(
              entityInstance: await ManyToOneQueryService().postQuery(
                  entityInstance: await OneToOneQueryService()
                      .postQuery(entityInstance)))));
    }
    return entityInstances;
  }
}
