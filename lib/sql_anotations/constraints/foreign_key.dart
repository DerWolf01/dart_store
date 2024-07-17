import 'package:dart_store/sql_anotations/constraints/constraint.dart';

abstract class ForeignKey<ReferencedTable> extends SQLConstraint {
  const ForeignKey();
}

class OneToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const OneToMany();
}

class OneToOne<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const OneToOne();
}

class ManyToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const ManyToMany();
}
