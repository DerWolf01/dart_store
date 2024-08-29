import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/internal_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';

class InternalColumnInstance<ValueType> extends InternalColumn
    implements ColumnInstance {
  InternalColumnInstance({
    required this.value,
    required super.dataType,
    required super.constraints,
    required super.name,
  });

  late ValueType value;

  dynamic get sqlConformValue => dataType.convert(value);
}
