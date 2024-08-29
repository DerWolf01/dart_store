import 'package:dart_store/data_definition/table/column/foreign_column.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';

class ForeignColumnInstance<ValueType> extends ForeignColumn 
    implements ColumnInstance {
  ForeignColumnInstance(
      {required super.foreignKey,
      required super.constraints,
      required super.name,
      required this.value});

  late ValueType value;
}
