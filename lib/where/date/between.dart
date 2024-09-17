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
  final dynamic value = null;
  @override
  final bool caseSensitive = true;

  Between({
    required this.internalColumn,
    required this.start,
    required this.end,
  }) : foreignField = ForeignField;
  @override
  String define() {
    final convertedStart = internalColumn.dataType.convert(start);
    if (!internalColumn.dataType.compareToValue(convertedStart)) {
      throw Exception(
          "Start date of value --> $value --> is not compoarible to column ${internalColumn.sqlName} of type ${internalColumn.dataType}");
    }
    final convertedEnd = internalColumn.dataType.convert(end);
    if (!internalColumn.dataType.compareToValue(convertedEnd)) {
      throw Exception(
          "End date of value --> $value --> is not compoarible to column ${internalColumn.sqlName} of type ${internalColumn.dataType}");
    }
    if (foreignField != dynamic && foreignField != null) {
      final TableDescription tableDescription =
          TableService().findTable(foreignField!);

      return "${tableDescription.tableName}.${internalColumn.sqlName} BETWEEN $convertedStart AND $convertedEnd";
    }
    return "${internalColumn.sqlName} ${comparisonOperator.operator()} BETWEEN $convertedStart AND $convertedEnd";
  }
}
