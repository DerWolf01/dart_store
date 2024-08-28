import 'dart:mirrors';
import 'package:change_case/change_case.dart';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/foreign_column.dart';
import 'package:dart_store/data_definition/table/column/internal_column.dart';

class ColumnService {
  List<Column> extractColumns(final ClassMirror classMirror) {
    final List<Column> columns = [];
    for (final declaration
        in ConversionService.declarations(classMirror).values) {
      final name = MirrorSystem.getName(declaration.simpleName);
      final snakeCase = name.toSnakeCase();
      final constraints = declaration.metadata
          .map(
            (e) => e.reflectee,
          )
          .whereType<SQLConstraint>()
          .toList();

      final dataType = declaration.metadata
          .where((element) => element.reflectee is SQLDataType);

      if (dataType.length > 1) {
        throw Exception(
            "Column $name in table ${classMirror.name} has more than one data type --> $dataType");
      }
      if (dataType.isNotEmpty) {
        final internalColumn = InternalColumn(
          dataType: dataType.first.reflectee,
          constraints: constraints,
          name: snakeCase,
        );
        columns.add(internalColumn);
        continue;
      }
      final foreignKey = declaration.metadata
          .where((element) => element.reflectee is ForeignKey)
          .firstOrNull;
      if (foreignKey != null) {
        final foreignKeyInstance = foreignKey.reflectee as ForeignKey;
        final column = ForeignColumn(
            constraints: constraints,
            foreignKey: foreignKeyInstance,
            name: snakeCase);
        columns.add(column);
        continue;
      }
    }
    return columns;
  }
}
