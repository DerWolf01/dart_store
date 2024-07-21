import 'package:dart_store/sql/sql_anotations/constraints/constraint.dart';

abstract class ForeignKey<ReferencedEntity> extends SQLConstraint {
  const ForeignKey();
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
