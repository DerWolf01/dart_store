import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign_column/foreign_column.dart';

class ManyToManyColumnInstance extends ForeignColumnInstance<List> {
  ManyToManyColumnInstance(
      {required super.foreignKey,
      required super.constraints,
      required super.name,
      required super.value});
}
