import 'package:dart_store/data_definition/constraint/constraint.dart';

/// A constraint to define a primary key.
class PrimaryKey extends SQLConstraint {
  final bool? autoIncrement;
  const PrimaryKey({this.autoIncrement = false});
}
