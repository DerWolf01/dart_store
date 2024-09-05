import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:change_case/change_case.dart';

abstract class ColumnInstance<ValueType> extends Column {
  ColumnInstance(
      {required this.value, required super.constraints, required super.name});

  ColumnInstance.fromColumn({required Column column, required this.value})
      : super(name: column.name, constraints: column.constraints);
  ValueType value;

  @override
  String get sqlName => name.toSnakeCase();
}
