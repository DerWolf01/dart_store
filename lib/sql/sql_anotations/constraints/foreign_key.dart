import 'dart:mirrors';

import 'package:dart_store/sql/sql_anotations/constraints/constraint.dart';

abstract class ForeignKey<ReferencedEntity> extends SQLConstraint {
  const ForeignKey();

  Type get referencedEntity =>
      reflect(this).type.typeArguments.first.reflectedType;
}

class OneToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const OneToMany();
}

class OneToOne<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const OneToOne();
}

class ManyToOne<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const ManyToOne();
}

class ManyToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const ManyToMany();
}
