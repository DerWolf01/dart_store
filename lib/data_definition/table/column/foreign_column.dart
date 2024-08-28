import 'package:dart_store/dart_store.dart';
import 'package:dart_store/data_definition/table/column/column.dart';

class ForeignColumn extends Column {
  ForeignKey foreignKey;

  ForeignColumn({
    required this.foreignKey,
    required super.constraints,
    required super.name,
  });
}
