import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';

export './anotation.dart';

/// An annotation to define a many to one relationship between two tables.
class ManyToOne<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const ManyToOne();
}
