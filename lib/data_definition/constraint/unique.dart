import 'package:dart_store/data_definition/constraint/constraint.dart';

/// A constraint to define that a column must have unique values.
class Unique extends SQLConstraint {
  const Unique();
}
