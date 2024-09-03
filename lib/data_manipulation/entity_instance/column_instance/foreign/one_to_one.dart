import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';

class OneToOneColumnInstance extends ForeignColumnInstance<EntityInstance> {
  OneToOneColumnInstance(
      {required super.foreignKey,
      required super.constraints,
      required super.name,
      required super.value});
}
