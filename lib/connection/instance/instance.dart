import 'package:dart_store/data_manipulation/entity_instance/entity_instance.dart';

/// A class to define a connection instance between to tables. Usually contians the primary key values of thr associated entities.
class TableConnectionInstance extends EntityInstance {
  TableConnectionInstance({required super.entity, required super.columns})
      : super(objectType: dynamic);
}
