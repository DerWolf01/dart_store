import 'dart:mirrors';

import 'package:dart_store/data_definition/constraint/service.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/column/service.dart';
import 'package:dart_store/data_definition/table/entity.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/data_definition/table/table_statement.dart';
import 'package:dart_store/my_logger.dart';
import 'package:dart_store/reflection/collector_service.dart';
import 'package:dart_store/utility/dart_store_utility.dart';

TableService get tableService => TableService();

class TableService with DartStoreUtility {
  static TableService? _instance;
  Map<String, TableDescription> createdTables = {};
  Map<Type, TableDescription> createdTablesByType = {};
  factory TableService() {
    return _instance ??= TableService._internal();
  }
  TableService._internal();

  Future<void> createTable(TableDescription tableDescription) async {
    if (createdTables.containsKey(tableDescription.tableName) ||
        createdTablesByType.containsKey(tableDescription.objectType)) {
      myLogger.log("Table already created: ${tableDescription.tableName}");
      return;
    }
    final TableStatement tableStatement = TableStatement(
        tableDescription.tableName,
        tableDescription.columns.whereType<InternalColumn>().toList());
    await ConstraintService().preTableDefinitionAndExecution(tableDescription);
    final sql = tableStatement.define();
    myLogger.log(sql);
    await executeSQL(sql);

    await ConstraintService().postTableDefinitionAndExecution(tableDescription);

    createdTables[tableDescription.tableName] = tableDescription;
  }

  TableDescription findTable(Type tableType) {
    if (createdTablesByType.containsKey(tableType)) {
      return createdTablesByType[tableType]!;
    }
    final classMirror = CollectorService()
        .searchClassesWithAnnotation<Entity>()
        .where((classMirror) => classMirror.reflectedType == tableType)
        .firstOrNull;
    if (classMirror == null) {
      throw Exception(
          'Table not found for type $tableType with simpleName = ${MirrorSystem.getName(classMirror?.simpleName ?? Symbol('"no name found"'))}. Anotated with @Entity to ensure table definition');
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

  /// Use this only if necessary as it searches all classes with @Entity annotation and computes a lot of data
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
}
