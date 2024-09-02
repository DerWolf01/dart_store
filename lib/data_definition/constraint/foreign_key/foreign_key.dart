import 'dart:mirrors';
import 'package:dart_store/data_definition/constraint/constraint.dart';
export './many_to_many/many_to_many.dart';
export './one_to_one/one_to_one.dart';
export './many_to_one/many_to_one.dart';
export './one_to_many/one_to_many.dart';

abstract class ForeignKey<ReferencedEntity> extends SQLConstraint {
  const ForeignKey();

  Type get referencedEntity =>
      reflect(this).type.typeArguments.first.reflectedType;
}
