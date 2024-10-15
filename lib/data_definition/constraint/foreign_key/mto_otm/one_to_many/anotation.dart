import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';

export './anotation.dart';

/// An annotation to define a one to many relationship between two tables.
class OneToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const OneToMany();
}
