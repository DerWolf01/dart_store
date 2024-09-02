import 'package:dart_store/data_definition/constraint/constraint.dart';
import 'package:dart_store/data_definition/table/column/column.dart';

abstract class ForeignColumn<T extends ForeignKey> extends Column {
  final T foreignKey;

  ForeignColumn({
    required super.name,
    required super.constraints,
    required this.foreignKey,
  });
}
