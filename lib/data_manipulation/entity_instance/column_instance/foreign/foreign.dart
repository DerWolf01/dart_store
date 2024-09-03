import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/column_instance.dart';

abstract class ForeignColumnInstance<ValueType>
    extends ColumnInstance<ValueType> implements ForeignColumn {
  ForeignColumnInstance(
      {required this.foreignKey,
      required super.constraints,
      required super.name,
      required super.value});

  @override
  ForeignKey foreignKey;
}
