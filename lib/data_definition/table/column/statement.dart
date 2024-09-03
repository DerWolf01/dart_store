import 'package:dart_store/data_definition/table/column/internal.dart';

class ColumnStatement {
  final InternalColumn column;

  ColumnStatement({required this.column});

  String define() =>
      "${column.sqlName} ${column.dataType.sqlTypeName()} ${unique()} ${notNull()} ${primaryKey()} ";
  String unique() => column.isUniqe ? "UNIQUE" : "";
  String primaryKey() => column.isPrimaryKey ? "PRIMARY KEY" : "";
  String notNull() => column.isNullable ? "" : "NOT NULL";
}
