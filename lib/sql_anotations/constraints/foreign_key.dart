import 'dart:mirrors';

import 'package:dart_persistence_api/sql_anotations/constraints/constraint.dart';

class ForeignKeyConnection extends ConstraintField {
  const ForeignKeyConnection(this.referencingTable, this.referencedTable);
  final ClassMirror referencingTable;
  final ClassMirror referencedTable;
}

abstract class ForeignKey<ReferencedTable> extends SQLConstraint {
  const ForeignKey();
}

class OneToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {}

class OneToOne<ReferencedTable> extends ForeignKey<ReferencedTable> {}

class ManyToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {}
