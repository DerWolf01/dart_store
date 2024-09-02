import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';

class ManyToMany<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const ManyToMany();
}
