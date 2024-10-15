import 'package:dart_store/data_definition/table/column/internal.dart';

/// A statement to define a column in a table.
class ColumnStatement {
  final InternalColumn column;

  ColumnStatement({required this.column});

  String define() =>
      "${column.sqlName} ${column.dataType.sqlTypeName()} ${unique()} ${notNull()} ${primaryKey()} ";

  String notNull() => column.isNullable ? "" : "NOT NULL";
  String primaryKey() => column.isPrimaryKey ? "PRIMARY KEY" : "";
  String unique() => column.isUniqe ? "UNIQUE" : "";
}
