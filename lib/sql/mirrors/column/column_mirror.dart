import 'dart:mirrors';
import 'package:dart_store/mapping/map_id.dart';
import 'package:dart_store/mapping/mapping.dart';
import 'package:dart_store/sql/sql_anotations/constraints/constraint.dart';
import 'package:dart_store/sql/sql_anotations/data_types/data_type.dart';

class ColumnMirror {
  ColumnMirror(
      {required this.name,
      required this.field,
      required this.dataType,
      required this.constraints,
      required this.mappings});

  final String name;
  final DeclarationMirror field;
  final SQLDataType dataType;
  final List<SQLConstraint> constraints;
  final List<Mapping> mappings;

  bool get mapId => mappings.any((m) => m is MapId);
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
