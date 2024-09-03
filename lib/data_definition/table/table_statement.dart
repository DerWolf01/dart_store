import 'package:dart_store/data_definition/table/column/statement.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/statement/statement.dart';

class TableStatement extends Statement {
  String name;
  List<ColumnStatement> columnsStatements;

  TableStatement(this.name, List<InternalColumn> columns)
      : columnsStatements =
            columns.map((column) => ColumnStatement(column: column)).toList();
  @override
  String define() =>
      "CREATE TABLE IF NOT EXISTS $name (${columnsStatements.map((column) => column.define()).join(", ")})";
}
