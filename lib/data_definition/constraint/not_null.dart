import 'package:dart_store/data_definition/constraint/constraint.dart';

/// A constraint to define that a column cannot be null.
class NotNull extends SQLConstraint {
  const NotNull();
}
