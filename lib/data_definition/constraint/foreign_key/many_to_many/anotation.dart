import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';

/// An annotation to define a many to many relationship between two tables.
class ManyToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const ManyToMany();
}
