import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/foreign/service.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/many_to_one.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_many.dart';
import 'package:dart_store/data_manipulation/entity_instance/column_instance/foreign/one_to_one.dart';

class ForeignColumnInstanceService extends ForeignColumnService {
  generateForeignColumnInstances(
      {required dynamic value,
      required String name,
      required ForeignKey foreignKey,
      required List<SQLConstraint> constraints}) {
    print("Foreign Column Instance Service: $foreignKey --> $value");
    if (foreignKey is ManyToMany) {
      return ManyToManyColumnInstance(
          foreignKey: foreignKey,
          constraints: constraints,
          name: name,
          value: value);
    }
    if (foreignKey is ManyToOne) {
      return ManyToOneColumnInstance(
          foreignKey: foreignKey,
          constraints: constraints,
          name: name,
          value: value);
    }
    if (foreignKey is OneToOne) {
      return OneToOneColumnInstance(
          foreignKey: foreignKey,
          constraints: constraints,
          name: name,
          value: value);
    }

    if (foreignKey is OneToMany) {
      return OneToManyColumnInstance(
          foreignKey: foreignKey,
          constraints: constraints,
          name: name,
          value: value);
    }

    throw Exception(
        'ForeignKey Type $foreignKey not supported. There is only support for ManyToMany, ManyToOne, OneToOne, OneToMany');
  }
}
