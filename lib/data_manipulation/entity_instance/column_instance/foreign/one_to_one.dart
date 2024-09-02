import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';

class OneToOneColumnInstance extends ForeignColumnInstance {
  OneToOneColumnInstance(
      {required super.foreignKey,
      required super.constraints,
      required super.name,
      required super.value});
}
