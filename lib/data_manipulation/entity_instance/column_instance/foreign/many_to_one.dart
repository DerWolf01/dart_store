import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';
import 'package:dart_store/data_definition/data_types/data_type.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/internal_column.dart';

class ManyToOneColumnInstance extends InternalColumnInstance
    implements ForeignColumnInstance {
  ManyToOneColumnInstance(
      {required this.foreignKey,
      required super.constraints,
      required super.name,
      required super.value,
      required super.dataType});

  @override
  ForeignKey foreignKey;
}
