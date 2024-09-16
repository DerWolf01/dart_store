import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/statement/statement.dart';
import 'package:dart_store/where/comparison_operator.dart';
// TODO implement or chaining

class Where<ForeignField> extends Statement {
  final Type? foreignField;
  final ComparisonOperator comparisonOperator;
  final InternalColumn internalColumn;
  final dynamic value;
  final bool caseSensitive;
  Where(
      {required this.comparisonOperator,
      required this.internalColumn,
      required this.value,
      this.caseSensitive = true})
      : foreignField = ForeignField;
  @override
  String define() {
    if (!internalColumn.dataType.compareToValue(value)) {
      throw Exception(
          "Value $value is not compoarible to column ${internalColumn.sqlName} of type ${internalColumn.dataType}");
    }
    final convertedValue = internalColumn.dataType.convert(value);
    if (!caseSensitive && (internalColumn.dataType is Varchar)) {
      return "LOWER(${internalColumn.sqlName}) ${comparisonOperator.operator()} LOWER($convertedValue)";
    }
    if (foreignField != dynamic && foreignField != null) {
      final TableDescription tableDescription =
          TableService().findTable(foreignField!);

      return "${tableDescription.tableName}.${internalColumn.sqlName} ${comparisonOperator.operator()} $convertedValue";
    }
    return "${internalColumn.sqlName} ${comparisonOperator.operator()} $convertedValue";
  }
}
