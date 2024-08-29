import 'package:dart_store/data_definition/table/column/column.dart';

abstract class ColumnInstance extends Column {
  ColumnInstance({required super.constraints, required super.name});
}
