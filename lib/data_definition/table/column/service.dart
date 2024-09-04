import 'dart:mirrors';
import 'package:dart_conversion/dart_conversion.dart';
import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/foreign/service.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';

class ColumnService {
  isConstraint(InstanceMirror instanceMirror) {
    final constraintClassMirror = reflectClass(SQLConstraint);
    return instanceMirror.type.isAssignableTo(constraintClassMirror) ||
        instanceMirror.type.isSubclassOf(constraintClassMirror) ||
        instanceMirror.type.isSubtypeOf(constraintClassMirror);
  }

  List<Column> extractColumns(final ClassMirror classMirror) {
    final List<Column> columns = [];
    for (final declaration
        in ConversionService.declarations(classMirror).values) {
      final name = MirrorSystem.getName(declaration.simpleName);

      final constraints = declaration.metadata
          .where(
            (element) => isConstraint(element),
          )
          .map(
            (e) => e.reflectee as SQLConstraint,
          )
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
          name: name,
        );
        columns.add(internalColumn);
        continue;
      }
      final foreignKey = declaration.metadata
          .where((element) => element.reflectee is ForeignKey)
          .firstOrNull;
      if (foreignKey != null) {
        final foreignKeyInstance = foreignKey.reflectee as ForeignKey;
        columns.add(ForeignColumnService().generateForeignColumn(
            foreignKey: foreignKeyInstance,
            constraints: constraints,
            name: name));
        continue;
      }
    }
    return columns;
  }
}
