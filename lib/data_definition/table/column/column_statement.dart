import 'package:dart_store/data_definition/table/column/internal_column.dart';

class ColumnStatement {
  final InternalColumn column;

  ColumnStatement({required this.column});

  String define() =>
      "${column.name} ${column.dataType.sqlTypeName()} ${unique()} ${notNull()} ${primaryKey()} ";
  String unique() => column.isUniqe ? "UNIQUE" : "";
  String primaryKey() => column.isPrimaryKey ? "PRIMARY KEY" : "";
  String notNull() => column.isNullable ? "" : "NOT NULL";
}
