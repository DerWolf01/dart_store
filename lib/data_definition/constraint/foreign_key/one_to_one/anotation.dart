import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';

/// An annotation to define a one to one relationship between two tables.
class OneToOne<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const OneToOne();
}
