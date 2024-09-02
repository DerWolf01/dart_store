import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';

class ExternalForeignColumn<T extends ForeignKey> extends ForeignColumn<T> {
  ExternalForeignColumn({
    required super.constraints,
    required super.name,
    required super.foreignKey,
  });
}
