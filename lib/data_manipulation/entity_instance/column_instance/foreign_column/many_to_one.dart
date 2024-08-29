import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign_column/foreign_column.dart';

class ManyToOneColumnInstance extends ForeignColumnInstance {
  ManyToOneColumnInstance(
      {required super.foreignKey,
      required super.constraints,
      required super.name,
      required super.value});
}
