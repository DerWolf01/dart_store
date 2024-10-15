export './constraint/constraint.dart';
export './data_types/data_type.dart';
export './table/entity.dart';

/// A class to define SQL queries.
abstract class DataDefinition {
  String define();
}
