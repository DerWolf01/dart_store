import 'package:dart_persistence_api/sql_anotations/constraints/constraint.dart';

class ForeignKey<ReferencedTable> extends SQLConstraint {}

class OneToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {}

class OneToOne<ReferencedTable> extends ForeignKey<ReferencedTable> {}

class ManyToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {}
