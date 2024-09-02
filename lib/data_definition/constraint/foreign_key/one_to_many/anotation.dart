import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';

class OneToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const OneToMany();
}
