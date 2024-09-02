import 'package:dart_store/data_definition/table/column/column.dart';

abstract class ColumnInstance<ValueType> extends Column {
  ColumnInstance(
      {required this.value, required super.constraints, required super.name});

  ValueType value;
}
