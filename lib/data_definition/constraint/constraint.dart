export './not_null.dart';
export './primary_key.dart';
export './service.dart';
export './unique.dart';
export 'foreign_key/foreign_key.dart';

/// A constraint to be applied to a column.
abstract class SQLConstraint {
  const SQLConstraint();
}
