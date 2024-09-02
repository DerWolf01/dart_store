import 'package:dart_store/data_definition/constraint/foreign_key/foreign_key.dart';

class ManyToOne<ReferencedTable> extends ForeignKey<ReferencedTable> {
  const ManyToOne();
}
