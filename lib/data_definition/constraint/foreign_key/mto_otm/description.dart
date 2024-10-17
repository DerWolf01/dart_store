import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/table_description.dart';

/// A description of a one to many and many to one relationship between two tables.
class OneToManyAndManyToOneDescription {
  final ForeignKey foreignKey;
  final TableDescription oneToManyTableDescription;
  final TableDescription manyToOneTableDescription;

  const OneToManyAndManyToOneDescription({
    required this.foreignKey,
    required this.manyToOneTableDescription,
    required this.oneToManyTableDescription,
  });
}
