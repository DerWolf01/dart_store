import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/statement/statement.dart';
import 'package:dart_store/where/comparison_operator.dart';

class Where<ForeignField extends Type?> extends Statement {
  Where(
      {required this.comparisonOperator,
      required this.internalColumn,
      required this.value})
      : foreignField = ForeignField;
  final Type? foreignField;
  final ComparisonOperator comparisonOperator;
  final InternalColumn internalColumn;
  final dynamic value;

  @override
  String define() {
    if (!internalColumn.dataType.compareToValue(value)) {
      throw Exception(
          "Value $value is not compoarible to column ${internalColumn.name} of type ${internalColumn.dataType}");
    }
    final convertedValue = internalColumn.dataType.convert(value);

    return "${internalColumn.name} ${comparisonOperator.operator()} $convertedValue";
  }
}
