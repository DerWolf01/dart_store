import 'dart:mirrors';
import 'package:dart_store/sql/sql_anotations/constraints/constraint.dart';
import 'package:dart_store/sql/sql_anotations/data_types/data_type.dart';

class ColumnDecl {
  ColumnDecl(
      {required this.name,
      required this.field,
      required this.dataType,
      required this.constraints});

  final String name;
  final DeclarationMirror field;
  final SQLDataType dataType;
  final List<SQLConstraint> constraints;

  bool get nullable => constraints.any((c) => c is NotNull);

  bool get unique => constraints.any((c) => c is Unique);

  bool get isPrimaryKey => constraints.any((c) => c is PrimaryKey);

  PrimaryKey? get primaryKey => constraints.whereType<PrimaryKey>().firstOrNull;

  bool isForeignKey() {
    return constraints.any((c) => c is ForeignKey);
  }

  T? getConstraint<T extends SQLConstraint>() =>
      constraints.whereType<T>().firstOrNull;

  ForeignKey? getForeignKey() {
    return constraints.whereType<ForeignKey>().firstOrNull;
  }
}

List<ColumnDecl> columnDecls<T>({Type? type}) {
  final classMirror = reflectClass(type ?? T);
  final List<ColumnDecl> columns = [];

  final fields = classMirror.declarations.values.whereType<VariableMirror>();

  for (final field in fields) {
    final fieldAnnotations = field.metadata;

    List<SQLDataType> dataTypes = fieldAnnotations
        .map((annotation) => annotation.reflectee)
        .whereType<SQLDataType>()
        .toList();

    List<SQLConstraint> constraints = fieldAnnotations
        .map((annotation) => annotation.reflectee)
        .whereType<SQLConstraint>()
        .toList();

    final isForeignField =
        constraints.where((element) => element is ForeignKey).isNotEmpty;
    if (isForeignField) {
    } else if (dataTypes.isEmpty) {
      continue;
    }

    final columnName = MirrorSystem.getName(field.simpleName);
    final dataType = isForeignField ? ForeignField() : dataTypes.first;

    columns.add(ColumnDecl(
        name: columnName,
        field: field,
        dataType: dataType,
        constraints: constraints));
  }

  return columns;
}
