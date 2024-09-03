import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/statement/statement.dart';

class QueryStatement extends Statement {
  QueryStatement({required this.tableDescription});
  final TableDescription tableDescription;
  @override
  String define() {
    return "SELECT * FROM ${tableDescription.tableName}";
  }
}
