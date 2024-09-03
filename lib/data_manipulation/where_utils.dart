import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/where/comparison_operator.dart';
import 'package:dart_store/where/filter_wheres.dart';
import 'package:dart_store/where/statement.dart';

List<Where> updateDefaultWhere(
        {required InternalColumn primaryKeyColumn, required dynamic id}) =>
    [
      Where(
          comparisonOperator: ComparisonOperator.equals,
          internalColumn: primaryKeyColumn,
          value: id)
    ];

List<Where> automaticallyFilterWhere({
  required List<Where> where,
  required InternalColumn primaryKeyColumn,
  required dynamic id,
  Type? externalColumnType,
  String? columnName,
}) =>
    where.isEmpty
        ? updateDefaultWhere(primaryKeyColumn: primaryKeyColumn, id: id)
        : filterWheres(
            where: where,
            columnName: columnName,
            externalColumnType: externalColumnType);
