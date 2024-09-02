import 'package:dart_store/data_definition/table/column/statement.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';

class TableStatement {
  String name;
  List<ColumnStatement> columnsStatements;

  TableStatement(this.name, List<InternalColumn> columns)
      : columnsStatements =
            columns.map((column) => ColumnStatement(column: column)).toList();

  String define() =>
      "CREATE TABLE IF NOT EXISTS $name (${columnsStatements.map((column) => column.define()).join(", ")})";
}
