import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/foreign.dart';
import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';
import 'package:dart_store/mapping/map_id.dart';

class ManyToManyColumnInstance
    extends ForeignColumnInstance<List<EntityInstance>> {
  ManyToManyColumnInstance(
      {required super.foreignKey,
      required super.constraints,
      required super.name,
      required super.value,
      required super.mapId});
}
