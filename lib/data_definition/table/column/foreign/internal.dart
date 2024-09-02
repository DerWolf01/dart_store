import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/foreign/foreign.dart';
import 'package:dart_store/data_definition/table/column/internal.dart'; 

class InternalForeignColumn<T extends ForeignKey> extends InternalColumn
    implements ForeignColumn<T> {
  InternalForeignColumn({
    required super.constraints,
    required super.dataType,
    required super.name,
    required this.foreignKey,
  });

  @override
  T foreignKey;
}
