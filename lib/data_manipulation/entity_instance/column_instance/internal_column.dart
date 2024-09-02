import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_definition/table/column/column.dart';
import 'package:dart_store/data_definition/table/column/internal.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';

class InternalColumnInstance<ValueType> extends ColumnInstance
    implements InternalColumn {
  InternalColumnInstance({
    required super.value,
    required this.dataType,
    required super.constraints,
    required super.name,
  });

  dynamic get sqlConformValue => dataType.convert(value);

  @override
  SQLDataType dataType;
}
