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

/// A service to define and execute table DDL statements.
class TableService with DartStoreUtility {
  static TableService? _instance;

  /// A map of existing tables.
  Map<Type, TableDescription> existingTables = {};
  factory TableService() {
    return _instance ??= TableService._internal();
  }
  TableService._internal();

  /// Create a table from a [TableDescription].
  Future<void> createTable(TableDescription tableDescription) async {
    if (existingTables.containsKey(tableDescription.objectType)) {
      myLogger.w("Table exists already: ${tableDescription.tableName}");
      return;
    }
    final TableStatement tableStatement = TableStatement(
        tableDescription.tableName,
        tableDescription.columns.whereType<InternalColumn>().toList());

    final sql = tableStatement.define();
    myLogger.i(sql);
    await executeSQL(sql);

    await ConstraintService().postTableDefinitionAndExecution(tableDescription);

    myLogger.d("Table created: ${tableDescription.tableName}");
    existingTables[tableDescription.objectType] = tableDescription;
  }

  /// Find a table by type.
  TableDescription findTable(Type tableType) {
    if (existingTables.containsKey(tableType)) {
      myLogger.d(
          "Returning existing table: ${existingTables[tableType]!.tableName}");
      return existingTables[tableType]!;
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

  /// Find all tables by looping through all class mirrors in the project.
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
