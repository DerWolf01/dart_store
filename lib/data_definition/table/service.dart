import 'package:dart_conversion/method_service.dart';
import 'package:dart_store/data_definition/constraint/service.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/service.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/entity.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/table/table_statement.dart';
import 'package:dart_store/reflection/collector_service.dart';
import 'package:change_case/change_case.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

class TableService with DartStoreUtility {
  List<TableDescription> findTables() =>
      CollectorService().searchClassesWithAnnotation<Entity>().map(
        (classMirror) {
          final List<Column> columns =
              ColumnService().extractColumns(classMirror);

          return TableDescription(
              objectType: classMirror.reflectedType,
              entity: classMirror.metadata
                  .firstWhere(
                    (element) => element.reflectee is Entity,
                  )
                  .reflectee as Entity,
              columns: columns);
        },
      ).toList();

  TableDescription findTable(Type tableType) {
    final classMirror = CollectorService()
        .searchClassesWithAnnotation<Entity>()
        .where((classMirror) => classMirror.reflectedType == tableType)
        .firstOrNull;
    if (classMirror == null) {
      throw Exception(
          "Table not found for type $tableType. Anotated with @Entity to ensure table definition");
    }

    final List<Column> columns = ColumnService().extractColumns(classMirror);

    return TableDescription(
        objectType: tableType,
        entity: classMirror.metadata
            .firstWhere(
              (element) => element.reflectee is Entity,
            )
            .reflectee as Entity,
        columns: columns);
  }

  Future<void> createTable(TableDescription tableDescription) async {
    final TableStatement tableStatement = TableStatement(
        tableDescription.tableName,
        tableDescription.columns.whereType<InternalColumn>().toList());
    final sql = tableStatement.define();
    print("Creating table ${tableDescription.tableName}");
    await executeSQL(sql);

    await ConstraintService().postTableDefinitionAndExecution(tableDescription);
  }
}
