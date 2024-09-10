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
import 'package:dart_store/where/filter_wheres.dart';
import 'package:dart_store/where/statement.dart';

class DataQueryService {
  Future<List<EntityInstance>> query(
      {required TableDescription description,
      List<Where> where = const [],
      Page? page}) async {
    QueryStatement queryStatement =
        QueryStatement(tableDescription: description);

    final StatementComposition statementComposition = StatementComposition(
        statement: queryStatement,
        where: filterWheres(where: where),
        page: page);

    final statementString = statementComposition.define();
    print("statementString: $statementString");
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
