import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_definition/table/service.dart';
import 'package:dart_store/data_definition/table/table_description.dart';
import 'package:dart_store/utility/dart_store_utility.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/statement.dart';

class Between<ForeignField> with DartStoreUtility implements Where {
  DateTime start;
  DateTime end;
  @override
  final Type? foreignField;

  @override
  final ComparisonOperator comparisonOperator = ComparisonOperator.equals;
  @override
  final InternalColumn internalColumn;
  @override
  final dynamic value;
  @override
  final bool caseSensitive = true;

  Between({
    required this.internalColumn,
    required this.value,
    required this.start,
    required this.end,
  }) : foreignField = ForeignField;
  @override
  String define() {
    if (!internalColumn.dataType.compareToValue(value)) {
      throw Exception(
          "Value $value is not compoarible to column ${internalColumn.sqlName} of type ${internalColumn.dataType}");
    }
    final convertedStart = internalColumn.dataType.convert(start);
    final convertedEnd = internalColumn.dataType.convert(end);

    if (foreignField != dynamic && foreignField != null) {
      final TableDescription tableDescription =
          TableService().findTable(foreignField!);

      return "${tableDescription.tableName}.${internalColumn.sqlName} BETWEEN $convertedStart AND $convertedEnd";
    }
    return "${internalColumn.sqlName} ${comparisonOperator.operator()} BETWEEN $convertedStart AND $convertedEnd";
  }
}
