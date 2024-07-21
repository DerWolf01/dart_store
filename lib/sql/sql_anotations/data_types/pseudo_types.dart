import 'package:dart_store/dart_store.dart';

class ForeignField extends SQLDataType {}

class PseudoEntity {
  const PseudoEntity(this.id);

  final dynamic id;
}
